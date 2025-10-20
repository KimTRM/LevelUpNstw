class_name BaseEnemy extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent

var _direction: Vector2 = Vector2.ZERO

var player_encountered: bool = false

func _physics_process(_delta: float) -> void:
	if player_encountered:
		_direction = (get_tree().get_first_node_in_group("Player").global_position - global_position).normalized()
	else:
		_direction = Vector2.ZERO

	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)


func _on_detection_area_component_body_entered(_body: Node2D) -> void:
	player_encountered = true


func _on_detection_area_component_body_exited(_body: Node2D) -> void:
	player_encountered = false
