class_name ShadowSprite extends CharacterBody2D

@onready var sprite: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var agro_area_component: Area2D = $AgroAreaComponent
@onready var attack_area_component: AttackAreaComponent = $AttackAreaComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: HealthBar = $HealthBar

var timer: Timer = Timer.new()
var _target: Node2D = null
var _direction: Vector2 = Vector2.ZERO

var lightning_attack_scene: PackedScene = preload("uid://b78gi0kqledx4")

var state_machine: CallableStateMachine = CallableStateMachine.new()
var _delta: float = 0.0

func _ready():
	if health_component and health_bar:
		health_bar.set_max_health(health_component.max_health)
		health_component.health_changed.connect(_on_health_changed)

	if health_component:
		health_component.died.connect(on_death)

	agro_area_component.agro_area_entered.connect(_on_agro_area_entered)
	agro_area_component.agro_area_exited.connect(_on_agro_area_exited)

	attack_area_component.attack_area_entered.connect(_on_attack_area_entered)
	attack_area_component.attack_area_exited.connect(_on_attack_area_exited)

	state_machine.add_states(normal_state)
	state_machine.add_states(chase_state)
	state_machine.add_states(attack_state, _enter_attack_state, _exit_attack_state)
	state_machine.set_initial_state(normal_state)

	timer.wait_time = 2.5
	timer.timeout.connect(func(): _attack())
	add_child(timer)

func _process(delta: float) -> void:
	_delta = delta
	state_machine.update()


# region States
func normal_state() -> void:
	_target = get_tree().get_first_node_in_group("Altar")
	_direction = (_target.global_position - global_position).normalized()
	_move(_direction)


func chase_state() -> void:
	_target = get_tree().get_first_node_in_group("Player")
	_direction = (_target.global_position - global_position).normalized()
	_move(_direction)


func _enter_attack_state() -> void:
	var bodies = attack_area_component.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			_target = body
			timer.start()
			return
		elif body.is_in_group("Altar"):
			_target = body
	timer.start()

func attack_state() -> void:
	_direction = Vector2.ZERO
	_move(_direction)

func _exit_attack_state() -> void:
	timer.stop()
# endregion

func _on_agro_area_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		print("Player entered agro area")
		state_machine.change_state(chase_state)

func _on_agro_area_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		print("Player exited agro area")
		if attack_area_component.get_overlapping_bodies().size() > 0:
			state_machine.change_state(attack_state)
		else:
			state_machine.change_state(normal_state)


func _on_attack_area_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		_target = body
		state_machine.change_state(attack_state)
	elif body.is_in_group("Altar"):
		_target = body
		state_machine.change_state(attack_state)

func _on_attack_area_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		if agro_area_component.get_overlapping_bodies().size() > 0:
			state_machine.change_state(chase_state)
		else:
			state_machine.change_state(normal_state)
			
func _attack() -> void:
	var lightning_attack_instance = lightning_attack_scene.instantiate()
	lightning_attack_instance.global_position = _target.global_position
	get_parent().add_child(lightning_attack_instance)

func _move(direction: Vector2) -> void:
	velocity = velocity_component.get_velocity(direction)
	velocity_component.accelerate_to_velocity(velocity, _delta)
	velocity_component.move(self)

func _on_health_changed(current_health: int, _max_health: int) -> void:
	if health_bar:
		health_bar.set_health(current_health)
		
func on_death():
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")
		animation_player.animation_finished.connect(_on_death_animation_finished)
	else:
		# Fade out
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.4)
		tween.finished.connect(queue_free)
	if health_bar and is_instance_valid(health_bar):
		health_bar.queue_free()

func _on_death_animation_finished(anim_name):
	if anim_name == "death":
		if health_bar and is_instance_valid(health_bar):
			health_bar.queue_free()
		queue_free()
