@abstract class_name PlayerResource extends Resource

@export var player_name: String = "Hero"
@export var sprite: Texture2D
@export var stats: Stats
var player: Player

@abstract func cast_basic_attack() -> void
@abstract func cast_skill() -> void
@abstract func cast_burst() -> void
