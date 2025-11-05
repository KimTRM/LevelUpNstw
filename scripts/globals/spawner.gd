extends Node

@export var spawn_interval: float = 2.0
@export var auto_start: bool = true
@export var spawn_points: Array[EnemySpawnPoint] = []

@export var indicator_duration: float = 1.5
@export var spawn_appear_duration: float = 0.35

var rift_scene: PackedScene = preload("uid://jpay2ha6ca6y")

var _spawned_count: int = 0
var _timer: Timer
var _is_wave_running: bool = false

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.one_shot = false
	_timer.autostart = auto_start
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)
	if auto_start:
		_timer.start()

func _on_timer_timeout() -> void:
	# Stop if any spawn point reached its max
	var should_stop := false
	for spawn_point in spawn_points:
		if spawn_point.max_spawns > 0 and _spawned_count >= spawn_point.max_spawns:
			should_stop = true
			break
	if should_stop:
		_timer.stop()
		return

	# Prevent overlapping waves while awaiting
	if _is_wave_running:
		return
	_is_wave_running = true
	await spawn_wave()
	_is_wave_running = false
	_spawned_count += 1

func spawn_wave() -> void:
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
