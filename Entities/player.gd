extends CharacterBody2D

const GRAVITY = 500.0
const WALK_SPEED = 200.0
const JUMP_FORCE = -200.0
const ACCELERATION = 15.0
const JUMP_CUT_MULTIPLIER = 0.5
const COYOTE_TIME = 0.2

var coyote_timer := 0.0

@onready var animations := $"Animated Sprite"

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	move_and_slide()




func handle_movement(delta:float)->void:
	var input_direction := Input.get_axis("move_left", "move_right")
	var target_velocity_x := input_direction * WALK_SPEED

	if not is_on_floor() and sign(input_direction) != sign(velocity.x) and input_direction != 0:
		target_velocity_x = lerp(target_velocity_x, target_velocity_x * 0.1, 1.0 - exp(-200 * delta))

	velocity.x = lerp(velocity.x, target_velocity_x, 1.0 - exp((-ACCELERATION * 2) * delta))
	
	handle_movement_animations(input_direction,delta)
	handle_air_effects(input_direction, delta)

func handle_movement_animations(input_direction: float, delta:float)->void:
	if sign(velocity.x) == 1:
		scale.x = input_direction
	if sign(velocity.x) == -1:
		scale.x = input_direction
		
	if sign(velocity.y) <= -1:
		animations.play("jumping")
		return
	if sign(velocity.y) >= 1:
		animations.play("falling")
		return
	
	if round(velocity.x) != 0:
		animations.play("walking")
		return
	
	animations.play("idle")


func handle_air_effects(input_direction: float, delta:float)->void:
	if is_on_wall_only() and Input.is_action_just_pressed("move_up"):
		velocity.y = JUMP_FORCE
		velocity.x += input_direction * -200

	if is_on_floor():
		velocity.y = 0.0
		coyote_timer = COYOTE_TIME
		
	if not is_on_floor():
		var gravity_multiplier := 1.0

		if is_on_wall_only():
			if velocity.y < 0.0:
				gravity_multiplier = 0.8
			else:
				gravity_multiplier = 0.5
			coyote_timer = COYOTE_TIME

		velocity.y += GRAVITY * gravity_multiplier * delta
		coyote_timer -= delta

	if coyote_timer > 0.0 and Input.is_action_just_pressed("move_up"):
		velocity.y = JUMP_FORCE
		coyote_timer = 0.0

	if velocity.y < 0.0 and Input.is_action_just_released("move_up"):
		velocity.y *= JUMP_CUT_MULTIPLIER
