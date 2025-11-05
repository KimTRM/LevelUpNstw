extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var heal_amount: int = 50
@export var duration: float = 5.0

func cast() -> void:
	animation_player.play("Start")
	await animation_player.animation_finished

	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_dispose)
	timer.start(duration)

	animation_player.play("Static")

func _dispose() -> void:
	animation_player.play("End")
	await animation_player.animation_finished
	queue_free()
