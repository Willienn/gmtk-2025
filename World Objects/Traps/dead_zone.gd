extends Area2D


func _on_body_entered(body: Player) -> void:
	if body is Player:
		body.health_component.take_damage(10, self)
