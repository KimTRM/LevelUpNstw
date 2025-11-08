class_name ENetConnectionManager extends PanelContainer

signal server_created
signal server_joined

@onready var host_ip: LineEdit = %HostIp
@onready var host_port: LineEdit = %HostPort

@onready var join_button: Button = %JoinButton
@onready var host_e_net_button: Button = %HostENetButton

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready() -> void:
	join_button.pressed.connect(_on_join_button_pressed)
	host_e_net_button.pressed.connect(_on_host_enet_button_pressed)

func _on_host_enet_button_pressed() -> void:
	peer.create_server(int(host_port.text), 32)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(func(id: int) -> void:
		print("Peer connected with ID: %d" % id)
	)

	server_created.emit()

	print("Hosting ENet server on port %d" % int(host_port.text))
	hide()


func _on_join_button_pressed() -> void:
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		print("Already connected to a server.")
		return
	
	peer.create_client(host_ip.text, int(host_port.text))
	multiplayer.multiplayer_peer = peer

	server_joined.emit()

	print("Joining ENet server at %s:%d" % [host_ip.text, int(host_port.text)])
	hide()
