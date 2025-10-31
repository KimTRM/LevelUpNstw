class_name HurtboxComponent extends Area2D

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)

	if not health_component:
		health_component = get_parent().get_node_or_null("HealthComponent")
		if not health_component:
			push_warning("HurtboxComponent: No HealthComponent found on parent or assigned directly.")
			
func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area
		var hit_damage = hitbox.attacker_stats.damage if hitbox.attacker_stats else hitbox.damage
		receive_hit(hit_damage)

func receive_hit(damage: int) -> void:
	if health_component:
		health_component.take_damage(damage)
		print("Hurtbox received ", damage, " damage.")
