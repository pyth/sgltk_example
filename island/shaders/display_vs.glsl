#version 330

in vec4 pos_in;
in vec2 tc_in;

out vec2 tc;

uniform mat4 model_matrix;

void main() {
	tc = tc_in;
	vec4 pos = model_matrix * pos_in;
	pos.x *= 2;
	pos.y *= 2;
	gl_Position = pos;
}
