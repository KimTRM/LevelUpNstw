class_name PlayerHud extends MarginContainer

@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var menu_button: Button = %MenuButton
@onready var pause_menu: PanelContainer = %PauseMenu

func _ready() -> void:
	pause_menu.hide()

func _on_menu_button_pressed() -> void:
	menu_button.hide()
	pause_menu.show()
	
