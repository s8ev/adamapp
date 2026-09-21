class_name RelayPlayer
extends CharacterBody2D
## Movement owns collision and action timers; visual/feedback nodes only observe it.

signal action_started(action: StringName)
signal landed(speed: float)
enum Motion { IDLE, RUN, JUMP, FALL, DASH, SLIDE, DODGE, CROUCH }
const RUN_SPEED := 220.0
const DASH_SPEED := 520.0
const DODGE_SPEED := 310.0
const SLIDE_SPEED := 360.0
const GRAVITY := 1100.0
const JUMP_SPEED := 370.0
const BUFFER := 0.10
const COYOTE := 0.09

var motion := Motion.IDLE
var facing := 1.0
var aim_direction := Vector2.RIGHT
var action_time := 0.0
var dash_cooldown := 0.0
var dodge_cooldown := 0.0
var slide_cooldown := 0.0
var coyote_time := 0.0
var wall_lock := 0.0
var invulnerable := false
var low_profile := false
var controls_enabled := true
var _just_respawned := true
var buffer := {"jump": 0.0, "dash": 0.0, "dodge": 0.0, "slide": 0.0}
var _body_shape: RectangleShape2D
var _clearance_shape: RectangleShape2D
@onready var collider: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	_body_shape = collider.shape.duplicate() as RectangleShape2D
	collider.shape = _body_shape
	_clearance_shape = RectangleShape2D.new()
	_clearance_shape.size = Vector2(13, 28)
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 4.0
	safe_margin = 0.04


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled or event.is_echo():
		return
	for action in buffer:
		if event.is_action_pressed(action):
			buffer[action] = BUFFER


func _process(_delta: float) -> void:
	var offset := get_global_mouse_position() - (global_position - Vector2(0, 20))
	if offset.length_squared() > 4.0:
		aim_direction = offset.normalized()
		facing = 1.0 if aim_direction.x >= 0 else -1.0


func _physics_process(delta: float) -> void:
	var was_grounded := is_on_floor() and not _just_respawned
	_just_respawned = false
	var incoming_y := velocity.y
	coyote_time = COYOTE if was_grounded else maxf(0.0, coyote_time - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
	slide_cooldown = maxf(0.0, slide_cooldown - delta)
	wall_lock = maxf(0.0, wall_lock - delta)
	action_time = maxf(0.0, action_time - delta)
	var axis := Input.get_axis("move_left", "move_right") if controls_enabled else 0.0
	var direction := signf(axis) if axis != 0 else facing
	var action_active := motion in [Motion.DASH, Motion.DODGE, Motion.SLIDE] and action_time > 0
	if not action_active:
		if buffer.dash > 0 and dash_cooldown <= 0:
			_begin(Motion.DASH, 0.12, direction * DASH_SPEED)
			dash_cooldown = 0.45
			buffer.dash = 0.0
		elif buffer.dodge > 0 and dodge_cooldown <= 0 and was_grounded:
			_begin(Motion.DODGE, 0.24, direction * DODGE_SPEED)
			dodge_cooldown = 0.70
			buffer.dodge = 0.0
		elif buffer.slide > 0 and slide_cooldown <= 0 and was_grounded:
			_begin(Motion.SLIDE, 0.55, direction * maxf(absf(velocity.x), SLIDE_SPEED))
			slide_cooldown = 0.70
			buffer.slide = 0.0
		else:
			motion = Motion.RUN if absf(axis) > 0 else Motion.IDLE
	# Jump cancels a slide, but cannot grant a second jump by dashing.
	if buffer.jump > 0 and motion not in [Motion.DASH, Motion.DODGE] and can_stand():
		if is_on_wall() and not was_grounded and wall_lock <= 0:
			velocity = Vector2(get_wall_normal().x * 265.0, -JUMP_SPEED)
			wall_lock = 0.14
			_finish_jump()
			action_started.emit(&"wall_jump")
		elif coyote_time > 0:
			velocity.y = -JUMP_SPEED
			_finish_jump()
	match motion:
		Motion.DASH:
			velocity.y = 0.0
		Motion.SLIDE:
			velocity.x = move_toward(velocity.x, direction * 125.0, 240.0 * delta)
			velocity.y += GRAVITY * delta
		Motion.DODGE:
			velocity.y += GRAVITY * delta
		_:
			var wants_low := (controls_enabled and Input.is_action_pressed("slide") and was_grounded) or not can_stand()
			var max_speed := 90.0 if wants_low else RUN_SPEED
			if wall_lock <= 0:
				velocity.x = move_toward(velocity.x, axis * max_speed, (1800.0 if axis != 0 else 2400.0) * delta)
			var gravity_scale := 1.0 if Input.is_action_pressed("jump") or velocity.y >= 0 else 1.9
			velocity.y = minf(velocity.y + GRAVITY * gravity_scale * delta, 680.0)
			if wants_low:
				motion = Motion.CROUCH
	invulnerable = motion == Motion.DODGE and action_time > 0.14
	_set_low(motion in [Motion.SLIDE, Motion.DODGE, Motion.CROUCH] or not can_stand())
	move_and_slide()
	if motion == Motion.DASH and is_on_wall():
		action_time = 0.0
	if not was_grounded and is_on_floor() and incoming_y > 100:
		landed.emit(incoming_y)
	if motion in [Motion.IDLE, Motion.RUN] and not is_on_floor():
		motion = Motion.JUMP if velocity.y < 0 else Motion.FALL
	for action in buffer:
		buffer[action] = maxf(0.0, float(buffer[action]) - delta)


func _begin(next: Motion, duration: float, speed: float) -> void:
	motion = next
	action_time = duration
	velocity.x = speed
	action_started.emit(StringName(Motion.keys()[next].to_lower()))


func _finish_jump() -> void:
	motion = Motion.JUMP
	action_time = 0.0
	coyote_time = 0.0
	buffer.jump = 0.0
	action_started.emit(&"jump")


func can_stand() -> bool:
	if not is_inside_tree() or _clearance_shape == null:
		return true
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _clearance_shape
	query.transform = Transform2D(0.0, global_position + Vector2(0, -15))
	query.collision_mask = 1
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()


func _set_low(value: bool) -> void:
	if low_profile == value:
		return
	low_profile = value
	_body_shape.size = Vector2(14, 16 if value else 30)
	collider.position.y = -8 if value else -15


func respawn(at: Vector2) -> void:
	_just_respawned = true
	global_position = at
	velocity = Vector2.ZERO
	motion = Motion.IDLE
	action_time = 0.0
	coyote_time = 0.0
	dash_cooldown = 0.0
	dodge_cooldown = 0.0
	slide_cooldown = 0.0
	invulnerable = false
	wall_lock = 0.0
	clear_inputs()
	_set_low(false)
	reset_physics_interpolation()


func clear_inputs() -> void:
	for action in buffer:
		buffer[action] = 0.0
