class_name HealthComponent extends Node

signal died
signal health_changed(current_health, max_health)

@export var max_health: int = 100
var current_health: int

func _ready():
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health = clamp(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		health_changed.emit(current_health, max_health)
		died.emit()

func heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0

func reset_health() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
