class_name InteractableArea extends Area2D

signal interacted(interactor, area) # Fired when interaction completes (tap or hold)
signal hold_started(interactor, area) # Optional: when hold begins
signal hold_progress(interactor, area, progress) # Optional: 0..1 progress while holding
signal hold_canceled(interactor, area) # Optional: when hold is released before completion


@export var prompt_text: String = "Press E to interact"
@export var hold_prompt_text: String = "Hold E to interact"
@export var interact_action: String = "ui_accept"
@export var player_group: String = "Player"
@export var single_use: bool = false
@export var show_debug_area: bool = false


# Hold settings
@export var require_hold: bool = false
@export_range(0.1, 10.0, 0.1) var hold_duration: float = 1.5


var current_interactor: Node = null
var is_inside: bool = false
var used: bool = false

# Hold state
var _is_holding: bool = false
var _hold_elapsed: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if used and single_use:
		return
	if _is_valid_interactor(body):
		current_interactor = body
		is_inside = true
		_show_prompt(true)


func _on_body_exited(body: Node) -> void:
	if current_interactor == body:
		_cancel_hold_if_any()
		current_interactor = null
		is_inside = false
		_show_prompt(false)


func _physics_process(delta: float) -> void:
	if used and single_use:
		return
	if not is_inside or current_interactor == null:
		return

	if not require_hold:
		# Tap-to-interact
		if Input.is_action_just_pressed(interact_action):
			_perform_interaction(current_interactor)
		return

	# Hold-to-interact
	if Input.is_action_just_pressed(interact_action) and not _is_holding:
		_start_hold()

	if _is_holding:
		if Input.is_action_pressed(interact_action):
			_hold_elapsed += delta
			var progress: float = clamp(_hold_elapsed / hold_duration, 0.0, 1.0)
			hold_progress.emit(current_interactor, self, progress)
			if _hold_elapsed >= hold_duration:
				_complete_hold()
		elif Input.is_action_just_released(interact_action):
			_cancel_hold_if_any()


func _start_hold() -> void:
	_is_holding = true
	_hold_elapsed = 0.0
	hold_started.emit(current_interactor, self)


func _complete_hold() -> void:
	_is_holding = false
	_hold_elapsed = 0.0
	_perform_interaction(current_interactor)


func _cancel_hold_if_any() -> void:
	if _is_holding:
		_is_holding = false
		_hold_elapsed = 0.0
		hold_canceled.emit(current_interactor, self)


func _perform_interaction(interactor: Node) -> void:
	emit_signal("interacted", interactor, self)

	if single_use:
		used = true
		_show_prompt(false)
		monitoring = false


func _is_valid_interactor(body: Node) -> bool:
	if player_group != "" and body.is_in_group(player_group):
		return true
	if body is CharacterBody2D:
		return true
	return false


func _show_prompt(_show: bool) -> void:
	if _show:
		var text := hold_prompt_text if require_hold else prompt_text
		var interaction: Interaction = UiManager.add_ui("interaction_prompt", load("uid://dcpv3ggsk0hyf"))
		interaction.set_button_text(text)
		UiManager.show_ui("interaction_prompt")
	else:
		UiManager.hide_ui("interaction_prompt")


func _draw() -> void:
	if show_debug_area:
		var size = Vector2(32, 32)
		draw_rect(Rect2(-size / 2, size), Color(1, 1, 1, 0.5), false)
