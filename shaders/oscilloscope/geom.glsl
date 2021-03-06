#version 330
precision highp float;

uniform int max_output_vertices_U;
uniform int num_points;
in int point_index[];

// sound amplitude in red component
uniform sampler1D SL; // left channel
uniform sampler1D SR; // right channel
uniform vec2 R; // resolution
uniform float T; // time

const float EPS = 1E-6;
const float param = .005;
// uniform float param;
out vec4 uvl;

layout(points) in;
layout(triangle_strip) out;
layout(max_vertices=24) out;

/*
   1------3
   | \    |
   |   \  |
   |     \|
   0------2
*/
void quad(vec2 P0, vec2 P1, float t0, float t1) {
	vec2 dir = P1-P0;
	float dl = length(dir);
	// If the segment is too short, just draw a square
	if (dl < EPS)
		dir = vec2(1.0, 0.0);
	else
	 	dir = normalize(dir);
	vec2 norm = vec2(-dir.y, dir.x);

	uvl = vec4(dl+param, -param, dl, t0);
	gl_Position = vec4(P0+(-dir-norm)*param, 0., 1.);
	EmitVertex(); // 0

	uvl = vec4(dl+param, param, dl, t0);
	gl_Position = vec4(P0+(-dir+norm)*param, 0., 1.);
	EmitVertex(); // 1

	uvl = vec4(-param, -param, dl, t0);
	gl_Position = vec4(P1+(dir-norm)*param, 0., 1.);
	EmitVertex(); // 2
	EndPrimitive();

	uvl = vec4(-param, -param, dl, t0);
	gl_Position = vec4(P1+(dir-norm)*param, 0., 1.);
	EmitVertex(); // 2

	uvl = vec4(dl+param, param, dl, t0);
	gl_Position = vec4(P0+(-dir+norm)*param, 0., 1.);
	EmitVertex(); // 1

	uvl = vec4(-param, param, dl, t0);
	gl_Position = vec4(P1+(dir+norm)*param, 0., 1.);
	EmitVertex(); // 3
	EndPrimitive();
}

void main() {
	int quad_id = point_index[0];
	float t0 = (quad_id+0)/float(num_points);
	float t1 = (quad_id+1)/float(num_points);

	float sr0 = texture(SR, t0).r;
	float sr1 = texture(SR, t1).r;
	vec2 P0 = vec2(t0*2.-1., sr0);
	vec2 P1 = vec2(t1*2.-1., sr1);
	quad(P0, P1, t0, t1);

	// quad(vec2(sl0,t0+.7),vec2(sl1,t1+.7), t0, t1);
	// quad(vec2(t0+.7,sr0),vec2(t1+.7,sr1), t0, t1);
}
