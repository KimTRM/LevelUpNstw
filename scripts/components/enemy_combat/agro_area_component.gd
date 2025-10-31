class_name AgroAreaComponent extends Area2D

signal agro_area_entered(player: Node)
signal agro_area_exited(player: Node)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		agro_area_entered.emit(body)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		agro_area_exited.emit(body)