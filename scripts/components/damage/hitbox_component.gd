class_name HitboxComponent extends Area2D

@export var damage: int = 10
@export var hitbox_lifetime: float = 0.0
@export var collision_layer_bits: int = 1
@export var collision_mask_bits: int = 6 # Bits 2 and 3 (enemy bodies + hurtboxes)

var attacker_stats: Stats

func _init(_attacker_stats: Stats = null, _hitbox_lifetime: float = 0.0, _shape: Shape2D = null) -> void:
	attacker_stats = _attacker_stats
	if _hitbox_lifetime > 0.0:
		hitbox_lifetime = _hitbox_lifetime
	if _shape:
		call_deferred("_setup_collision_shape", _shape)

func _ready() -> void:
	monitorable = false
	area_entered.connect(_on_area_entered)
	
	# Set collision layers and masks
	collision_layer = collision_layer_bits
	collision_mask = collision_mask_bits

	# Auto-setup lifetime timer if specified
	if hitbox_lifetime > 0.0:
		var new_timer := Timer.new()
		add_child(new_timer)
		new_timer.timeout.connect(queue_free)
		new_timer.start(hitbox_lifetime)


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		var hurtbox: HurtboxComponent = area
		var hit_damage = attacker_stats.damage if attacker_stats else damage
		hurtbox.receive_hit(hit_damage)


func _setup_collision_shape(_shape: Shape2D) -> void:
	var collision_shape := CollisionShape2D.new()
	collision_shape.shape = _shape
	add_child(collision_shape)
