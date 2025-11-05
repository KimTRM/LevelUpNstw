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
var stats: Stats

func _ready() -> void:
	initialize_player()

func _physics_process(_delta: float) -> void:
	velocity_component.max_speed = stats.base_movement_speed
	velocity = velocity_component.get_velocity(input_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)
	
	if can_play_animation:
		_update_animation()


func initialize_player() -> void:
	input.move_input.connect(func(direction: Vector2) -> void:
		input_direction = direction
	)

	input.toggle_auto_target_pressed.connect(func() -> void:
		auto_target_skill = not auto_target_skill
		print("Auto Target Skill: %s" % auto_target_skill)
	)

	if player_resource:
		stats = player_resource.stats
		player_resource.player = self
		velocity_component.max_speed = stats.base_movement_speed

		if input.basic_attack_pressed.is_connected(player_resource.cast_basic_attack):
			input.basic_attack_pressed.disconnect(player_resource.cast_basic_attack)
		if input.skill_pressed.is_connected(player_resource.cast_skill):
			input.skill_pressed.disconnect(player_resource.cast_skill)
		if input.burst_pressed.is_connected(player_resource.cast_burst):
			input.burst_pressed.disconnect(player_resource.cast_burst)
			
		input.basic_attack_pressed.connect(player_resource.cast_basic_attack)
		input.skill_pressed.connect(player_resource.cast_skill)
		input.burst_pressed.connect(player_resource.cast_burst)


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
	var direction: Vector2

	if auto_target_skill:
		var nearest_enemy = get_nearest_enemy()
		if nearest_enemy:
			direction = (get_nearest_enemy_location() - global_position).normalized()
		else:
			direction = (get_global_mouse_position() - global_position).normalized()
	else:
		direction = (get_global_mouse_position() - global_position).normalized()

	return direction


func get_target_location() -> Vector2:
	var location: Vector2

	if auto_target_skill:
		var nearest_enemy = get_nearest_enemy()
		if nearest_enemy:
			location = get_nearest_enemy_location()
		else:
			location = get_global_mouse_position()
	else:
		location = get_global_mouse_position()

	return location

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
