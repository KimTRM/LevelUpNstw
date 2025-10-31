class_name Player extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

@export var player_resource: PlayerResource

var animation_direction: String = "down"
var input_direction: Vector2
var stats: Stats

func _ready() -> void:
	if player_resource != null:
		stats = player_resource.stats
		player_resource.player = self
		velocity_component.max_speed = stats.base_movement_speed

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("basic_attack"):
		player_resource.cast_basic_attack()
		
	if Input.is_action_just_pressed("skill"):
		player_resource.cast_skill()
		
	if Input.is_action_just_pressed("burst"):
		player_resource.cast_burst()


func _physics_process(_delta: float) -> void:
	input_direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = velocity_component.get_velocity(input_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)
	
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
		animation_player.play("walk_" + animation_direction)
	else:
		animation_player.play("idle_" + animation_direction)
