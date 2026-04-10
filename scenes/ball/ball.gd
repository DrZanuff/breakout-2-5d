extends CharacterBody2D

class_name Ball

signal launched
signal brick_collision(position: Vector2, color: Brick.COLORS)

## Path into instanced `ball_3d_container.tscn` — %Ball3D does not resolve from this scene root.
@onready var ball_3d: MeshInstance3D = $SubViewport/Ball3DContainer/Ball3D

@export var speed: float = 400.0
## How much horizontal aim the paddle adds (0 = only vertical bounce).
@export var paddle_english: float = 0.92
## 2D collision radius — larger = slower spin for the same travel (no-slip baseline).
@export var sphere_radius_pixels: float = 22.090721
## Multiplies 3D roll angle each physics tick (1 = match no-slip, 2 = double spin, etc.).
@export_range(0.0, 5.0, 0.05, "or_greater") var roll_speed_scale: float = 1.0
## Minimum 2D speed (px/s) before applying spin — cuts jitter when nearly still.
@export_range(0.0, 50.0, 0.5, "or_greater") var roll_min_linear_speed: float = 2.0
## Flip if the 3D ball appears to spin the wrong way for your viewport/camera.
@export var roll_sign: float = 1.0

var _released: bool = false
var _paddle: Player
var _follow_offset: Vector2 = Vector2(0, -36)
var _prev_global_pos: Vector2


func _ready() -> void:
	_prev_global_pos = global_position


func setup(paddle: Player) -> void:
	_paddle = paddle
	_released = false
	velocity = Vector2.ZERO
	_prev_global_pos = global_position


func reset_on_paddle() -> void:
	_released = false
	velocity = Vector2.ZERO
	_prev_global_pos = global_position
	if ball_3d:
		ball_3d.rotation = Vector3.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if _released or _paddle == null:
		return
	if event.is_pressed() and not event.is_echo():
		if event.is_action(&"launch_ball"):
			_release_ball()
		elif event is InputEventKey and (event as InputEventKey).keycode == KEY_SPACE:
			_release_ball()


func _physics_process(delta: float) -> void:
	if _paddle == null:
		return
	if not _released:
		global_position = _paddle.global_position + _follow_offset
		_apply_viewport_roll(delta)
		_prev_global_pos = global_position
		return

	var motion := velocity * delta
	var col := move_and_collide(motion)
	if col == null:
		_apply_viewport_roll(delta)
		_prev_global_pos = global_position
		return

	var collider := col.get_collider()
	var normal := col.get_normal()
	var collider_position := col.get_position()
	
	if collider is Brick:
		(collider as Brick).hit()
		brick_collision.emit(collider_position, collider.get_current_color())
		velocity = velocity.bounce(normal)
	elif collider is Player:
		_bounce_off_paddle(col)
	else:
		velocity = velocity.bounce(normal)

	_apply_viewport_roll(delta)
	_prev_global_pos = global_position


## Rolls the SubViewport sphere from effective 2D motion (velocity or carry on paddle).
func _apply_viewport_roll(delta: float) -> void:
	if ball_3d == null or delta <= 0.0:
		return
	var v := (global_position - _prev_global_pos) / delta
	var linear_speed := v.length()
	if linear_speed < roll_min_linear_speed:
		return
	var angle := (
		roll_sign
		* roll_speed_scale
		* linear_speed
		* delta
		/ maxf(sphere_radius_pixels, 0.001)
	)
	# 2D: +y is down. 3D floor XZ with Y up → map motion onto the plane.
	var v_xz := Vector3(v.x, 0.0, -v.y)
	var axis := Vector3.UP.cross(v_xz)
	var ax_len_sq := axis.length_squared()
	if ax_len_sq < 1e-10:
		return
	ball_3d.global_rotate(axis / sqrt(ax_len_sq), angle)


func _release_ball() -> void:
	_released = true
	var dir := Vector2(randf_range(-0.35, 0.35), -1.0).normalized()
	velocity = dir * speed
	launched.emit()


func _bounce_off_paddle(col: KinematicCollision2D) -> void:
	if _paddle == null:
		velocity = velocity.bounce(col.get_normal())
		return
	var rel_x := global_position.x - _paddle.global_position.x
	var half := _paddle.half_width
	var t := clampf(rel_x / maxf(half, 1.0), -1.0, 1.0)
	var out := Vector2(t * paddle_english, -1.0).normalized() * speed
	velocity = out
