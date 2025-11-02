class_name Player extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

@export var player_resource: PlayerResource
@export var auto_target_skill: bool = true
@export var attack_range: float = 300.0

var can_play_animation: bool = true
var animation_direction: String = "down"
var input_direction: Vector2
var stats: Stats

func _ready() -> void:
	if player_resource != null:
		stats = player_resource.stats
		player_resource.player = self
		velocity_component.max_speed = stats.base_movement_speed

func _input(_event: InputEvent) -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_just_pressed("basic_attack"):
		player_resource.cast_basic_attack()
		
	if Input.is_action_just_pressed("skill"):
		player_resource.cast_skill()
		
	if Input.is_action_just_pressed("burst"):
		player_resource.cast_burst()

	if Input.is_action_just_pressed("toggle_auto_target"):
		auto_target_skill = not auto_target_skill
		print("Auto Target Skill: %s" % auto_target_skill)
		
func _physics_process(_delta: float) -> void:
	velocity_component.max_speed = stats.base_movement_speed
	velocity = velocity_component.get_velocity(input_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)
	
	if can_play_animation:
		_update_animation()


func _update_animation():
	if input_direction == Vector2.DOWN:
		animation_direction = "down"
	elif input_direction == Vector2.UP:
		animation_direction = "up"
	elif input_direction == Vector2.LEFT or input_direction == Vector2.RIGHT:
		animation_direction = "side"
		sprite.flip_h = input_direction.x < 0

	if input_direction != Vector2.ZERO:
		animation_player.play("walk")
	else:
		animation_player.play("idle")

func hide_player() -> void:
	can_play_animation = false
	animation_player.stop()
	sprite.hide()

func show_player() -> void:
	can_play_animation = true
	animation_player.play()
	sprite.show()


func get_target_direction() -> Vector2:
	var direction: Vector2

	if auto_target_skill:
		var nearest_enemy = _find_nearest_enemy()
		if nearest_enemy:
			direction = (nearest_enemy.global_position - global_position).normalized()
		else:
			direction = (get_global_mouse_position() - global_position).normalized()
	else:
		direction = (get_global_mouse_position() - global_position).normalized()

	return direction


func _find_nearest_enemy() -> Node2D:
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