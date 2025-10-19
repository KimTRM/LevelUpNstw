class_name Player
extends CharacterBody2D

const SPEED = 300.0
@export var extra_speed: float = 1.0

func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
