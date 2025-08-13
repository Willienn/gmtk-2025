extends Node
class_name HealthComponent

signal health_changed(old_value: float, new_value: float)
signal health_depleted(killer: CharacterBody2D)
signal threshold_reached(threshold: float)
@onready var parent: Player = get_parent()

@export var max_health := 100.0:
	set(value):
		max_health = max(value, 0.1)
		current_health = min(current_health, max_health)

@export var thresholds: Array[float] = [375.0, 250.0, 125.0]:
	set(value):
		thresholds = value.duplicate()  # evita modificar referência externa
		thresholds.sort()  # crescente
		thresholds.reverse()  # decrescente

@onready var current_health := max_health:
	set(value):
		var new_health := clampf(value, 0.0, max_health)
		if is_equal_approx(current_health, new_health):
			return

		var old_health := current_health
		current_health = new_health
		health_changed.emit(old_health, current_health)

		for threshold in thresholds:
			if old_health > threshold and current_health <= threshold:
				threshold_reached.emit(threshold)

var hit_count := 0:
	set(value):
		hit_count = min(value, 3)


func take_damage(amount: float, shooter: Trap) -> void:
	if parent.collision_mask == 2:
		return
	if parent.has_method("handle_damage"):
		parent.handle_damage()
	current_health -= amount
	hit_count += 1

	if current_health <= 0.0:
		die(shooter)


func heal(amount: float) -> void:
	current_health += amount


func die(shooter: Trap) -> void:
	health_depleted.emit(shooter)
	get_parent().global_position = Vector2(82, 32)
	#get_parent().queue_free()
