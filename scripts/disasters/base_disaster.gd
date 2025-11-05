extends Node2D
class_name BaseDisaster

## Base class for all disaster types
## Provides common functionality for particle effects and collision zones

# Disaster properties
@export var disaster_name: String = "Base Disaster"
@export var disaster_radius: float = 200.0
@export var damage_per_second: float = 5.0

# References to child nodes
var particles: GPUParticles2D
var collision_area: Area2D
var collision_shape: CollisionShape2D

# Bodies currently in the disaster zone
var bodies_in_zone: Array[Node2D] = []


func _ready() -> void:
	_setup_disaster()


func _setup_disaster() -> void:
	"""Initialize the disaster components - to be overridden by child classes"""
	pass


func _process(delta: float) -> void:
	"""Apply disaster effects to entities in the zone"""
	_apply_disaster_effects(delta)


func _apply_disaster_effects(_delta: float) -> void:
	"""Override this in child classes to implement specific disaster effects"""
	pass


func _on_area_entered(body: Node2D) -> void:
	"""Track bodies entering the disaster zone"""
	if body not in bodies_in_zone:
		bodies_in_zone.append(body)
		_on_body_enter_zone(body)


func _on_area_exited(body: Node2D) -> void:
	"""Track bodies leaving the disaster zone"""
	if body in bodies_in_zone:
		bodies_in_zone.erase(body)
		_on_body_exit_zone(body)


func _on_body_enter_zone(_body: Node2D) -> void:
	"""Override this to handle entities entering the disaster zone"""
	pass


func _on_body_exit_zone(_body: Node2D) -> void:
	"""Override this to handle entities leaving the disaster zone"""
	pass


func activate() -> void:
	"""Activate the disaster (start particles, enable collision)"""
	if particles:
		particles.emitting = true
	if collision_area:
		collision_area.monitoring = true


func deactivate() -> void:
	"""Deactivate the disaster (stop particles, disable collision)"""
	if particles:
		particles.emitting = false
	if collision_area:
		collision_area.monitoring = false
