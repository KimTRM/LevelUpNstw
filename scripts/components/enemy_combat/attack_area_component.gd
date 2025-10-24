class_name AttackAreaComponent extends Area2D

signal attack_area_entered(body: Node)
signal attack_area_exited(body: Node)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func is_body_in_attack_area(body: Node) -> bool:
	return body in get_overlapping_bodies()

func _on_body_entered(body: Node) -> void:
	if body is BasePlayer || body is Altar:
		attack_area_entered.emit(body)

func _on_body_exited(body: Node) -> void:
	if body is BasePlayer || body is Altar:
		attack_area_exited.emit(body)
