shader_type canvas_item;

// Screen content drawn before this CanvasItem (same viewport / canvas).
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform float blur_strength : hint_range(0.0, 8.0, 0.1) = 3.0;
// How much the gradient RGB tints the blurred background (0 = pure blur).
uniform float tint_intensity : hint_range(0.0, 2.0, 0.05) = 1.0;
// Slight brightening like matte glass (0 = off).
uniform float frosted_boost : hint_range(0.0, 0.3, 0.01) = 0.06;

vec4 gaussian_blur_9(sampler2D tex, vec2 uv, vec2 pixel_step) {
	vec2 o = pixel_step * blur_strength;
	// 3×3 Gaussian kernel (sigma ≈ 1), normalized.
	vec4 c = textureLod(tex, uv, 0.0) * 0.2270270270;
	c += textureLod(tex, uv + vec2(o.x, 0.0), 0.0) * 0.1945945946;
	c += textureLod(tex, uv - vec2(o.x, 0.0), 0.0) * 0.1945945946;
	c += textureLod(tex, uv + vec2(0.0, o.y), 0.0) * 0.1945945946;
	c += textureLod(tex, uv - vec2(0.0, o.y), 0.0) * 0.1945945946;
	c += textureLod(tex, uv + vec2(o.x, o.y), 0.0) * 0.0540540541;
	c += textureLod(tex, uv - vec2(o.x, o.y), 0.0) * 0.0540540541;
	c += textureLod(tex, uv + vec2(-o.x, o.y), 0.0) * 0.0540540541;
	c += textureLod(tex, uv + vec2(o.x, -o.y), 0.0) * 0.0540540541;
	return c;
}

void fragment() {
	vec4 grad = texture(TEXTURE, UV);
	vec4 blurred = gaussian_blur_9(screen_texture, SCREEN_UV, SCREEN_PIXEL_SIZE);

	// Gradient alpha controls how much tint is applied (low opacity → more of the blur shows).
	float tint_mix = clamp(grad.a * tint_intensity, 0.0, 1.0);
	vec3 base = clamp(blurred.rgb + vec3(frosted_boost * (1.0 - tint_mix)), 0.0, 1.0);
	vec3 glass_rgb = mix(base, grad.rgb, tint_mix);

	COLOR = vec4(glass_rgb, grad.a);
}
