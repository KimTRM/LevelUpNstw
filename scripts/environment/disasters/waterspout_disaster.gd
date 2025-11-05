extends ComboDisaster
class_name WaterspoutDisaster

## Waterspout Combo Disaster - Wind + Water
## Generates waterspout with strong knockback effects
## Visual: Swirling water and wind particles in a vortex
## Escalation: Knockback force increases, vortex expands

@export var knockback_force: float = 300.0
@export var rotation_speed: float = 240.0  # Faster than firestorm

var initial_radius: float = 220.0
var max_radius: float = 380.0
var initial_particle_amount: int = 550
var max_particle_amount: int = 1100

var rotation_angle: float = 0.0
var vortex_direction: Vector2 = Vector2.ZERO
var direction_timer: float = 0.0


func _setup_disaster() -> void:
	combo_name = "Waterspout"
	disaster_name = "Waterspout"
	disaster_type_1 = "TYPHOON"
	disaster_type_2 = "FLOOD"
	disaster_radius = initial_radius
	damage_per_second = 15.0  # Moderate-high damage

	# Initialize random vortex push direction
	_update_vortex_direction()

	# Primary particles: Water vortex
	particles = GPUParticles2D.new()
	particles.amount = initial_particle_amount
	particles.lifetime = 2.0
	particles.explosiveness = 0.2
	particles.randomness = 0.6
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	var water_material = ParticleProcessMaterial.new()
	water_material.particle_flag_disable_z = true
	water_material.direction = Vector3(0, -0.3, 0)  # Slight upward spiral
	water_material.spread = 160.0
	water_material.initial_velocity_min = 100.0
	water_material.initial_velocity_max = 200.0
	water_material.gravity = Vector3(0, 20, 0)  # Slight downward pull

	# Tangential acceleration for spiral effect
	water_material.tangential_accel_min = 50.0
	water_material.tangential_accel_max = 100.0

	# Water vortex color gradient - blues with white foam
	var water_gradient = Gradient.new()
	water_gradient.add_point(0.0, Color(0.8, 0.9, 1.0, 1.0))   # White foam
	water_gradient.add_point(0.3, Color(0.4, 0.7, 1.0, 0.9))   # Light blue
	water_gradient.add_point(0.7, Color(0.1, 0.4, 0.8, 0.7))   # Deep blue
	water_gradient.add_point(1.0, Color(0.0, 0.2, 0.5, 0.0))   # Dark blue, transparent

	var water_gradient_texture = GradientTexture1D.new()
	water_gradient_texture.gradient = water_gradient
	water_material.color_ramp = water_gradient_texture

	water_material.scale_min = 4.0
	water_material.scale_max = 12.0

	water_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	water_material.emission_ring_axis = Vector3(0, 0, 1)
	water_material.emission_ring_height = 100.0
	water_material.emission_ring_radius = disaster_radius * 0.9
	water_material.emission_ring_inner_radius = disaster_radius * 0.2

	particles.process_material = water_material
	add_child(particles)

	# Secondary particles: Wind and spray
	particles_secondary = GPUParticles2D.new()
	particles_secondary.amount = 350
	particles_secondary.lifetime = 1.2

	var wind_material = ParticleProcessMaterial.new()
	wind_material.particle_flag_disable_z = true
	wind_material.direction = Vector3(1, 0, 0)
	wind_material.spread = 180.0
	wind_material.initial_velocity_min = 150.0
	wind_material.initial_velocity_max = 300.0

	# Wind spray color - white/grey with blue tint
	var spray_gradient = Gradient.new()
	spray_gradient.add_point(0.0, Color(0.9, 0.95, 1.0, 0.8))
	spray_gradient.add_point(0.5, Color(0.7, 0.8, 0.9, 0.6))
	spray_gradient.add_point(1.0, Color(0.5, 0.6, 0.8, 0.0))

	var spray_gradient_texture = GradientTexture1D.new()
	spray_gradient_texture.gradient = spray_gradient
	wind_material.color_ramp = spray_gradient_texture

	wind_material.scale_min = 3.0
	wind_material.scale_max = 8.0

	wind_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	wind_material.emission_sphere_radius = disaster_radius

	particles_secondary.process_material = wind_material
	add_child(particles_secondary)

	# Setup collision area
	collision_area = Area2D.new()
	collision_shape = CollisionShape2D.new()

	var circle_shape = CircleShape2D.new()
	circle_shape.radius = disaster_radius

	collision_shape.shape = circle_shape
	collision_area.add_child(collision_shape)
	add_child(collision_area)

	collision_area.body_entered.connect(_on_area_entered)
	collision_area.body_exited.connect(_on_area_exited)

	# Create visual overlay - blue/white tint
	create_combo_overlay(Color(0.5, 0.7, 1.0, 0.0))

	activate()


func _process(delta: float) -> void:
	super._process(delta)

	# Rotate the waterspout
	rotation_angle += rotation_speed * delta
	if rotation_angle >= 360.0:
		rotation_angle -= 360.0

	rotation_degrees = rotation_angle

	# Update knockback direction periodically
	direction_timer += delta
	if direction_timer >= 0.8:
		direction_timer = 0.0
		_update_vortex_direction()


func _update_vortex_direction() -> void:
	"""Update the knockback direction randomly"""
	var angle = randf() * TAU
	vortex_direction = Vector2(cos(angle), sin(angle))


func _update_escalation(_delta: float) -> void:
	# Escalate radius
	disaster_radius = lerp(initial_radius, max_radius, escalation_progress)

	# Update water particles
	if particles:
		var new_amount = int(lerp(initial_particle_amount, max_particle_amount, escalation_progress))
		particles.amount = new_amount

		var water_material = particles.process_material as ParticleProcessMaterial
		if water_material:
			water_material.emission_ring_radius = disaster_radius * 0.9
			water_material.emission_ring_inner_radius = disaster_radius * 0.2

	# Update wind particles
	if particles_secondary:
		var wind_material = particles_secondary.process_material as ParticleProcessMaterial
		if wind_material:
			wind_material.emission_sphere_radius = disaster_radius
			# Increase wind speed
			var speed_mult = 1.0 + escalation_progress * 0.5
			wind_material.initial_velocity_min = 150.0 * speed_mult
			wind_material.initial_velocity_max = 300.0 * speed_mult

	# Update collision area
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = disaster_radius

	# Update overlay opacity
	if combo_overlay:
		combo_overlay.color.a = lerp(0.0, 0.4, escalation_progress)


func _apply_disaster_effects(delta: float) -> void:
	# Apply strong knockback and water damage
	for body in bodies_in_zone:
		# Apply knockback in vortex direction
		var knockback_strength = knockback_force * (1.0 + escalation_progress) * delta

		if body.has_method("apply_push_force"):
			body.apply_push_force(vortex_direction * knockback_strength)
		elif body is CharacterBody2D:
			body.velocity += vortex_direction * knockback_strength

		# Apply water damage
		if body.has_method("take_damage"):
			var water_damage = damage_per_second * combo_damage_multiplier * delta
			body.take_damage(water_damage, "water")


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " caught in Waterspout - strong knockback!")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " escaped Waterspout")
