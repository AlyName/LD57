extends Block
class_name BlockBook

func _init() -> void:
	pass

func _ready() -> void:
	super._ready()
	star_bar.visible = false

func activate_move():
	print('book' + str(b_pos))
	# energy_num += 1
	return false
