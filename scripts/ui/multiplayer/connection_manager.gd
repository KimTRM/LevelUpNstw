class_name ConnectionManager extends Control

signal hosting
signal joining(ip_address: String)

@onready var enet_connection_manager: ENetConnectionManager = %ENetConnectionManager

func _ready() -> void:
    enet_connection_manager.server_created.connect(_host_handler)
    enet_connection_manager.server_joined.connect(_join_handler)

func _host_handler() -> void:
    hosting.emit()

func _join_handler(ip_address: String) -> void:
    joining.emit(ip_address)