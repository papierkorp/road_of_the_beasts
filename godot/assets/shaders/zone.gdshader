shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, depth_draw_never;
// A zone on a square, painted on the paper: a hatched wash in the zone's colour and one brush arrow in the
// direction it moves whoever arrives or ends a turn inside. dir = (0, 0): no arrow (the centre of a pull).

uniform vec4 color : source_color = vec4(0.45, 0.28, 0.6, 1.0);
uniform vec2 dir = vec2(0.0, 0.0);
uniform float strength = 1.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 p = UV - 0.5;
	float hatch = smoothstep(0.35, 0.65, abs(fract((p.x + p.y) * 7.0) - 0.5) * 2.0);
	float edge = smoothstep(0.5, 0.42, max(abs(p.x), abs(p.y)));
	float a = (0.16 + 0.2 * hatch) * edge;
	if (dot(dir, dir) > 0.01) {
		vec2 d = normalize(dir);
		float along = dot(p, d);
		float across = abs(dot(p, vec2(-d.y, d.x)));
		float shaft = step(-0.32, along) * step(along, 0.1) * (1.0 - smoothstep(0.045, 0.06, across + (along + 0.32) * -0.02));
		float head = step(0.06, along) * (1.0 - smoothstep(-0.01, 0.01, across - (0.36 - along) * 0.72));
		a = max(a, max(shaft, head) * 0.92);
	} else {
		float r = length(p);
		a = max(a, (1.0 - smoothstep(0.03, 0.045, abs(r - 0.16))) * 0.9);
		a = max(a, (1.0 - smoothstep(0.05, 0.065, r)) * 0.9);
	}
	ALBEDO = color.rgb;
	ALPHA = a * strength;
}
