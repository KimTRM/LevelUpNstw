extends Node2D

# Reference to the disaster manager
@onready var disaster_manager: DisasterManager = $DisasterManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to disaster manager signals for debugging
	if disaster_manager:
		disaster_manager.disaster_started.connect(_on_disaster_started)
		disaster_manager.disaster_ended.connect(_on_disaster_ended)

		print("Disaster Response System initialized!")
		print("Disasters will cycle every ", disaster_manager.disaster_duration, " seconds")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_disaster_started(disaster_type: String) -> void:
	"""Called when a new disaster starts"""
	print("=== NEW DISASTER: ", disaster_type, " ===")


func _on_disaster_ended(disaster_type: String) -> void:
	"""Called when a disaster ends"""
	print("=== DISASTER ENDED: ", disaster_type, " ===")


# Debug function to display current disaster info
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space or Enter key
		if disaster_manager:
			print("Current Disaster: ", disaster_manager.get_current_disaster_name())
