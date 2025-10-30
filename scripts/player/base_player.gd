class_name BasePlayer extends CharacterBody2D

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

const SPEED = 300.0
@export var extra_speed: float = 1.0

var _direction: Vector2
var _animation_direction: String = "down"

var stats: Stats
var _flame_strike_cooldown: float = 0.0
var _flame_strike_cooldown_time: float = 1.5
var _purifying_blaze_scene: PackedScene

func _ready() -> void:
	# si scene kang fire ball
	_purifying_blaze_scene = preload("res://scenes/players/apoy_bagani/purifying_blaze.tscn")

func _physics_process(_delta: float) -> void:
	_direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = velocity_component.get_velocity(_direction)
	velocity_component.accelerate_to_velocity(velocity * extra_speed, _delta)
	velocity_component.move(self)
	
	# si cool down tig update ko 
	if _flame_strike_cooldown > 0.0:
		_flame_strike_cooldown -= _delta
	
	_update_attack()
	update_animation()

	# ini si mapping na Q sa key board para mag cast si skill
	if Input.is_action_just_pressed("Flame_shoot"):
		shoot_flame_projectile()


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

func _update_attack() -> void:
	# ini si basic attack kapag nag space bar ka mag tatake damage ang enemy tig impelement ko lang
	# laag nalang igdi ang assest if meron na 
	if Input.is_key_pressed(KEY_SPACE) || Input.is_action_just_pressed("ui_accept"):
		# dai ini pag iroon
		var rect := RectangleShape2D.new()
		rect.size = Vector2(24, 12)
		var hb := Hitbox.new(stats, 0.12, rect)
		add_child(hb)
		# kapag sain ka naharap doon din ma direct ang casting nya
		var forward := Vector2.ZERO
		match _animation_direction:
			"down":
				forward = Vector2(0, 1)
			"up":
				forward = Vector2(0, -1)
			"side":
				var x_dir := -1 if sprite.flip_h else 1
				forward = Vector2(x_dir, 0)
		hb.global_position = global_position + forward * 16
	
	# mapping E
	if Input.is_action_just_pressed("Flame_strike"):
		cast_flame_strike()

func cast_flame_strike() -> void:
	# check ko lang ini if nag cooldown 
	if _flame_strike_cooldown > 0.0:
		return
	
	# Reset cooldown
	_flame_strike_cooldown = _flame_strike_cooldown_time
	
	fire_fireball()

func fire_fireball() -> void:
	if not _purifying_blaze_scene:
		return
	
	var fire_effect = _purifying_blaze_scene.instantiate()
	add_child(fire_effect)

	fire_effect.position = Vector2.ZERO
	fire_effect.velocity = Vector2.ZERO
	fire_effect.damage = stats.damage
	
	# animation lang ini
	var anim_player = fire_effect.get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.play("blazing")

	var tween := fire_effect.create_tween()
	tween.set_loops()
	tween.tween_property(fire_effect, "scale", Vector2(1.4, 1.4), 0.5)
	tween.tween_property(fire_effect, "scale", Vector2(1.5, 1.5), 0.5)

func shoot_flame_projectile():
	if not _purifying_blaze_scene:
		return
	
	# ini si fire ball dai ko pa na implement
	var fireball = _purifying_blaze_scene.instantiate()
	get_tree().current_scene.add_child(fireball)
	fireball.global_position = global_position
	fireball.scale = Vector2(1, 1) # dai pag hirion
	fireball.damage = stats.damage
	
	var shot_dir = _direction
	if shot_dir == Vector2.ZERO:
		match _animation_direction:
			"down":
				shot_dir = Vector2(0, 1)
			"up":
				shot_dir = Vector2(0, -1)
			"side":
				shot_dir = Vector2(-1 if sprite.flip_h else 1, 0)
	shot_dir = shot_dir.normalized()
	if shot_dir == Vector2.ZERO:
		shot_dir = Vector2(1, 0)
	fireball.velocity = shot_dir * 500.0
	
	var anim_player = fireball.get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.play("blazing")
