#version 300 es

precision highp float;

layout(location = 0) in vec2 pos;

void main()
{
    gl_Position = vec4(pos.x, pos.y, 0., 1.);
}
