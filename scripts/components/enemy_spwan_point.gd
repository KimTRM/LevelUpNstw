class_name EnemySpawnPoint extends Marker2D

@export var enemy_to_spawn: PackedScene
@export var max_spawns: int = 1
@export var count_per_wave: int = 5
@export var spawn_spacing: float = 50.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Spawner.spawn_points.append(self)
