class_name ApoyBagani extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

const SPEED = 300.0
@export var extra_speed: float = 1.0

var _direction: Vector2
var _animation_direction: String = "down"

@export var stats: Stats

var flame_strike_scene: PackedScene = preload("uid://cwb6ilcsanu23")
var _purifying_blaze_scene: PackedScene = preload("uid://dicv1bk7u0vgs")

func _physics_process(_delta: float) -> void:
	_direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity * extra_speed, _delta)
	velocity_component.move(self)
	
	update_animation()

	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("skill"):
		var projectile = flame_strike_scene.instantiate()
	
		var direction = (get_global_mouse_position() - global_position).normalized()
		projectile.cast(global_position, direction)
		get_parent().add_child(projectile)
		
	if Input.is_action_just_pressed("burst"):
		var purifying_blaze = _purifying_blaze_scene.instantiate()
		add_child(purifying_blaze)
		purifying_blaze.cast()

	if Input.is_action_just_pressed("basic_attack"):
		_cast_basic_attack()


func update_animation():
	if _direction == Vector2.DOWN:
		_animation_direction = "down"
	elif _direction == Vector2.UP:
		_animation_direction = "up"
	elif _direction == Vector2.LEFT or _direction == Vector2.RIGHT:
		_animation_direction = "side"
		sprite.flip_h = _direction.x < 0

	if _direction != Vector2.ZERO:
		animation_player.play("walk_" + _animation_direction)
	else:
		animation_player.play("idle_" + _animation_direction)

func _cast_basic_attack() -> void:
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 12)
	var hitbox_instance: HitboxComponent = HitboxComponent.new(stats, 0.12, rect)
	add_child(hitbox_instance)
		
	var forward := Vector2.ZERO
	match _animation_direction:
		"down":
			forward = Vector2(0, 1)
		"up":
				forward = Vector2(0, -1)
		"side":
			var x_dir := -1 if sprite.flip_h else 1
			forward = Vector2(x_dir, 0)
	hitbox_instance.global_position = global_position + forward * 16
