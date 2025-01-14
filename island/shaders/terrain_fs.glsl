#version 400

in vec3 pos_w;
in vec2 tc;
in vec3 norm;
in float height;
in vec4 pos_ls[3];

layout (location = 0) out vec4 color;
layout (location = 1) out float shadow;
layout (location = 2) out vec4 position;
layout (location = 3) out vec3 normals;
layout (location = 4) out float spec;

uniform vec3 cam_pos;
uniform float sand_level;
uniform float sand_mix_level;
uniform float grass_level;
uniform float grass_mix_level;
uniform float rock_level;
uniform float rock_mix_level;
uniform vec3 shadow_distance;
uniform sampler2DArray terrain_texture;
uniform sampler2DArrayShadow shadow_map;

void main() {
	float eta = 0.0001;
	float shadow_fade_dist = 5;

	vec4 tex_sand = texture(terrain_texture, vec3(tc, 0));
	vec4 tex_grass = texture(terrain_texture, vec3(tc, 1));
	vec4 tex_rock = texture(terrain_texture, vec3(tc, 2));
	vec4 tex_snow = texture(terrain_texture, vec3(tc, 3));

	if(height <= sand_level) {
		color = tex_sand;
	} else if(height <= sand_mix_level || abs(height - sand_level) < eta) {
		color = mix(tex_sand, tex_grass, (height - sand_level) / (sand_mix_level - sand_level));
	} else if(height <= grass_level || abs(height - grass_level) < eta) {
		color = tex_grass;
	} else if(height <= grass_mix_level || abs(height - grass_level) < eta) {
		color = mix(tex_grass, tex_rock, (height - grass_level) / (grass_mix_level - grass_level));
	} else if(height <= rock_level || abs(height - rock_level) < eta) {
		color = tex_rock;
	} else if(height <= rock_mix_level || abs(height - rock_level) < eta) {
		color = mix(tex_rock, tex_snow, (height - rock_level) / (rock_mix_level - rock_level));
	} else {
		color = tex_snow;
	}
	if(height <= rock_level)
		color = mix(color, tex_rock, 1.0f - dot(normalize(norm), vec3(0, 1, 0)));
	color.a = 1;

	float cam_dist = length(cam_pos - pos_w.xyz);
	//float fade_factor = clamp(1.0 - ((cam_dist - (shadow_distance.z - shadow_fade_dist)) / shadow_fade_dist), 0, 1);

	vec4 pos_shadow0 = vec4(pos_ls[0].xy, 0, pos_ls[0].z - 0.035);

	vec4 pos_shadow1 = vec4(pos_ls[1].xy, 1, pos_ls[1].z - 0.01);

	vec4 pos_shadow2 = vec4(pos_ls[2].xy, 2, pos_ls[2].z - 0.002);

	shadow = 0.0;
	vec2 texel_size = 1.0 / textureSize(shadow_map, 0).xy;
	for(int x = -1; x < 2; x++) {
		for(int y = -1; y < 2; y++) {
			if(cam_dist <= shadow_distance.x) {
				//color = vec4(1,0,0,1);
				shadow += texture(shadow_map, pos_shadow0 + vec4(vec2(x, y) * texel_size, 0, 0));
			} else if(cam_dist <= shadow_distance.y) {
				//color = vec4(0,1,0,1);
				shadow += texture(shadow_map, pos_shadow1 + vec4(vec2(x, y) * texel_size, 0, 0));
			} else {
				//color = vec4(0,0,1,1);
				shadow += texture(shadow_map, pos_shadow2 + vec4(vec2(x, y) * texel_size, 0, 0));
			}
		}
	}
	shadow = clamp(shadow / 9, 0, 1);

	position = vec4(pos_w, 1);
	normals = normalize(norm);
	if(height > rock_mix_level)
		spec = 1;
	else
		spec = 0;
}
