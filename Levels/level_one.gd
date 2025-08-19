extends Node2D
@onready var camera: Camera2D = $Camera2D

const AREAS := {
	"a":
	{
		"camera_pos": Vector2(640, 360),
		"safe_pos": Vector2(26, 28),
		"transitions": {"to_b": {"pos": Vector2(1320, 476), "to": "b"}}
	},
	"b":
	{
		"camera_pos": Vector2(1920, 360),
		"safe_pos": Vector2(1331, 476),
		"transitions":
		{
			"to_a": {"pos": Vector2(1250, 472), "to": "a"},
			"to_c": {"pos": Vector2(2575, 80), "to": "c"}
		}
	},
	"c":
	{
		"camera_pos": Vector2(3200, 360),
		"safe_pos": Vector2(2580, 80),
		"transitions": {"to_b": {"pos": Vector2(2540, 80), "to": "b"}}
	}
}

var current_area: String


func _ready() -> void:
	var current_area = get_current_area()


func _process(delta: float) -> void:
	pass


# Trigger when entering transition one (a <-> b)
func on_body_entered_level_transition_one(body: Node2D) -> void:
	if body is not Player:
		return

	if current_area == "a":
		# Going from A to B
		Global.player.global_position = AREAS["a"]["transitions"]["to_b"]["pos"]
		camera.global_position = AREAS["b"]["camera_pos"]
	elif current_area == "b":
		# Going from B to A
		Global.player.global_position = AREAS["b"]["transitions"]["to_a"]["pos"]
		camera.global_position = AREAS["a"]["camera_pos"]


# Trigger when entering transition two (b <-> c)
func on_body_entered_level_transition_two(body: Node2D) -> void:
	if body is not Player:
		return

	var current_area = get_current_area()
	if current_area == "b":
		# Going from B to C
		Global.player.global_position = AREAS["b"]["transitions"]["to_c"]["pos"]
		camera.global_position = AREAS["c"]["camera_pos"]
	elif current_area == "c":
		# Going from C to B
		Global.player.global_position = AREAS["c"]["transitions"]["to_b"]["pos"]
		camera.global_position = AREAS["b"]["camera_pos"]


func on_player_died() -> void:
	var current_area = get_current_area()
	if current_area != "":
		Global.player.global_position = AREAS[current_area]["safe_pos"]


func get_current_area() -> String:
	for name in AREAS.keys():
		if camera.global_position.is_equal_approx(AREAS[name]["camera_pos"]):
			return name
	return ""
