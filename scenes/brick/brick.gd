extends StaticBody2D

class_name Brick

signal destroyed

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

## Seconds to fade the sprite after a hit (starts immediately).
@export var fade_duration: float = 0.42
@export var fade_ease: Tween.EaseType = Tween.EASE_IN
@export var fade_trans: Tween.TransitionType = Tween.TRANS_QUAD

enum COLORS {BLUE,GREEN,RED,YELLOW,PURPLE,WHITE}
const _colors_map = { 
	COLORS.BLUE: "blue",
	COLORS.GREEN: "green",
	COLORS.RED: "red",
	COLORS.YELLOW: "yellow",
	COLORS.PURPLE: "purple",
	COLORS.WHITE: "white",
}

var _current_color:COLORS = COLORS.BLUE

var _gone: bool = false


func _ready() -> void:
	add_to_group(&"bricks")
	_current_color = randi_range(COLORS.BLUE, COLORS.WHITE) as COLORS
	_sprite.play("%s_idle" % _colors_map[_current_color])


func hit() -> void:
	if _gone:
		return
	_gone = true
	destroyed.emit()
	collision_layer = 0
	collision_mask = 0
	_sprite.play("%s_col" % _colors_map[_current_color])
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_sprite, ^"modulate:a", 0.0, fade_duration).set_ease(fade_ease).set_trans(fade_trans)
	tw.chain().tween_callback(queue_free)
