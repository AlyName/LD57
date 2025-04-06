shader_type canvas_item;

// 老式显像管效果着色器
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.05; // 扫描线强度
uniform float noise_intensity : hint_range(0.0, 0.1) = 0.02; // 噪点强度
uniform float vignette_power : hint_range(0.0, 5.0) = 0.5; // 渐晕强度
uniform float glow_radius : hint_range(0.0, 1.0) = 0.1; // 辉光半径
uniform vec4 modulate: source_color;

// 随机数生成
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {


    // 屏幕曲率变形
    vec2 uv = UV;
    
    // 色差偏移
    vec4 col=texture(TEXTURE,uv);
	
	//if(texture(TEXTURE,uv).a == 0.0){
		//return;
	//}
    
    // 扫描线效果
    float scanline = sin(uv.y * SCREEN_PIXEL_SIZE.y * 20000.0 + TIME * 1.0);
    scanline = 1.0 - scanline_intensity * (1.0 - smoothstep(0.1, 0.9, abs(scanline)));
	
	scanline = float(round(16.0*scanline))/16.0;
    
    // 辉光效果
    vec4 glow = vec4(0.0);
    for (float i = -3.0; i <= 3.0; i += 1.0) {
        for (float j = -3.0; j <= 3.0; j += 1.0) {
            vec2 offset = vec2(i, j) * SCREEN_PIXEL_SIZE * glow_radius;
            glow += texture(TEXTURE, uv + offset);
        }
    }
    glow /= 49.0;
    
    // 噪点效果
    float noise = mix(1.0 - noise_intensity, 1.0 + noise_intensity, rand(uv + TIME));
    
    // 渐晕效果
    float vignette = 1.0 - length(uv - 0.5) * vignette_power;
    vignette = smoothstep(0.0, 1.0, vignette);
    
    // 最终合成
    COLOR = (col * scanline + glow * 0.3) * noise * vignette * modulate;
    //COLOR.a = modulate.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
