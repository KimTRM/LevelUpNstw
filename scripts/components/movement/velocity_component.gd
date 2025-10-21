class_name VelocityComponent extends Node

@export var max_speed: float = 100.0
@export var acceleration: float = 10.0

var velocity: Vector2 = Vector2.ZERO

func move(character: CharacterBody2D) -> void:
	character.velocity = velocity
	character.move_and_slide()


func get_velocity(direction: Vector2) -> Vector2:
	return direction.normalized() * max_speed


func accelerate_to_velocity(target_velocity: Vector2, delta: float) -> void:
	velocity = velocity.lerp(target_velocity, acceleration * delta)
