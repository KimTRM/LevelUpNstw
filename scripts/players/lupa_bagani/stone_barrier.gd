extends TileMapLayer

@export var lifetime: float = 10.0
@export var fade_duration: float = 1.5
@export var rise_height: float = 32.0
@export var rise_time: float = 0.4
@export var offset_distance: float = 100

@export var barrier_width: int = 5
@export var barrier_height: int = 2
@export var terrain_set: int = 0
@export var terrain_id: int = 0 # the terrain type ID (usually 0 if you only have one terrain in the TileSet)

func cast(caster_position: Vector2, facing_direction: Vector2) -> void:
	# Spawn slightly in front of the player
	global_position = caster_position + facing_direction.normalized() * offset_distance

	# Rotate placement if facing left/right (optional)
	var dir_sign = sign(facing_direction.x)
	if dir_sign == 0: dir_sign = 1 # avoid division by zero

	create_barrier_tiles(dir_sign)
	animate_rise()
	crumble_later()

func create_barrier_tiles(dir_sign: float):
	clear()
	var center = local_to_map(Vector2.ZERO)

	# Collect all cells first
	var cells_to_paint: Array[Vector2i] = []
	for x in range(-barrier_width / 2.0, barrier_width / 2.0 + 1.0):
		for y in range(-barrier_height, 1):
			var cell = center + Vector2i(x * int(dir_sign), y)
			cells_to_paint.append(cell)
	
	# Paint all cells at once for proper terrain connection
	set_cells_terrain_connect(cells_to_paint, terrain_set, terrain_id)

func animate_rise():
	var start_pos = position + Vector2(0, rise_height)
	position = start_pos
	var tween = create_tween()
	tween.tween_property(self, "position:y", start_pos.y - rise_height, rise_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func crumble_later():
	await get_tree().create_timer(lifetime - fade_duration).timeout
	start_crumble()
	await get_tree().create_timer(fade_duration).timeout
	queue_free()

func start_crumble():
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, fade_duration).set_trans(Tween.TRANS_SINE)

	var shake_tween = create_tween()
	shake_tween.set_loops(6)
	shake_tween.tween_property(self, "position:y", position.y - 3, 0.05).set_trans(Tween.TRANS_SINE)
	shake_tween.tween_property(self, "position:y", position.y + 3, 0.05).set_trans(Tween.TRANS_SINE)
	shake_tween.tween_property(self, "position:y", position.y, 0.05).set_trans(Tween.TRANS_SINE)
