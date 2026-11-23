shader_type spatial;
render_mode cull_front, unshaded, shadows_disabled;
// The ink line around a figure: the back faces of the mesh, pushed outward and painted in ink. The line keeps its
// width whatever the scale of the part. form: 0 round meshes (pushed along the normal; the line swells a little
// along the mesh, as a brush does) · 1 boxes and prisms (pushed from the corners) · 2 cylinders and cones (pushed
// away from the axis and from the middle), so the line stays closed at hard edges.

uniform vec4 ink : source_color = vec4(0.12, 0.11, 0.10, 1.0);
uniform float width = 0.016;
uniform int form = 0;

void vertex() {
	vec3 dir = normalize(MODEL_NORMAL_MATRIX * NORMAL);
	float w = width * (0.8 + 0.35 * sin(dot(VERTEX, vec3(19.0, 27.0, 23.0))));
	if (form == 1) {
		vec3 corner = sign(VERTEX);
		if (dot(corner, corner) > 0.5) {
			dir = normalize(mat3(MODEL_MATRIX) * normalize(corner));
			w = width * 1.6;
		}
	} else if (form == 2) {
		vec2 away = length(VERTEX.xz) > 0.0001 ? normalize(VERTEX.xz) : vec2(0.0);
		vec3 rim = vec3(away.x, sign(VERTEX.y), away.y);
		if (dot(rim, rim) > 0.5) {
			dir = normalize(mat3(MODEL_MATRIX) * normalize(rim));
			w = width * 1.3;
		}
	}
	VERTEX += inverse(mat3(MODEL_MATRIX)) * (dir * w);
}

void fragment() {
	ALBEDO = ink.rgb;
}
