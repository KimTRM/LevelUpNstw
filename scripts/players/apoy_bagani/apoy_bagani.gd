class_name ApoyBagani extends PlayerResource

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
	var flame_strike_scene: PackedScene = load("uid://cwb6ilcsanu23")
	var flame_strike_instance = flame_strike_scene.instantiate()

	player.get_parent().add_child(flame_strike_instance)
	flame_strike_instance.cast(player.global_position, player.get_target_direction())


func cast_burst() -> void:
	var purifying_blaze_scene: PackedScene = load("uid://dicv1bk7u0vgs")
	var purifying_blaze_instance = purifying_blaze_scene.instantiate()
	
	player.add_child(purifying_blaze_instance)
	purifying_blaze_instance.cast()
