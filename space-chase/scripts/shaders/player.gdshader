// NOTE: Shader automatically converted from Godot Engine 4.3.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;

uniform vec4 inputColor: source_color = vec4(1.0);
uniform float intensity: hint_range(0.0, 1.0, 0.1);
uniform float blendOriginal: hint_range(0.0, 1.0, 0.1);

uniform vec4 tintColor: source_color = vec4(1.0);

varying vec4 modulateColor;


void vertex() {
	modulateColor = COLOR;
}


void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	float greyscale = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;
	vec3 shiftedColor = vec3(greyscale) + (1.0 - pow(greyscale, 2.0)) * (intensity) * inputColor.rgb;
	vec3 finalColor = mix(pixelColor.rgb, shiftedColor, blendOriginal);
	finalColor = finalColor * tintColor.rgb;
	//COLOR = color;
	COLOR = vec4(finalColor, pixelColor.a) * modulateColor;
}