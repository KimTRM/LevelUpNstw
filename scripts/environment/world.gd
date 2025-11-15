class_name World extends Node2D

@onready var multiplayer_player_spawner: MultiplayerSpawner = $Node/MultiplayerPlayerSpawner

var multiplayer_player_scene: PackedScene = preload("uid://51oucobki1xe")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_player_spawner.spawn_function = _multiplayer_player


func spawn_player(authority_player_id: int) -> void:
	multiplayer_player_spawner.spawn(authority_player_id)


func _multiplayer_player(authority_player_id: int) -> Player:
	var player: Player = multiplayer_player_scene.instantiate() as Player
	player.player_resource = load("uid://ddsf0h48t34dj") as PlayerResource
	player.name = str(authority_player_id)

	return player
