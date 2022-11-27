extends Camera2D

const PADDING_PERCENT := 20
const MIN_ZOOM := 0.6
const MAX_ZOOM := 1.75

onready var screen_size := Vector2(Global.GAME_WIDTH, Global.GAME_HEIGHT)
onready var players := []

func _ready() -> void:
	offset = screen_size * 0.5

func calculate_box(size: Vector2) -> Rect2:
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	
	# find lowest -x, -y and highest x, y
	for player in players:
		var pos: Vector2 = player.global_position
		
		min_x = min(min_x, pos.x) # if pos.x is less than infinity keep it
		max_x = max(max_x, pos.x) # if pos.x is more than negative infinity keep it
		
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	var correct_pixel = -(size * 0.01) * -PADDING_PERCENT
	
	var four_point_list = [
		min_x - correct_pixel.y,
		max_x + correct_pixel.y,
		min_y - correct_pixel.y,
		max_y + correct_pixel.y
	]
	return rect2_from_4_point_list(four_point_list)

func rect2_from_4_point_list(list: Array) -> Rect2:
	var center := Vector2( ((list[0] + list[1]) * 0.5), ((list[3] + list[2]) * 0.5) )
	var size := Vector2( (list[1] - list[0]), (list[3] - list[2]) )
	return Rect2(center, size)

func _physics_process(_delta: float) -> void:
	var custom_rect2 := calculate_box(screen_size)
	var zoom_ratio := max(custom_rect2.size.x / screen_size.x, custom_rect2.size.y / screen_size.y)
	
	var offset_target := custom_rect2.position
	offset_target.y = clamp(offset_target.y, 0, 500 / zoom.x)
	
	var zoom_target := Vector2(1, 1) * clamp(zoom_ratio, MIN_ZOOM, MAX_ZOOM)
	
	offset = lerp(offset, offset_target, 0.1)
	zoom = lerp(zoom, zoom_target, 0.05)
