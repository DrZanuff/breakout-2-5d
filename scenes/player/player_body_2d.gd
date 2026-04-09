extends CharacterBody2D

class_name Player

## Horizontal speed in pixels per second.
@export var move_speed: float = 520.0
## Paddle half-width used for clamping (should match collision / sprite).
@export var half_width: float = 50.0
## Inner playfield X bounds (from wall collision layout in game.tscn).
@export var play_x_min: float = 0.0
@export var play_x_max: float = 1200.0


func _physics_process(_delta: float) -> void:
	var dir := Input.get_axis(&"move_left", &"move_right")
	velocity = Vector2(dir * move_speed, 0.0)
	move_and_slide()
	global_position.x = clampf(global_position.x, play_x_min + half_width, play_x_max - half_width)
