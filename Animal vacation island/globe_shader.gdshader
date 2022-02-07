shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

const highp float PI = 3.14159265359;
uniform bool active = false;
uniform float radius = 80.0;
uniform vec3 origin = vec3(0, -80, 0);

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	
	if (active == true) {
		mat4 inverse_world_matrix = inverse(WORLD_MATRIX);
		vec3 world_vertex = (WORLD_MATRIX*vec4(VERTEX, 1.0)).xyz;
	    float angle = (world_vertex.z - origin.z)/radius;
	    angle = clamp(angle, -PI*0.5, PI*0.5);
	    
	    float excess = (world_vertex.z - origin.z) - angle*radius;
	    vec3 radial = vec3(0, cos(angle), sin(angle));
	    world_vertex.zy = origin.zy + radial.zy*(world_vertex.y - origin.y);
	    world_vertex.y -= abs(excess);
		VERTEX = (inverse_world_matrix*vec4(world_vertex, 1.0)).xyz;
	    mat3 angle_matrix = mat3(
	        vec3(1, 0, 0),
	        radial,
	        vec3(0, -radial.z, radial.y)
	    );
		vec3 world_normal = (WORLD_MATRIX*vec4(NORMAL, 0.0)).xyz;
		vec3 world_tangent = (WORLD_MATRIX*vec4(TANGENT, 0.0)).xyz;
		vec3 world_binormal = (WORLD_MATRIX*vec4(BINORMAL, 0.0)).xyz;
	    world_normal = angle_matrix*world_normal;
	    world_tangent = angle_matrix*world_tangent;
	    world_binormal = angle_matrix*world_binormal;
		NORMAL = (inverse_world_matrix*vec4(world_normal, 0.0)).xyz;
		TANGENT = (inverse_world_matrix*vec4(world_tangent, 0.0)).xyz;
		BINORMAL = (inverse_world_matrix*vec4(world_binormal, 0.0)).xyz;
		
	}
}




void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}