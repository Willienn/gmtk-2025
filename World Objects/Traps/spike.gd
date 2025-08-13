extends AnimatedSprite2D
class_name Trap

@onready var hitbox := $StaticBody2D/CollisionShape2D

var target:Player = null

func _physics_process(delta: float) -> void:
	if self.frame > 1:
		if target and target.collision_mask != 2:
			target.healt_component.take_damage(10,self)


func _on_body_entered(body: Player) -> void:
	if body.collision_mask == 2: return
	target = body
	play()


func _on_animation_finished() -> void:
	frame = 0


func _on_body_exited(body: Node2D) -> void:
	target = null
