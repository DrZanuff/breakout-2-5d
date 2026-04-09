extends Marker3D

## Peak rotation speed (deg/s). Kept low for a barely-noticeable drift.
@export_range(0.05, 4.0, 0.01, "or_greater") var max_degrees_per_second: float = 0.65
## Minimum seconds before picking a new drift axis/speed.
@export var retarget_interval_min: float = 5.0
## Maximum seconds before picking a new drift axis/speed.
@export var retarget_interval_max: float = 14.0
## How fast current spin eases toward the new target (per second, exponential).
@export var velocity_follow: float = 0.4

var _omega: Vector3 = Vector3.ZERO
var _omega_target: Vector3 = Vector3.ZERO
var _until_retarget: float = 0.0


func _ready() -> void:
	_pick_omega_target()
	_schedule_retarget()


func _schedule_retarget() -> void:
	_until_retarget = randf_range(retarget_interval_min, retarget_interval_max)


func _pick_omega_target() -> void:
	var axis := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	if axis.length_squared() < 1e-6:
		axis = Vector3.UP
	else:
		axis = axis.normalized()
	var min_speed := deg_to_rad(max_degrees_per_second * 0.12)
	var max_speed := deg_to_rad(max_degrees_per_second)
	var speed := randf_range(min_speed, max_speed)
	_omega_target = axis * speed


func _process(delta: float) -> void:
	_until_retarget -= delta
	if _until_retarget <= 0.0:
		_pick_omega_target()
		_schedule_retarget()

	var blend := 1.0 - exp(-velocity_follow * delta)
	_omega = _omega.lerp(_omega_target, blend)

	var mag_sq := _omega.length_squared()
	if mag_sq < 1e-12:
		return
	var mag := sqrt(mag_sq)
	global_rotate(_omega / mag, mag * delta)
