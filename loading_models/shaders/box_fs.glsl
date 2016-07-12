#version 130

in vec3 cam_vec;
in vec3 light_vec;
in vec3 norm;
in vec2 tc;

out vec4 color;

uniform sampler2D texture_diffuse;

void main() {
	vec4 tex = texture(texture_diffuse, tc);

	vec3 eye = normalize(cam_vec);
	vec3 norm = normalize(norm);
	vec3 light = normalize(light_vec);
	vec3 reflection = normalize(reflect(light, norm));

	float LN = max(0.0, dot(norm, light));
	float VR = max(0.0, dot(eye, reflection) * sign(LN));

	float light_dist = length(light_vec);
	float attenuation = 1.0 / (1.0 +
					0.09 * light_dist +
					0.0032 * light_dist * light_dist);

	vec4 amb = 0.2 * tex;

	vec4 diff = vec4(LN * tex.xyz, 1);

	vec4 spec = vec4(vec3(0.7 * pow(VR, 10)), 1);

	color = amb + vec4(attenuation * (diff + spec).xyz, 1);
}
