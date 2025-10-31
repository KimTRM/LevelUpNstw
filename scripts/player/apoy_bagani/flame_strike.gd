extends Node2D

@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed: float = 300.0
@export var max_distance: float = 100.0
@export var pierce_count: int = 1 # How many enemies it can hit before destroying
@export var damage: int = 10

var direction: Vector2 = Vector2.RIGHT
var traveled_distance: float = 0.0
var hit_enemies: Array = []
var is_active: bool = false

func _ready() -> void:
	# Optional: Add a timer to auto-destroy after some time
	var lifetime_timer := Timer.new()
	lifetime_timer.wait_time = max_distance / speed
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_disperse)
	add_child(lifetime_timer)
	lifetime_timer.start()

	hitbox.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta: float) -> void:
	if not is_active:
		return
	
	# Move in the direction
	var velocity := direction * speed * delta
	global_position += velocity
	traveled_distance += velocity.length()
	
	# Destroy if traveled max distance
	if traveled_distance >= max_distance:
		_disperse()

func cast(from_position: Vector2, target_direction: Vector2) -> void:
	global_position = from_position
	direction = target_direction.normalized()
	is_active = true

	scale = Vector2.ZERO

	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.25)
	# Rotate sprite to face direction
	rotation = direction.angle()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		_disperse()


func _disperse() -> void:
	animation_player.play("strike")
	await animation_player.animation_finished
	queue_free()
