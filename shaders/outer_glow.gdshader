shader_type canvas_item;

uniform float alpha = 1.0;
uniform float rad;
uniform float intns;
uniform vec4 r_color: source_color;

float _2DCone(float x,float y,float radius){
	// calc the standard 2D gaussian
	return max(0.0,1.0-sqrt(x*x + y*y)/radius);
}
vec4 _pureOuterGlow(sampler2D _samp_inglow, vec2 _uv_inglow, float _rad_inglow, float _intns_inglow){
	// Step 1: Get the color of the texture
	vec4 col_origin = texture(_samp_inglow, _uv_inglow);
	if(col_origin.a <=0.01){
		col_origin = vec4(0,0,0,0);
	}else{
		col_origin = r_color;
	}
	vec4 col_blur = vec4(0,0,0,0);
	// Step 2.1: Calculate the blur color
	int _amount_inglow = int(_rad_inglow);
	float total_v = 0.0;
	for(int i = -_amount_inglow; i <= _amount_inglow; i++){
		for(int j = -_amount_inglow; j <= _amount_inglow; j++){
			vec2 _coord_blur = _uv_inglow + vec2(float(i),float(j))*0.01;
			float _intensity = _2DCone(float(i),float(j),_rad_inglow);
			col_blur += texture(_samp_inglow,_coord_blur)*_intensity;
			total_v += _intensity;
		}
	}
	col_blur /= total_v;
	// Step 2.2: Calculate the final color
	//vec4 col_final = col_origin*(1.0-_intns_inglow)+col_blur*_intns_inglow;
	//float c = col_origin.a / (col_origin.a + col_blur.a);
	//vec4 col_final = col_origin * c + col_blur * (1.0-c);
	vec4 col_final = vec4(r_color.rgb,col_origin.a+col_blur.a);
	//if(col_origin.a == 1.0){
		//col_final.a=1.0;
	//}
	vec4 col_rea = vec4(col_final.r*_intns_inglow,
		col_final.g*_intns_inglow,
		col_final.b*_intns_inglow,
		col_final.a*(_intns_inglow*2.0-1.0));
	return col_rea;
}

void fragment() {
	// if(COLOR.a < 0.05){
		COLOR=_pureOuterGlow(TEXTURE, UV,rad, intns);
		//COLOR.a = alpha;
	// }
	// COLOR.a=0.5;

}
