extends CharacterBody2D
class_name Player

const GRAVITY := 600.0
const JUMP_FORCE := -200.0
const ACCELERATION := 15.0
const JUMP_CUT_MULTIPLIER := 0.5
const COYOTE_TIME := 0.2
const RUN_SPEED := 200.0
const WALK_SPEED := 150.0
const DASH_FORCE := 2000.0
const WALL_KICK_FORCE := 600.0
const WALL_SLIDE_SPEED := 80.0

@onready var health_component: HealthComponent = $"Health Component"
@onready var hurtbox: CollisionShape2D = $Hurtbox
@onready var animations := $"Animated Sprite"

var walk_speed := WALK_SPEED
var coyote_timer := 0.0
var is_running := false
var is_dashing := false
var can_dash := true
var can_wall_jump := true

signal died


func _ready() -> void:
	Global.player = self


func _physics_process(delta: float) -> void:
	#prints(global_position)
	handle_movement(delta)
	move_and_slide()


func handle_movement(delta: float) -> void:
	handle_horizontal_movement(delta)
	handle_air_effects(delta)
	handle_dash()
	handle_movement_animations()


func handle_horizontal_movement(delta: float) -> void:
	var input_direction := Input.get_axis("move_left", "move_right")

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
	if is_on_floor() or is_on_wall():
		can_dash = true

	var input_direction := Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("dash") and input_direction != 0 and can_dash:
		can_dash = false
		is_dashing = true
		velocity.x = input_direction * DASH_FORCE
		animations.play("dashing")
		await animations.animation_finished
		is_dashing = false


func handle_air_effects(delta: float) -> void:
	var input_direction := Input.get_axis("move_left", "move_right")

	if is_on_wall_only():
		if Input.is_action_just_pressed("move_up") and can_wall_jump:
			var wall_normal := get_wall_normal()
			velocity.x = wall_normal.x * WALL_KICK_FORCE
			velocity.y = JUMP_FORCE
			can_wall_jump = false
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

	if is_dashing:
		multiplier = 0.8

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
	if Input.is_action_just_released("move_up"):
		velocity.y *= JUMP_CUT_MULTIPLIER


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


func on_died() -> void:
	emit_signal("died")
	velocity = Vector2(0, 0)


func handle_damage() -> void:
	velocity *= Vector2(-0.8, -0.6)
	self.collision_mask = 2
	await get_tree().create_timer(0.5).timeout
	self.collision_mask = 6
