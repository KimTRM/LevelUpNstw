class_name WildfireDisaster
extends HazardComponent

func _ready():
    super._ready()
    hazard_name = "Wildfire"
    element_type = "Fire"
    damage_per_second = 10.0
    lifetime = 12.0
    spread_radius = 0.0
    activate()

func _try_spread():
    var clone = duplicate()
    clone.position += Vector2(randf_range(-spread_radius, spread_radius), randf_range(-spread_radius, spread_radius))
    get_parent().add_child(clone)
    clone.activate()

func interact(player_element: String):
    if not interactable: return
    match player_element:
        "Water":
            deactivate()
            fade_out()
        "Wind":
            deactivate()
            fade_out()
        _:
            pass
