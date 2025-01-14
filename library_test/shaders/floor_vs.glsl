#version 400

layout (location = 0) in mat4 model_matrix;
layout (location = 4) in mat3 normal_matrix;

layout (location = 7) in vec4 pos_in;
layout (location = 8) in vec4 tang_in;
layout (location = 9) in vec3 norm_in;
layout (location = 10) in vec3 tex_coord_in0;

out vec3 pos_v_tc;
out vec3 cam_vec_tc;
out vec3 pos_ts_tc;
out vec3 light_tc;
out vec3 tc_tc;

uniform mat4 view_matrix;
uniform vec3 cam_pos;
uniform vec3 light_pos;

void main() {
	vec4 pos = model_matrix * pos_in;

	vec3 norm = normalize(normal_matrix * norm_in);
	vec3 tang = normalize(normal_matrix * tang_in.xyz);
	vec3 bitang = normalize(cross(tang, norm));
	mat3 tangent_matrix = transpose(mat3(tang, bitang, norm));

	pos_v_tc = (view_matrix * pos).xyz;
	pos_ts_tc = tangent_matrix * pos.xyz;
	light_tc = tangent_matrix * (light_pos - pos.xyz);
	cam_vec_tc = tangent_matrix * (cam_pos - pos.xyz);

	tc_tc = tex_coord_in0;

	gl_Position = pos;
}
