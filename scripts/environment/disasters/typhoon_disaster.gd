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

var current_wind_direction: Vector2 = Vector2.ZERO
var target_wind_direction: Vector2 = Vector2.ZERO
var wind_timer: float = 0.0
var wind_transition_speed: float = 2.0

# Camera reference for positioning particles
var camera_ref: Camera2D = null

# Get particle reference from scene
@onready var wind_particles: CPUParticles2D = $WindParticles


func _setup_disaster() -> void:
	disaster_name = "Typhoon"
	disaster_radius = 300.0
	damage_per_second = 3.0  # Minor damage from flying debris

	# Initialize random wind direction
	_update_wind_direction()

	# Set particles reference for BaseDisaster
	particles = wind_particles

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

	# Activate immediately
	activate()


func set_camera(cam: Camera2D) -> void:
	"""Set the camera reference for positioning particles"""
	camera_ref = cam
	print("Typhoon: Camera set for particle positioning")


func _physics_process(_delta: float) -> void:
	# Update particle position to follow camera in physics process for smooth interpolation
	if camera_ref and wind_particles:
		wind_particles.global_position = camera_ref.get_screen_center_position()


func _process(delta: float) -> void:
	super._process(delta)

	# Update escalation
	escalation_timer += delta
	escalation_progress = clamp(escalation_timer / max_escalation_time, 0.0, 1.0)

	# Escalate wind force
	wind_force = lerp(initial_wind_force, max_wind_force, escalation_progress)

	# Smooth wind direction transitions
	current_wind_direction = current_wind_direction.lerp(target_wind_direction, delta * wind_transition_speed)

	# Update wind direction periodically
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


func _apply_disaster_effects(_delta: float) -> void:
	# Apply wind push and damage to bodies in the typhoon zone
	for body in bodies_in_zone:
		# Apply wind push force
		if body.has_method("apply_push_force"):
			body.apply_push_force(current_wind_direction * wind_force * _delta)
		elif body is CharacterBody2D:
			# Direct velocity manipulation if no method exists
			body.velocity += current_wind_direction * wind_force * _delta

		# Apply minor debris damage
		if body.has_method("take_damage"):
			body.take_damage(damage_per_second * _delta, "wind")


func _on_body_enter_zone(body: Node2D) -> void:
	print(body.name, " entered Typhoon zone - wind pushing and debris damage")


func _on_body_exit_zone(body: Node2D) -> void:
	print(body.name, " exited Typhoon zone")


func get_current_wind_direction() -> Vector2:
	"""Returns the current wind direction vector"""
	return current_wind_direction
