extends CharacterBody2D
class_name Player
const GRAVITY := 500.0
const JUMP_FORCE := -200.0
const ACCELERATION := 15.0
const JUMP_CUT_MULTIPLIER := 0.5
const COYOTE_TIME := 0.2

@onready var animations := $"Animated Sprite"
@onready var cursor := $Area2D/Cursor
@onready var area_2d := $Area2D
@onready var area_shape := $Area2D/CollisionShape2D
var walk_speed := 200.0
var coyote_timer := 0.0
var is_running := false
var track_mouse := false
var is_dashing := false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:

	handle_mouse()
	handle_movement(delta)
	move_and_slide()

func handle_mouse()->void:
	var mouse_pos = get_global_mouse_position()
	
	var area_center = area_2d.global_position
	var radius = area_shape.shape.radius
	
	var distance_to_center = mouse_pos.distance_to(area_center)
	
	var clamped_pos = mouse_pos
	if distance_to_center > radius:
		var direction = (mouse_pos - area_center).normalized()
		clamped_pos = area_center + direction * radius
	
	cursor.global_position = clamped_pos

func handle_movement(delta: float) -> void:
	var input_direction := Input.get_axis("move_left", "move_right")

	
	if Input.is_action_pressed("run") and is_on_floor() and input_direction != 0:
		is_running = true
	else:
		is_running = false
		
	if is_running:
		walk_speed = 300.0
	else:
		walk_speed = lerp(walk_speed, 200.0, 1.0 - exp(-ACCELERATION * delta))
		
	var target_velocity_x := input_direction * walk_speed
	
	if not is_on_floor() and sign(input_direction) != sign(velocity.x) and input_direction != 0:
		target_velocity_x = lerp(target_velocity_x, target_velocity_x * 0.1, 1.0 - exp(-200 * delta))
		
	velocity.x = lerp(velocity.x, target_velocity_x, 1.0 - exp((-ACCELERATION * 2) * delta))
	
	if Input.is_action_just_pressed("dash") and input_direction != 0:
		is_dashing = true
		velocity.x += input_direction * 2000 
		animations.play("dashing")
		await animations.animation_finished
		is_dashing = false
		return
	
	handle_movement_animations(input_direction, delta)
	handle_air_effects(input_direction, delta)

func handle_movement_animations(input_direction: float, delta: float) -> void:
	if sign(velocity.x) == 1:
		animations.flip_h = false
	if sign(velocity.x) == -1:
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

func handle_air_effects(input_direction: float, delta: float) -> void:
	if is_on_wall_only() and Input.is_action_just_pressed("move_up"):
		velocity.x += input_direction * -400
		
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		
	if not is_on_floor():
		var gravity_multiplier := 1.0
		if is_on_wall_only():
			if velocity.y < 0.0:
				gravity_multiplier = 0.8
			else:
				gravity_multiplier = 0.3
				velocity.y = 80
			coyote_timer = COYOTE_TIME
		velocity.y += GRAVITY * gravity_multiplier * delta
		coyote_timer -= delta
		
	if coyote_timer > 0.0 and Input.is_action_just_pressed("move_up"):
		velocity.y = JUMP_FORCE
		coyote_timer = 0.0
		
	if velocity.y < 0.0 and Input.is_action_just_released("move_up"):
		velocity.y *= JUMP_CUT_MULTIPLIER
