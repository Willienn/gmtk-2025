extends Trap


@onready var hitbox := $Area2D/CollisionShape2D


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if self.frame > 1:
		hitbox.shape.size.y = 64.0
		hitbox.position.y = 0.0
	else:
		hitbox.shape.size.y = 15.0
		hitbox.position.y = 27.0


func _on_animation_finished() -> void:
	await get_tree().create_timer(1).timeout
	play()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.health_component .take_damage(10, self)
