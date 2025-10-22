extends Area2D

signal attack_area_entered(player: BasePlayer)
signal attack_area_exited(player: BasePlayer)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is BasePlayer:
		attack_area_entered.emit(body)

func _on_body_exited(body: Node) -> void:
	if body is BasePlayer:
		attack_area_exited.emit(body)
