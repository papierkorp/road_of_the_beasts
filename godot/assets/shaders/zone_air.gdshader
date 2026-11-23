shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, depth_draw_never;
// The air over a zone square: brush streaks on the four sides of the column above it, so a zone fills its whole
// square and not only the ground. With a direction the streaks run that way (on the sides that lie along it);
// `swirl` (the centre of a pull) sends them around the column; without either they rise. They thin out upward
// and stay sparse, so whatever stands in the zone is still seen.

uniform vec4 color : source_color = vec4(0.45, 0.28, 0.6, 1.0);
uniform vec2 dir = vec2(0.0, 0.0);
uniform float strength = 1.0;
uniform bool swirl = false;
uniform float tall = 0.85;

varying vec3 lpos;
varying vec3 lnorm;

float hash(float n) {
	return fract(sin(n * 91.345) * 47453.5453);
}

void vertex() {
	lpos = VERTEX;
	lnorm = NORMAL;
}

void fragment() {
	if (abs(lnorm.y) > 0.5) {
		discard;
	}
	float up = lpos.y / tall + 0.5;               // 0 at the ground, 1 at the top
	float show = 1.0;
	float a;
	bool moving = dot(dir, dir) > 0.01;
	if (moving || swirl) {
		float along;
		if (moving) {
			vec2 d = normalize(dir);
			along = dot(lpos.xz, d);
			show = 1.0 - abs(dot(normalize(lnorm.xz), d));
		} else {
			// around the column: each side continues the one before it
			along = abs(lnorm.x) > 0.5 ? lpos.z * sign(lnorm.x) : -lpos.x * sign(lnorm.z);
		}
		float rows = 4.0;
		float row = floor(up * rows);
		float in_row = abs(fract(up * rows) - 0.5);
		float dash = fract(along * 1.3 - TIME * (0.45 + 0.35 * hash(row)) + hash(row + 3.1));
		// a streak: a sharp head, a tail that thins out
		float body = smoothstep(0.0, 0.55, dash) * (1.0 - smoothstep(0.6, 0.66, dash));
		a = (1.0 - smoothstep(0.1, 0.34 * (0.35 + 0.65 * dash), in_row)) * body;
	} else {
		float across = abs(lnorm.x) > 0.5 ? lpos.z : lpos.x;
		float cols = 5.0;
		float col = floor((across + 0.5) * cols);
		float in_col = abs(fract((across + 0.5) * cols) - 0.5);
		float dash = fract(up * 1.1 - TIME * (0.2 + 0.2 * hash(col)) + hash(col + 5.7));
		float body = smoothstep(0.0, 0.5, dash) * (1.0 - smoothstep(0.55, 0.62, dash));
		a = (1.0 - smoothstep(0.08, 0.26, in_col)) * body;
	}
	ALBEDO = color.rgb;
	// a thin veil gives the column its body
	ALPHA = (a * show * (1.0 - up * 0.6) * 0.95 + 0.1 * (1.0 - up)) * strength;
}
