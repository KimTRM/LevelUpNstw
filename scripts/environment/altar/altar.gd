class_name Altar extends StaticBody2D

@onready var interactable_area: InteractableArea = $InteractableArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)


func _on_interacted(_interactor: Node, _area: InteractableArea) -> void:
	animation_player.play("interacted")
	await animation_player.animation_finished
	animation_player.play("Interacted idle")

	print("Altar interacted with by %s" % _interactor.name)
