extends ComboDisaster
class_name SteamDisaster

## Steam Combo Disaster - Fire + Water
## Creates concealing steam cloud that obscures vision heavily
## Visual: Thick white/grey steam particles
## Escalation: Steam density increases, vision becomes nearly zero

var initial_particle_amount: int = 600
var max_particle_amount: int = 1200
var initial_radius: float = 250.0
var max_radius: float = 400.0


func _setup_disaster() -> void:
	combo_name = "Steam"
	disaster_name = "Steam"
	disaster_type_1 = "WILDFIRE"
	disaster_type_2 = "FLOOD"
	disaster_radius = initial_radius
	damage_per_second = 8.0  # Moderate damage from hot steam

	# Primary particles: Steam clouds
	particles = GPUParticles2D.new()
	particles.amount = initial_particle_amount
	particles.lifetime = 3.0
	particles.explosiveness = 0.1
	particles.randomness = 0.8
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	var steam_material = ParticleProcessMaterial.new()
	steam_material.particle_flag_disable_z = true
	steam_material.direction = Vector3(0, -0.5, 0)  # Slowly rise
	steam_material.spread = 180.0
	steam_material.initial_velocity_min = 30.0
	steam_material.initial_velocity_max = 70.0
	steam_material.gravity = Vector3(0, -20, 0)  # Slight upward drift

	# Steam color gradient - white to grey, very opaque
	var steam_gradient = Gradient.new()
	steam_gradient.add_point(0.0, Color(1.0, 1.0, 1.0, 0.9))   # Dense white
	steam_gradient.add_point(0.5, Color(0.85, 0.85, 0.9, 0.8)) # Light grey
	steam_gradient.add_point(1.0, Color(0.6, 0.6, 0.7, 0.0))   # Fading grey

	var steam_gradient_texture = GradientTexture1D.new()
	steam_gradient_texture.gradient = steam_gradient
	steam_material.color_ramp = steam_gradient_texture

	steam_material.scale_min = 10.0  # Large steam clouds
	steam_material.scale_max = 25.0

	steam_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	steam_material.emission_sphere_radius = disaster_radius

	particles.process_material = steam_material
	add_child(particles)

	# Secondary particles: Water droplets condensing
	particles_secondary = GPUParticles2D.new()
	particles_secondary.amount = 200
	particles_secondary.lifetime = 1.5

	var water_material = ParticleProcessMaterial.new()
	water_material.particle_flag_disable_z = true
	water_material.direction = Vector3(0, 1, 0)  # Fall down
	water_material.spread = 60.0
	water_material.initial_velocity_min = 50.0
	water_material.initial_velocity_max = 100.0
	water_material.gravity = Vector3(0, 150, 0)

	# Water droplet color
	var water_gradient = Gradient.new()
	water_gradient.add_point(0.0, Color(0.7, 0.8, 1.0, 0.7))
	water_gradient.add_point(1.0, Color(0.4, 0.5, 0.8, 0.0))

	var water_gradient_texture = GradientTexture1D.new()
	water_gradient_texture.gradient = water_gradient
	water_material.color_ramp = water_gradient_texture

	water_material.scale_min = 2.0
	water_material.scale_max = 4.0

	water_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	water_material.emission_sphere_radius = disaster_radius * 0.7

	particles_secondary.process_material = water_material
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

	# Create visual overlay - very dense white/grey for heavy vision obscuring
	create_combo_overlay(Color(0.9, 0.9, 0.95, 0.0))

	activate()


func _update_escalation(_delta: float) -> void:
	# Escalate steam density (particle count)
	if particles:
		var new_amount = int(lerp(initial_particle_amount, max_particle_amount, escalation_progress))
		particles.amount = new_amount

		var steam_material = particles.process_material as ParticleProcessMaterial
		if steam_material:
			# Increase emission radius
			disaster_radius = lerp(initial_radius, max_radius, escalation_progress)
			steam_material.emission_sphere_radius = disaster_radius

	# Update collision area
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = disaster_radius

	# Escalate vision obscuring - HEAVY overlay
	if combo_overlay:
		var max_alpha = 0.65  # Very high opacity for near-total blindness
		combo_overlay.color.a = lerp(0.0, max_alpha, escalation_progress)


func _apply_disaster_effects(delta: float) -> void:
	# Apply steam burn damage
	for body in bodies_in_zone:
		if body.has_method("take_damage"):
			var steam_damage = damage_per_second * combo_damage_multiplier * delta
			body.take_damage(steam_damage, "heat")


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " entered Steam cloud - vision heavily obscured!")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " exited Steam cloud")
