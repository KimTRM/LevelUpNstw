class_name AttackAreaComponent extends Area2D

signal attack_area_entered(body: Node)
signal attack_area_exited(body: Node)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") || body.is_in_group("Altar"):
		attack_area_entered.emit(body)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player") || body.is_in_group("Altar"):
		attack_area_exited.emit(body)
