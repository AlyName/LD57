shader_type canvas_item;

uniform float alpha = 0.0;
uniform vec4 color_a : source_color;
uniform vec4 color_b : source_color;
uniform vec4 color_c : source_color;
uniform vec4 color_d : source_color;

void fragment() {
	float x = float(int(UV.x * 200.0))/200.0;
	float y = float(int(UV.y * 200.0))/200.0;
	float ya = sin(x*6.0+TIME) / 8.0 + 0.2;
	float yb = sin(x*6.0-TIME) / 8.0 + 0.5;
	float yc = sin(x*6.0+TIME) / 8.0 + 0.8;
	if(y<ya){
		COLOR = color_a;
	}else if(y<yb){
		COLOR = color_b;
	}else if(y<yc){
		COLOR = color_c;
	}else{
		COLOR = color_d;
	}
	COLOR.a = alpha;
}

