class_name NPC extends CharacterBody2D

@export var follow_distance: float = 150.0
@export var follow_speed: float = 120.0
@export var separation_distance: float = 40.0
@export var separation_force: float = 200.0
@export var stop_distance: float = 30.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D

var player: Node2D = null
var is_following: bool = false
var velocity_component: VelocityComponent
var idle_tween: Tween = null

func _ready() -> void:
	# Create velocity component for smooth movement
	velocity_component = VelocityComponent.new()
	velocity_component.max_speed = follow_speed
	velocity_component.acceleration = 15.0
	add_child(velocity_component)
	
	# Set up detection area
	if detection_shape.shape == null:
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = follow_distance
		detection_shape.shape = circle_shape
	
	# Connect signals
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)
	
	# Add to NPC group
	add_to_group("NPC")
	
	# Add slight color variation for visual distinction
	var color_variations = [
		Color(1.0, 1.0, 1.0),      # White (default)
		Color(0.9, 1.0, 0.9),      # Light green
		Color(1.0, 0.9, 0.9),      # Light red
	]
	var random_index = randi() % color_variations.size()
	sprite.modulate = color_variations[random_index]
	
	# Add subtle pulsing animation
	_start_idle_animation()

func _physics_process(delta: float) -> void:
	if not is_following or not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var desired_velocity = calculate_desired_velocity()
	
	# Apply separation from other NPCs
	var separation_velocity = calculate_separation()
	desired_velocity += separation_velocity
	
	# Update velocity component
	velocity_component.accelerate_to_velocity(desired_velocity, delta)
	velocity = velocity_component.velocity
	
	# Move the NPC
	velocity_component.move(self)
	
	# Face the direction of movement for visual polish
	if velocity.length() > 10.0:
		var angle = velocity.angle()
		sprite.rotation = lerp_angle(sprite.rotation, angle, delta * 5.0)
		# Scale up slightly when moving
		sprite.scale = sprite.scale.lerp(Vector2(1.05, 1.05), delta * 3.0)
	else:
		# Return to normal scale when idle
		sprite.scale = sprite.scale.lerp(Vector2(1.0, 1.0), delta * 3.0)

func calculate_desired_velocity() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO
	
	var direction = (player.global_position - global_position).normalized()
	var distance = global_position.distance_to(player.global_position)
	
	# Stop if too close to player
	if distance < stop_distance:
		return Vector2.ZERO
	
	# Slow down when approaching
	var speed_multiplier = 1.0
	if distance < stop_distance * 2.0:
		speed_multiplier = (distance - stop_distance) / stop_distance
	
	return direction * follow_speed * speed_multiplier

func calculate_separation() -> Vector2:
	var separation = Vector2.ZERO
	var nearby_npcs = get_tree().get_nodes_in_group("NPC")
	var count = 0
	
	for npc in nearby_npcs:
		if npc == self or not is_instance_valid(npc):
			continue
		
		var distance = global_position.distance_to(npc.global_position)
		if distance < separation_distance and distance > 0:
			var direction = (global_position - npc.global_position).normalized()
			var force = (separation_distance - distance) / separation_distance
			separation += direction * force
			count += 1
	
	if count > 0:
		separation /= count
		separation = separation.normalized() * separation_force
	
	return separation

func _on_player_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		is_following = true
		# Stop idle animation
		if idle_tween:
			idle_tween.kill()
			idle_tween = null
		# Visual feedback - slightly scale up
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.2)

func _on_player_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		is_following = false
		player = null
		# Visual feedback - scale back and return to idle
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
		_start_idle_animation()

func _start_idle_animation() -> void:
	# Stop any existing idle animation
	if idle_tween:
		idle_tween.kill()
	# Reset alpha to full
	sprite.modulate.a = 1.0
	# Subtle pulsing when idle
	idle_tween = create_tween().set_loops()
	idle_tween.tween_property(sprite, "modulate:a", 0.85, 1.5)
	idle_tween.tween_property(sprite, "modulate:a", 1.0, 1.5)

