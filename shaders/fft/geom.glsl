#version 330
precision highp float;

uniform int max_output_vertices_U;
uniform int num_points;
in int point_index[];

// frequency
uniform sampler1D FL; // left channel
uniform sampler1D FR; // right channel
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

	const float stretch = 200.;
	float fl0 = texture(FL, pow(stretch, t0-1.)-(1.-t0)/stretch).r;
	float fl1 = texture(FL, pow(stretch, t1-1.)-(1.-t1)/stretch).r;
	// float fr0 = texture(FR, pow(stretch, t0-1.)-(1.-t0)/stretch).r;
	// float fr1 = texture(FR, pow(stretch, t1-1.)-(1.-t1)/stretch).r;

	vec2 P0;
	vec2 P1;

	// LOG FFT
	// P0 = vec2(t0*2.-1., log2(10.*fl0+0.002)/18.0-.5);
	// P1 = vec2(t1*2.-1., log2(10.*fl1+0.002)/18.0-.5);
	// quad(P0, P1, t0, t1);

	// LOG FFT
	P0 = vec2(t0*2.-1., 2.*sqrt(40.*fl0)/23.0-.9);
	P1 = vec2(t1*2.-1., 2.*sqrt(40.*fl1)/23.0-.9);
	quad(P0, P1, t0, t1);

	// // NORMAL FFT
	// P0 = vec2(t0*2.-1., fl0-1.);
	// P1 = vec2(t1*2.-1., fl1-1.);
	// quad(P0, P1, t0, t1);
}
