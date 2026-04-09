extends Node2D

const BRICK_SCENE := preload("res://scenes/brick/brick.tscn")

@onready var player: Player = $PlayerBody2D
@onready var ball: Ball = $Ball
@onready var bricks_root: Node2D = $Bricks
@onready var death_zone: Area2D = $DeathZone
@onready var status: Label = $UI/StatusLabel

@export var starting_lives: int = 3
@export var brick_columns: int = 16
@export var brick_rows: int = 6
@export var brick_origin: Vector2 = Vector2(72, 72)
@export var brick_cell: Vector2 = Vector2(68, 38)

var lives: int
var bricks_remaining: int = 0
var _locked: bool = false


func _enter_tree() -> void:
	_ensure_default_inputs()


func _ready() -> void:
	lives = starting_lives
	death_zone.body_entered.connect(_on_death_zone_body_entered)
	await _spawn_bricks()
	ball.setup(player)
	_update_status()


func _ensure_default_inputs() -> void:
	var bindings: Dictionary = {
		&"move_left": [KEY_LEFT, KEY_A],
		&"move_right": [KEY_RIGHT, KEY_D],
		&"launch_ball": [KEY_SPACE],
	}
	for action in bindings.keys():
		if InputMap.has_action(action):
			continue
		InputMap.add_action(action)
		for key in bindings[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)


func _spawn_bricks() -> void:
	for c in bricks_root.get_children():
		c.queue_free()
	await get_tree().process_frame
	bricks_remaining = 0
	for row in brick_rows:
		for col in brick_columns:
			var brick: Brick = BRICK_SCENE.instantiate() as Brick
			brick.position = brick_origin + Vector2(col * brick_cell.x, row * brick_cell.y)
			brick.destroyed.connect(_on_brick_destroyed)
			bricks_root.add_child(brick)
			bricks_remaining += 1


func _on_brick_destroyed() -> void:
	bricks_remaining -= 1
	if bricks_remaining <= 0 and not _locked:
		_win()


func _on_death_zone_body_entered(body: Node2D) -> void:
	if _locked or not (body is Ball):
		return
	lives -= 1
	(body as Ball).reset_on_paddle()
	if lives <= 0:
		_game_over()
	else:
		_update_status()


func _win() -> void:
	_locked = true
	ball.reset_on_paddle()
	ball.velocity = Vector2.ZERO
	status.text = "You cleared the bricks — press R to play again"


func _game_over() -> void:
	_locked = true
	ball.reset_on_paddle()
	ball.velocity = Vector2.ZERO
	ball.process_mode = Node.PROCESS_MODE_DISABLED
	status.text = "Game over — press R to restart"


func _unhandled_input(event: InputEvent) -> void:
	if not _locked:
		return
	if event.is_pressed() and not event.is_echo() and event is InputEventKey:
		var k := event as InputEventKey
		if k.physical_keycode == KEY_R:
			get_viewport().set_input_as_handled()
			_restart()


func _restart() -> void:
	ball.process_mode = Node.PROCESS_MODE_INHERIT
	_locked = false
	lives = starting_lives
	status.text = ""
	await _spawn_bricks()
	ball.setup(player)
	_update_status()


func _update_status() -> void:
	if _locked:
		return
	status.text = "Lives: %d  |  Bricks: %d  |  A/D or arrows to move, space to launch" % [lives, bricks_remaining]
