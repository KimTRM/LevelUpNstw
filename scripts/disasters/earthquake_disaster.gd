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
var initial_debris_density: int = 400
var max_debris_density: int = 800
var shake_intensity: float = 5.0

var shake_time: float = 0.0  # Accumulated time for smooth sine wave
var shake_speed_x: float = 3.0  # Horizontal shake frequency
var shake_speed_y: float = 4.5  # Vertical shake frequency (slightly different for more natural feel)
var base_shake_offset: Vector2 = Vector2.ZERO

# Camera reference for screen shake
var camera_ref: Camera2D = null


func _setup_disaster() -> void:
	disaster_name = "Earthquake"
	disaster_radius = 280.0
	damage_per_second = 5.0  # Minor damage from falling debris

	# Particles: Falling debris (based on Steam's water droplets template)
	particles = GPUParticles2D.new()
	particles.amount = initial_debris_density
	particles.lifetime = 1.5
	particles.explosiveness = 0.2
	particles.randomness = 0.6
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	var debris_material = ParticleProcessMaterial.new()
	debris_material.particle_flag_disable_z = true
	debris_material.direction = Vector3(0, 1, 0)  # Fall down
	debris_material.spread = 60.0
	debris_material.initial_velocity_min = 50.0
	debris_material.initial_velocity_max = 100.0
	debris_material.gravity = Vector3(0, 150, 0)

	# Debris color gradient - browns, greys, dust colors
	var debris_gradient = Gradient.new()
	debris_gradient.add_point(0.0, Color(0.7, 0.6, 0.5, 1.0))   # Light sandy brown
	debris_gradient.add_point(0.3, Color(0.5, 0.4, 0.3, 1.0))   # Brown
	debris_gradient.add_point(0.6, Color(0.4, 0.4, 0.4, 0.9))   # Grey stone
	debris_gradient.add_point(1.0, Color(0.3, 0.25, 0.2, 0.0))  # Dark, fading

	var debris_gradient_texture = GradientTexture1D.new()
	debris_gradient_texture.gradient = debris_gradient
	debris_material.color_ramp = debris_gradient_texture

	debris_material.scale_min = 2.0
	debris_material.scale_max = 6.0

	debris_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	debris_material.emission_sphere_radius = disaster_radius * 0.7

	particles.process_material = debris_material
	# Add particles directly as child for smooth rendering
	add_child(particles)

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
	"""Set the camera reference for screen shake"""
	camera_ref = cam


func _process(delta: float) -> void:
	super._process(delta)

	# Update escalation
	escalation_timer += delta
	escalation_progress = clamp(escalation_timer / max_escalation_time, 0.0, 1.0)

	# Escalate shake intensity
	shake_intensity = lerp(initial_shake_intensity, max_shake_intensity, escalation_progress)

	# Escalate debris amount
	if particles:
		var new_amount = int(lerp(initial_debris_density, max_debris_density, escalation_progress))
		particles.amount = new_amount

		var debris_material = particles.process_material as ParticleProcessMaterial
		if debris_material:
			debris_material.emission_sphere_radius = disaster_radius * 0.7

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
	else:
		# Fallback: shake disaster visuals if no camera
		if particles:
			particles.position = base_shake_offset

		if collision_area:
			collision_area.position = base_shake_offset


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


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " entered Earthquake zone - random knockdown and debris damage")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " exited Earthquake zone")
