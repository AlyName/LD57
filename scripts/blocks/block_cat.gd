extends Block
class_name BlockCat

func _init() -> void:
	pass

func _ready() -> void:
	super._ready()
	pattern.texture = load("res://imgs/block_unknown.png")

func activate_move() -> bool:
	return false

func first_show() -> void:
	pattern.texture = load("res://imgs/block_cat.png")
