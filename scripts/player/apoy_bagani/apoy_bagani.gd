class_name ApoyBagani extends PlayerResource

var flame_strike_scene: PackedScene = preload("uid://cwb6ilcsanu23")
var purifying_blaze_scene: PackedScene = preload("uid://dicv1bk7u0vgs")

func cast_basic_attack() -> void:
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 12)
	var hitbox_instance: HitboxComponent = HitboxComponent.new(player.stats, 0.12, rect)
	player.add_child(hitbox_instance)

	var forward := Vector2.ZERO
	match player.animation_direction:
		"down":
			forward = Vector2(0, 1)
		"up":
			forward = Vector2(0, -1)
		"side":
			var x_dir := -1 if player.sprite.flip_h else 1
			forward = Vector2(x_dir, 0)
	hitbox_instance.global_position = player.global_position + forward * 16
	hitbox_instance.global_position = player.global_position + forward * 16

	
func cast_skill() -> void:
	var projectile = flame_strike_scene.instantiate()

	var direction = (player.get_global_mouse_position() - player.global_position).normalized()
	projectile.cast(player.global_position, direction)
	player.get_parent().add_child(projectile)

func cast_burst() -> void:
	var purifying_blaze = purifying_blaze_scene.instantiate()
	player.add_child(purifying_blaze)
	purifying_blaze.cast()
