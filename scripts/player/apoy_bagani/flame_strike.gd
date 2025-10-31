extends Node2D

@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed: float = 300.0
@export var max_distance: float = 500.0
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
	hitbox.body_entered.connect(_on_hitbox_body_entered)

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
	# Check if it's an enemy
	if area.get_parent().is_in_group("Enemy"):
		var enemy = area.get_parent()
		
		# Don't hit the same enemy twice
		if hit_enemies.has(enemy):
			return
		
		hit_enemies.append(enemy)
		
		# Deal damage if enemy has health component
		var health_component = enemy.get_node_or_null("HealthComponent")
		if health_component and health_component.has_method("take_damage"):
			health_component.take_damage(damage)
		
		# Check pierce count
		if hit_enemies.size() >= pierce_count:
			_disperse()

func _on_hitbox_body_entered(body: Node2D) -> void:
	# Destroy on collision with walls/obstacles
	if body.is_in_group("Wall") or body is TileMap:
		_disperse()

func _disperse() -> void:
	animation_player.play("strike")
	await animation_player.animation_finished
	queue_free()
