class_name Interaction extends MarginContainer

@onready var interact_label: Label = %Label
@onready var interact_button: Button = %Button
@onready var progress_bar: ProgressBar = %ProgressBar

var _interactable_area: InteractableArea = null
var _is_connected: bool = false
var _is_button_held: bool = false
var _button_hold_time: float = 0.0

func _ready() -> void:
    # Hide progress bar initially if it exists
    if progress_bar:
        progress_bar.visible = false
        progress_bar.min_value = 0.0
        progress_bar.max_value = 1.0
        progress_bar.value = 0.0
    
    # Connect button signals for both tap and hold
    if interact_button:
        interact_button.pressed.connect(_on_button_pressed)
        interact_button.button_down.connect(_on_button_down)
        interact_button.button_up.connect(_on_button_up)

func _process(delta: float) -> void:
    # Handle button hold for mobile
    if _is_button_held and _interactable_area and _interactable_area.require_hold:
        _button_hold_time += delta
        var progress: float = clamp(_button_hold_time / _interactable_area.hold_duration, 0.0, 1.0)
        
        # Update progress bar
        if progress_bar:
            progress_bar.value = progress
        
        # Emit progress signal
        if _interactable_area.current_interactor:
            _interactable_area.hold_progress.emit(_interactable_area.current_interactor, _interactable_area, progress)
        
        # Complete hold when duration reached
        if _button_hold_time >= _interactable_area.hold_duration:
            _complete_button_hold()

func bind_to_interactable(area: InteractableArea) -> void:
    if _is_connected and _interactable_area:
        unbind_from_interactable()
    
    _interactable_area = area
    if not _interactable_area:
        return
    
    # Connect to signals
    _interactable_area.hold_started.connect(_on_hold_started)
    _interactable_area.hold_progress.connect(_on_hold_progress)
    _interactable_area.hold_canceled.connect(_on_hold_canceled)
    _interactable_area.interacted.connect(_on_interacted)
    _is_connected = true
    
    # Set initial text
    var text := _interactable_area.hold_prompt_text if _interactable_area.require_hold else _interactable_area.prompt_text
    set_button_text(text)

func unbind_from_interactable() -> void:
    if not _is_connected or not _interactable_area:
        return
    
    if _interactable_area.hold_started.is_connected(_on_hold_started):
        _interactable_area.hold_started.disconnect(_on_hold_started)
    if _interactable_area.hold_progress.is_connected(_on_hold_progress):
        _interactable_area.hold_progress.disconnect(_on_hold_progress)
    if _interactable_area.hold_canceled.is_connected(_on_hold_canceled):
        _interactable_area.hold_canceled.disconnect(_on_hold_canceled)
    if _interactable_area.interacted.is_connected(_on_interacted):
        _interactable_area.interacted.disconnect(_on_interacted)
    
    _is_connected = false
    _interactable_area = null

func set_button_text(text: String) -> void:
    if interact_button:
        interact_button.text = text

func _on_button_pressed() -> void:
    # Tap interaction (only for non-hold interactions)
    if _interactable_area and _interactable_area.current_interactor and not _interactable_area.require_hold:
        _interactable_area._perform_interaction(_interactable_area.current_interactor)

func _on_button_down() -> void:
    # Visual feedback - button pressed
    if interact_button:
        interact_label.modulate = Color(0.8, 0.8, 0.8) # Darken label
        interact_button.modulate = Color(0.8, 0.8, 0.8) # Darken button
    
    # Start hold for mobile
    if _interactable_area and _interactable_area.require_hold and _interactable_area.current_interactor:
        _is_button_held = true
        _button_hold_time = 0.0
        
        if progress_bar:
            progress_bar.visible = true
            progress_bar.value = 0.0
        
        # Emit hold started
        _interactable_area.hold_started.emit(_interactable_area.current_interactor, _interactable_area)

func _on_button_up() -> void:
    # Visual feedback - button released
    if interact_button:
        interact_label.modulate = Color.WHITE # Reset to normal
        interact_button.modulate = Color.WHITE # Reset to normal
    
    # Cancel hold if released early
    if _is_button_held and _interactable_area and _interactable_area.require_hold:
        _cancel_button_hold()

func _complete_button_hold() -> void:
    if not _interactable_area or not _interactable_area.current_interactor:
        return
    
    _is_button_held = false
    _button_hold_time = 0.0
    
    # Reset button visual
    if interact_button:
        interact_label.modulate = Color.WHITE # Reset to normal
        interact_button.modulate = Color.WHITE
    
    # Trigger interaction
    _interactable_area._perform_interaction(_interactable_area.current_interactor)

func _cancel_button_hold() -> void:
    _is_button_held = false
    _button_hold_time = 0.0
    
    if progress_bar:
        progress_bar.visible = false
        progress_bar.value = 0.0
    
    # Emit cancel signal
    if _interactable_area and _interactable_area.current_interactor:
        _interactable_area.hold_canceled.emit(_interactable_area.current_interactor, _interactable_area)

func _on_hold_started(_interactor: Node, _area: InteractableArea) -> void:
    # Only handle keyboard/gamepad holds if not already handling button hold
    if _is_button_held:
        return
    
    # Visual feedback - darken button for keyboard input too
    if interact_button:
        interact_label.modulate = Color(0.8, 0.8, 0.8)
        interact_button.modulate = Color(0.8, 0.8, 0.8)
    
    if progress_bar:
        progress_bar.visible = true
        progress_bar.value = 0.0

func _on_hold_progress(_interactor: Node, _area: InteractableArea, progress: float) -> void:
    # Only handle keyboard/gamepad progress if not handling button hold
    if _is_button_held:
        return
    
    if progress_bar:
        progress_bar.value = progress

func _on_hold_canceled(_interactor: Node, _area: InteractableArea) -> void:
    # Only handle keyboard/gamepad cancel if not handling button hold
    if _is_button_held:
        return
    
    # Reset button visual
    if interact_button:
        interact_button.modulate = Color.WHITE
    
    if progress_bar:
        progress_bar.visible = false
        progress_bar.value = 0.0

func _on_interacted(_interactor: Node, _area: InteractableArea) -> void:
    # Reset button visual after successful interaction
    if interact_button:
        interact_button.modulate = Color.WHITE
    
    if progress_bar:
        progress_bar.visible = false
        progress_bar.value = 0.0

func _exit_tree() -> void:
    unbind_from_interactable()
