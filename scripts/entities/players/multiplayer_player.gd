class_name Player extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

@export var player_resource: PlayerResource
@export var auto_target_skill: bool = true
@export var attack_range: float = 300.0
@export var input: InputController

var can_play_animation: bool = true
var input_direction: Vector2
var aim_direction: Vector2 = Vector2.RIGHT # Current aim direction
var target_location: Vector2 = Vector2.ZERO # Synced target location

var my_player_resource: PlayerResource
var player_id: int
var stats: Stats

func _enter_tree() -> void:
	player_id = int(str(name))
	set_multiplayer_authority(player_id)
	input.set_multiplayer_authority(player_id)


func _ready() -> void:
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false

	initialize_player()

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	# Update aim direction from controller or mouse
	_update_aim_direction()

	velocity_component.max_speed = stats.base_movement_speed
	velocity = velocity_component.get_velocity(input_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)
	
	if can_play_animation:
		_update_animation()


func initialize_player() -> void:
	if player_resource:
		# Create a duplicate resource for this player instance
		my_player_resource = player_resource.duplicate(true)
		stats = my_player_resource.stats
		my_player_resource.player = self
		velocity_component.max_speed = stats.base_movement_speed

	if not is_multiplayer_authority():
		return
		
	input.move_input.connect(func(direction: Vector2) -> void:
		input_direction = direction
	)

	input.toggle_auto_target_pressed.connect(func() -> void:
		auto_target_skill = not auto_target_skill
		print("Auto Target Skill: %s" % auto_target_skill)
	)

	input.basic_attack_pressed.connect(_on_basic_attack_pressed)
	input.skill_pressed.connect(_on_skill_pressed)
	input.burst_pressed.connect(_on_burst_pressed)


# ===== INPUT HANDLERS =====

func _on_basic_attack_pressed() -> void:
	_cast_basic_attack_rpc.rpc(aim_direction)

func _on_skill_pressed() -> void:
	_cast_skill_rpc.rpc(aim_direction)

func _on_burst_pressed() -> void:
	# Calculate target location locally before sending
	var burst_target = _calculate_target_location()
	_cast_burst_rpc.rpc(burst_target)


# ===== RPC WRAPPERS =====

@rpc("any_peer", "call_local", "reliable")
func _cast_basic_attack_rpc(direction: Vector2) -> void:
	var prev_aim = aim_direction
	aim_direction = direction
	
	if my_player_resource:
		my_player_resource.cast_basic_attack()
	
	aim_direction = prev_aim

@rpc("any_peer", "call_local", "reliable")
func _cast_skill_rpc(direction: Vector2) -> void:
	var prev_aim = aim_direction
	aim_direction = direction
	
	if my_player_resource:
		my_player_resource.cast_skill()
	
	aim_direction = prev_aim

@rpc("any_peer", "call_local", "reliable")
func _cast_burst_rpc(location: Vector2) -> void:
	# Set the synced target location
	var prev_target = target_location
	target_location = location

	if my_player_resource:
		my_player_resource.cast_burst()
	
	target_location = prev_target


# ===== AIMING & TARGETING =====

func _update_aim_direction() -> void:
	var right_stick = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	
	if right_stick.length() > 0.2:
		aim_direction = right_stick.normalized()
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		aim_direction = (get_global_mouse_position() - global_position).normalized()
	elif input_direction.length() > 0.1:
		aim_direction = input_direction.normalized()


func get_facing_direction() -> Vector2:
	if input_direction != Vector2.ZERO:
		var normalized = input_direction.normalized()
	
		if abs(normalized.x) > abs(normalized.y):
			sprite.flip_h = normalized.x < 0
		
		if abs(normalized.y) > abs(normalized.x):
			return Vector2.UP if normalized.y < 0 else Vector2.DOWN
		else:
			return Vector2.RIGHT if normalized.x > 0 else Vector2.LEFT
	
	if sprite.flip_h:
		return Vector2.LEFT
	else:
		return Vector2.RIGHT


func get_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var nearest_enemy: Node2D = null
	var nearest_distance: float = attack_range
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
			
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	
	return nearest_enemy


func get_nearest_enemy_location() -> Vector2:
	var nearest_enemy = get_nearest_enemy()
	if nearest_enemy:
		return nearest_enemy.global_position
	return Vector2.ZERO


func get_target_direction() -> Vector2:
	if auto_target_skill:
		var nearest_enemy = get_nearest_enemy()
		if nearest_enemy:
			return (get_nearest_enemy_location() - global_position).normalized()
	
	# Return the synced aim direction
	return aim_direction

# Helper function to calculate target location locally
func _calculate_target_location() -> Vector2:
	if auto_target_skill:
		var nearest_enemy = get_nearest_enemy()
		if nearest_enemy:
			return get_nearest_enemy_location()
		else:
			return get_global_mouse_position()
	else:
		return get_global_mouse_position()

# This function now returns the synced target location
func get_target_location() -> Vector2:
	# If target_location is set (from RPC), use it
	if target_location != Vector2.ZERO:
		return target_location
	
	# Otherwise calculate it (for local use)
	return _calculate_target_location()

func hide_player() -> void:
	can_play_animation = false
	animation_player.stop()
	sprite.hide()

func show_player() -> void:
	can_play_animation = true
	animation_player.play()
	sprite.show()


func _update_animation():
	get_facing_direction()
	
	if input_direction != Vector2.ZERO:
		animation_player.play("walk")
	else:
		animation_player.play("idle")


func change_player_resource(new_resource: PlayerResource) -> void:
	# Disconnect old input signals if they exist
	if my_player_resource and is_multiplayer_authority():
		if input.basic_attack_pressed.is_connected(_on_basic_attack_pressed):
			input.basic_attack_pressed.disconnect(_on_basic_attack_pressed)
		if input.skill_pressed.is_connected(_on_skill_pressed):
			input.skill_pressed.disconnect(_on_skill_pressed)
		if input.burst_pressed.is_connected(_on_burst_pressed):
			input.burst_pressed.disconnect(_on_burst_pressed)
	
	# Set new resource
	player_resource = new_resource
	my_player_resource = player_resource.duplicate(true)
	my_player_resource.player = self
	stats = my_player_resource.stats
	
	# Reconnect input signals if this is the authority
	if is_multiplayer_authority():
		input.basic_attack_pressed.connect(_on_basic_attack_pressed)
		input.skill_pressed.connect(_on_skill_pressed)
		input.burst_pressed.connect(_on_burst_pressed)
	
	print("[Player %d] Changed to: %s" % [player_id, my_player_resource.player_name])
