extends MarginContainer

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player


func _on_apoy_button_pressed() -> void:
	player.player_resource = load("uid://b35at8uw3aue5") as PlayerResource
	player.initialize_player()
	print("Switched to Apoy Bagani")


func _on_tubig_button_pressed() -> void:
	player.player_resource = load("uid://cb7onuplhhdot") as PlayerResource
	player.initialize_player()
	print("Switched to Tubig Bagani")


func _on_lupa_button_pressed() -> void:
	player.player_resource = load("uid://1ail0cf63jae") as PlayerResource
	player.initialize_player()
	print("Switched to Lupa Bagani")


func _on_hangin_button_pressed() -> void:
	player.player_resource = load("uid://ddsf0h48t34dj") as PlayerResource
	player.initialize_player()
	print("Switched to Hangin Bagani")
