extends Block
class_name BlockWing

var dir: int = 1
var last_energy_num_0: int = 0
var particle_2

func _init() -> void:
	pass


func activate_move() -> bool:
	# energy_num += 1
	# is_hidden = false
	return false

func _process(delta: float) -> void:
	super._process(delta)
	pattern.scale = Vector2(dir, 1.0)
	if last_energy_num_0 < energy_num:
		last_energy_num_0 = energy_num
		if energy_num == 3:
			particle_2 = ParticleManager.instance.create_particle("constant", position, 16)
		elif energy_num == 4:
			particle_2.queue_free()
			Main.instance.lock_board()
			var f_tween = Root.instance.new_tween()
			f_tween.tween_property(pattern, "position", Vector2(-50*dir, -288) - position, 6)
			f_tween.tween_callback(func():
				Main.instance.unlock_board()
				var real_pattern = pattern.duplicate()
				real_pattern.position = Vector2(-50*dir, -296)
				real_pattern.scale = Vector2(dir, 1.0)
				real_pattern.material = material.duplicate()
				real_pattern.use_parent_material = false
				var fake_center = Main.instance.current_level.fake_center
				if fake_center != null:
					fake_center.add_child(real_pattern)
				pattern.visible = false
			)

func construct_misc(misc: Dictionary) -> void:
	super.construct_misc(misc)
	if misc.has("dir"):
		dir = 1 if misc["dir"] == 1 else -1
		
