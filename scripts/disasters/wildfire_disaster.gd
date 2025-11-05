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
var initial_particle_amount: int = 300
var max_particle_amount: int = 600

# Visual overlay for smoke
var smoke_overlay: ColorRect


func _setup_disaster() -> void:
	disaster_name = "Wildfire"
	disaster_radius = initial_radius
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

	# Create smoke overlay (dark grey/brown for smoke)
	smoke_overlay = ColorRect.new()
	smoke_overlay.color = Color(0.3, 0.2, 0.2, 0.0)  # Start transparent
	smoke_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	smoke_overlay.z_index = 100
	smoke_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(smoke_overlay)

	# Activate immediately
	activate()


func _process(delta: float) -> void:
	super._process(delta)

	# Update escalation
	escalation_timer += delta
	escalation_progress = clamp(escalation_timer / max_escalation_time, 0.0, 1.0)

	# Escalate fire spread (increase radius and particle count)
	disaster_radius = lerp(initial_radius, max_radius, escalation_progress)

	if particles:
		var new_amount = int(lerp(initial_particle_amount, max_particle_amount, escalation_progress))
		particles.amount = new_amount

		# Update emission radius
		var material = particles.process_material as ParticleProcessMaterial
		if material:
			material.emission_sphere_radius = disaster_radius

	# Update collision area radius
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = disaster_radius

	# Escalate smoke visibility reduction
	if smoke_overlay:
		var max_alpha = 0.4  # Maximum 40% opacity for thick smoke
		smoke_overlay.color.a = lerp(0.0, max_alpha, escalation_progress)


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
