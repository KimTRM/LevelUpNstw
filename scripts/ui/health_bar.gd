class_name HealthBar extends Node2D

@onready var bar_background: ColorRect = $BarBackground
@onready var bar_fill: ColorRect = $BarFill
@onready var bar_label: Label = $BarLabel

@export var max_health: int = 100
@export var show_label: bool = false
@export var bar_width: float = 50.0
@export var bar_height: float = 6.0
@export var offset_y: float = -30.0

var current_health: int = 100

func _ready():
	update_visuals()

func set_max_health(value: int):
	max_health = value
	current_health = value
	update_visuals()

func set_health(value: int):
	current_health = clamp(value, 0, max_health)
	update_visuals()

func update_visuals():
	if not bar_background or not bar_fill:
		return
	
	# Calculate health percentage
	var health_percentage = float(current_health) / float(max_health) if max_health > 0 else 0.0
	
	# Update background and fill sizes
	bar_background.size = Vector2(bar_width + 2, bar_height + 2)
	bar_fill.size = Vector2(bar_width * health_percentage, bar_height)
	
	# Position elements
	bar_background.position = Vector2(-(bar_width + 2) / 2, offset_y)
	bar_fill.position = Vector2(-bar_width / 2, offset_y + 1)
	
	# Update label if enabled
	if bar_label:
		bar_label.visible = false

