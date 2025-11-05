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
var initial_particle_amount: int = 500
var max_particle_amount: int = 1000

# Visual overlay for smoke
var smoke_overlay: ColorRect


func _setup_disaster() -> void:
	disaster_name = "Wildfire"
	disaster_radius = initial_radius
	damage_per_second = fire_damage_per_second

	# Primary particles: Fire (based on Firestorm template)
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

	# EMISSION SHAPE: Ring shape similar to combo disasters
	fire_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	fire_material.emission_ring_axis = Vector3(0, 0, 1)
	fire_material.emission_ring_height = 50.0
	fire_material.emission_ring_radius = disaster_radius * 0.8
	fire_material.emission_ring_inner_radius = disaster_radius * 0.3

	particles.process_material = fire_material
	# Add particles directly as child for smooth rendering
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

	# Update fire particles
	if particles:
		var new_amount = int(lerp(initial_particle_amount, max_particle_amount, escalation_progress))
		particles.amount = new_amount

		var fire_material = particles.process_material as ParticleProcessMaterial
		if fire_material:
			fire_material.emission_ring_radius = disaster_radius * 0.8
			fire_material.emission_ring_inner_radius = disaster_radius * 0.3

	# Update collision area radius
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = disaster_radius

	# Escalate smoke visibility reduction
	if smoke_overlay:
		var max_alpha = 0.4  # Maximum 40% opacity for thick smoke
		smoke_overlay.color.a = lerp(0.0, max_alpha, escalation_progress)


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
