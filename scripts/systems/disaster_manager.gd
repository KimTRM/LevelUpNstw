extends Node2D
class_name DisasterManager

## Manages the dynamic disaster generation and cycling system
## Randomly selects and cycles through disasters every 10 seconds

signal disaster_started(disaster_type: String)
signal disaster_ended(disaster_type: String)

# Disaster type enumeration
enum DisasterType {
	FLOOD,
	WILDFIRE,
	EARTHQUAKE,
	TYPHOON
}

# Preloaded disaster scenes
var disaster_scenes: Dictionary = {}

# Current active disaster
var current_disaster: Node2D = null
var current_disaster_type: DisasterType = -1

# Timer for disaster cycling
var disaster_timer: Timer

# Disaster cycle duration (10 seconds as per specs)
@export var disaster_duration: float = 10.0

# Spawn position for disasters (center of the play area)
@export var disaster_spawn_position: Vector2 = Vector2(400, 300)


func _ready() -> void:
	# Preload all disaster scenes
	_load_disaster_scenes()

	# Setup the disaster timer
	_setup_timer()

	# Start the first disaster immediately
	_spawn_random_disaster()


func _load_disaster_scenes() -> void:
	"""Preload all disaster scene resources"""
	disaster_scenes[DisasterType.FLOOD] = preload("res://scenes/disasters/flood.tscn")
	disaster_scenes[DisasterType.WILDFIRE] = preload("res://scenes/disasters/wildfire.tscn")
	disaster_scenes[DisasterType.EARTHQUAKE] = preload("res://scenes/disasters/earthquake.tscn")
	disaster_scenes[DisasterType.TYPHOON] = preload("res://scenes/disasters/typhoon.tscn")


func _setup_timer() -> void:
	"""Initialize the disaster cycling timer"""
	disaster_timer = Timer.new()
	disaster_timer.wait_time = disaster_duration
	disaster_timer.one_shot = false
	disaster_timer.timeout.connect(_on_disaster_timer_timeout)
	add_child(disaster_timer)
	disaster_timer.start()


func _spawn_random_disaster() -> void:
	"""Randomly select and spawn a disaster"""
	# Clean up previous disaster if it exists
	if current_disaster != null:
		_end_current_disaster()

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
	current_disaster = disaster_scene.instantiate()
	current_disaster.position = disaster_spawn_position
	current_disaster_type = disaster_type

	# Add to scene tree
	add_child(current_disaster)

	# Emit signal
	var disaster_name = DisasterType.keys()[disaster_type]
	disaster_started.emit(disaster_name)

	print("Disaster started: ", disaster_name)


func _end_current_disaster() -> void:
	"""Clean up and remove the current disaster"""
	if current_disaster == null:
		return

	var disaster_name = DisasterType.keys()[current_disaster_type]
	disaster_ended.emit(disaster_name)

	print("Disaster ended: ", disaster_name)

	# Remove the disaster from the scene
	current_disaster.queue_free()
	current_disaster = null
	current_disaster_type = -1


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
