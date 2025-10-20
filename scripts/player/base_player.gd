class_name BasePlayer extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

const SPEED = 300.0
@export var extra_speed: float = 1.0

var _direction: Vector2
var _animation_direction: String = "down"

func _physics_process(_delta: float) -> void:
	_direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity * extra_speed, _delta)
	velocity_component.move(self)
	
	update_animation()


func update_animation():
	if _direction == Vector2.DOWN:
		_animation_direction = "down"
	elif _direction == Vector2.UP:
		_animation_direction = "up"
	elif _direction == Vector2.LEFT or _direction == Vector2.RIGHT:
		_animation_direction = "side"
		sprite.flip_h = _direction.x < 0

	if _direction != Vector2.ZERO:
		animation_player.play("walk_" + _animation_direction)
	else:
		animation_player.play("idle_" + _animation_direction)
