extends KinematicBody2D

const GRAVITY = 1000
const JUMP_SPEED = -800
const MOVE_SPEED = 600
const COYOTE_TIME = 0.2
const JUMP_CUT_TIME = 0.05
const WALL_JUMP_SPEED = 20
const WALL_JUMP_GRAVITY_SCALE = 2

var velocity = Vector2.ZERO
var is_grounded = false
var coyote_timer = 0.0
var jump_cut_timer = 0.0
var wall_jump_timer = 0.0
var wall_direction = 0

func _physics_process(delta):
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("jump"):
		if is_grounded or coyote_timer < COYOTE_TIME:
			if not is_grounded and velocity.y < 0:
				jump_cut_timer = JUMP_CUT_TIME
			velocity.y = JUMP_SPEED
		elif wall_jump_timer > 0:
			velocity.x = WALL_JUMP_SPEED * wall_direction
			velocity.y = JUMP_SPEED
			wall_jump_timer = 0
		elif is_touching_wall():
			wall_jump_timer = 0.2
			wall_direction = get_wall_direction()

	input_vector = input_vector.normalized()

	if input_vector.x != 0:
		velocity.x = input_vector.x * MOVE_SPEED
	else:
		velocity.x = 0

	if jump_cut_timer > 0:
		jump_cut_timer -= delta
		if jump_cut_timer <= 0:
			velocity.y = 0

	if wall_jump_timer > 0:
		wall_jump_timer -= delta
		velocity.y += GRAVITY * delta * WALL_JUMP_GRAVITY_SCALE
	else:
		velocity.y += GRAVITY * delta

	velocity = move_and_slide(velocity, Vector2.UP)

	if is_on_floor():
		is_grounded = true
		coyote_timer = 0.0
	else:
		is_grounded = false
		coyote_timer += delta

func is_touching_wall():
	var bodies = get_slide_count()
	for i in range(bodies):
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("walls"):
			return true
	return false

func get_wall_direction():
	var bodies = get_slide_count()
	for i in range(bodies):
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("walls"):
			if collision.normal.x > 0:
				return -1
			else:
				return 1
	return 0
