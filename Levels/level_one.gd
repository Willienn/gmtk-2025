extends Node2D

@onready var camera: Camera2D = $Camera2D

const camera_positions := {
	"a": Vector2(640.0, 360.0),
	"b": Vector2(1920.0, 360.0),
}

const safe_positions := {"a": Vector2(26.0, 28.0), "b": Vector2(1331.0, 476.0)}

const transition_positions := {"a": Vector2(1248.0, 476.0), "b": Vector2(1331.0, 476.0)}


func _process(delta: float) -> void:
	pass


func on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return

	if camera.global_position == camera_positions.a:
		Global.player.global_position = transition_positions.b
		camera.global_position = camera_positions.b
	else:
		camera.global_position = camera_positions.a
		Global.player.global_position = transition_positions.a


func _on_player_died() -> void:
	if camera.global_position == camera_positions.a:
		Global.player.global_position = safe_positions.a
	else:
		Global.player.global_position = safe_positions.b
