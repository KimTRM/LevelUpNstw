extends Node2D

@onready var inner_ring: AnimatedSprite2D = %InnerRing
@onready var middle_ring: AnimatedSprite2D = %MiddleRing
@onready var outer_ring: AnimatedSprite2D = %OuterRing
@onready var hitbox: HitboxComponent = $HitboxComponent

@export var duration: float = 10.0
@export var damage_per_tick: int = 5
@export var damage_interval: float = 0.5

var active_hurtboxes: Array[HurtboxComponent] = []
var damage_timer: Timer

func cast() -> void:
	_ignite()

	var lifetime_timer := Timer.new()
	add_child(lifetime_timer)

	# Setup continuous damage timer
	damage_timer = Timer.new()
	damage_timer.wait_time = damage_interval
	damage_timer.timeout.connect(_apply_damage_to_all)
	add_child(damage_timer)
	damage_timer.start()

	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox.area_exited.connect(_on_hitbox_area_exited)
	lifetime_timer.timeout.connect(_quench)
	lifetime_timer.start(duration)

func _ignite():
	inner_ring.hide()
	middle_ring.hide()
	outer_ring.hide()
	
	inner_ring.show()
	inner_ring.play("Ignite")
	await inner_ring.animation_finished
	inner_ring.hide()

	middle_ring.show()
	middle_ring.play("Ignite")
	await middle_ring.animation_finished
	middle_ring.hide()

	outer_ring.show()
	outer_ring.play("Ignite")
	await outer_ring.animation_finished
	outer_ring.play("blazing")

	var ring_tween := outer_ring.create_tween()
	ring_tween.set_loops()
	ring_tween.tween_property(outer_ring, "scale", Vector2(1.45, 1.45), 0.5)
	ring_tween.tween_property(outer_ring, "scale", Vector2(1.5, 1.5), 0.5)

	var hitbox_tween := hitbox.create_tween()
	hitbox_tween.set_loops()
	hitbox_tween.tween_property(hitbox, "scale", Vector2(1.0, 1.0), 0.5)
	hitbox_tween.tween_property(hitbox, "scale", Vector2(1.5, 1.5), 0.5)

func _quench():
	var ring_tween := outer_ring.create_tween()
	ring_tween.tween_property(outer_ring, "scale", Vector2(5, 5), 0.5)
	ring_tween.set_parallel(true)
	ring_tween.tween_property(outer_ring, "modulate:a", 0.0, 0.4)

	var hitbox_tween := hitbox.create_tween()
	hitbox_tween.tween_property(hitbox, "scale", Vector2(5, 5), 0.5)
	await hitbox_tween.finished
	
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		if not active_hurtboxes.has(area):
			active_hurtboxes.append(area)
			# Apply damage immediately on entry
			area.receive_hit(damage_per_tick)

func _on_hitbox_area_exited(area: Area2D) -> void:
	if area is HurtboxComponent:
		active_hurtboxes.erase(area)

func _apply_damage_to_all() -> void:
	# Clean up any freed hurtboxes and apply damage to valid ones
	active_hurtboxes = active_hurtboxes.filter(func(hb): return is_instance_valid(hb))
	
	for hurtbox in active_hurtboxes:
		if is_instance_valid(hurtbox):
			hurtbox.receive_hit(damage_per_tick)
