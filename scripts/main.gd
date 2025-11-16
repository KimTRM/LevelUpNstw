extends Node

# @onready var disaster_manager: DisasterManager = $DisasterManager
@onready var connection_manager: ConnectionManager = %ConnectionManager
@onready var world: World = %World

func _ready() -> void:
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)
	
	connection_manager.hosting.connect(_on_connection_manager_hosting)
	connection_manager.joining.connect(_on_connection_manager_joining)


func _on_connection_manager_hosting() -> void:
	var error: Error = NetworkManager.create_game()
	if error == OK:
		print("Server created successfully")
		# Wait a frame for everything to initialize
		await get_tree().process_frame
		# Spawn host player
		world.spawn_player(1)
		# Hide connection UI
		connection_manager.hide()
	else:
		push_error("Failed to create server: %s" % error)


func _on_connection_manager_joining(ip_address: String) -> void:
	var error: Error = NetworkManager.join_game(ip_address)
	if error == OK:
		print("Connecting to server at %s..." % ip_address)
	else:
		push_error("Failed to connect: %s" % error)


func _on_player_connected(peer_id: int, player_info: Dictionary) -> void:
	print("Player %d connected: %s" % [peer_id, player_info])
	
	# Only spawn on server
	if not NetworkManager.is_host():
		print("Not host, skipping spawn")
		return
	
	# Don't spawn host again (already spawned in _on_connection_manager_hosting)
	if peer_id == 1:
		print("Host already spawned, skipping")
		return
	
	# Wait a frame to ensure everything is synced
	await get_tree().process_frame
	
	print("Spawning player %d" % peer_id)
	world.spawn_player(peer_id)
	
	# Hide connection UI for the joining player
	if peer_id == NetworkManager.get_local_peer_id():
		connection_manager.hide()


func _on_player_disconnected(peer_id: int) -> void:
	print("Player %d disconnected" % peer_id)
	
	var players: Array[Node] = get_tree().get_nodes_in_group("Player")
	var player_node: Node = null
	
	for player in players:
		if player.get_multiplayer_authority() == peer_id:
			player_node = player
			break
	
	if player_node:
		player_node.queue_free()


func _on_server_disconnected() -> void:
	print("Server disconnected. Returning to menu...")
	# Show connection UI again
	connection_manager.show()
	
	# Clean up all players
	var players_container: Node = world.get_node_or_null("Players")
	if players_container:
		for child in players_container.get_children():
			child.queue_free()
