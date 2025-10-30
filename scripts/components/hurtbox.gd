class_name Hurtbox extends Area2D

@onready var owner_stats: Stats = owner.stats

func _ready() -> void:
	# Disable all by default
	for i in range(1, 33):
		set_collision_layer_value(i, false)
		set_collision_mask_value(i, false)
	# Place this hurtbox on the correct physics layer so hitboxes can detect it
	match owner_stats.faction:
		Stats.Faction.PLAYER:
			# Player hurtboxes on layer 4
			set_collision_layer_value(4, true)
			# Listen to enemy hitboxes on layer 2 (enemies); also allow player hitboxes if needed
			set_collision_mask_value(2, true)
			set_collision_mask_value(1, true)
		Stats.Faction.ENEMY:
			# Enemy hurtboxes on layer 3
			set_collision_layer_value(3, true)
			# Listen to player hitboxes on layer 1 (players)
			set_collision_mask_value(1, true)

func receive_hit(damage: int) -> void:
	owner_stats.take_damage(damage)
