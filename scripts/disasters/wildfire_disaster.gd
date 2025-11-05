extends BaseDisaster
class_name WildfireDisaster

## Wildfire Disaster - Apoy's Domain
## Visual: Spreading flames, smoke effects
## Gameplay: Damages all players except Apoy over time
## Escalation: Fire spreads to new areas, creating walls of flame

@export var fire_damage_per_second: float = 10.0


func _setup_disaster() -> void:
	disaster_name = "Wildfire"
	disaster_radius = 220.0
	damage_per_second = fire_damage_per_second

	# Setup particles for fire effect
	particles = GPUParticles2D.new()
	particles.amount = 300
	particles.lifetime = 1.5
	particles.explosiveness = 0.1
	particles.randomness = 0.6
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	# Create particle process material for flames
	var material = ParticleProcessMaterial.new()

	# Fire particle settings - orange/red/yellow
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, -1, 0)  # Rise upward
	material.spread = 45.0
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.gravity = Vector3(0, -80, 0)  # Negative gravity for flames rising

	# Color gradient for fire - orange to red to dark
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 1.0, 0.3, 1.0))   # Bright yellow
	gradient.add_point(0.3, Color(1.0, 0.5, 0.0, 1.0))   # Orange
	gradient.add_point(0.7, Color(0.8, 0.1, 0.0, 0.8))   # Red
	gradient.add_point(1.0, Color(0.2, 0.0, 0.0, 0.0))   # Dark red, transparent

	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	# Scale variation - flames grow as they rise
	material.scale_min = 3.0
	material.scale_max = 8.0
	material.scale_curve = _create_scale_curve()

	particles.process_material = material

	# Emission shape - circle
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = disaster_radius

	add_child(particles)

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


func _create_scale_curve() -> Curve:
	"""Create a curve for flames that grow as they rise"""
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0.3))
	curve.add_point(Vector2(0.5, 1.0))
	curve.add_point(Vector2(1, 0.5))
	return curve


func _apply_disaster_effects(delta: float) -> void:
	# Apply fire damage to bodies in the wildfire zone
	for body in bodies_in_zone:
		# TODO: Check if body is Apoy (fire elemental) - they should be immune
		if body.has_method("take_damage"):
			body.take_damage(fire_damage_per_second * delta, "fire")


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " entered Wildfire zone - taking fire damage")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " exited Wildfire zone")
