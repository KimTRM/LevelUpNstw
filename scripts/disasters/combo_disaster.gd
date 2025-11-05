extends BaseDisaster
class_name ComboDisaster

## Base class for combo disasters created by combining two disaster types
## Provides combined visual and mechanical effects

# Combo properties
@export var combo_name: String = "Combo Disaster"
@export var disaster_type_1: String = ""
@export var disaster_type_2: String = ""

# Enhanced effects for combos
@export var combo_damage_multiplier: float = 1.5  # Combos deal 50% more damage

# Secondary particle system for combined effects
var particles_secondary: GPUParticles2D

# Visual overlays
var combo_overlay: ColorRect

# Escalation
var escalation_timer: float = 0.0
var escalation_progress: float = 0.0
@export var max_escalation_time: float = 10.0

# Camera reference for positioning
var camera_ref: Camera2D = null


func _ready() -> void:
	super._ready()
	print("Combo disaster initialized: ", combo_name)


func set_camera(cam: Camera2D) -> void:
	"""Set the camera reference for positioning particles and effects"""
	camera_ref = cam
	print("ComboDisaster (", combo_name, "): Camera set for positioning")


func _physics_process(_delta: float) -> void:
	# Update position to follow camera in physics process for smooth interpolation
	if camera_ref:
		global_position = camera_ref.get_screen_center_position()


func _process(delta: float) -> void:
	super._process(delta)

	# Update escalation
	escalation_timer += delta
	escalation_progress = clamp(escalation_timer / max_escalation_time, 0.0, 1.0)

	# Call escalation update (to be overridden by child classes)
	_update_escalation(delta)


func _update_escalation(_delta: float) -> void:
	"""Override this in child classes to implement escalation"""
	pass


func create_combo_overlay(color: Color) -> void:
	"""Create a visual overlay for the combo effect"""
	combo_overlay = ColorRect.new()
	combo_overlay.color = color
	combo_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	combo_overlay.z_index = 100
	combo_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(combo_overlay)
