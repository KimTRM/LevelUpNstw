extends Area2D

var velocity: Vector2 = Vector2.ZERO
var damage: int = 10

func _ready():
	
	collision_layer = 1  # Player layer
	collision_mask = 2 | 3  # enemy layer pati si hurt box nya

	# naka connect yan sa same signal 
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	if velocity != Vector2.ZERO:
		position += velocity * delta

		if velocity.length() > 0:
			rotation = velocity.angle()

		if position.distance_to(Vector2.ZERO) > 2000:
			queue_free()

func _on_body_entered(body: Node):

	if body.has_node("HealthComponent"):
		var hc = body.get_node("HealthComponent")
		if hc and hc.has_method("take_damage"):
			hc.take_damage(damage)

func _on_area_entered(area: Area2D):
	if area.has_method("receive_hit"):
		area.receive_hit(damage)
		
func _on_timer_timeout():
	queue_free()
	get_tree().current_scene.get_node("PurifyingBlaze").queue_free()
