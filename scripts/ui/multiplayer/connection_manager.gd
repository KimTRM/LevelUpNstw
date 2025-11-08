class_name ConnectionManager extends Control

signal hosting
signal joining

@onready var enet_connection_manager: ENetConnectionManager = %ENetConnectionManager

func _ready() -> void:
	enet_connection_manager.server_created.connect(_host_handler)
	enet_connection_manager.server_joined.connect(_join_handler)

func _host_handler() -> void:
	print("Hosting signal received in ConnectionManager.")
	hosting.emit()

func _join_handler() -> void:
	print("Joining signal received in ConnectionManager.")
	joining.emit()