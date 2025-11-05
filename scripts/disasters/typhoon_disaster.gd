extends BaseDisaster
class_name TyphoonDisaster

## Typhoon Disaster - Hangin's Domain
## Visual: High winds, debris storms
## Gameplay: Pushes players and projectiles randomly
## Escalation: Wind speed increases, visibility decreases

@export var initial_wind_force: float = 100.0
@export var max_wind_force: float = 400.0
@export var wind_change_interval: float = 0.5  # Change direction every 0.5 seconds
@export var max_escalation_time: float = 10.0  # Time to reach max escalation

# Escalation variables
var escalation_timer: float = 0.0
var escalation_progress: float = 0.0  # 0.0 to 1.0
var wind_force: float = 100.0
var initial_particle_amount: int = 550
var max_particle_amount: int = 1100

var current_wind_direction: Vector2 = Vector2.ZERO
var target_wind_direction: Vector2 = Vector2.ZERO  # For smooth transitions
var wind_timer: float = 0.0
var wind_transition_speed: float = 2.0  # How fast wind direction changes

# Visual overlay for debris/reduced visibility
var debris_overlay: ColorRect


func _setup_disaster() -> void:
	disaster_name = "Typhoon"
	disaster_radius = 300.0
	damage_per_second = 3.0  # Minor damage from flying debris

	# Initialize random wind direction
	_update_wind_direction()

	# Primary particles: Wind vortex (based on Waterspout template)
	particles = GPUParticles2D.new()
	particles.amount = initial_particle_amount
	particles.lifetime = 2.0
	particles.explosiveness = 0.2
	particles.randomness = 0.6
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	var wind_material = ParticleProcessMaterial.new()
	wind_material.particle_flag_disable_z = true
	wind_material.direction = Vector3(0, -0.3, 0)  # Slight upward spiral
	wind_material.spread = 160.0
	wind_material.initial_velocity_min = 100.0
	wind_material.initial_velocity_max = 200.0
	wind_material.gravity = Vector3(0, 20, 0)  # Slight downward pull

	# Tangential acceleration for spiral effect
	wind_material.tangential_accel_min = 50.0
	wind_material.tangential_accel_max = 100.0

	# Wind color gradient - white/grey with slight motion blur effect
	var wind_gradient = Gradient.new()
	wind_gradient.add_point(0.0, Color(1.0, 1.0, 1.0, 0.8))   # Bright white
	wind_gradient.add_point(0.3, Color(0.85, 0.85, 0.9, 0.7)) # Light grey
	wind_gradient.add_point(0.7, Color(0.6, 0.6, 0.65, 0.4))  # Medium grey
	wind_gradient.add_point(1.0, Color(0.4, 0.4, 0.45, 0.0))  # Dark grey, transparent

	var wind_gradient_texture = GradientTexture1D.new()
	wind_gradient_texture.gradient = wind_gradient
	wind_material.color_ramp = wind_gradient_texture

	wind_material.scale_min = 4.0
	wind_material.scale_max = 12.0

	wind_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	wind_material.emission_ring_axis = Vector3(0, 0, 1)
	wind_material.emission_ring_height = 100.0
	wind_material.emission_ring_radius = disaster_radius * 0.9
	wind_material.emission_ring_inner_radius = disaster_radius * 0.2

	particles.process_material = wind_material
	# Add particles directly as child for smooth rendering
	add_child(particles)

	# Setup collision area for typhoon zone
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

	# Create debris overlay (grey for obscured visibility)
	debris_overlay = ColorRect.new()
	debris_overlay.color = Color(0.5, 0.5, 0.5, 0.0)  # Start transparent
	debris_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	debris_overlay.z_index = 100
	debris_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(debris_overlay)

	# Activate immediately
	activate()


func _process(delta: float) -> void:
	super._process(delta)

	# Update escalation
	escalation_timer += delta
	escalation_progress = clamp(escalation_timer / max_escalation_time, 0.0, 1.0)

	# Escalate wind force
	wind_force = lerp(initial_wind_force, max_wind_force, escalation_progress)

	# Escalate radius
	disaster_radius = lerp(300.0, 480.0, escalation_progress)

	# Update wind particles
	if particles:
		var new_amount = int(lerp(initial_particle_amount, max_particle_amount, escalation_progress))
		particles.amount = new_amount

		var wind_material = particles.process_material as ParticleProcessMaterial
		if wind_material:
			wind_material.emission_ring_radius = disaster_radius * 0.9
			wind_material.emission_ring_inner_radius = disaster_radius * 0.2

	# Update collision area
	if collision_shape and collision_shape.shape is CircleShape2D:
		(collision_shape.shape as CircleShape2D).radius = disaster_radius

	# Escalate visibility reduction
	if debris_overlay:
		var max_alpha = 0.35  # Maximum 35% opacity
		debris_overlay.color.a = lerp(0.0, max_alpha, escalation_progress)

	# SMOOTH WIND DIRECTION: Lerp between directions instead of instant changes
	current_wind_direction = current_wind_direction.lerp(target_wind_direction, delta * wind_transition_speed)

	# Update particle direction smoothly
	if particles and particles.process_material:
		var wind_material = particles.process_material as ParticleProcessMaterial
		wind_material.direction = Vector3(current_wind_direction.x, current_wind_direction.y, 0)

	# Update wind direction target periodically
	wind_timer += delta
	if wind_timer >= wind_change_interval:
		wind_timer = 0.0
		_update_wind_direction()


func _update_wind_direction() -> void:
	"""Update the target wind direction randomly (actual direction lerps to it)"""
	var angle = randf() * TAU  # Random angle
	target_wind_direction = Vector2(cos(angle), sin(angle))

	# Initialize current direction on first call
	if current_wind_direction == Vector2.ZERO:
		current_wind_direction = target_wind_direction


func _apply_disaster_effects(delta: float) -> void:
	# Apply wind push and damage to bodies in the typhoon zone
	for body in bodies_in_zone:
		# Apply wind push force
		if body.has_method("apply_push_force"):
			body.apply_push_force(current_wind_direction * wind_force * delta)
		elif body is CharacterBody2D:
			# Direct velocity manipulation if no method exists
			body.velocity += current_wind_direction * wind_force * delta

		# Apply minor debris damage
		if body.has_method("take_damage"):
			body.take_damage(damage_per_second * delta, "wind")


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " entered Typhoon zone - wind pushing and debris damage")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " exited Typhoon zone")


func get_current_wind_direction() -> Vector2:
	"""Returns the current wind direction vector"""
	return current_wind_direction
