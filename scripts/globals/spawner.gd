extends Node

@export var spawn_interval: float = 2.0
@export var auto_start: bool = true
@export var spawn_points: Array[EnemySpawnPoint] = []

# Wave-based controls
@export var respawn_delay_seconds: float = 5.0
@export var total_spawn_duration_seconds: float = 60.0

@export var indicator_duration: float = 1.5
@export var spawn_appear_duration: float = 0.35

# Use path-based preload to avoid broken UID references after file moves/reimports
var rift_scene: PackedScene = preload("uid://jpay2ha6ca6y")

var _spawned_count: int = 0
var _timer: Timer
var _is_wave_running: bool = false
var _stopped: bool = false
var _stop_spawning_at_ms: int = 0
var _current_wave_enemies: Array[Node] = []

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.one_shot = true
	_timer.autostart = false
	add_child(_timer)
	_timer.timeout.connect(func(): await _spawn_next_wave_if_allowed())

	_stop_spawning_at_ms = Time.get_ticks_msec() + int(total_spawn_duration_seconds * 1000.0)

	if auto_start:
		await _start_when_spawn_points_ready()

func _start_when_spawn_points_ready() -> void:
	# In autoloads, this can run before the main scene and spawn points are ready
	var wait_ms_deadline := Time.get_ticks_msec() + 2000
	while spawn_points.is_empty() and Time.get_ticks_msec() < wait_ms_deadline:
		await get_tree().process_frame
	# If still empty, try one more small delay to allow registration
	if spawn_points.is_empty():
		await get_tree().create_timer(0.1).timeout
	# Spawn initial wave if still within allowed time
	if Time.get_ticks_msec() < _stop_spawning_at_ms and not spawn_points.is_empty():
		await spawn_wave()

func _spawn_next_wave_if_allowed() -> void:
	if _stopped:
		return
	if Time.get_ticks_msec() >= _stop_spawning_at_ms:
		_stopped = true
		return
	if _is_wave_running:
		return
	_is_wave_running = true
	await spawn_wave()
	_is_wave_running = false
	_spawned_count += 1

func spawn_wave() -> void:
	# Reset current wave tracking
	_current_wave_enemies.clear()
	var spawn_positions: Array[Vector2] = []
	var enemy_scenes: Array[PackedScene] = []
	
	# Collect all spawn positions and enemy types
	for spawn_point in spawn_points:
		for i in range(spawn_point.count_per_wave):
			var spawn_position = spawn_point.global_position + Vector2(spawn_point.spawn_spacing * i, 0)
			spawn_positions.append(spawn_position)
			enemy_scenes.append(spawn_point.enemy_to_spawn)
	
	# Show all indicators simultaneously
	for pos in spawn_positions:
		show_spawn_indicator(pos)
	
	# Wait for the indicators to finish their "in" animation
	await get_tree().create_timer(indicator_duration).timeout
	
	# Spawn all enemies simultaneously
	for i in range(spawn_positions.size()):
		spawn_enemy(enemy_scenes[i], spawn_positions[i])

func show_spawn_indicator(pos: Vector2) -> void:
	var indicator := rift_scene.instantiate()
	indicator.global_position = pos
	
	# Get the current scene and find the Entities node
	var current_scene = get_tree().current_scene
	var entities_node = current_scene.get_node_or_null("Entities")
	if entities_node:
		entities_node.add_child(indicator)
	else:
		current_scene.add_child(indicator)

	var indicator_animation_player := indicator.get_node_or_null("AnimationPlayer") as AnimationPlayer
	indicator_animation_player.speed_scale = 1.5
	indicator_animation_player.play("opening")
	await indicator_animation_player.animation_finished

	indicator_animation_player.speed_scale = 1.0
	indicator_animation_player.play("Idle")
	await indicator_animation_player.animation_finished

	indicator_animation_player.speed_scale = 1.5
	indicator_animation_player.play_backwards("opening")
	await indicator_animation_player.animation_finished
	indicator.queue_free()

func spawn_enemy(enemy_to_spawn: PackedScene, pos: Vector2) -> void:
	var instance = enemy_to_spawn.instantiate()
	instance.global_position = pos

	# Temporarily disable collisions during the appear animation
	var had_collision := instance is CollisionObject2D
	var original_layer := 0
	var original_mask := 0
	if had_collision:
		original_layer = instance.collision_layer
		original_mask = instance.collision_mask
		instance.collision_layer = 0
		instance.collision_mask = 0

	# Get the current scene and find the Entities node
	var current_scene = get_tree().current_scene
	var entities_node = current_scene.get_node_or_null("Entities")
	if entities_node:
		entities_node.add_child(instance)
	else:
		current_scene.add_child(instance)

	# Track this enemy for wave completion using tree exit (covers all death paths)
	_current_wave_enemies.append(instance)
	instance.tree_exited.connect(_on_enemy_tree_exited)

	# Find the Visuals node for the spawn animation (after adding to tree so it's ready)
	var visuals_node = instance.get_node_or_null("Visuals") as Node2D
	var can_tween_visual := visuals_node != null
	
	var original_scale := Vector2.ONE
	var original_alpha := 1.0
	if can_tween_visual:
		original_scale = visuals_node.scale
		original_alpha = visuals_node.modulate.a
		visuals_node.scale = Vector2.ZERO
		visuals_node.modulate.a = 0.0
	else:
		# Fallback: try to tween the root if Visuals doesn't exist
		if instance is CanvasItem:
			var canvas := instance as CanvasItem
			original_scale = canvas.scale
			original_alpha = canvas.modulate.a
			canvas.scale = Vector2.ZERO
			canvas.modulate.a = 0.0
			can_tween_visual = true

	if can_tween_visual:
		var target_node: Node2D = visuals_node if visuals_node else instance as Node2D
		if is_instance_valid(target_node):
			var tween := target_node.create_tween().set_parallel(true)
			tween.tween_property(target_node, "scale", original_scale, spawn_appear_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(target_node, "modulate:a", original_alpha, spawn_appear_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.finished.connect(func():
				if had_collision and is_instance_valid(instance):
					instance.collision_layer = original_layer
					instance.collision_mask = original_mask)
	else:
		# If no tween, just restore collisions immediately
		if had_collision and is_instance_valid(instance):
			instance.collision_layer = original_layer
			instance.collision_mask = original_mask

func _on_enemy_tree_exited() -> void:
	# Clean up any freed references
	for i in range(_current_wave_enemies.size() - 1, -1, -1):
		if not is_instance_valid(_current_wave_enemies[i]) or _current_wave_enemies[i].get_parent() == null:
			_current_wave_enemies.remove_at(i)
	# If all enemies are gone, schedule the next wave after delay, unless stopped/time's up
	if _current_wave_enemies.is_empty():
		if _stopped:
			return
		if Time.get_ticks_msec() >= _stop_spawning_at_ms:
			_stopped = true
			return
		# Wait respawn delay then spawn next wave if still allowed
		await get_tree().create_timer(respawn_delay_seconds).timeout
		await _spawn_next_wave_if_allowed()
