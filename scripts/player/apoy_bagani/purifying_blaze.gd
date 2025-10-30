extends Node2D

@onready var inner_ring: AnimatedSprite2D = %InnerRing
@onready var middle_ring: AnimatedSprite2D = %MiddleRing
@onready var outer_ring: AnimatedSprite2D = %OuterRing

@export var duration: float = 10.0
var damage: int = 10

func cast() -> void:
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

	var tween := outer_ring.create_tween()
	tween.set_loops()
	tween.tween_property(outer_ring, "scale", Vector2(1.4, 1.4), 0.5)
	tween.tween_property(outer_ring, "scale", Vector2(1.5, 1.5), 0.5)

	var lifetime_timer := Timer.new()
	add_child(lifetime_timer)
	lifetime_timer.wait_time = duration
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(queue_free)
	lifetime_timer.start()
