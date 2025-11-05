extends BaseDisaster
class_name EarthquakeDisaster

## Earthquake Disaster - Lupa's Domain
## Visual: Screen shake, falling debris
## Gameplay: Random knockdown, terrain changes
## Escalation: Chasms open, buildings collapse

@export var shake_intensity: float = 10.0
@export var knockdown_chance: float = 0.3  # 30% chance per second
@export var debris_density: int = 150

var shake_timer: float = 0.0
var shake_frequency: float = 0.1  # Shake every 0.1 seconds


func _setup_disaster() -> void:
	disaster_name = "Earthquake"
	disaster_radius = 280.0
	damage_per_second = 5.0  # Minor damage from falling debris

	# Setup particles for falling debris
	particles = GPUParticles2D.new()
	particles.amount = debris_density
	particles.lifetime = 2.0
	particles.explosiveness = 0.2
	particles.randomness = 0.7
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	# Create particle process material for debris
	var material = ParticleProcessMaterial.new()

	# Debris particle settings - brown/grey rocks
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, 1, 0)  # Fall downward
	material.spread = 30.0
	material.initial_velocity_min = 100.0
	material.initial_velocity_max = 200.0
	material.gravity = Vector3(0, 400, 0)  # Strong gravity for rocks

	# Angular velocity for tumbling debris
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0

	# Color gradient for debris - browns and greys
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.5, 0.4, 0.3, 1.0))   # Brown
	gradient.add_point(0.5, Color(0.4, 0.4, 0.4, 1.0))   # Grey
	gradient.add_point(1.0, Color(0.3, 0.25, 0.2, 0.6))  # Dark brown, fading

	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	# Scale variation for different sized debris
	material.scale_min = 4.0
	material.scale_max = 10.0

	particles.process_material = material

	# Emission shape - rectangle for debris falling from above
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(disaster_radius, 20, 0)

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


func _process(delta: float) -> void:
	super._process(delta)

	# Update shake timer
	shake_timer += delta
	if shake_timer >= shake_frequency:
		shake_timer = 0.0
		_apply_screen_shake()


func _apply_screen_shake() -> void:
	"""Apply screen shake effect by offsetting the disaster position slightly"""
	# Random offset for shake effect
	var shake_offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)

	# Apply shake to particles and collision area
	if particles:
		particles.position = shake_offset

	if collision_area:
		collision_area.position = shake_offset


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
