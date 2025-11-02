class_name TubigBagani extends PlayerResource

func cast_basic_attack() -> void:
	pass

func cast_skill() -> void:
	var healing_ring_scene: PackedScene = load("uid://qxvwxrf0halb")
	var healing_ring_instance = healing_ring_scene.instantiate()

	player.add_child(healing_ring_instance)
	healing_ring_instance.cast()

func cast_burst() -> void:
	pass
