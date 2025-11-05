class_name NPC extends CharacterBody2D

# pasensya na kim magulo code ko , inayos as far possible 


@export var follow_distance: float = 150.0
@export var follow_speed: float = 120.0
@export var separation_distance: float = 40.0
@export var separation_force: float = 200.0
@export var stop_distance: float = 30.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var dialogue_label: Label = $Dialogue
@onready var dialogue_timer: Timer = $DialogueTimer

var player: Node2D = null
var is_following: bool = false
var velocity_component: VelocityComponent
var idle_tween: Tween = null
var last_player_direction: Vector2 = Vector2.DOWN

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
	
	# detection kapag nasa area na 
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)
	dialogue_timer.timeout.connect(func():
		if is_instance_valid(dialogue_label):
			dialogue_label.visible = false)

	add_to_group("NPC")

	var color_variations = [
		Color(1.0, 1.0, 1.0),      # White
		Color(0.9, 1.0, 0.9),      # Light green
		Color(1.0, 0.9, 0.9),      # Light red
	]
	var random_index = randi() % color_variations.size()
	sprite.modulate = color_variations[random_index]
	
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
	velocity_component.move(self)

	if velocity.length() > 10.0:
		var angle = velocity.angle()
		sprite.rotation = lerp_angle(sprite.rotation, angle, delta * 5.0)

func calculate_desired_velocity() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO

	# Follow slightly behind the Chacter behind the palyerssf
	var target_position: Vector2 = player.global_position
	if player is CharacterBody2D:
		var pv: Vector2 = (player as CharacterBody2D).velocity
		if pv.length() > 0.1:
			last_player_direction = pv.normalized()
		target_position = player.global_position - last_player_direction * 20.0

	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	# Stop if too close to player
	if distance < stop_distance:
		return Vector2.ZERO
	
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
		# Stop idle npc 
		if idle_tween:
			idle_tween.kill()
			idle_tween = null
		# Optional dialogue npc
		if is_instance_valid(dialogue_label):
			dialogue_label.visible = true
			dialogue_label.text = "Thank you!"
			dialogue_timer.start()
		# Show brief dialogue
		if is_instance_valid(dialogue_label):
			dialogue_label.visible = true
			dialogue_label.text = "Thank you!"
			dialogue_timer.start()

func _on_player_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		pass

func _start_idle_animation() -> void:

	if idle_tween:
		idle_tween.kill()

	sprite.modulate.a = 1.0

	idle_tween = create_tween().set_loops()
	idle_tween.tween_property(sprite, "modulate:a", 0.85, 1.5)
	idle_tween.tween_property(sprite, "modulate:a", 1.0, 1.5)