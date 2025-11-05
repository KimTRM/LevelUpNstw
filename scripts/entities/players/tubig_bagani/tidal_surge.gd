extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func cast() -> void:
	animation_player.play("default")
	await animation_player.animation_finished
	queue_free()
