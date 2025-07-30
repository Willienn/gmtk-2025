extends CharacterBody2D

const GRAVITY = 500.0
const WALK_SPEED = 200.0
const JUMP_FORCE = -200.0
const ACCELERATION = 15.0
const JUMP_CUT_MULTIPLIER = 0.5
const COYOTE_TIME = 0.2  

var coyote_timer := 0.0

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_axis("move_left", "move_right")
	var target_velocity_x := input_direction * WALK_SPEED

	if not is_on_floor() and sign(input_direction) != sign(velocity.x) and input_direction != 0:
		target_velocity_x = lerp(target_velocity_x, target_velocity_x * 0.1, 1.0 - exp(-200 * delta))

	velocity.x = lerp(velocity.x, target_velocity_x, 1.0 - exp(-ACCELERATION * delta))

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		coyote_timer -= delta
	else:
		velocity.y = 0.0
		coyote_timer = COYOTE_TIME  

	if coyote_timer > 0.0 and Input.is_action_just_pressed("move_up"):
		velocity.y = JUMP_FORCE
		coyote_timer = 0.0 

	if velocity.y < 0.0 and Input.is_action_just_released("move_up"):
		velocity.y *= JUMP_CUT_MULTIPLIER

	move_and_slide()
