shader_type canvas_item;

uniform float speed = 0.6;
uniform float amp = 0.2;
uniform float freq = 15.0;
uniform float stripes = 4.82; 
uniform float stripe_thickness = 1.33;
uniform vec3 stripe_color : source_color = vec3(0.59, .98, .69); 
uniform vec3 background_color : source_color = vec3(0, 0, 0); 


uniform vec2 mouse_pos = vec2(0.5, 0.5);
uniform float bend_radius = 0.25;
uniform float bend_strength = 0.3;


vec2 rot(vec2 uv, float angle) {
	float s = sin(angle);
	float c = cos(angle);
	mat2 rotation_matrix = mat2(vec2(c, s), vec2(-s, c));
	return uv * rotation_matrix;
}


void fragment() {
	vec2 uv = SCREEN_UV - 0.5;
	uv = rot(uv, -0.2 + sin(TIME) * 0.05);
	
	float osc = sin(uv.x * freq) * amp;
	uv.y += osc * sin(TIME * speed + uv.x * 2.0);
	
	vec2 mouse_centered = mouse_pos - 0.5;
	float dist = distance(SCREEN_UV, mouse_pos);
	float influence = smoothstep(bend_radius, 0.0, dist);
	vec2 to_mouse = normalize(mouse_centered - uv);
	uv.y -= influence * bend_strength * to_mouse.y;

	uv.y = fract(uv.y * stripes);
	
	float mask = smoothstep(0.5, 0.55, uv.y);
	mask -= smoothstep(0.5 + stripe_thickness, 0.55 + stripe_thickness, uv.y);
	vec3 final_color = mix(background_color.rgb, stripe_color.rgb, mask);
	COLOR = vec4(final_color, 1.0);
}