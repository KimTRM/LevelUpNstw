class_name ApoyBagani extends PlayerResource

func cast_basic_attack() -> void:
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 12)
	var hitbox_instance: HitboxComponent = HitboxComponent.new(player.stats, 0.12, rect)
	player.add_child(hitbox_instance)

	var forward := Vector2.ZERO

	forward = player.get_facing_direction()
	hitbox_instance.global_position = player.global_position + forward * 16
	hitbox_instance.global_position = player.global_position + forward * 16

func cast_skill() -> void:
	var flame_strike_scene: PackedScene = load("uid://cwb6ilcsanu23")
	var flame_strike_instance = flame_strike_scene.instantiate()

	flame_strike_instance.global_position = player.global_position
	flame_strike_instance.direction = player.get_target_direction()

	player.get_parent().add_child(flame_strike_instance)
	flame_strike_instance.cast()


func cast_burst() -> void:
	var purifying_blaze_scene: PackedScene = load("uid://dicv1bk7u0vgs")
	var purifying_blaze_instance = purifying_blaze_scene.instantiate()

	player.add_child(purifying_blaze_instance)
	purifying_blaze_instance.cast()
