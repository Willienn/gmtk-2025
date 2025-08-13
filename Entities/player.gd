extends CharacterBody2D
class_name Player

const GRAVITY := 600.0
const JUMP_FORCE := -200.0
const ACCELERATION := 15.0
const JUMP_CUT_MULTIPLIER := 0.5
const COYOTE_TIME := 0.2
const RUN_SPEED := 300.0
const WALK_SPEED := 200.0
const DASH_FORCE := 2000.0
const WALL_KICK_FORCE := 400.0
const WALL_SLIDE_SPEED := 80.0
const DASH_DURATION := 0.2
const WALL_JUMP_DASH_LOCK := 0.15
const JUMP_RELEASE_BUFFER := 0.1

@onready var health_component: HealthComponent = $"Health Component"
@onready var hurtbox: CollisionShape2D = $Hurtbox
@onready var animations := $"Animated Sprite"

var walk_speed := WALK_SPEED
var coyote_timer := 0.0
var is_running := false
var is_dashing := false
var can_dash := true
var can_wall_jump := true
var dash_timer := 0.0
var jump_release_timer := 0.0
var dash_lock_timer := 0.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	update_timers(delta)
	handle_movement(delta)
	move_and_slide()

func update_timers(delta: float) -> void:
	if dash_timer > 0:
		dash_timer -= delta
	if dash_lock_timer > 0:
		dash_lock_timer -= delta
	if jump_release_timer > 0:
		jump_release_timer -= delta

	if Input.is_action_just_released("move_up"):
		jump_release_timer = JUMP_RELEASE_BUFFER

func handle_movement(delta: float) -> void:
	handle_dash()
	handle_horizontal_movement(delta)
	handle_air_effects(delta)
	handle_movement_animations()

func handle_horizontal_movement(delta: float) -> void:
	var input_direction := Input.get_axis("move_left", "move_right")

	if is_on_floor() or is_on_wall():
		can_dash = true

	if Input.is_action_pressed("run") and is_on_floor() and input_direction != 0:
		is_running = true
	else:
		is_running = false

	if is_running:
		walk_speed = RUN_SPEED
	else:
		walk_speed = lerp(walk_speed, WALK_SPEED, 1.0 - exp(-ACCELERATION * delta))

	var target_velocity_x := input_direction * walk_speed

	if not is_on_floor() and sign(input_direction) != sign(velocity.x) and input_direction != 0:
		velocity.x = lerp(velocity.x, 0.0, 1.0 - exp(-200 * delta))

	velocity.x = lerp(velocity.x, target_velocity_x, 1.0 - exp((-ACCELERATION * 2) * delta))

func handle_dash() -> void:
	if dash_timer > 0 or dash_lock_timer > 0:
		return

	var input_direction := Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("dash") and input_direction != 0 and can_dash:
		can_dash = false
		is_dashing = true
		dash_timer = DASH_DURATION
		velocity.x = input_direction * DASH_FORCE
		animations.play("dashing")

	if dash_timer <= 0:
		is_dashing = false

func handle_air_effects(delta: float) -> void:
	var input_direction := Input.get_axis("move_left", "move_right")

	if is_on_wall_only():
		if Input.is_action_just_pressed("move_up") and can_wall_jump:
			velocity.x += input_direction * -WALL_KICK_FORCE
			velocity.y = JUMP_FORCE
			can_wall_jump = false
			dash_lock_timer = WALL_JUMP_DASH_LOCK
	else:
		can_wall_jump = true

	# Coyote time reset
	if is_on_floor():
		coyote_timer = COYOTE_TIME

	if not is_on_floor():
		apply_gravity(delta)
		coyote_timer -= delta

	try_jump()

func apply_gravity(delta: float) -> void:
	var multiplier := 1.0
	if is_on_wall_only():
		if velocity.y < 0.0:
			multiplier = 0.8
		else:
			multiplier = 0.3
			if velocity.y > WALL_SLIDE_SPEED:
				velocity.y = WALL_SLIDE_SPEED
		coyote_timer = COYOTE_TIME

	velocity.y += GRAVITY * multiplier * delta

func try_jump() -> void:
	if (coyote_timer > 0.0 or is_on_wall_only()) and Input.is_action_just_pressed("move_up"):
		velocity.y = JUMP_FORCE
		coyote_timer = 0.0
		jump_release_timer = 0.0
	elif velocity.y < 0.0 and jump_release_timer > 0:
		velocity.y *= JUMP_CUT_MULTIPLIER
		jump_release_timer = 0.0

func handle_movement_animations() -> void:
	if sign(velocity.x) == 1:
		animations.flip_h = false
	elif sign(velocity.x) == -1:
		animations.flip_h = true

	if sign(velocity.y) <= -1 and not is_dashing:
		animations.play("jumping")
		return
	if sign(velocity.y) >= 1 and not is_dashing:
		animations.play("falling")
		return
	if is_running and not is_dashing:
		animations.play("running")
		return
	if round(velocity.x) != 0 and not is_dashing:
		animations.play("walking")
		return
	if not is_dashing:
		animations.play("idle")

func handle_damage() -> void:
	velocity *= Vector2(-0.8, -0.6)
	self.collision_mask = 2
	await get_tree().create_timer(0.5).timeout
	self.collision_mask = 6
