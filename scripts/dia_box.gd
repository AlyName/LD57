extends PanelContainer
class_name DiaBox

# @export var default_width: int = 512
# @export var default_height: int = 512
@export var chars_per_second: float = 30.0  # 字符显示速度

var char_queue: Array[String] = []
var content_label: RichTextLabel

var panel: Panel

func _ready() -> void:
	# 初始化对话框样式
	# custom_minimum_size = Vector2(default_width, default_height)
	var dest_y = position.y
	position = Vector2(position.x, -1000)  # 初始位置在画面外上方

	theme = load("res://main_theme.tres")
	
	# 创建进入动画
	var enter_tween = Root.instance.new_tween()
	enter_tween.tween_property(self, "position", Vector2(position.x, dest_y), 0.5)
	
	# 初始化 MarginContainer
	var margin_container = MarginContainer.new()
	margin_container.theme = theme
	add_child(margin_container)

	# 初始化 Panel
	panel = Panel.new()
	panel.theme = theme
	panel.add_theme_stylebox_override("panel", load("res://albedo_panel.tres"))
	add_child(panel)
	panel.material = ShaderMaterial.new()
	panel.material.shader = load("res://shaders/panel.gdshader")
	panel.material.set_shader_parameter("modulate", Color("544361c2"))
	
	# 初始化文本标签
	content_label = RichTextLabel.new()
	content_label.name = "Content"
	content_label.bbcode_enabled = true
	content_label.fit_content = true
	content_label.scroll_active = false
	content_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	content_label.theme = theme
	add_child(content_label)
	
	# 启动字符显示定时器
	var timer = Timer.new()
	timer.wait_time = 1.0 / chars_per_second
	timer.autostart = true
	timer.timeout.connect(_show_next_char)
	add_child(timer)

	# 设置 Shader
	material = ShaderMaterial.new()
	material.shader = load("res://shaders/outer_glow.gdshader")
	material.set_shader_parameter("rad", 5.0)
	material.set_shader_parameter("intns", 1.05)
	material.set_shader_parameter("r_color", Color(1.0, 1.0, 1.0, 1.0))

func _process(delta: float) -> void:
	material.set_shader_parameter("rad", 5.0 + 3.5 * sin(Root.instance.global_time))

func parse_text(text: String, character: String) -> Array:
	var orig = (text.replace("\\n", "\n")+'\n').split("")
	var parsed = []
	for char in orig:
		if character == "A":
			parsed.append("[color=#FFD9CC]"+char+"[/color]")
		elif character == "B":
			parsed.append("[color=#CCDEFF]"+char+"[/color]")
		elif character == "C":
			parsed.append(char)
	return parsed

func add_dialog(text: String, character: String = "A") -> void:
	if character == "A":
		panel.add_theme_stylebox_override("panel", load("res://albedo_panel.tres"))
	elif character == "B":
		panel.add_theme_stylebox_override("panel", load("res://laqe_panel.tres"))
	elif character == "C":
		panel.add_theme_stylebox_override("panel", load("res://hint_panel.tres"))
	char_queue.append_array(parse_text(text, character))

func _show_next_char() -> void:
	if char_queue.size() > 0:
		content_label.text += char_queue.pop_front()

func close() -> void:
	# 向上移出屏幕
	var fade_tween = Root.instance.new_tween()
	fade_tween.tween_property(self, "position", Vector2(position.x, -1000), 0.5)
	fade_tween.tween_callback(queue_free)

# 使用示例：
# var dia_box = DiaBox.new()
# dia_box.position = Vector2(100, 100)
# get_parent().add_child(dia_box)
# dia_box.add_dialog("这是一个示例对话...")
# # 稍后调用 dia_box.close() 
