class_name ShadowSprite extends CharacterBody2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var agro_area_component: Area2D = $AgroAreaComponent
@onready var attack_area_component: Area2D = $AttackAreaComponent
@onready var timer: Timer = $Timer

var _direction: Vector2 = Vector2.ZERO

var lightning_attack_scene: PackedScene = preload("uid://b78gi0kqledx4")

var state_machine: CallableStateMachine = CallableStateMachine.new()
var _delta: float = 0.0

func _ready():
	agro_area_component.agro_area_entered.connect(func(_player): state_machine.change_state(chase_state))
	agro_area_component.agro_area_exited.connect(func(_player): state_machine.change_state(normal_state))

	attack_area_component.attack_area_entered.connect(func(_player): state_machine.change_state(attack_state))
	attack_area_component.attack_area_exited.connect(func(_player): state_machine.change_state(normal_state))
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
	_direction = Vector2.ZERO
	
	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)

	if (agro_area_component.get_overlapping_bodies().size() > 0):
		state_machine.change_state(chase_state)


func chase_state() -> void:
	_direction = (get_tree().get_first_node_in_group("Player").global_position - global_position).normalized()
	
	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)


func _enter_attack_state() -> void:
	timer.start()

func attack_state() -> void:
	_direction = Vector2.ZERO

	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)

func _exit_attack_state() -> void:
	timer.stop()

func _attack() -> void:
	var lightning_attack_instance = lightning_attack_scene.instantiate()
	lightning_attack_instance.global_position = get_tree().get_first_node_in_group("Player").global_position
	lightning_attack_instance.scale = Vector2(2, 2)
	get_parent().add_child(lightning_attack_instance)
