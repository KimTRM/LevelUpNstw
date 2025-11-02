extends Node2D

@export var stun_duration: float = 2.0
@export var quake_radius: float = 96.0
@export var lifetime: float = 0.5


func cast(player: Player) -> void:
	var hitbox = HitboxComponent.new()
	hitbox.damage = player.stats.base_attack if player.stats else 10
	hitbox.global_position = player.global_position
	hitbox.scale = Vector2.ONE * (quake_radius / 32.0)
	add_child(hitbox)

	# Optional animation / screen shake can be added here
	await get_tree().create_timer(lifetime).timeout
	queue_free()
