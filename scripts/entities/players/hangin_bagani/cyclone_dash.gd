extends Node2D

@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var duration: float = 5.0
var player: Player

func cast(_player: Player) -> void:
	player = _player
	player.hide_player()
	player.stats.base_movement_speed *= 1.5

	animation_player.play("start")
	await animation_player.animation_finished

	var lifetime_timer := Timer.new()
	add_child(lifetime_timer)

	lifetime_timer.timeout.connect(_disperse)
	lifetime_timer.start(duration)

	animation_player.play("spinning")
	

func _disperse() -> void:
	player.stats.base_movement_speed = player.stats.base_movement_speed / 1.5
	animation_player.play("end")
	await animation_player.animation_finished
	player.show_player()
	queue_free()
