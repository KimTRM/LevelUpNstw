extends BaseDisaster
class_name FloodDisaster

## Flood Disaster - Tubig's Domain
## Visual: Rising water levels, reduced visibility
## Gameplay: Slows non-Tubig players, conducts electricity
## Escalation: Water level rises over time, creating isolated islands

@export var slow_multiplier: float = 0.6  # Slows movement to 60% speed
@export var water_rise_speed: float = 10.0  # How fast water level rises


func _setup_disaster() -> void:
	disaster_name = "Flood"
	disaster_radius = 250.0
	damage_per_second = 0.0  # Flood doesn't deal direct damage

	# Setup particles for water effect
	particles = GPUParticles2D.new()
	particles.amount = 200
	particles.lifetime = 2.0
	particles.explosiveness = 0.0
	particles.randomness = 0.5
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	# Create particle process material for water droplets
	var material = ParticleProcessMaterial.new()

	# Water particle settings - blue color
	material.particle_flag_disable_z = true
	material.direction = Vector3(0, 1, 0)  # Fall downward
	material.spread = 180.0
	material.initial_velocity_min = 20.0
	material.initial_velocity_max = 50.0
	material.gravity = Vector3(0, 98, 0)

	# Color gradient for water - shades of blue
	var gradient = Gradient.new()
	gradient.set_color(0, Color(0.2, 0.5, 1.0, 0.8))  # Light blue
	gradient.set_color(1, Color(0.0, 0.3, 0.7, 0.3))  # Darker blue, more transparent

	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	# Scale variation
	material.scale_min = 2.0
	material.scale_max = 5.0

	particles.process_material = material

	# Emission shape - circle
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = disaster_radius

	add_child(particles)

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


func _apply_disaster_effects(delta: float) -> void:
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
