extends ComboDisaster
class_name FirestormDisaster

## Firestorm Combo Disaster - Fire + Wind
## Creates expanding tornado of fire that pulls in enemies and deals massive damage
## Visual: Swirling flames with wind particles
## Escalation: Tornado expands and intensifies

@export var pull_force: float = 150.0  # Pull entities toward center
@export var rotation_speed: float = 180.0  # Degrees per second

var initial_radius: float = 200.0
var max_radius: float = 400.0
var initial_particle_amount: int = 500
var max_particle_amount: int = 1000

var rotation_angle: float = 0.0


func _setup_disaster() -> void:
	combo_name = "Firestorm"
	disaster_name = "Firestorm"
	disaster_type_1 = "WILDFIRE"
	disaster_type_2 = "TYPHOON"
	disaster_radius = initial_radius
	damage_per_second = 20.0  # High damage for combo

	# Primary particles: Fire
	particles = GPUParticles2D.new()
	particles.amount = initial_particle_amount
	particles.lifetime = 2.0
	particles.explosiveness = 0.3
	particles.randomness = 0.7
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	var fire_material = ParticleProcessMaterial.new()
	fire_material.particle_flag_disable_z = true
	fire_material.direction = Vector3(0, -1, 0)  # Rise upward
	fire_material.spread = 180.0
	fire_material.initial_velocity_min = 80.0
	fire_material.initial_velocity_max = 150.0
	fire_material.gravity = Vector3(0, -60, 0)

	# Fire color gradient
	var fire_gradient = Gradient.new()
	fire_gradient.add_point(0.0, Color(1.0, 1.0, 0.5, 1.0))   # Bright yellow
	fire_gradient.add_point(0.4, Color(1.0, 0.4, 0.0, 1.0))   # Orange
	fire_gradient.add_point(0.8, Color(0.9, 0.0, 0.0, 0.8))   # Red
	fire_gradient.add_point(1.0, Color(0.3, 0.0, 0.0, 0.0))   # Dark, transparent

	var fire_gradient_texture = GradientTexture1D.new()
	fire_gradient_texture.gradient = fire_gradient
	fire_material.color_ramp = fire_gradient_texture

	fire_material.scale_min = 4.0
	fire_material.scale_max = 10.0

	fire_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	fire_material.emission_ring_axis = Vector3(0, 0, 1)
	fire_material.emission_ring_height = 50.0
	fire_material.emission_ring_radius = disaster_radius * 0.8
	fire_material.emission_ring_inner_radius = disaster_radius * 0.3

	particles.process_material = fire_material
	add_child(particles)

	# Secondary particles: Wind streaks
	particles_secondary = GPUParticles2D.new()
	particles_secondary.amount = 300
	particles_secondary.lifetime = 1.0
	particles_secondary.explosiveness = 0.0
	particles_secondary.randomness = 0.6

	var wind_material = ParticleProcessMaterial.new()
	wind_material.particle_flag_disable_z = true
	wind_material.direction = Vector3(1, 0, 0)
	wind_material.spread = 180.0
	wind_material.initial_velocity_min = 200.0
	wind_material.initial_velocity_max = 350.0

	# Wind color - semi-transparent white/grey with orange tint
	var wind_gradient = Gradient.new()
	wind_gradient.add_point(0.0, Color(1.0, 0.8, 0.6, 0.7))
	wind_gradient.add_point(0.5, Color(0.9, 0.7, 0.5, 0.5))
	wind_gradient.add_point(1.0, Color(0.6, 0.4, 0.3, 0.0))

	var wind_gradient_texture = GradientTexture1D.new()
	wind_gradient_texture.gradient = wind_gradient
	wind_material.color_ramp = wind_gradient_texture

	wind_material.scale_min = 3.0
	wind_material.scale_max = 7.0

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

	# Create visual overlay - orange/red tint
	create_combo_overlay(Color(1.0, 0.4, 0.0, 0.0))

	activate()


func _process(delta: float) -> void:
	super._process(delta)

	# Rotate the firestorm effect
	rotation_angle += rotation_speed * delta
	if rotation_angle >= 360.0:
		rotation_angle -= 360.0

	rotation_degrees = rotation_angle


func _update_escalation(_delta: float) -> void:
	# Escalate radius
	disaster_radius = lerp(initial_radius, max_radius, escalation_progress)

	# Update fire particles
	if particles:
		var new_amount = int(lerp(initial_particle_amount, max_particle_amount, escalation_progress))
		particles.amount = new_amount

		var fire_material = particles.process_material as ParticleProcessMaterial
		if fire_material:
			fire_material.emission_ring_radius = disaster_radius * 0.8
			fire_material.emission_ring_inner_radius = disaster_radius * 0.3

	# Update wind particles
	if particles_secondary:
		var wind_material = particles_secondary.process_material as ParticleProcessMaterial
		if wind_material:
			wind_material.emission_sphere_radius = disaster_radius

	# Update collision area
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = disaster_radius

	# Update overlay opacity
	if combo_overlay:
		combo_overlay.color.a = lerp(0.0, 0.45, escalation_progress)


func _apply_disaster_effects(delta: float) -> void:
	# Apply pull force toward center and fire damage
	for body in bodies_in_zone:
		# Pull toward center
		var direction_to_center = (global_position - body.global_position).normalized()
		var pull_strength = pull_force * escalation_progress * delta

		if body.has_method("apply_push_force"):
			body.apply_push_force(direction_to_center * pull_strength)
		elif body is CharacterBody2D:
			body.velocity += direction_to_center * pull_strength

		# Apply massive fire damage
		if body.has_method("take_damage"):
			var combo_damage = damage_per_second * combo_damage_multiplier * delta
			body.take_damage(combo_damage, "fire")


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " entered Firestorm - massive damage and pull effect!")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " escaped Firestorm")
