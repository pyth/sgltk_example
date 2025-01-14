#version 400

layout (vertices = 4) out;

in vec2 tile_pos_tc[];

out vec2 tc_te[];
out vec2 tc2_te[];

uniform vec3 cam_pos;
uniform uint terrain_side;
uniform int max_tess_level;

float get_tess_level(float dist0, float dist1) {
	float step = 100;
	float dist = mix(dist0, dist1, 0.5);

	if(dist <= step)
		return float(max_tess_level);

	else if(dist <= 2 * step)
		return float(max_tess_level / 2);

	else if(dist <= 4 * step)
		return float(max_tess_level / 4);

	else if(dist <= 8 * step)
		return float(max_tess_level / 8);

	else if(dist <= 16 * step)
		return float(max_tess_level / 16);

	else if(dist <= 32 * step)
		return float(max_tess_level / 32);

	else
		return float(max_tess_level / 64);
}

void main() {
	float dist0 = length(cam_pos - gl_in[0].gl_Position.xyz);
	float dist1 = length(cam_pos - gl_in[1].gl_Position.xyz);
	float dist2 = length(cam_pos - gl_in[2].gl_Position.xyz);
	float dist3 = length(cam_pos - gl_in[3].gl_Position.xyz);

	gl_TessLevelOuter[0] = get_tess_level(dist0, dist1);
	gl_TessLevelOuter[1] = get_tess_level(dist0, dist2);
	gl_TessLevelOuter[2] = get_tess_level(dist2, dist3);
	gl_TessLevelOuter[3] = get_tess_level(dist1, dist3);

	gl_TessLevelInner[0] = max(gl_TessLevelOuter[1], gl_TessLevelOuter[3]);
	gl_TessLevelInner[1] = max(gl_TessLevelOuter[0], gl_TessLevelOuter[2]);

	float tc_per_tile = 1.0 / int(terrain_side);
	switch(gl_InvocationID) {
		case 0:
			tc_te[gl_InvocationID] = vec2(tile_pos_tc[0].x, tile_pos_tc[0].y) * tc_per_tile;
			tc2_te[gl_InvocationID] = vec2(0, 0);
			break;
		case 1:
			tc_te[gl_InvocationID] = vec2(tile_pos_tc[0].x + 1, tile_pos_tc[0].y) * tc_per_tile;
			tc2_te[gl_InvocationID] = vec2(1, 0);
			break;
		case 2:
			tc_te[gl_InvocationID] = vec2(tile_pos_tc[0].x, tile_pos_tc[0].y + 1) * tc_per_tile;
			tc2_te[gl_InvocationID] = vec2(0, 1);
			break;
		case 3:
			tc_te[gl_InvocationID] = vec2(tile_pos_tc[0].x + 1, tile_pos_tc[0].y + 1) * tc_per_tile;
			tc2_te[gl_InvocationID] = vec2(1, 1);
			break;
	}

	gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
}
