class_name HanginBagani extends PlayerResource

func cast_basic_attack() -> void:
	pass

func cast_skill() -> void:
	var gust_blast_scene: PackedScene = load("uid://crexpafhthv7v")
	var gust_blast_instance = gust_blast_scene.instantiate()

	player.get_parent().add_child(gust_blast_instance)
	gust_blast_instance.cast(player.global_position, player.get_target_direction())

func cast_burst() -> void:
	var cyclone_dash_scene: PackedScene = load("uid://n4csovw2vb4h")
	var cyclone_dash_instance = cyclone_dash_scene.instantiate()
	
	player.add_child(cyclone_dash_instance)
	cyclone_dash_instance.cast(player)
