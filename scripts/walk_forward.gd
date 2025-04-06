extends AnimatedSprite2D

var ni
func _ready() -> void:
	ni = 1
	self.frame_changed.connect(func():
		ni += 1
		if ni % 8 == 1:
			self.position += Vector2.RIGHT * 416
	)

func run():
	play("run")
