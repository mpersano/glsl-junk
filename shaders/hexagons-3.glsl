#version 300 es

precision highp float;

uniform float time;
uniform vec2 resolution;

out vec4 color;

const float PI = 3.14159265358979323844;

const vec2 text_size = vec2(80., 16.); // pixels

const float text[160] = float[160](251,255,255,255,127,255,255,255,255,254,251,193,63,128,127,255,255,255,255,254,251,221,160,187,127,255,1,192,255,254,131,221,187,187,127,255,255,249,0,0,187,221,59,128,1,128,255,92,255,254,187,221,187,187,125,191,127,94,255,254,153,221,160,187,125,191,127,255,31,254,213,221,59,128,125,191,63,255,207,252,212,221,251,251,125,191,191,255,239,253,199,221,251,251,125,191,191,255,239,253,239,92,59,128,1,128,191,255,207,253,199,94,227,251,127,255,63,255,31,252,87,62,248,251,127,255,127,254,255,254,147,255,255,251,127,255,255,248,127,254,57,255,31,0,127,255,255,227,63,255,124,0,255,255,127,255,255,255,143,255);

float wobble(vec2 pos)
{
	return .5 + .5*sin(time*2.*PI + 3.*length(pos));
}

float in_hexagon(vec2 pos, vec2 center, float r)
{
	vec2 d = pos - center;
	float l = r*wobble(center)*cos(PI/6.)/cos(mod(atan(d.x, d.y) + PI, PI/3.) - PI/6.);
	return smoothstep(l + .001, l, length(d));
}

float in_cluster(vec2 pos)
{
	const float d = .2;

	float v = 0.;

	for (float r = -3.; r <= 3.; r++) {
		float l = 7. - abs(r);
		vec2 center = vec2(-.5*(l - 1.)*d, r*d*sqrt(3.)/2.);
		for (float c = 0.; c < l; c++) {
			v += in_hexagon(pos, center, .5*d);
			center += vec2(d, 0.);
		}
	}

	return v;
}

float in_text(vec2 pos)
{
	vec2 p = vec2(pos.x, -pos.y)*80. + .5*text_size;

	if (any(greaterThanEqual(p, text_size)) || any(lessThan(p, vec2(0.))))
		return 0.;

	vec2 uv = floor(p);

	float v = text[int(uv.y*(text_size.x/8.) + floor(uv.x/8.))];

	return 1. - mod(floor(v/pow(2., mod(uv.x, 8.))), 2.);
}

void main()
{
        vec2 pos = (gl_FragCoord.xy*2. - resolution)/min(resolution.x, resolution.y);

	float s = .5 + .5*cos(gl_FragCoord.y*2.*PI/4.);

	vec4 bg = mix(vec4(.25, .25, .25, 1.), vec4(0., 0., 0., 0.), .5*length(pos));

	float v0 = in_cluster(pos)*mix(1., .25, step(pos.y, .2)*step(-.2, pos.y))*s;
	float v1 = in_text(pos)*(s + .25);

	color = mix(bg, vec4(.5, 1., .5, 1.), v0) + mix(vec4(0., 0., 0., 1.), vec4(.75, 1., .75, 1.), v1);
}
