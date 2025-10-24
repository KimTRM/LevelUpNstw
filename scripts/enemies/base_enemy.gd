class_name BaseEnemy extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var agro_area_component: Area2D = $AgroAreaComponent
@onready var attack_area_component: Area2D = $AttackAreaComponent

var _direction: Vector2 = Vector2.ZERO

var state_machine: CallableStateMachine = CallableStateMachine.new()
var _delta: float = 0.0

func _ready():
	agro_area_component.agro_area_entered.connect(func(_player): state_machine.change_state(normal_state))
	agro_area_component.agro_area_exited.connect(func(_player): state_machine.change_state(attack_state))

	attack_area_component.attack_area_entered.connect(func(_player): state_machine.change_state(attack_state))
	attack_area_component.attack_area_exited.connect(func(_player): state_machine.change_state(normal_state))

	# Setup States
	state_machine.add_states(normal_state)
	state_machine.add_states(attack_state)
	state_machine.set_initial_state(normal_state)

func _process(delta: float) -> void:
	_delta = delta
	state_machine.update()


func normal_state() -> void:
	_direction = (get_tree().get_first_node_in_group("Player").global_position - global_position).normalized()
	
	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)


func attack_state() -> void:
	_direction = Vector2.ZERO

	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)
