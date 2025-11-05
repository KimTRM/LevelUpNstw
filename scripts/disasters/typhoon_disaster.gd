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
var initial_particle_amount: int = 400
var max_particle_amount: int = 800

var current_wind_direction: Vector2 = Vector2.ZERO
var wind_timer: float = 0.0

# Visual overlay for debris/reduced visibility
var debris_overlay: ColorRect


func _setup_disaster() -> void:
	disaster_name = "Typhoon"
	disaster_radius = 300.0
	damage_per_second = 3.0  # Minor damage from flying debris

	# Initialize random wind direction
	_update_wind_direction()

	# Setup particles for wind and debris
	particles = GPUParticles2D.new()
	particles.amount = initial_particle_amount
	particles.lifetime = 1.5
	particles.explosiveness = 0.0
	particles.randomness = 0.8
	particles.visibility_rect = Rect2(-disaster_radius, -disaster_radius, disaster_radius * 2, disaster_radius * 2)

	# Create particle process material for wind debris
	var material = ParticleProcessMaterial.new()

	# Wind particle settings - white/grey streaks
	material.particle_flag_disable_z = true
	material.direction = Vector3(1, 0, 0)  # Will be dynamic
	material.spread = 20.0
	material.initial_velocity_min = 150.0
	material.initial_velocity_max = 300.0
	material.gravity = Vector3(0, 0, 0)  # No gravity for wind

	# Damping to simulate air resistance
	material.damping_min = 10.0
	material.damping_max = 20.0

	# Color gradient for wind - white to grey, semi-transparent
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1.0, 1.0, 1.0, 0.8))   # Bright white
	gradient.add_point(0.5, Color(0.7, 0.7, 0.7, 0.6))   # Light grey
	gradient.add_point(1.0, Color(0.4, 0.4, 0.4, 0.0))   # Dark grey, transparent

	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture

	# Scale variation for wind streaks
	material.scale_min = 2.0
	material.scale_max = 6.0

	particles.process_material = material

	# Emission shape - sphere for omnidirectional wind
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = disaster_radius

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

	# Escalate particle count (more debris)
	if particles:
		var new_amount = int(lerp(initial_particle_amount, max_particle_amount, escalation_progress))
		particles.amount = new_amount

		# Increase particle speed
		var material = particles.process_material as ParticleProcessMaterial
		if material:
			var speed_multiplier = 1.0 + escalation_progress
			material.initial_velocity_min = 150.0 * speed_multiplier
			material.initial_velocity_max = 300.0 * speed_multiplier

	# Escalate visibility reduction
	if debris_overlay:
		var max_alpha = 0.35  # Maximum 35% opacity
		debris_overlay.color.a = lerp(0.0, max_alpha, escalation_progress)

	# Update wind direction periodically
	wind_timer += delta
	if wind_timer >= wind_change_interval:
		wind_timer = 0.0
		_update_wind_direction()


func _update_wind_direction() -> void:
	"""Update the wind direction randomly"""
	var angle = randf() * TAU  # Random angle
	current_wind_direction = Vector2(cos(angle), sin(angle))

	# Update particle direction
	if particles and particles.process_material:
		var material = particles.process_material as ParticleProcessMaterial
		material.direction = Vector3(current_wind_direction.x, current_wind_direction.y, 0)


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
