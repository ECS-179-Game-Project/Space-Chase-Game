shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D overlay_texture: source_color, filter_nearest_mipmap, repeat_enable;
uniform float weight: hint_range(-1.0, 1.0, 0.1);
uniform float speed: hint_range(0.0, 1.0, 0.02);

varying vec2 st;

void vertex() {
	st.x = UV.x + TIME * speed;
	st.y = UV.y + cos(10.0 * TIME * speed) * 0.02;
}

void fragment() {
	vec3 tex_color = texture(overlay_texture, st).rgb;
	vec4 pixel_color = texture(TEXTURE, UV);
	float replace_weight = (pixel_color.r + pixel_color.g + pixel_color.b) / 3.0 + weight;
	replace_weight = pow(1.5 - replace_weight, 4.0) - 1.0;
	if (replace_weight > 1.0) {
		replace_weight = 1.0;
	} else if (replace_weight < 0.0) {
		replace_weight = 0.0;
	}
	//vec4 overlay_color = vec4(tex_color, replace_weight);
	COLOR = pixel_color + vec4(tex_color, 1.0) * replace_weight;
	//COLOR = vec4(vec3(replace_weight), 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}