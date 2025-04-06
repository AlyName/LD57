extends Block
class_name BlockHeart

var is_in_enlight = false
var last_energy_num_0: int = 0
var particle_1
var particle_2

func _init() -> void:
	pass

func _ready() -> void:
	await super._ready()
	border.texture = load("res://imgs/block_empty.png")
	star_bar.visible = false
	material.shader = load("res://shaders/outer_glow_rainbow.gdshader")
	z_index += 1

func _process(delta: float) -> void:
	if not initialized:
		return
	if is_in_enlight:
		handle_glow_enlight()
		shake()
		return
	handle_glow(energy_num)
	handle_pos()
	shake()
	if last_energy_num_0 < energy_num:
		last_energy_num_0 = energy_num
		if energy_num == 2:
			particle_1 = ParticleManager.instance.create_particle("constant", position, 16)
		elif energy_num == 3:
			particle_2 = ParticleManager.instance.create_particle("constant", position, 32)
		elif energy_num == 4:
			particle_1.queue_free()
			particle_2.queue_free()
			if Main.instance.n_level_id == 6:
				Main.instance.lock_board()
				var f_tween = Root.instance.new_tween()
				f_tween.tween_property(pattern, "position", Vector2(0, -288) - position, 6)
				f_tween.tween_callback(func():
					Main.instance.unlock_board()
					var real_pattern = pattern.duplicate()
					real_pattern.position = Vector2(0, -296)
					real_pattern.scale = Vector2(1.0, 1.0)
					real_pattern.material = material.duplicate()
					real_pattern.use_parent_material = false
					var fake_center = Main.instance.current_level.fake_center
					if fake_center != null:
						fake_center.add_child(real_pattern)
					pattern.visible = false
				)

func activate_move() -> bool:
	return false

func handle_glow(n_num: int) -> void:
	if n_num == 0:
		glow_strength = 0.0
		shader.set_shader_parameter("disable", true)
		shader.set_shader_parameter("rad", 1.0)
		shader.set_shader_parameter("intns", 1.0)
	else:
		glow_strength = 0.5 * n_num - 0.4
		shader.set_shader_parameter("disable", false)
		shader.set_shader_parameter("rad", 10*glow_strength)
		shader.set_shader_parameter("intns", 1+0.5*glow_strength)

func shake() -> void:
	if Main.instance.n_level_id == 6:
		return
	var strength = max(0,0.75 * energy_num-0.75)
	var offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
	position = calc_pos() + offset

	if energy_num == 3:
		Camera.instance.shake(0.5)

func enlight() -> void:
	is_in_enlight = true

func handle_glow_enlight() -> void:
	glow_strength += 0.02
	shader.set_shader_parameter("rad", 2.5*glow_strength + 12)
	shader.set_shader_parameter("intns", 1+0.5*glow_strength)
