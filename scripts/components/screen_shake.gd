class_name ScreenShake extends Camera2D

static var instance: ScreenShake

@export var duration: float = 1.0
@export var strength: float = 50.0

var tween: Tween = null

func _ready() -> void:
    instance = self

func shake(_duration: float, _strength: float) -> void:
    var d = _duration if _duration > 0 else duration
    var s = _strength if _strength > 0 else strength
    var base_offest = offset

    if tween:
        tween.kill()
    
    tween = get_tree().create_tween()
    tween.tween_method(func(delay: float) -> void:
        var movement = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * s * delay
        offset = base_offest + movement, 1.0, 0.0, d)