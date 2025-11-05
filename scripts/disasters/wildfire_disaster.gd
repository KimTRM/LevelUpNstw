extends BaseDisaster
class_name WildfireDisaster

## Wildfire Disaster - Apoy's Domain
## Visual: Spreading flames, smoke effects
## Gameplay: Damages all players except Apoy over time
## Escalation: Fire spreads to new areas, creating walls of flame

@export var fire_damage_per_second: float = 10.0
@export var max_escalation_time: float = 10.0  # Time to reach max escalation

# Escalation variables
var escalation_timer: float = 0.0
var escalation_progress: float = 0.0  # 0.0 to 1.0
var initial_radius: float = 220.0
var max_radius: float = 350.0

# Camera reference for positioning particles
var camera_ref: Camera2D = null

# Get particle reference from scene
@onready var fire_particles: CPUParticles2D = $FireParticles


func _setup_disaster() -> void:
	disaster_name = "Wildfire"
	disaster_radius = initial_radius
	damage_per_second = fire_damage_per_second

	# Set particles reference for BaseDisaster
	particles = fire_particles

	# Setup collision area for fire zone
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
	print("Wildfire: Camera set for particle positioning")


func _physics_process(_delta: float) -> void:
	# Update particle position to follow camera in physics process for smooth interpolation
	if camera_ref and fire_particles:
		fire_particles.global_position = camera_ref.get_screen_center_position()


func _process(delta: float) -> void:
	super._process(delta)

	# Update escalation
	escalation_timer += delta
	escalation_progress = clamp(escalation_timer / max_escalation_time, 0.0, 1.0)

	# Escalate fire spread (increase radius)
	disaster_radius = lerp(initial_radius, max_radius, escalation_progress)

	# Update collision area radius
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = disaster_radius


func _apply_disaster_effects(_delta: float) -> void:
	# Apply fire damage to bodies in the wildfire zone
	for body in bodies_in_zone:
		# TODO: Check if body is Apoy (fire elemental) - they should be immune
		if body.has_method("take_damage"):
			body.take_damage(fire_damage_per_second * _delta, "fire")


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " entered Wildfire zone - taking fire damage")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " exited Wildfire zone")
