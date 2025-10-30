class_name Stats
extends Node

enum Faction {
	PLAYER,
	ENEMY
}

var max_health: int = 100
var current_health: int = 100
var damage: int = 10
var faction: Faction = Faction.PLAYER

func _init(_owner: Node = null, _max_health: int = 100, _damage: int = 10, _faction: Faction = Faction.PLAYER) -> void:
	owner = _owner
	max_health = _max_health
	current_health = _max_health
	damage = _damage
	faction = _faction

func take_damage(amount: int) -> void:
	current_health -= amount
	print("%s took %d damage! HP: %d/%d" % [str(owner), amount, current_health, max_health])

	if current_health <= 0:
		die()

func die() -> void:
	print("%s has been defeated!" % str(owner))
	if owner and owner.has_method("on_death"):
		owner.on_death()
