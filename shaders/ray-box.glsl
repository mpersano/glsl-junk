#version 300 es

precision highp float;

uniform float time;
uniform vec2 resolution;

out vec4 color;

const float PI = 3.14159265358979323844;

bool intersects(vec3 ro, vec3 rd, vec3 box_min, vec3 box_max, out float t_intersection)
{
    vec3 t1 = (box_min - ro)/rd;
    vec3 t2 = (box_max - ro)/rd;

    vec3 t_min = min(t1, t2);
    vec3 t_max = max(t1, t2);

    float t_near = max(t_min.x, max(t_min.y, t_min.z));
    float t_far = min(t_max.x, min(t_max.y, t_max.z));

    if (t_near > t_far || t_far < 0.)
        return false;

    t_intersection = t_near;

    return true;
}

// (function borrowed from a shader found on GLSL Sandbox)
mat3 camera(vec3 e, vec3 la)
{
    vec3 roll = vec3(0, 1, 0);
    vec3 f = normalize(la - e);
    vec3 r = normalize(cross(roll, f));
    vec3 u = normalize(cross(f, r));

    return mat3(r, u, f);
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
                float l = length(p);

                float s = 1. + .75*(.5 + .5*sin(time*4.*PI - 3.5*l));

                float t = 0.;
                if (intersects(ro, rd, p - vec3(s), p + vec3(s), t) && t < t_intersection) {
                    t_intersection = t;

                    vec3 n = ro + rd*t_intersection - p;

                    const float EPSILON = 1e-6;
                    normal = step(vec3(s - EPSILON), n) + step(vec3(s - EPSILON), -n);
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
