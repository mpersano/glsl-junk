#version 300 es

precision highp float;

uniform float time;
uniform vec2 resolution;

out vec4 color;

const float PI = 3.14159265358979323844;

bool intersects(vec3 ro, vec3 rd, vec3 box_min, vec3 box_max, out float t_intersection)
{
    float t_near = -1e6;
    float t_far = 1e6;

    vec3 normal = vec3(0.);

    for (int i = 0; i < 3; i++) {
        if (rd[i] == 0.) {
            // ray is parallel to plane
            if (ro[i] < box_min[i] || ro[i] > box_max[i])
                return false;
        } else {
            vec2 t = vec2(box_min[i] - ro[i], box_max[i] - ro[i])/rd[i];

            if (t[0] > t[1])
                t = t.yx;

            t_near = max(t_near, t[0]);
            t_far = min(t_far, t[1]);

            if (t_near > t_far || t_far < 0.)
                return false;
        }
    }

    t_intersection = t_near;

    return true;
}

mat3 camera(vec3 e, vec3 la) {
    vec3 roll = vec3(0, 1, 0);
    vec3 f = normalize(la - e);
    vec3 r = normalize(cross(roll, f));
    vec3 u = normalize(cross(f, r));
    
    return mat3(r, u, f);
}

float wobble(float l)
{
	return .5 + .5*sin(time*4.*PI - 3.5*l);
}

void main(void)
{
    vec2 uv = (2.*gl_FragCoord.xy - resolution)/min(resolution.x, resolution.y);

    float a = time*2.*PI;

    vec3 ro = 8.0*vec3(cos(a), 1.0, -sin(a));
    vec3 rd = camera(ro, vec3(0))*normalize(vec3(uv, 2.));

    const float INFINITY = 1e6;

    float t_intersection = INFINITY;

    const float cluster_size = 3.;
    vec3 normal = vec3(0.);

    for (float i = 0.; i < cluster_size; i++) {
        for (float j = 0.; j < cluster_size; j++) {
            for (float k = 0.; k < cluster_size; k++) {
                vec3 p = 1.25*(vec3(i, j, k) - .5*vec3(cluster_size - 1.));

                float s = 1. + .75*wobble(length(p));

                float t = 0.;

                if (intersects(ro, rd, p - vec3(s), p + vec3(s), t) && t < t_intersection) {
                    t_intersection = t;

                    vec3 n = ro + rd*t_intersection - p;

                    const float EPSILON = 1e-6;

                    vec3 q0 = step(vec3(s - EPSILON), n);
                    vec3 q1 = step(vec3(s - EPSILON), -n);

                    normal = q0 + q1;
                }
            }
        }
    }

    vec4 c;

    if (t_intersection == INFINITY) {
	    c = mix(vec4(.5, .5, .5, 1.), vec4(0., 0., 0., 0.), .5*length(uv));
    } else {
        float v = .5 + .5*clamp(dot(normalize(normal), normalize(vec3(1., 2., -.5))), 0., 1.);
        c = vec4(v, v, v, 1.);
    }

	color = (.5 + .5*cos(gl_FragCoord.y*2.*PI/3.))*c;
}
