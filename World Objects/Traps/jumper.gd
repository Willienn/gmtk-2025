extends StaticBody2D

var should_impulse := false
var target_body: Player = null
const HITBOX_SPEED := 10.0

@onready var animated_sprite: AnimatedSprite2D = $"Animated Sprite"
@onready var hitbox: CollisionShape2D = $CollisionShape2D

enum impulse_directions { UP, DOWN, LEFT, RIGHT }

const IMPULSE_VECTORS := {
	impulse_directions.UP: Vector2(0, -1),
	impulse_directions.DOWN: Vector2(0, 1),
	impulse_directions.LEFT: Vector2(-1, 0),
	impulse_directions.RIGHT: Vector2(1, 0),
}

@export var direction := impulse_directions.UP


func _ready() -> void:
	print(direction)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		target_body = body
		should_impulse = true
		animated_sprite.play()


func _on_area_2d_body_exited(body: Node2D) -> void:
	should_impulse = false


func _process(delta: float) -> void:
	if should_impulse and animated_sprite.frame == 1 and target_body:
		var dir: Vector2 = IMPULSE_VECTORS[direction]

		# você pode ajustar a força separadamente para X e Y
		if dir.y != 0:
			target_body.velocity.y = 400 * dir.y
		if dir.x != 0:
			target_body.velocity.x = 10000 * dir.x

		should_impulse = false

	if target_body:
		hitbox.position.y = lerpf(hitbox.position.y, -2, 1.0 - exp(-HITBOX_SPEED * delta))
		hitbox.scale.y = lerpf(hitbox.scale.y, 0.5, 1.0 - exp(-HITBOX_SPEED * delta))


func on_animation_finished() -> void:
	hitbox.position.y = -4.5
	hitbox.scale.y = 1
	animated_sprite.frame = 0
	should_impulse = false
	target_body = null
