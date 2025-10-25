class_name Spawner
extends Node

@export var to_spawn: PackedScene
@export var spawn_interval: float = 2.0
@export var max_spawns: int = 0
@export var auto_start: bool = true
@export var spawn_points: Array[NodePath] = []
@export var count_per_wave: int = 5
@export var spawn_spacing: float = 50.0

var _spawned_count: int = 0
var _timer: Timer

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = spawn_interval
	_timer.one_shot = false
	_timer.autostart = auto_start
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)
	if auto_start:
		_timer.start()

func _on_timer_timeout() -> void:
	if max_spawns > 0 and _spawned_count >= max_spawns:
		_timer.stop()
		return
	spawn_wave()
	_spawned_count += 1

func spawn_wave() -> void:
	if to_spawn == null or spawn_points.is_empty():
		return
	for path in spawn_points:
		var base_node = get_node_or_null(path)
		if base_node:
			for i in range(count_per_wave):
				var instance = to_spawn.instantiate()
				var offset = Vector2(spawn_spacing * i, 0)
				instance.global_position = base_node.global_position + offset
				get_parent().add_child(instance)
