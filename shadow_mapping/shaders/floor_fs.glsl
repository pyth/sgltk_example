#version 130

in vec3 pos_ls;
in vec3 cam_vec;
in vec3 norm;
in vec2 tc;

out vec4 color;

uniform vec3 light_dir;
uniform sampler2D floor_tex;
uniform sampler2D shadow_map;

void main() {
	float saved_depth = texture(shadow_map, pos_ls.xy).r;
	float shadow = pos_ls.z - 0.01 > saved_depth ? 0.0 : 1.0;
	if(pos_ls.x > 1.0 || pos_ls.y > 1.0)
		shadow = 1.0;

	vec4 tex = texture(floor_tex, tc);

	vec3 cam = normalize(cam_vec);
	vec3 norm = normalize(norm);
	vec3 light = -normalize(light_dir);
	vec3 reflection = normalize(reflect(light, norm));

	float LN = max(0.0, dot(norm, light));
	float VR = max(0.0, dot(cam, reflection) * sign(LN));

	vec4 amb = 0.2 * tex;
	vec4 diff = LN * tex;
	vec4 spec = 0.7 * tex * pow(VR, 10);

	color = amb + shadow * (diff + spec);
}
