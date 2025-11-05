extends BaseDisaster
class_name FloodDisaster

## Flood Disaster - Tubig's Domain
## Visual: Rising water levels, reduced visibility
## Gameplay: Slows non-Tubig players, conducts electricity
## Escalation: Water level rises over time, creating isolated islands

@export var slow_multiplier: float = 0.6  # Slows movement to 60% speed
@export var water_rise_speed: float = 10.0  # How fast water level rises
@export var max_escalation_time: float = 10.0  # Time to reach max escalation

# Escalation variables
var escalation_timer: float = 0.0
var escalation_progress: float = 0.0  # 0.0 to 1.0
var initial_particle_amount: int = 600
var max_particle_amount: int = 1200

# Visual overlay for reduced visibility
var visibility_overlay: ColorRect


func _setup_disaster() -> void:
	disaster_name = "Flood"
	disaster_radius = 250.0
	damage_per_second = 0.0  # Flood doesn't deal direct damage

	# Primary particles: Water clouds (based on Steam template)
	particles = GPUParticles2D.new()
	particles.amount = initial_particle_amount
	particles.lifetime = 3.0
	particles.explosiveness = 0.1
	particles.randomness = 0.8
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	var water_material = ParticleProcessMaterial.new()
	water_material.particle_flag_disable_z = true
	water_material.direction = Vector3(0, -0.5, 0)  # Slowly rise
	water_material.spread = 180.0
	water_material.initial_velocity_min = 30.0
	water_material.initial_velocity_max = 70.0
	water_material.gravity = Vector3(0, -20, 0)  # Slight upward drift

	# Water color gradient - blues with white highlights
	var water_gradient = Gradient.new()
	water_gradient.add_point(0.0, Color(0.7, 0.9, 1.0, 0.9))   # Light blue with white
	water_gradient.add_point(0.4, Color(0.3, 0.6, 1.0, 0.8))   # Medium blue
	water_gradient.add_point(0.8, Color(0.1, 0.4, 0.8, 0.6))   # Deep blue
	water_gradient.add_point(1.0, Color(0.0, 0.2, 0.5, 0.0))   # Dark blue, transparent

	var water_gradient_texture = GradientTexture1D.new()
	water_gradient_texture.gradient = water_gradient
	water_material.color_ramp = water_gradient_texture

	water_material.scale_min = 10.0  # Large water clouds
	water_material.scale_max = 25.0

	# EMISSION SHAPE: Sphere shape similar to combo disasters
	water_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	water_material.emission_sphere_radius = disaster_radius

	particles.process_material = water_material
	# Add particles directly as child for smooth rendering
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

	# Create visibility overlay (blue tint for underwater effect)
	visibility_overlay = ColorRect.new()
	visibility_overlay.color = Color(0.2, 0.4, 0.8, 0.0)  # Start transparent
	visibility_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_overlay.z_index = 100
	# Make it cover the entire viewport
	visibility_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(visibility_overlay)

	# Activate immediately
	activate()


func _process(delta: float) -> void:
	super._process(delta)

	# Update escalation
	escalation_timer += delta
	escalation_progress = clamp(escalation_timer / max_escalation_time, 0.0, 1.0)

	# Escalate water density (particle count)
	if particles:
		var new_amount = int(lerp(initial_particle_amount, max_particle_amount, escalation_progress))
		particles.amount = new_amount

		var water_material = particles.process_material as ParticleProcessMaterial
		if water_material:
			# Increase emission radius
			disaster_radius = lerp(250.0, 400.0, escalation_progress)
			water_material.emission_sphere_radius = disaster_radius

	# Escalate visibility reduction
	if visibility_overlay:
		var max_alpha = 0.3  # Maximum 30% opacity
		visibility_overlay.color.a = lerp(0.0, max_alpha, escalation_progress)


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


