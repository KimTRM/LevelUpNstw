class_name HazardComponent extends Area2D

@export var hazard_name: String = "Wildfire"
@export var element_type: String = "Fire"
@export var damage_per_second: float = 5.0
@export var lifetime: float = 10.0
@export var spread_radius: float = 0.0
@export var interactable: bool = true

@onready var timer := Timer.new()
@onready var particles := $Particles2D if has_node("Particles2D") else null

var active: bool = false
var time_elapsed: float = 0.0

func _ready():
    add_child(timer)
    timer.wait_time = 1.0
    timer.timeout.connect(_on_tick)
    if lifetime > 0:
        await get_tree().create_timer(lifetime).timeout
        queue_free()

func activate():
    if active: return
    active = true
    timer.start()
    if particles:
        particles.emitting = true

func deactivate():
    if not active: return
    active = false
    timer.stop()
    if particles:
        particles.emitting = false

func _on_tick():
    if not active: return
    time_elapsed += 1.0

    # TODO : Replace with the damage component system
    for body in get_overlapping_bodies():
        if body.has_method("apply_damage"):
            body.apply_damage(damage_per_second)
    if spread_radius > 0:
        _try_spread()

func _try_spread():
    # Optional: duplicate this hazard in nearby area
    var nearby = get_tree().get_nodes_in_group("Hazard")
    if nearby.size() < 10:
        var clone = duplicate()
        clone.position += Vector2(randf() * spread_radius, randf() * spread_radius)
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
        "Earth":
            deactivate()
            fade_out()

func fade_out():
    if particles:
        particles.emitting = false
		
    if has_node("AnimationPlayer"):
        $AnimationPlayer.play("fade_out")
    else:
        queue_free()
