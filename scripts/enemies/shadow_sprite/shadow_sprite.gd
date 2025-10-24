class_name ShadowSprite extends CharacterBody2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var agro_area_component: Area2D = $AgroAreaComponent
@onready var attack_area_component: AttackAreaComponent = $AttackAreaComponent
@onready var timer: Timer = $Timer

var _target: Node2D = null
var _direction: Vector2 = Vector2.ZERO

var lightning_attack_scene: PackedScene = preload("uid://b78gi0kqledx4")

var state_machine: CallableStateMachine = CallableStateMachine.new()
var _delta: float = 0.0

func _ready():
	agro_area_component.agro_area_entered.connect(_on_agro_area_entered)
	agro_area_component.agro_area_exited.connect(_on_agro_area_exited)

	attack_area_component.attack_area_entered.connect(_on_attack_area_entered)
	attack_area_component.attack_area_exited.connect(_on_attack_area_exited)
	timer.timeout.connect(func(): _attack())

	# Setup States
	state_machine.add_states(normal_state)
	state_machine.add_states(chase_state)
	state_machine.add_states(attack_state, _enter_attack_state, _exit_attack_state)
	state_machine.set_initial_state(normal_state)

func _process(delta: float) -> void:
	_delta = delta
	state_machine.update()


func normal_state() -> void:
	# print("change to normal state")
	_target = get_tree().get_first_node_in_group("Altar")
	_direction = (_target.global_position - global_position).normalized()

	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)

	if (attack_area_component.get_overlapping_bodies().size() > 1):
		print("change to attack state from normal state")
		state_machine.change_state(attack_state)
	
	if (agro_area_component.get_overlapping_bodies().size() > 1):
		print("change to chase state from normal state")
		state_machine.change_state(chase_state)

	
func chase_state() -> void:
	# print("change to chase state")
	_target = get_tree().get_first_node_in_group("Player")
	_direction = (_target.global_position - global_position).normalized()

	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)

	if (attack_area_component.get_overlapping_bodies().size() > 1):
		state_machine.change_state(attack_state)


func _enter_attack_state() -> void:
	timer.start()

func attack_state() -> void:
	# print("in attack state")
	_direction = Vector2.ZERO

	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)

func _exit_attack_state() -> void:
	timer.stop()

func _attack() -> void:
	var lightning_attack_instance = lightning_attack_scene.instantiate()
	lightning_attack_instance.global_position = _target.global_position
	lightning_attack_instance.scale = Vector2(2, 2)
	get_parent().add_child(lightning_attack_instance)

func _on_agro_area_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		state_machine.change_state(chase_state)

func _on_agro_area_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		state_machine.change_state(normal_state)

func _on_attack_area_entered(body: Node) -> void:
	if body.is_in_group("Player") || body.is_in_group("Altar"):
		state_machine.change_state(attack_state)

func _on_attack_area_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		state_machine.change_state(chase_state)