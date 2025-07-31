extends AnimatedSprite2D
@onready var hitbox := $StaticBody2D/CollisionShape2D

func _physics_process(delta: float) -> void:
	if self.frame > 1 :
		hitbox.disabled = true
	else:
		hitbox.disabled = false
