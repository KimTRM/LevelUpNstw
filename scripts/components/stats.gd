class_name Stats extends Resource

enum Faction {
	PLAYER,
	ENEMY
}

enum ElementalAffinity {
	NONE,
	APOY,
	TUBIG,
	LUPA,
	HANGIN
}

@export var elemental_affinity: ElementalAffinity = ElementalAffinity.NONE
@export var max_health: int = 100
@export var base_attack: int = 10
@export var base_defense: int = 10
@export var base_movement_speed: float = 200.0
@export var faction: Faction = Faction.PLAYER

var current_health: int = max_health

func _init(_max_health: int = 100, _base_attack: int = 10, _faction: Faction = Faction.PLAYER) -> void:
	max_health = _max_health
	current_health = _max_health
	base_attack = _base_attack
	faction = _faction

func take_damage(amount: int) -> void:
	current_health -= amount
	print("%s took %d damage! HP: %d/%d" % [amount, current_health, max_health])
