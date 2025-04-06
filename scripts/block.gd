extends Node2D
class_name Block

# const
const SIZE: int = 64
const MAX_ENERGY: int = 5
const STAR_BAR_Y_OFFSET: float = 0.0
const STAR_BAR_X_EXTEND: float = 55.0
const DT: float = 0.3

# meta
var b_id: int
var b_type: String
var border_sprite: Texture2D
var pattern_sprite: Texture2D
var color: Color
var block_name: String
var block_desc: String

# in-game
var initialized: bool = false
var is_hidden: bool = false
var b_pos: Vector2
var energy_num: int
var extra_data: Dictionary
var glow_strength: float = 0.0


# display
var border: Node2D
var pattern: Node2D
var star_bar: Node2D
var shader: ShaderMaterial
var sudden_intns: float = 0.0
var sudden_rad: float = 0.0
var hidden_texture: Texture2D = preload("res://imgs/block_hide.png")

# misc
var shake_k: float = 0.0
var lerp_color: Color
var last_b_pos: Vector2
var last_energy_num: int = 0
var history_max_energy: int = 0
var paused_process: bool = false
var p_tween: Tween

func _init() -> void:
	pass

func _ready() -> void:
	border = Sprite2D.new()
	border.texture = border_sprite
	border.use_parent_material = true
	add_child(border)
	pattern = Sprite2D.new()
	if not is_hidden:
		pattern.texture = pattern_sprite
	else:
		pattern.texture = hidden_texture
	pattern.use_parent_material = true
	add_child(pattern)
	star_bar = Node2D.new()
	star_bar.position.y = STAR_BAR_Y_OFFSET
	star_bar.use_parent_material = true
	add_child(star_bar)

	await fly_in()
	material = ShaderMaterial.new()
	material.shader = load("res://shaders/outer_glow.gdshader")
	shader = material
	modulate = Color(1.0,1.0,1.0,1.0)
	initialized = true


func _process(delta: float) -> void:
	if not initialized:
		return
	handle_glow(energy_num)
	if last_energy_num != energy_num:
		update_star_bar(last_energy_num, energy_num)
		last_energy_num = energy_num
		if history_max_energy == 0 and energy_num > 0:
			first_show()
		history_max_energy = max(history_max_energy, energy_num)
	handle_pos()


func handle_glow(n_num: int) -> void:
	if n_num == 0:
		glow_strength = lerp(glow_strength, 0.0, 0.1)
		lerp_color = lerp(lerp_color, Color(0.2,0.2,0.2,1.0), 0.1)
		shader.set_shader_parameter("r_color", lerp_color)
		shader.set_shader_parameter("rad", 1.0)
		shader.set_shader_parameter("intns", 1.0)
	else:
		glow_strength = lerp(glow_strength, 0.1 + 0.2 * n_num + 0.1 * sin(Root.instance.global_time), 0.1)
		lerp_color = lerp(lerp_color, color, 0.1)
		shader.set_shader_parameter("r_color", lerp_color)
		shader.set_shader_parameter("rad", 10*glow_strength+sudden_rad)
		shader.set_shader_parameter("intns", 1+0.5*glow_strength+sudden_intns)
	sudden_intns = lerp(sudden_intns, 0.0, 0.1)
	sudden_rad = lerp(sudden_rad, 0.0, 0.1)

func sudden_handle_pos() -> void:
	position = calc_pos()
	last_b_pos = b_pos

func handle_pos() -> void:
	if last_b_pos != b_pos:
		if p_tween != null:
			p_tween.kill()
		p_tween = Root.instance.new_tween()
		p_tween.tween_property(self, "position", calc_pos(), DT)
		last_b_pos = b_pos
	elif shake_k > 0.05:
		spring_shake()

func fly_in() -> void:
	modulate = Color(0.2,0.2,0.2,1.0)
	lerp_color = Color(0.2,0.2,0.2,1.0)
	var init_pos = calc_pos()
	var dice = randf_range(0, 1)
	if dice < 0.25:
		init_pos.x = 0.75 * Root.instance.width
	elif dice < 0.5:
		init_pos.x = -0.75 * Root.instance.width
	elif dice < 0.75:
		init_pos.y = 0.75 * Root.instance.height
	else:
		init_pos.y = -0.75 * Root.instance.height
	position = init_pos
	
	var g_tween = Root.instance.new_tween().set_trans(Tween.TRANS_CUBIC)
	g_tween.tween_interval(randf_range(0, 2*DT))
	
	g_tween.tween_property(self, "position", calc_pos(), randf_range(4*DT, 8*DT))
	await g_tween.finished
	last_b_pos = b_pos

