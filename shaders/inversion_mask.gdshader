shader_type canvas_item;
// 声明使用屏幕纹理
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // 获取当前片元的纹理颜色
    vec4 texture_color = texture(TEXTURE, UV);
    // 获取屏幕对应位置的颜色
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // 当纹理颜色为黑色时进行反色处理
    if (texture_color == vec4(1,1,1,1)) {
        COLOR = vec4(1.0 - screen_color.rgb, screen_color.a);
    } else {
        // 否则直接输出屏幕原色
        COLOR = screen_color;
    }
} 