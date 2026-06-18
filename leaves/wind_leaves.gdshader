shader_type spatial;
render_mode world_vertex_coords;
render_mode cull_disabled;
/** Direction of wind*/
uniform vec3 wind_direction = vec3(1,0,0); 

/** Controls how strong vertices are displaced*/
uniform float wind_strength = 0.1;
uniform float wind_distance_mod = 0.1;

/** Controls how fast vertices swing back and forth*/
uniform float speed = 1.0;

uniform vec2 uv_scale = vec2(1.0,1.0);
uniform sampler2D color_texture:source_color;
void vertex() {
	VERTEX.xyz += sin(TIME*speed+VERTEX.y/10.0) * normalize(wind_direction) * wind_strength * pow(wind_distance_mod,2);
}

void fragment() {
	ALBEDO = texture(color_texture,UV*uv_scale).xyz;
	ALPHA = texture(color_texture,UV*uv_scale).a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
