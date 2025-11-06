class_name InteractableArea extends Area2D

signal interacted(interactor, area) # Fired when interaction completes (tap or hold)
signal hold_started(interactor, area) # Optional: when hold begins
signal hold_progress(interactor, area, progress) # Optional: 0..1 progress while holding
signal hold_canceled(interactor, area) # Optional: when hold is released before completion


@export var prompt_text: String = "Press F to interact"
@export var hold_prompt_text: String = "Hold F to interact"
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

func set_prompt(new_prompt: String) -> void:
	prompt_text = new_prompt

	if is_inside:
		_show_prompt(true)
	else:
		_show_prompt(false)

func set_hold_prompt(new_prompt: String) -> void:
	hold_prompt_text = new_prompt
	
	if is_inside:
		_show_prompt(true)
	else:
		_show_prompt(false)

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
		if Input.is_action_just_pressed("interact"):
			_perform_interaction(current_interactor)
		return

	# Hold-to-interact
	if Input.is_action_just_pressed("interact") and not _is_holding:
		_start_hold()

	if _is_holding:
		if Input.is_action_pressed("interact"):
			_hold_elapsed += delta
			var progress: float = clamp(_hold_elapsed / hold_duration, 0.0, 1.0)
			hold_progress.emit(current_interactor, self, progress)
			if _hold_elapsed >= hold_duration:
				_complete_hold()
		elif Input.is_action_just_released("interact"):
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
	interacted.emit(interactor, self)

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
	var key := "interaction_prompt"
	if _show:
		var _text := hold_prompt_text if require_hold else prompt_text
		
		# Check if UI already exists
		if not UiManager.has_ui(key):
			var scene: PackedScene = load("uid://dcpv3ggsk0hyf")
			UiManager.add_ui(key, scene)
		
		# Bind this interactable area to the UI
		var interaction: Interaction = UiManager.ui_screens.get(key) as Interaction
		if interaction:
			interaction.bind_to_interactable(self)
			interaction.set_button_text(_text)
		
		UiManager.show_ui(key)
	else:
		# Only hide if UI exists
		if UiManager.has_ui(key):
			# Unbind when hiding
			var interaction: Interaction = UiManager.ui_screens.get(key) as Interaction
			if interaction:
				interaction.unbind_from_interactable()
			UiManager.hide_ui(key)


func _draw() -> void:
	if show_debug_area:
		var size = Vector2(32, 32)
		draw_rect(Rect2(-size / 2, size), Color(1, 1, 1, 0.5), false)
