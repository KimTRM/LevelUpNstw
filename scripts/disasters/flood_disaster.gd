extends BaseDisaster
class_name FloodDisaster

## Flood Disaster - Tubig's Domain
## Visual: Rising water levels, reduced visibility
## Gameplay: Slows non-Tubig players, conducts electricity
## Escalation: Water level rises over time, creating isolated islands

@export var slow_multiplier: float = 0.6  # Slows movement to 60% speed
@export var max_escalation_time: float = 10.0  # Time to reach max escalation

# Escalation variables
var escalation_timer: float = 0.0
var escalation_progress: float = 0.0  # 0.0 to 1.0

# Camera reference for positioning particles
var camera_ref: Camera2D = null

# Get particle reference from scene
@onready var water_particles: CPUParticles2D = $WaterParticles


func _setup_disaster() -> void:
	disaster_name = "Flood"
	disaster_radius = 250.0
	damage_per_second = 0.0  # Flood doesn't deal direct damage

	# Set particles reference for BaseDisaster
	particles = water_particles

	# Setup collision area for flood zone
	collision_area = Area2D.new()
	collision_shape = CollisionShape2D.new()

	var circle_shape = CircleShape2D.new()
	circle_shape.radius = disaster_radius

	collision_shape.shape = circle_shape
	collision_area.add_child(collision_shape)
	add_child(collision_area)

	# Connect signals
	collision_area.body_entered.connect(_on_area_entered)
	collision_area.body_exited.connect(_on_area_exited)

	# Activate immediately
	activate()


func set_camera(cam: Camera2D) -> void:
	"""Set the camera reference for positioning particles"""
	camera_ref = cam
	print("Flood: Camera set for particle positioning")


func _physics_process(_delta: float) -> void:
	# Update particle position to follow camera in physics process for smooth interpolation
	if camera_ref and water_particles:
		# Position rain particles at top of screen
		var screen_center = camera_ref.get_screen_center_position()
		var viewport_height = get_viewport().get_visible_rect().size.y
		water_particles.global_position = Vector2(screen_center.x, screen_center.y - viewport_height / 2.0)


func _process(delta: float) -> void:
	super._process(delta)

	# Update escalation
	escalation_timer += delta
	escalation_progress = clamp(escalation_timer / max_escalation_time, 0.0, 1.0)


func _apply_disaster_effects(_delta: float) -> void:
	# Apply slow effect to bodies in the flood zone
	for body in bodies_in_zone:
		if body.has_method("apply_slow_effect"):
			body.apply_slow_effect(slow_multiplier)


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " entered Flood zone - movement slowed")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " exited Flood zone")
	# Remove slow effect when exiting
	if body.has_method("remove_slow_effect"):
		body.remove_slow_effect()
