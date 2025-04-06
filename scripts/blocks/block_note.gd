extends Block
class_name BlockNote

var note_type: int = 0

var nts = ['C', 'E', 'G', '#C']

func _init() -> void:
	pass

func activate_move() -> bool:
	# energy_num += 1
	return false

func construct_misc(misc: Dictionary) -> void:
	super.construct_misc(misc)
	if misc.has("notetype"):
		note_type = misc["notetype"]
		var label = Label.new()
		label.text = nts[note_type]
		label.theme = load("res://main_theme.tres")
		label.add_theme_font_size_override("font_size", 20)
		label.position = Vector2(-20,-23)
		label.use_parent_material = true
		add_child(label)

func add_energy(n_num: int) -> void:
	super.add_energy(n_num)
	if n_num > 0:
		add_shake(5.0)
		if Main.instance.current_level != null and Main.instance.current_level is Level5:
			Main.instance.current_level.sound_note(note_type)
		if note_type == 0:
			AudioManager.instance.play_sfx("1")
		elif note_type == 1:
			AudioManager.instance.play_sfx("3")
		elif note_type == 2:
			AudioManager.instance.play_sfx("5")
		elif note_type == 3:
			AudioManager.instance.play_sfx("8")
