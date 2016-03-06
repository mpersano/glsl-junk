#version 300 es

// see http://glslsandbox.com/e#31298 for uglier webgl version
// (without arrays, for loops without constant expressions, etc)

precision highp float;

uniform float time;
uniform vec2 resolution;

out vec4 color;

const float PI = 3.14159265358979323844;

const vec2 text_size = vec2(80., 16.); // pixels

const float text[54] = float[54](
	0x000004, 0x008000, 0x000000, 0x3e0401, 0x807fc0, 0x000000, 0x040100, 0x445f22,
	0xfe0080, 0x01003f, 0x44227c, 0x008044, 0xff0600, 0x2244ff, 0xfe7fc4, 0xa3007f,
	0x440100, 0x444422, 0x804082, 0x0100a1, 0x5f2266, 0x408244, 0xe00080, 0x222a01,
	0x827fc4, 0x00c040, 0x2b0330, 0x040422, 0x404082, 0x021000, 0x042238, 0x408204,
	0x100040, 0xa31002, 0xfe7fc4, 0x00407f, 0x380230, 0x041ca1, 0xc00080, 0x03e000,
	0x07c1a8, 0x008004, 0x000180, 0x006c01, 0x800400, 0x070000, 0xc60180, 0xffe000,
	0x000080, 0x00c01c, 0x00ff83, 0x008000, 0x700000, 0xffff00 );

float wobble(vec2 pos)
{
	return .5 + .5*sin(time*2.*PI - 3.5*length(pos));
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
	vec2 p = floor(vec2(pos.x, -pos.y)*80. + .5*text_size);

	if (any(greaterThanEqual(p, text_size)) || any(lessThan(p, vec2(0.))))
		return 0.;

	float idx = p.y*text_size.x + p.x;

	float v = text[int(floor(idx/24.))];
	return mod(floor(v/pow(2., mod(idx, 24.))), 2.);
}

void main()
{
        vec2 pos = (gl_FragCoord.xy*2. - resolution)/min(resolution.x, resolution.y);

	float s = .5 + .5*cos(gl_FragCoord.y*2.*PI/4.);

	vec4 bg = mix(vec4(.25, .25, .25, 1.), vec4(0., 0., 0., 0.), .5*length(pos));

	float v0 = in_cluster(pos)*mix(1., .25, step(pos.y, .2)*step(-.2, pos.y))*s;
	float v1 = in_text(pos)*(s + .25);

	color = mix(bg, vec4(.5, 2., .5, 1.), v0) + mix(vec4(0., 0., 0., 1.), vec4(.75, 1., .75, 1.), v1);
}
