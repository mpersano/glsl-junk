#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;
uniform float time;

const float PI = 3.14159265;

const float W = .04;

const float Q0 = .3;
const float Q1 = Q0 + .5*W;

const float R0 = .21;
const float R1 = R0 + W;

const float HB = .02;

const float HR = .04;
const float HW = .36;

const float M0 = .13;
const float M1 = M0 + W;

const float EW = .08;
const float EY = -.02;
const float ER = .05;
const float EA = .03;

const float TB = .01;
const float TR0 = R1 + TB;
const float TR1 = Q0 - TB;

float outer_circle(vec2 p)
{
    float r = length(p);

    if (r > Q0 && r < Q1) {
        if (p.x < 0 || p.y < -HR - W || p.y > HR + W) {
            return 1.;
        }
    }

    return 0.;
}

float inner_circle(vec2 p)
{
    float r = length(p);

    if (r > R0 && r < R1) {
        if (p.x > 0) {
            if (p.y < -HR || p.y > HR + W) {
                return 1.;
            }
        } else {
            if (p.y > HR || p.y < HR - HB) {
                return 1.;
            }
        }
    }

    return 0.;
}

float hat(vec2 p)
{
    float r = length(p);

    if (p.y < -HR && p.y > -HR - W && p.x > 0 && p.x < HW && r > R1) {
        return 1.;
    }

    if (p.y > HR && p.y < HR + W && p.x < HW && (p.x > 0. || r < R0)) {
        return 1.;
    }

    if (p.x > HW && abs(p.y) < HR + W) {
        float r0 = length(p - vec2(HW, 0.));
        if (r0 < HR + W && r0 > HR) {
            return 1.;
        }
    }

    return 0.;
}

float mouth(vec2 p)
{
    float r = length(p);

    if (r < M1 && p.y < -HR && (r > M0 || p.y > -HR - W)) {
        return 1.;
    }

    return 0.;
}

float eye(vec2 p, float x0)
{
    if (p.y > EY) {
        float r0 = length(p - vec2(x0, EY));

        if (r0 < ER) {
            float r1 = length(p - vec2(x0, EY - EA));

            if (r1 > length(vec2(x0 - ER, EY) - vec2(x0, EY - EA))) {
                return 1.;
            }
        }
    }

    return 0.;
}

float hash(float n) { return fract(sin(n) * 1e4); }
float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float pattern(vec2 p)
{
    float r = length(p);

    if (r > TR0 && r < TR1) {
        if (p.x < 0 || p.y < -HR - W || p.y > HR + W) {
            vec2 uv = vec2(
                (atan(p.y, p.x) + time + PI)/2.*PI,
                (r - TR0)/(TR1 - TR0));
            return hash(uv);
        }
    }

    return 0.;
}

void main(void)
{
    vec2 p = gl_FragCoord.xy/resolution.xy - vec2(.5);
    float c = outer_circle(p) + inner_circle(p) + hat(p) + mouth(p) + eye(p, -EW) + eye(p, EW) + pattern(p);
    gl_FragColor = mix(vec4(1.), vec4(0., 0., .6, 1.), c);
}
