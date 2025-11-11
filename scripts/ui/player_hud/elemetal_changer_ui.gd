extends MarginContainer

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_find_local_player()

func _find_local_player() -> void:
	# Wait a frame for players to be spawned
	await get_tree().process_frame
	
	var players = get_tree().get_nodes_in_group("Player")
	for p in players:
		if p is Player and p.is_multiplayer_authority():
			player = p
			print("Found local player: %d" % player.player_id)
			return
	
	# If still not found, try again after a short delay
	if player == null:
		await get_tree().create_timer(0.5).timeout
		_find_local_player()

func _on_apoy_button_pressed() -> void:
	if not player:
		push_warning("Player not found!")
		return
		
	_change_element.rpc("uid://b35at8uw3aue5")
	print("Switched to Apoy Bagani")

func _on_tubig_button_pressed() -> void:
	if not player:
		push_warning("Player not found!")
		return
		
	_change_element.rpc("uid://cb7onuplhhdot")
	print("Switched to Tubig Bagani")

func _on_lupa_button_pressed() -> void:
	if not player:
		push_warning("Player not found!")
		return
		
	_change_element.rpc("uid://1ail0cf63jae")
	print("Switched to Lupa Bagani")

func _on_hangin_button_pressed() -> void:
	if not player:
		push_warning("Player not found!")
		return
		
	_change_element.rpc("uid://ddsf0h48t34dj")
	print("Switched to Hangin Bagani")

@rpc("any_peer", "call_local", "reliable")
func _change_element(resource_path: String) -> void:
	if not player:
		return
		
	var new_resource = load(resource_path) as PlayerResource
	if new_resource:
		player.change_player_resource(new_resource)
