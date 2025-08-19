extends StaticBody2D

var should_impulse := false
var target_body: Player = null
const HITBOX_SPEED := 10.0

@onready var animated_sprite: AnimatedSprite2D = $"Animated Sprite"
@onready var hitbox: CollisionShape2D = $CollisionShape2D

enum direction { UP, DOWN, LEFT, RIGHT }

const IMPULSE_VECTORS := {
	direction.UP: Vector2.UP,
	direction.DOWN: Vector2.DOWN,
	direction.LEFT: Vector2.LEFT,
	direction.RIGHT: Vector2.RIGHT,
}

@export var impulse_directions := direction.UP


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
		var dir: Vector2 = IMPULSE_VECTORS[impulse_directions]

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
