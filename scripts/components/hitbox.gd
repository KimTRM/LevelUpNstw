class_name Hitbox
extends Area2D

var attacker_stats: Stats
var hitbox_lifetime: float
var shape: Shape2D

func _init(_attacker_stats: Stats, _hitbox_lifetime: float, _shape: Shape2D) -> void:
	attacker_stats = _attacker_stats
	hitbox_lifetime = _hitbox_lifetime
	shape = _shape

func _ready() -> void:
	monitorable = false
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	# Collide with both hurtbox layers and enemy bodies
	for i in range(1, 33):
		set_collision_layer_value(i, false)
		set_collision_mask_value(i, false)
	# Place on player's layer by default; masks will target enemy body + hurtboxes
	set_collision_layer_value(1, true)
	set_collision_mask_value(2, true) # Enemy bodies
	set_collision_mask_value(3, true) # enemy_hurtbox

	if hitbox_lifetime > 0.0:
		var new_timer := Timer.new()
		add_child(new_timer)
		new_timer.timeout.connect(queue_free)
		new_timer.call_deferred("start", hitbox_lifetime)

	if shape:
		var collision_shape := CollisionShape2D.new()
		collision_shape.shape = shape
		add_child(collision_shape)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("receive_hit"):
		area.receive_hit(attacker_stats.damage)

func _on_body_entered(body: Node) -> void:
	# If the body has a HealthComponent child, apply damage
	if body.has_node("HealthComponent"):
		var hc = body.get_node("HealthComponent")
		if hc and hc.has_method("take_damage"):
			hc.take_damage(attacker_stats.damage)
