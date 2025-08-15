extends AnimatedSprite2D
class_name Trap


func _on_area_2d_body_entered(body: Player) -> void:
	if body is Player:
		body.health_component.take_damage(999, self)
