shader_type canvas_item;

uniform vec4 r_color: source_color;
uniform float r_speed = 0.01;
uniform float alpha = 1.0;

void fragment() {
	vec2 b_uv = UV + vec2(TIME*r_speed, 0.0);
	b_uv.x -= float(int(b_uv.x));
	if (b_uv.x < 0.0){
		b_uv.x += 1.0;
	}
	COLOR = texture(TEXTURE, b_uv) * r_color;
	COLOR.a *= alpha;
}
