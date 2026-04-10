extends CPUParticles2D

class_name BrickParticle

const _colors_map = { 
	Brick.COLORS.BLUE: "#4ABFF0",
	Brick.COLORS.GREEN: "#9FCE31",
	Brick.COLORS.RED: "#F23737",
	Brick.COLORS.YELLOW: "#FFCC00",
	Brick.COLORS.PURPLE: "#835995",
	Brick.COLORS.WHITE: "#CCCCCC",
}

var _current_color:Brick.COLORS = Brick.COLORS.BLUE

func set_particle_color(color: Brick.COLORS):
	var new_color = Color(_colors_map[color])
	if new_color: 
		self.color = new_color

func _ready() -> void:
	self.emitting = true

func _on_finished() -> void:
	queue_free()
