extends PanelContainer

@onready var menu_button: Button = %MenuButton

func _on_resume_button_pressed() -> void:
	hide()
	menu_button.show()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	pass # Replace with function body.
