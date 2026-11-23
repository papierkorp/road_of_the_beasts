shader_type spatial;
render_mode cull_back;
// A square of the board as painted paper: a colour wash, an ink edge drawn by hand, a pattern for what the ground
// is and one ink sign for when it acts.
// mark: 0 none · 1 Dragon Vein (rings) · 2 acts on entering (points inward) · 3 acts on leaving (points outward) ·
// 4 acts on staying (a ring).
// pattern: 0 none · 1 cracks · 2 thorns · 3 moss · 4 ripples · 5 sand · 6 stones · 7 void · 8 loops · 9 seal ·
// 10 petals · 11 bars. `glow` lets the pattern shine (ground that deals damage).

uniform vec4 wash : source_color = vec4(0.86, 0.82, 0.72, 1.0);
uniform vec4 ink : source_color = vec4(0.12, 0.11, 0.10, 1.0);
uniform vec4 mark_color : source_color = vec4(0.12, 0.11, 0.10, 1.0);
uniform int mark = 0;
uniform int pattern = 0;
uniform vec4 pattern_color : source_color = vec4(0.12, 0.11, 0.10, 1.0);
uniform float pattern_strength = 0.7;
uniform float glow = 0.0;
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

// x: distance to the nearest point of a scattered grid, y: distance to the border between two cells.
vec2 cells(vec2 x) {
	vec2 n = floor(x);
	vec2 f = fract(x);
	float d1 = 8.0;
	float d2 = 8.0;
	for (int j = -1; j <= 1; j++) {
		for (int i = -1; i <= 1; i++) {
			vec2 g = vec2(float(i), float(j));
			vec2 o = vec2(hash(n + g), hash(n + g + 17.3));
			float d = length(g + o - f);
			if (d < d1) {
				d2 = d1;
				d1 = d;
			} else if (d < d2) {
				d2 = d;
			}
		}
	}
	return vec2(d1, d2 - d1);
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

// How much of the pattern lies on a point: p on the square (-0.5 … 0.5), w on the board.
float pattern_of(vec2 p, vec2 w) {
	float r = length(p);
	if (pattern == 1) {                           // cracks that glow
		return 1.0 - smoothstep(0.03, 0.1, cells(w * 3.1).y);
	}
	if (pattern == 2) {                           // thorns: scattered four-pointed barbs
		vec2 q = w * 3.0;
		vec2 id = floor(q);
		vec2 c = fract(q) - 0.5 + (vec2(hash(id), hash(id + 5.1)) - 0.5) * 0.3;
		float turn = hash(id + 9.7) * 1.57;
		c = vec2(c.x * cos(turn) - c.y * sin(turn), c.x * sin(turn) + c.y * cos(turn));
		vec2 a = abs(c);
		float far = max(a.x, a.y);
		return (1.0 - smoothstep(0.0, 0.02, min(a.x, a.y) - 0.07 * (1.0 - far / 0.4))) * step(far, 0.4);
	}
	if (pattern == 3) {                           // moss: soft cushions
		float n = noise(w * 4.6) * 0.65 + noise(w * 11.0) * 0.35;
		return smoothstep(0.5, 0.62, n) * (0.7 + 0.3 * noise(w * 30.0));
	}
	if (pattern == 4) {                           // ripples that run outward
		float ring = abs(fract(r * 5.0 - TIME * 0.22) - 0.5);
		return (1.0 - smoothstep(0.07, 0.15, ring)) * smoothstep(0.52, 0.3, r);
	}
	if (pattern == 5) {                           // sand: wind ribs
		float y = p.y + 0.035 * sin(p.x * 11.0 + noise(w * 2.0) * 4.0);
		return 1.0 - smoothstep(0.1, 0.2, abs(fract(y * 6.0) - 0.5));
	}
	if (pattern == 6) {                           // stones: the joints of broken rock
		return 1.0 - smoothstep(0.03, 0.08, cells(w * 3.7).y);
	}
	if (pattern == 7) {                           // void: a slow dark whirl
		float arm = abs(fract(atan(p.y, p.x) / 6.2832 * 3.0 + r * 2.6 - TIME * 0.04) - 0.5);
		return max(1.0 - smoothstep(0.1, 0.22, arm), 1.0 - smoothstep(0.08, 0.16, r));
	}
	if (pattern == 8) {                           // loops: snares laid side by side
		vec2 q = fract(w * 3.0) - 0.5;
		return 1.0 - smoothstep(0.02, 0.05, abs(length(q) - 0.3));
	}
	if (pattern == 9) {                           // a seal: a square in a square
		float outer = abs(abs(p.x) + abs(p.y) - 0.4);
		float inner = abs(max(abs(p.x), abs(p.y)) - 0.17);
		return 1.0 - smoothstep(0.015, 0.035, min(outer, inner));
	}
	if (pattern == 10) {                          // petals: small four-leaved sprouts
		vec2 q = w * 2.7;
		vec2 id = floor(q);
		vec2 c = fract(q) - 0.5 + (vec2(hash(id), hash(id + 3.3)) - 0.5) * 0.3;
		float leaf = 0.2 * abs(cos(atan(c.y, c.x) * 2.0 + hash(id + 1.7) * 3.0));
		return 1.0 - smoothstep(0.0, 0.03, length(c) - leaf);
	}
	if (pattern == 11) {                          // bars: nothing can be set here
		return 1.0 - smoothstep(0.12, 0.2, abs(fract((p.x - p.y) * 3.5) - 0.5));
	}
	return 0.0;
}

void fragment() {
	vec3 col = wash.rgb;
	vec3 shine = vec3(0.0);
	float cloud = noise(wpos.xz * 2.3) * 0.6 + noise(wpos.xz * 9.0) * 0.4;
	col *= 0.93 + cloud * 0.12;
	if (lnorm.y > 0.5) {
		vec2 p = lpos.xz / tile;
		float d = 0.5 - max(abs(p.x), abs(p.y));
		float wobble = noise(wpos.xz * 14.0) * 0.022 + noise(wpos.xz * 3.0) * 0.02;
		float edge = 1.0 - smoothstep(0.012 + wobble, 0.04 + wobble, d);
		vec2 shaky = vec2(noise(wpos.xz * 6.0) - 0.5, noise(wpos.zx * 6.0) - 0.5) * 0.02;
		float s = sign_of(p + shaky);
		if (pattern > 0) {
			float m = pattern_of(p + shaky, wpos.xz) * smoothstep(0.03, 0.09, d) * (1.0 - s);
			col = mix(col, pattern_color.rgb, m * pattern_strength);
			shine = pattern_color.rgb * m * glow * (0.55 + 0.25 * sin(TIME * 1.7 + wpos.x * 2.0 + wpos.z * 3.0));
		}
		col = mix(col, ink.rgb, edge * 0.82);
		col = mix(col, mark_color.rgb, s * (0.72 + cloud * 0.2));
	} else {
		col = mix(col, ink.rgb, 0.72);
	}
	ALBEDO = col;
	EMISSION = shine;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}
