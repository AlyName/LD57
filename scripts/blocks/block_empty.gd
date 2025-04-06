extends Block
class_name BlockEmpty

func _init() -> void:
	pass

func _ready() -> void:
	super._ready()
	star_bar.visible = false

func activate_move():
	print('empty' + str(b_pos))
	# if energy_num > 0:
	# 	energy_num -= 1
	return false
