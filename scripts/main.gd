extends Node

# @onready var disaster_manager: DisasterManager = $DisasterManager
@onready var connection_manager: ConnectionManager = %ConnectionManager
@onready var world: World = %World

func _ready() -> void:
	connection_manager.hosting.connect(_on_connection_manager_hosting)
	connection_manager.joining.connect(_on_connection_manager_joining)


	# if disaster_manager:
	# 	disaster_manager.disaster_started.connect(_on_disaster_started)
	# 	disaster_manager.disaster_ended.connect(_on_disaster_ended)
	# 	print("Disaster Response System initialized!")
	# 	print("Disasters will cycle every ", disaster_manager.disaster_duration, " seconds")


func _on_connection_manager_hosting() -> void:
	world._spawn_player(1)
	
	multiplayer.peer_connected.connect(
		func(peer_id: int) -> void:
			world._spawn_player(peer_id)
	)
	
	print("ConnectionManager signaled hosting.")


func _on_connection_manager_joining() -> void:
	print("ConnectionManager signaled joining.")


# func _on_disaster_started(disaster_type: String) -> void:
# 	"""Called when a new disaster starts"""
# 	print("=== NEW DISASTER: ", disaster_type, " ===")


# func _on_disaster_ended(disaster_type: String) -> void:
# 	"""Called when a disaster ends"""
# 	print("=== DISASTER ENDED: ", disaster_type, " ===")


# # Debug function to display current disaster info
# func _input(event: InputEvent) -> void:
# 	if event.is_action_pressed("ui_accept"): # Space or Enter key
# 		if disaster_manager:
# 			print("Current Disaster: ", disaster_manager.get_current_disaster_name())