func fly_out() -> void:
	var final_pos = calc_pos()
	var dice = randf_range(0, 1)
	if dice < 0.25:
		final_pos.x = 0.75 * Root.instance.width
	elif dice < 0.5:
		final_pos.x = -0.75 * Root.instance.width
	elif dice < 0.75:
		final_pos.y = 0.75 * Root.instance.height
	else:
		final_pos.y = -0.75 * Root.instance.height

	var g_tween = Root.instance.new_tween().set_trans(Tween.TRANS_CUBIC)
	g_tween.tween_interval(randf_range(0, 2*DT))
	
	g_tween.tween_property(self, "position", final_pos, randf_range(4*DT, 8*DT))
	await g_tween.finished

func activate_move():
	return false

func first_show() -> void:
	pass

func construct_misc(misc: Dictionary) -> void:
	if misc.has("hidden"):
		is_hidden = misc.hidden

func calc_pos() -> Vector2:
	var x = b_pos.x * SIZE
	var y = b_pos.y * SIZE
	var offset = Vector2(Main.instance.width, Main.instance.height) * SIZE / 2
	return Vector2(x, y) - offset + Vector2(SIZE / 2, SIZE / 2)

func clear_star_bar() -> void:
	for child in star_bar.get_children():
		if child is Path2D:
			for t in child.get_children():
				if t is PathFollow2D and t.has_meta("orbit_tween"):
					t.get_meta("orbit_tween").kill()
		child.queue_free()

func update_star_bar(last_n_num: int, n_num: int) -> void:
	# clear_star_bar()
	if last_n_num > n_num:
		for i in range(n_num, last_n_num):
			print(i)
			var child = star_bar.get_child(i)
			if child != null:
				child.queue_free()
	else:
		for i in range(last_n_num, n_num):
			# 创建路径系统
			var path = Path2D.new()
			var follow = PathFollow2D.new()
			var star = Sprite2D.new()
			var particle_small = load("res://scenes/particle_small.tscn").instantiate()
			
			# 配置星星
			star.texture = load("res://imgs/shiny_star.png")
			star.scale = Vector2(0.8,0.8)
			star.z_index = 1
			
			# 生成随机椭圆参数
			var a = randf_range(15.0, 35.0)
			var b = randf_range(10.0, 15.0)
			var rota = randf_range(0.0, TAU)
			var tt = randf_range(14,16)
			
			# 创建椭圆路径
			var curve = Curve2D.new()
			for t in range(0, 360, 10):
				var angle = deg_to_rad(t)
				var point = Vector2(a * cos(angle), b * sin(angle)).rotated(rota)
				curve.add_point(point)
			curve.add_point(curve.get_point_position(0))  # 闭合路径
			
			# 组装节点
			path.curve = curve
			follow.rotates = false
			path.add_child(follow)
			follow.add_child(star)
			star_bar.add_child(path)
			star.add_child(particle_small)
			# 创建循环动画
			var tween = Root.instance.new_tween().set_trans(Tween.TRANS_LINEAR)
			tween.bind_node(follow)
			tween.set_loops()
			tween.tween_property(follow, "progress_ratio", 1.0, tt)
			tween.tween_callback(func():
				follow.progress_ratio = 0.0
			)
			star.set_meta("orbit_tween", tween)

func add_energy(n_num: int) -> void:
	# AudioManager.instance.play_sfx("powerup")
	energy_num += n_num
	if energy_num > MAX_ENERGY:
		energy_num = MAX_ENERGY
	if energy_num > 0 and is_hidden:
		is_hidden = false
		pattern.texture = pattern_sprite

func spark(intns: float=1.0, rad: float=5.0) -> void:
	sudden_intns += intns
	sudden_rad += rad

func add_shake(k: float) -> void:
	shake_k += k

func spring_shake():
	shake_k *= 0.99
	shake_k = max(shake_k, 0.0)
	if shake_k <= 0.05:
		shake_k = 0.0
	else:
		position = calc_pos() + Vector2(randf_range(-shake_k, shake_k), randf_range(-shake_k, shake_k))

func pause_process() -> void:
	paused_process = true

func resume_process() -> void:
	paused_process = false
