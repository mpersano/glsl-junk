#version 300 es

precision highp float;

uniform float time;
uniform vec2 resolution;

out vec4 color;

const float PI = 3.14159265358979323844;

//
//  r*cos(a) = R + t*(R*cos(b) - R)
//  r*sin(a) = t*R*sin(b)
//
//  t = (r*sin(a))/(R*sin(b))
//
//  r*cos(a) = R + (r*sin(a))/(R*sin(b))*(R*cos(b) - R)
//  r*cos(a) = R + (r*sin(a)/sin(b))*(cos(b) - 1)
//  r*(cos(a) - (sin(a)/sin(b))*(cos(b) - 1)) = R
//  r = R/(cos(a) - (sin(a)/sin(b))*(cos(b) - 1)) = cos(b)/cos(a - b)! thanks wolfram alpha

float inside_polygon(vec2 pos, vec2 center, float r, float n, float s)
{
        float theta = 2.*PI/n;

        vec2 d = pos - center;

        float a = mod(mod(atan(d.y, d.x) + s, 2.*PI), theta);
        float l = length(d);

        float m = r*cos(.5*theta)/cos(a - .5*theta);

        const float border = .001;

        return smoothstep(m + border, m - border, l);
}

float wobble(vec2 pos)
{
        vec2 d = pos;
        float a = (atan(d.y, d.x) + PI/2.)/(2.*PI);

        float l = .75;

        float t = time;
        float o = t*(1. + l);

        return smoothstep(o, o - l, a);
}

float inside_triangle(vec2 pos, vec2 center, float r, float s)
{
        return inside_polygon(pos, center, wobble(center)*r, 3., s);
}

float inside_triangles(vec2 pos, float r)
{
        const float da = 2.*PI/6.;
        float a = 0.;

        float v = 0.;

        for (int i = 0; i < 6; i++) {
                float c = cos(a);
                float s = sin(a);

                vec2 d = vec2(c, s);
                vec2 n = vec2(-s, c);

                vec2 o0 = (2./3.)*sqrt(3.)*d*r;
                vec2 o1 = (5./6.)*sqrt(3.)*d*r;

                float r_triangle = 1.*r/sqrt(3.);

                v += inside_triangle(pos, o0, r_triangle, a) +
                     inside_triangle(pos, o1 - n*.5*r, r_triangle, a + PI) +
                     inside_triangle(pos, o1 + n*.5*r, r_triangle, a + PI);

                a += da;
        }

        return v;
}

void main()
{
        const float radius = 40.;

        vec2 pos = (gl_FragCoord.xy*2. - resolution)/min(resolution.x, resolution.y);

        float r0 = .25;
        float r1 = 2.*r0;

        float r = mix(r1, r0, time);
        float v = inside_triangles(pos, r) + inside_polygon(pos, vec2(0., 0.), r, 6., PI/6.);

        color = mix(vec4(.5, 1., 1., 1.), vec4(.0, .25, .25, 1.), min(v, 1.));
}
