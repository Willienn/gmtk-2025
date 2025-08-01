extends StaticBody2D

var should_impulse := false
var target_body : Variant = null
@onready var animated_sprite:AnimatedSprite2D = $"Animated Sprite"
@onready var hitbox:CollisionShape2D = $CollisionShape2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		target_body = body
		should_impulse = true
		animated_sprite.play()

func _on_area_2d_body_exited(body: Node2D) -> void:
	should_impulse = false


func _process(delta: float) -> void:
	if should_impulse and animated_sprite.frame == 3 and target_body:
		target_body.velocity.y = -400
		should_impulse = false 
	if target_body:
		hitbox.position.y =  lerpf(hitbox.position.y,-2, 1.0 - exp(-10 * delta))
		hitbox.scale.y = lerpf(hitbox.scale.y,0.5, 1.0 - exp(-10 * delta))
#-4
#0.9    


func on_animation_finished() -> void:
	print("finished")
	
	hitbox.position.y = -4.5
	hitbox.scale.y = 1 
	animated_sprite.frame = 0
	should_impulse = false
	target_body = null
