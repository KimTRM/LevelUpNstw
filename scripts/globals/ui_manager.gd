extends CanvasLayer

var ui_screens: Dictionary = {}

# Register a UI node by name
func register_ui(ui_name: String, node: Node) -> void:
	if node:
		ui_screens[ui_name] = node
		print("UI registered:", ui_name)
	else:
		push_error("Tried to register a null node for: " + ui_name)

# Show a specific UI screen
func show_ui(ui_name: String) -> void:
	var ui = ui_screens.get(ui_name)
	if ui:
		ui.visible = true
	else:
		push_error("UI not found: " + ui_name)

# Hide a specific UI screen
func hide_ui(ui_name: String) -> void:
	var ui = ui_screens.get(ui_name)
	if ui:
		ui.visible = false
	else:
		push_error("UI not found: " + ui_name)

# Toggle visibility
func toggle_ui(ui_name: String) -> void:
	var ui = ui_screens.get(ui_name)
	if ui:
		ui.visible = !ui.visible

# Hide all registered UI
func hide_all() -> void:
	for screen in ui_screens.values():
		screen.visible = false

# Update text of a Label-type UI
func update_label(ui_name: String, text: String) -> void:
	var ui = ui_screens.get(ui_name)
	if ui and ui is Label:
		ui.text = text
	else:
		push_error("Label not found or wrong type: " + ui_name)

# Add and register a UI scene dynamically (optional helper)
func add_ui(ui_name: String, scene: PackedScene) -> Node:
	var instance = scene.instantiate()
	add_child(instance)
	ui_screens[ui_name] = instance
	return instance

func has_ui(ui_name: String) -> bool:
	return ui_screens.has(ui_name)