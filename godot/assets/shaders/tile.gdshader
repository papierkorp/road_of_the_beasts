shader_type spatial;
render_mode cull_back;
// A square of the board as painted paper: a colour wash, an ink edge drawn by hand and one ink sign for what the
// ground does. mark: 0 none · 1 Dragon Vein (rings) · 2 acts on entering (points inward) · 3 acts on leaving
// (points outward) · 4 acts on staying (a ring).

uniform vec4 wash : source_color = vec4(0.86, 0.82, 0.72, 1.0);
uniform vec4 ink : source_color = vec4(0.12, 0.11, 0.10, 1.0);
uniform vec4 mark_color : source_color = vec4(0.12, 0.11, 0.10, 1.0);
uniform int mark = 0;
uniform float tile = 0.92;

varying vec3 lpos;
varying vec3 lnorm;
varying vec3 wpos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	lpos = VERTEX;
	lnorm = NORMAL;
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float sign_of(vec2 p) {
	float a = max(abs(p.x), abs(p.y));
	float b = min(abs(p.x), abs(p.y));
	float r = length(p);
	float w = 0.012;
	if (mark == 1) {
		float rings = min(abs(r - 0.33), abs(r - 0.19)) - 0.028;
		return 1.0 - smoothstep(-w, w, min(rings, r - 0.075));
	}
	if (mark == 2) {
		return (1.0 - smoothstep(-w, w, b - (a - 0.17) * 0.75)) * step(0.17, a) * (1.0 - smoothstep(0.36 - w, 0.36 + w, a));
	}
	if (mark == 3) {
		return (1.0 - smoothstep(-w, w, b - (0.38 - a) * 0.75)) * smoothstep(0.19 - w, 0.19 + w, a);
	}
	if (mark == 4) {
		return 1.0 - smoothstep(-w, w, abs(r - 0.2) - 0.04);
	}
	return 0.0;
}

void fragment() {
	vec3 col = wash.rgb;
	float cloud = noise(wpos.xz * 2.3) * 0.6 + noise(wpos.xz * 9.0) * 0.4;
	col *= 0.93 + cloud * 0.12;
	if (lnorm.y > 0.5) {
		vec2 p = lpos.xz / tile;
		float d = 0.5 - max(abs(p.x), abs(p.y));
		float wobble = noise(wpos.xz * 14.0) * 0.022 + noise(wpos.xz * 3.0) * 0.02;
		float edge = 1.0 - smoothstep(0.012 + wobble, 0.04 + wobble, d);
		col = mix(col, ink.rgb, edge * 0.82);
		float s = sign_of(p + vec2(noise(wpos.xz * 6.0) - 0.5, noise(wpos.zx * 6.0) - 0.5) * 0.02);
		col = mix(col, mark_color.rgb, s * (0.72 + cloud * 0.2));
	} else {
		col = mix(col, ink.rgb, 0.72);
	}
	ALBEDO = col;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}
