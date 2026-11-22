shader_type canvas_item;
// Rice paper: a warm ground with soft mottling, fine fibres and a darker edge. No texture file.

uniform vec4 paper : source_color = vec4(0.937, 0.902, 0.824, 1.0);
uniform vec4 shade : source_color = vec4(0.82, 0.76, 0.64, 1.0);
uniform float grain = 0.035;
uniform float edge = 0.55;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p *= 2.03;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 px = UV / SCREEN_PIXEL_SIZE;
	float clouds = fbm(px / 260.0);
	float fibre = noise(vec2(px.x / 90.0, px.y / 3.0)) * 0.5 + noise(vec2(px.x / 2.5, px.y / 140.0)) * 0.5;
	float speck = hash(floor(px / 1.5));
	vec2 c = UV - 0.5;
	float vignette = smoothstep(0.35, 0.78, length(c * vec2(1.0, 1.15)));
	vec3 col = mix(paper.rgb, shade.rgb, clouds * 0.28 + vignette * edge * 0.5);
	col -= (fibre - 0.5) * grain;
	col -= (speck - 0.5) * grain * 0.6;
	COLOR = vec4(col, 1.0);
}
