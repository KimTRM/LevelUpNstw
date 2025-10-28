class_name Interaction extends MarginContainer

@onready var interact_button: Button = $RockButton

func set_button_text(text: String) -> void:
	interact_button.text = text
