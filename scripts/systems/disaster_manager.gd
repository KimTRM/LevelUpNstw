extends Node2D
class_name DisasterManager

## Manages the dynamic disaster generation and cycling system
## Randomly selects and cycles through disasters every 10 seconds
## Disasters follow the camera for consistent on-screen visibility

signal disaster_started(disaster_type: String)
signal disaster_ended(disaster_type: String)
signal combo_disaster_started(combo_name: String, disaster1: String, disaster2: String)

# Disaster type enumeration
enum DisasterType {
	FLOOD,
	WILDFIRE,
	EARTHQUAKE,
	TYPHOON
}

# Combo disaster enumeration
enum ComboType {
	FIRESTORM,      # Fire + Wind
	MUDSLIDE,       # Water + Earth (not implemented - no earth disasters yet)
	STEAM,          # Fire + Water
	WATERSPOUT      # Wind + Water
}

# Preloaded disaster scenes
var disaster_scenes: Dictionary = {}
var combo_disaster_scenes: Dictionary = {}

# Current active disasters (can be 1 or 2 for combos)
var current_disasters: Array[Node2D] = []
var current_disaster_type: DisasterType = -1
var current_combo_type: int = -1
var is_combo_active: bool = false

# Camera reference for following
var camera: Camera2D = null

# Timer for disaster cycling
var disaster_timer: Timer

# Disaster cycle duration (10 seconds as per specs)
@export var disaster_duration: float = 10.0

# Chance for combo disaster to occur (20%)
@export var combo_chance: float = 0.2

# Camera-relative spawn position (disasters spawn at camera center)
@export var camera_relative_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Find the camera in the scene
	_find_camera()

	# Preload all disaster scenes
	_load_disaster_scenes()

	# Setup the disaster timer
	_setup_timer()

	# Start the first disaster immediately (delayed slightly for camera to be ready)
	await get_tree().create_timer(0.1).timeout
	_spawn_random_disaster()


func _find_camera() -> void:
	"""Find the Camera2D in the scene tree"""
	# Look for player first
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		# Get camera from player
		camera = player.get_node_or_null("Camera2D")
		if camera:
			print("DisasterManager: Camera found on player")
			return

	# Fallback: search entire tree
	camera = get_tree().get_first_node_in_group("MainCamera")
	if camera:
		print("DisasterManager: Camera found in MainCamera group")
	else:
		push_warning("DisasterManager: No camera found! Disasters will spawn at world position.")


func _load_disaster_scenes() -> void:
	"""Preload all disaster scene resources"""
	disaster_scenes[DisasterType.FLOOD] = preload("res://scenes/disasters/flood.tscn")
	disaster_scenes[DisasterType.WILDFIRE] = preload("res://scenes/disasters/wildfire.tscn")
	disaster_scenes[DisasterType.EARTHQUAKE] = preload("res://scenes/disasters/earthquake.tscn")
	disaster_scenes[DisasterType.TYPHOON] = preload("res://scenes/disasters/typhoon.tscn")

	# Preload combo disasters
	combo_disaster_scenes[ComboType.FIRESTORM] = preload("res://scenes/disasters/firestorm.tscn")
	combo_disaster_scenes[ComboType.STEAM] = preload("res://scenes/disasters/steam.tscn")
	combo_disaster_scenes[ComboType.WATERSPOUT] = preload("res://scenes/disasters/waterspout.tscn")


func _setup_timer() -> void:
	"""Initialize the disaster cycling timer"""
	disaster_timer = Timer.new()
	disaster_timer.wait_time = disaster_duration
	disaster_timer.one_shot = false
	disaster_timer.timeout.connect(_on_disaster_timer_timeout)
	add_child(disaster_timer)
	disaster_timer.start()


func _spawn_random_disaster() -> void:
	"""Randomly select and spawn a disaster or combo"""
	# Clean up previous disasters if they exist
	_end_current_disasters()

	# Check if we should spawn a combo disaster (20% chance)
	if randf() < combo_chance and combo_disaster_scenes.size() > 0:
		_spawn_combo_disaster()
	else:
		# Randomly select a disaster type
		var disaster_types = DisasterType.values()
		var random_type = disaster_types[randi() % disaster_types.size()]

		# Spawn the new disaster
		_spawn_disaster(random_type)


