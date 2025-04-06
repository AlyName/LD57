shader_type canvas_item;

uniform float grid_size = 0.025;
uniform vec4 color_1: source_color;
uniform vec4 color_2: source_color; 

void fragment() {
	float tx = UV.x + UV.y + TIME / 50.0;
	float ty = UV.x - UV.y + TIME / 100.0;
	if(ty<0.0) ty += 1.0;
	int gx = int(tx/grid_size)%2;
	int gy = int(ty/grid_size)%2;
	if(((gx == 0)&&(gy!=0))||((gx != 0)&&(gy==0))){
		COLOR = color_1;
	}else{
		COLOR = color_2;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
