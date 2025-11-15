extends Node

signal player_connected(peer_id: int, info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_disconnected

const DEFAULT_SERVER_IP: String = "127.0.0.1"
const PORT: int = 7000
const MAX_CONNECTIONS: int = 8


# ──────────────────────────────────────────────
#  BAGANI ROLES (STATIC)
# ──────────────────────────────────────────────
enum ElementalRole {
    APOY,
    TUBIG,
    LUPA,
    HANGIN,
}


# ──────────────────────────────────────────────
#  LOCAL PLAYER INFO (STATICALLY TYPED)
# ──────────────────────────────────────────────
var local_player_info: Dictionary = {
    "name": "",
    "role": ElementalRole.APOY,
    "scene": "", # Player scene path
}


# ──────────────────────────────────────────────
#  STORES ALL PLAYERS
#  players[id] = Dictionary
# ──────────────────────────────────────────────
var players: Dictionary[int, Dictionary] = {}
var players_loaded: int = 0


# ──────────────────────────────────────────────
#  SIGNAL HOOKS
# ──────────────────────────────────────────────
func _ready() -> void:
    multiplayer.peer_connected.connect(_on_player_connected)
    multiplayer.peer_disconnected.connect(_on_player_disconnected)
    multiplayer.connected_to_server.connect(_on_connected_ok)
    multiplayer.connection_failed.connect(_on_connected_fail)
    multiplayer.server_disconnected.connect(_on_server_disconnected)


# ──────────────────────────────────────────────
#  SERVER STARTUP
# ──────────────────────────────────────────────
func create_game() -> Error:
    var peer := ENetMultiplayerPeer.new()
    var err: Error = peer.create_server(PORT, MAX_CONNECTIONS)

    if err != OK:
        return err

    multiplayer.multiplayer_peer = peer

    # Server ALWAYS becomes ID 1
    players[1] = local_player_info.duplicate(true)
    player_connected.emit(1, players[1])

    return OK


# ──────────────────────────────────────────────
#  CLIENT CONNECT
# ──────────────────────────────────────────────
func join_game(address: String = "") -> Error:
    if address.is_empty():
        address = DEFAULT_SERVER_IP

    var peer := ENetMultiplayerPeer.new()
    var err: Error = peer.create_client(address, PORT)

    if err != OK:
        return err

    multiplayer.multiplayer_peer = peer
    return OK


func remove_multiplayer_peer() -> void:
    multiplayer.multiplayer_peer = null
    players.clear()


# ──────────────────────────────────────────────
#  LOAD GAME SCENE
# ──────────────────────────────────────────────
@rpc("call_local", "reliable")
func load_game(scene_path: String) -> void:
    get_tree().change_scene_to_file(scene_path)


# Each peer calls this AFTER loading the scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded() -> void:
    if multiplayer.is_server():
        players_loaded += 1

        if players_loaded == players.size():
            players_loaded = 0
            var game: Node = get_node_or_null("/root/Game")

            if game and game.has_method("start_game"):
                game.start_game()


# ──────────────────────────────────────────────
#  PLAYER REGISTRATION
# ──────────────────────────────────────────────
func _on_player_connected(id: int) -> void:
    # Tell the new peer OUR info
    _register_player.rpc_id(id, local_player_info)

    # Ask the new peer for THEIR info
    request_player_info.rpc_id(id)


# Request the player's info
@rpc("any_peer", "reliable")
func request_player_info() -> void:
    var sender_id: int = multiplayer.get_remote_sender_id()
    _register_player.rpc_id(sender_id, local_player_info)


# Store the player's info
@rpc("any_peer", "reliable")
func _register_player(info: Dictionary) -> void:
    var sender: int = multiplayer.get_remote_sender_id()

    players[sender] = info.duplicate(true)
    player_connected.emit(sender, players[sender])


# ──────────────────────────────────────────────
#  DISCONNECT EVENTS
# ──────────────────────────────────────────────
func _on_player_disconnected(id: int) -> void:
    players.erase(id)
    player_disconnected.emit(id)


func _on_connected_ok() -> void:
    var id: int = multiplayer.get_unique_id()

    players[id] = local_player_info.duplicate(true)
    player_connected.emit(id, players[id])


func _on_connected_fail() -> void:
    multiplayer.multiplayer_peer = null


func _on_server_disconnected() -> void:
    multiplayer.multiplayer_peer = null
    players.clear()
    server_disconnected.emit()