func _spawn_disaster(disaster_type: DisasterType) -> void:
	"""Spawn a specific disaster type"""
	if not disaster_scenes.has(disaster_type):
		push_error("Disaster scene not found for type: " + str(disaster_type))
		return

	# Instance the disaster scene
	var disaster_scene = disaster_scenes[disaster_type]
	var disaster = disaster_scene.instantiate()

	# FIXED APPROACH: Parent to camera so emission follows player
	# Particles use top_level=true to prevent jitter
	if camera:
		camera.add_child(disaster)
		disaster.position = camera_relative_offset
		# Pass camera reference to disaster for screen shake effects
		if disaster.has_method("set_camera"):
			disaster.set_camera(camera)
	else:
		add_child(disaster)
		disaster.position = get_viewport_rect().size / 2

	current_disasters.append(disaster)
	current_disaster_type = disaster_type
	is_combo_active = false

	# Emit signal
	var disaster_name = DisasterType.keys()[disaster_type]
	disaster_started.emit(disaster_name)

	print("Disaster started: ", disaster_name)


func _spawn_combo_disaster() -> void:
	"""Spawn a random combo disaster"""
	var combo_types = combo_disaster_scenes.keys()
	if combo_types.size() == 0:
		# Fallback to regular disaster if no combos available
		_spawn_random_disaster()
		return

	var random_combo = combo_types[randi() % combo_types.size()]
	var combo_scene = combo_disaster_scenes[random_combo]
	var combo_disaster = combo_scene.instantiate()

	# FIXED APPROACH: Parent to camera so emission follows player
	# Particles use top_level=true to prevent jitter
	if camera:
		camera.add_child(combo_disaster)
		combo_disaster.position = camera_relative_offset
		# Pass camera reference for effects
		if combo_disaster.has_method("set_camera"):
			combo_disaster.set_camera(camera)
	else:
		add_child(combo_disaster)
		combo_disaster.position = get_viewport_rect().size / 2

	current_disasters.append(combo_disaster)
	current_combo_type = random_combo
	is_combo_active = true

	# Emit combo signal
	var combo_name = ComboType.keys()[random_combo]
	var disaster_pair = _get_combo_disaster_types(random_combo)
	combo_disaster_started.emit(combo_name, disaster_pair[0], disaster_pair[1])

	print("Combo Disaster started: ", combo_name, " (", disaster_pair[0], " + ", disaster_pair[1], ")")


func _get_combo_disaster_types(combo_type: int) -> Array[String]:
	"""Returns the two disaster types that make up a combo"""
	match combo_type:
		ComboType.FIRESTORM:
			return ["WILDFIRE", "TYPHOON"]
		ComboType.STEAM:
			return ["WILDFIRE", "FLOOD"]
		ComboType.WATERSPOUT:
			return ["TYPHOON", "FLOOD"]
		_:
			return ["UNKNOWN", "UNKNOWN"]


func _end_current_disasters() -> void:
	"""Clean up and remove all current disasters"""
	if current_disasters.size() == 0:
		return

	# Emit end signals
	if is_combo_active:
		var combo_name = ComboType.keys()[current_combo_type]
		print("Combo Disaster ended: ", combo_name)
	else:
		if current_disaster_type != -1:
			var disaster_name = DisasterType.keys()[current_disaster_type]
			disaster_ended.emit(disaster_name)
			print("Disaster ended: ", disaster_name)

	# Remove all disasters from the scene
	for disaster in current_disasters:
		disaster.queue_free()

	current_disasters.clear()
	current_disaster_type = -1
	current_combo_type = -1
	is_combo_active = false


func _on_disaster_timer_timeout() -> void:
	"""Called every 10 seconds to cycle to a new disaster"""
	_spawn_random_disaster()


func get_current_disaster_type() -> int:
	"""Returns the current active disaster type"""
	return current_disaster_type


func get_current_disaster_name() -> String:
	"""Returns the current active disaster name as a string"""
	if current_disaster_type == -1:
		return "None"
	return DisasterType.keys()[current_disaster_type]
