extends BaseDisaster
class_name EarthquakeDisaster

## Earthquake Disaster - Lupa's Domain
## Visual: Screen shake, falling debris
## Gameplay: Random knockdown, terrain changes
## Escalation: Chasms open, buildings collapse

@export var initial_shake_intensity: float = 5.0
@export var max_shake_intensity: float = 20.0
@export var knockdown_chance: float = 0.3  # 30% chance per second
@export var max_escalation_time: float = 10.0  # Time to reach max escalation

# Escalation variables
var escalation_timer: float = 0.0
var escalation_progress: float = 0.0  # 0.0 to 1.0
var shake_intensity: float = 5.0

var shake_time: float = 0.0  # Accumulated time for smooth sine wave
var shake_speed_x: float = 3.0  # Horizontal shake frequency
var shake_speed_y: float = 4.5  # Vertical shake frequency (slightly different for more natural feel)
var base_shake_offset: Vector2 = Vector2.ZERO

# Camera reference for screen shake
var camera_ref: Camera2D = null

# Get particle references from scene
@onready var particle_container: Node2D = $ParticleContainer
@onready var debris_particles: CPUParticles2D = $ParticleContainer/EarthquakeDebris
@onready var fog_particles: CPUParticles2D = $ParticleContainer/EarthquakeDebrisFog


func _setup_disaster() -> void:
	disaster_name = "Earthquake"
	disaster_radius = 280.0
	damage_per_second = 5.0  # Minor damage from falling debris

	# Set main particles reference for BaseDisaster
	particles = debris_particles

	# Setup collision area for earthquake zone
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
	"""Set the camera reference for screen shake and particle positioning"""
	camera_ref = cam
	print("Earthquake: Camera set for screen shake")


func _physics_process(_delta: float) -> void:
	# Update particle container position to follow camera in physics process for smooth interpolation
	if camera_ref and particle_container:
		particle_container.global_position = camera_ref.get_screen_center_position()


func _process(delta: float) -> void:
	super._process(delta)

	# Update escalation
	escalation_timer += delta
	escalation_progress = clamp(escalation_timer / max_escalation_time, 0.0, 1.0)

	# Escalate shake intensity
	shake_intensity = lerp(initial_shake_intensity, max_shake_intensity, escalation_progress)

	# Update shake time for smooth oscillation
	shake_time += delta
	_apply_smooth_screen_shake()


func _apply_smooth_screen_shake() -> void:
	"""Apply smooth swaying screen shake using sine waves"""
	# Create smooth oscillating shake using sine waves
	var shake_x = sin(shake_time * shake_speed_x) * shake_intensity
	var shake_y = sin(shake_time * shake_speed_y) * shake_intensity * 0.7  # Slightly less vertical movement

	# Add some variation with a slower sine wave for more natural feel
	shake_x += sin(shake_time * shake_speed_x * 0.5) * shake_intensity * 0.3
	shake_y += sin(shake_time * shake_speed_y * 0.6) * shake_intensity * 0.2

	base_shake_offset = Vector2(shake_x, shake_y)

	if camera_ref:
		# Apply smooth shake to camera offset
		camera_ref.offset = base_shake_offset


func _apply_disaster_effects(delta: float) -> void:
	# Apply earthquake effects to bodies in the zone
	for body in bodies_in_zone:
		# Random chance to knock down entities
		if randf() < knockdown_chance * delta:
			if body.has_method("apply_knockdown"):
				body.apply_knockdown()

		# Apply debris damage
		if body.has_method("take_damage"):
			body.take_damage(damage_per_second * delta, "physical")


func activate() -> void:
	"""Activate the disaster (start particles, enable collision)"""
	super.activate()
	if fog_particles:
		fog_particles.emitting = true


func deactivate() -> void:
	"""Deactivate the disaster (stop particles, disable collision)"""
	super.deactivate()
	if fog_particles:
		fog_particles.emitting = false


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " entered Earthquake zone - random knockdown and debris damage")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " exited Earthquake zone")


func _exit_tree() -> void:
	"""Clean up when disaster ends"""
	# Stop emitting particles
	if debris_particles:
		debris_particles.emitting = false
	if fog_particles:
		fog_particles.emitting = false

	# Reset camera shake
	if camera_ref:
		camera_ref.offset = Vector2.ZERO
