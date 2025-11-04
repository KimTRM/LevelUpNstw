class_name TubigBagani extends PlayerResource

func cast_basic_attack() -> void:
	pass

func cast_skill() -> void:
	var healing_ring_scene: PackedScene = load("uid://qxvwxrf0halb")
	var player_instances = player.get_tree().get_nodes_in_group("Player") as Array[Player]
	
	for p in player_instances:
		if is_instance_valid(p):
			print("Casting Healing Ring on all players..." + str(player_instances.size()))
			var healing_ring_instance = healing_ring_scene.instantiate()
			p.add_child(healing_ring_instance)
			healing_ring_instance.cast()
	
	
func cast_burst() -> void:
	var tidal_surge_scene: PackedScene = load("uid://cscw014s2d4d0")
	var tidal_surge_instance = tidal_surge_scene.instantiate()

	tidal_surge_instance.global_position = player.get_target_location()

	player.get_parent().add_child(tidal_surge_instance)
	tidal_surge_instance.cast()
