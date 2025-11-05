class_name LupaBagani extends PlayerResource


func cast_basic_attack() -> void:
	pass

func cast_skill() -> void:
	var stone_barrier_scene: PackedScene = load("uid://bs1o4uwrouo1b")
	var barrier = stone_barrier_scene.instantiate()

	barrier.global_position = player.global_position
	player.get_parent().add_child(barrier)
	barrier.cast(player.global_position, player.get_target_direction())

func cast_burst() -> void:
	var earthquake_strike_scene: PackedScene = load("uid://b8sbokcx1bndo")
	var quake = earthquake_strike_scene.instantiate()
	player.add_child(quake)
	quake.cast(player)
