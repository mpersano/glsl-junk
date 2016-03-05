#version 300 es

precision highp float;

uniform vec2 resolution;
uniform float time;

const float PI = 3.14159265358979323844;

out vec4 color;

float wobble(vec2 pos)
{
	return .5 + .5*sin(time*2.*PI + 3.*length(pos));
}

bool inside_triangle(vec2 pos, vec2 center, float r, float s)
{
	float w = wobble(center);

	float r_inner = r*w;

	const float da = 2.*PI/3.;
	float a = s*w;

	for (int i = 0; i < 3; i++) {
		vec2 n = vec2(sin(a), cos(a));

		if (dot(n, pos - (center + r_inner*n)) > 0.)
			return false;
		a += da;
	}
	
	return true;
}

bool inside_hexagon(vec2 pos, vec2 center, float r)
{
	float r_inner = .5*r;

	const float da = 2.*PI/6.;
	float a = 0.;

	for (int i = 0; i < 6; i++) {
		if (inside_triangle(pos, center + r*vec2(sin(a), cos(a)), r_inner, a))
			return true;
		a += da;
	}

	return false;
}

bool inside_cluster(vec2 pos)
{
	float r_outer = .5;

	if (inside_hexagon(pos, vec2(0., 0.), .3*r_outer))
		return true;

	const float da = 2.*PI/6.;
	float a = 0.;
	
	for (int i = 0; i < 6; i++) {
		if (inside_hexagon(pos, r_outer*vec2(sin(a), cos(a)), .35*r_outer))
			return true;
		a += da;
	}

	return false;
}

void main()
{
        vec2 p = (gl_FragCoord.xy*2. - resolution)/min(resolution.x, resolution.y);
	color = inside_cluster(p) ? vec4(.5, 1., 1., 1.) : vec4(.25, .25, .25, 1.);
}
