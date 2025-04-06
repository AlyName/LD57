extends Sprite2D
class_name SmallThing

var speed: float = 100
var direction: Vector2 = Vector2.ZERO

var og_y: float = 0


func _ready() -> void:
	var coin = randi_range(0,1)
	if coin == 0:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT
	scale = Vector2(direction.x,1)
	position = Vector2(-1200*direction.x, randf_range(-300, 300))
	z_index = -10
	og_y = position.y

var local_time =0

func _process(delta: float) -> void:
	local_time += delta
	position.x += speed * delta * direction.x
	position.y = og_y + sin(local_time) * 50

	if abs(position.x) > 1400:
		queue_free()
		
