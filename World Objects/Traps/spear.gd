extends AnimatedSprite2D

@onready var hitbox := $StaticBody2D/CollisionShape2D

func _ready() -> void:
	pass
func _physics_process(delta: float) -> void:
	if self.frame > 1:
		hitbox.shape.size.y = 64.0
		hitbox.position.y = 0.0
	else:
		hitbox.shape.size.y = 15.0
		hitbox.position.y = 27.0
