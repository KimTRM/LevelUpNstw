extends Node2D

@export var purifying_blaze_scene: PackedScene
@export var projectile_speed: float = 600.0
@export var cooldown_time: float = 0.5

var can_fire := true

func cast_flame_strike(position: Vector2, direction: Vector2):
	if not can_fire:
		return
	if purifying_blaze_scene:
		var projectile = purifying_blaze_scene.instantiate()
		projectile.global_position = position
		projectile.rotation = direction.angle()
		get_tree().current_scene.add_child(projectile)

		projectile.set("velocity", direction * projectile_speed)

		can_fire = false
		await get_tree().create_timer(cooldown_time).timeout
		can_fire = true
