class_name Stats
extends Resource

enum Faction {
	PLAYER,
	ENEMY
}

@export var max_health: int = 100
@export var damage: int = 10
@export var faction: Faction = Faction.PLAYER

var current_health: int = 100

func _init(_max_health: int = 100, _damage: int = 10, _faction: Faction = Faction.PLAYER) -> void:
	max_health = _max_health
	current_health = _max_health
	damage = _damage
	faction = _faction

func take_damage(amount: int) -> void:
	current_health -= amount
	print("%s took %d damage! HP: %d/%d" % [amount, current_health, max_health])
