extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var stun_duration: float = 2.0
@export var quake_radius: float = 96.0
@export var lifetime: float = 0.5


func cast(_player: Player) -> void:
	animation_player.play("default")
	await animation_player.animation_finished
	queue_free()
