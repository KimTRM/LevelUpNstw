class_name Altar extends StaticBody2D

@onready var interactable_area: InteractableArea = $InteractableArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_area.interacted.connect(_on_interacted)
	pass # Replace with function body.

func _on_interacted(_interactor: Node, _area: InteractableArea) -> void:
	print("Altar interacted with by %s" % _interactor.name)
