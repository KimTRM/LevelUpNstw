class_name NPC extends CharacterBody2D

@onready var base_sprite_2d: Sprite2D = $Base/BaseSprite2D
@onready var clothes_sprite_2d: Sprite2D = $Clothes/ClothesSprite2D
@onready var base_animation_player: AnimationPlayer = $Base/BaseAnimationPlayer
@onready var clothes_animation_player: AnimationPlayer = $Clothes/ClothesAnimationPlayer
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var interactable_area: InteractableArea = $InteractableArea

@export var skin_color: Color = Color(0.945, 0.706, 0.478)
@export var follow_distance: float = 150.0
@export var follow_speed: float = 120.0
@export var separation_distance: float = 40.0
@export var separation_force: float = 200.0
@export var stop_distance: float = 30.0

var state_machine: CallableStateMachine = CallableStateMachine.new()
var player: Player = null
var last_player_direction: Vector2 = Vector2.DOWN
var is_following: bool = false

# ===== INITIALIZATION =====

func _ready() -> void:
	base_sprite_2d.modulate = skin_color
	velocity_component.max_speed = follow_speed
	interactable_area.interacted.connect(_on_interacted)
	
	_setup_state_machine()

func _setup_state_machine() -> void:
	state_machine.add_states(idle_state)
	state_machine.add_states(follow_state)
	state_machine.set_initial_state(idle_state)

# ===== UPDATE =====

func _physics_process(delta: float) -> void:
	state_machine.update(delta)

# ===== STATES =====

func idle_state(_delta: float) -> void:
	_play_animation("Idle")
	velocity = Vector2.ZERO
	move_and_slide()

func follow_state(delta: float) -> void:
	_play_animation("walk")
	
	var movement = _calculate_follow_velocity() + _calculate_separation_velocity()
	
	if movement == Vector2.ZERO:
		_play_animation("Idle")
	
	velocity_component.accelerate_to_velocity(movement, delta)
	velocity = velocity_component.velocity
	move_and_slide()

# ===== MOVEMENT CALCULATION =====

func _calculate_follow_velocity() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO
	
	var target = _get_follow_target()
	var direction = (target - global_position).normalized()
	var distance = global_position.distance_to(target)
	
	_update_sprite_flip(direction)
	
	if distance < stop_distance:
		return Vector2.ZERO
	
	var speed = _calculate_speed(distance)
	return direction * speed

func _get_follow_target() -> Vector2:
	var target = player.global_position
	
	if player.velocity.length() > 0.1:
		last_player_direction = player.velocity.normalized()
	
	return target - last_player_direction * 50.0

func _calculate_speed(distance: float) -> float:
	if distance < stop_distance * 2.0:
		return follow_speed * (distance - stop_distance) / stop_distance
	return follow_speed

func _calculate_separation_velocity() -> Vector2:
	var nearby_npcs = get_tree().get_nodes_in_group("NPC")
	var separation = Vector2.ZERO
	var count = 0
	
	for npc in nearby_npcs:
		if not _should_separate_from(npc):
			continue
		
		var distance = global_position.distance_to(npc.global_position)
		var direction = (global_position - npc.global_position).normalized()
		var force = (separation_distance - distance) / separation_distance
		
		separation += direction * force
		count += 1
	
	if count == 0:
		return Vector2.ZERO
	
	return (separation / count).normalized() * separation_force

func _should_separate_from(npc: Node) -> bool:
	if npc == self or not is_instance_valid(npc):
		return false
	
	var distance = global_position.distance_to(npc.global_position)
	return distance < separation_distance and distance > 0

# ===== VISUALS =====

func _play_animation(anim_name: String) -> void:
	base_animation_player.play(anim_name)
	clothes_animation_player.play(anim_name)

func _update_sprite_flip(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		var flip = direction.x < 0
		clothes_sprite_2d.flip_h = flip
		base_sprite_2d.flip_h = flip

func _update_interaction_prompt() -> void:
	if is_following:
		interactable_area.set_prompt("Stop Following")
	else:
		interactable_area.set_prompt("Follow Me")

# ===== SIGNALS =====

func _on_interacted(_interactor: Node, _area: InteractableArea) -> void:
	if _interactor is Player:
		player = _interactor
		is_following = !is_following

		state_machine.change_state(follow_state if is_following else idle_state)
		_update_interaction_prompt()
