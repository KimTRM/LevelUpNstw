class_name InputController extends Node

signal move_input(direction: Vector2)
signal basic_attack_pressed()
signal skill_pressed()
signal burst_pressed()
signal toggle_auto_target_pressed()

@export var enabled: bool = true

func _process(_delta: float) -> void:
	if not enabled or not is_multiplayer_authority():
		return

	var direction = Input.get_vector("left", "right", "up", "down")
	move_input.emit(direction)

	if Input.is_action_just_pressed("basic_attack"):
		basic_attack_pressed.emit()
	if Input.is_action_just_pressed("skill"):
		skill_pressed.emit()
	if Input.is_action_just_pressed("burst"):
		burst_pressed.emit()
	if Input.is_action_just_pressed("toggle_auto_target"):
		toggle_auto_target_pressed.emit()

func get_input_direction() -> Vector2:
	if not enabled or not is_multiplayer_authority():
		return Vector2.ZERO
	return Input.get_vector("left", "right", "up", "down")
