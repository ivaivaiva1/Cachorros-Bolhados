shader_type canvas_item;
render_mode blend_premul_alpha;

// === Glow (dourado) ===
uniform float radius = 5.0;
uniform float amount = 0.25;

// === Blink / Hit Flash ===
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_pct : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	vec4 col = texture(TEXTURE, UV);
	vec4 glow = col;

	// --- Glow radial simples ---
	float r = radius;
	glow += texture(TEXTURE, UV + vec2(-r, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(-r, 0.0) * ps);
	glow += texture(TEXTURE, UV + vec2(-r, r) * ps);
	glow += texture(TEXTURE, UV + vec2(0.0, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(0.0, r) * ps);
	glow += texture(TEXTURE, UV + vec2(r, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(r, 0.0) * ps);
	glow += texture(TEXTURE, UV + vec2(r, r) * ps);

	r *= 2.0;
	glow += texture(TEXTURE, UV + vec2(-r, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(-r, 0.0) * ps);
	glow += texture(TEXTURE, UV + vec2(-r, r) * ps);
	glow += texture(TEXTURE, UV + vec2(0.0, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(0.0, r) * ps);
	glow += texture(TEXTURE, UV + vec2(r, -r) * ps);
	glow += texture(TEXTURE, UV + vec2(r, 0.0) * ps);
	glow += texture(TEXTURE, UV + vec2(r, r) * ps);

	glow /= 17.0;
	glow *= amount;
	col.rgb *= col.a;

	vec4 final_col = glow + col;

	// --- Mistura com o flash apenas onde há alpha ---
	final_col.rgb = mix(final_col.rgb, flash_color.rgb, flash_pct * col.a);
	final_col.a = col.a;

	COLOR = final_col;
}
