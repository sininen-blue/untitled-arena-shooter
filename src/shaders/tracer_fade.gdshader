shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform float fade_progress : hint_range(0.0, 1.0) = 1.0;

uniform vec4 tracer_color : source_color = vec4(1.0, 0.85, 0.3, 1.0);
uniform float emission_strength : hint_range(0.0, 10.0) = 3.0;
uniform float tip_sharpness : hint_range(0.1, 8.0) = 2.0;

void fragment() {
	float along = UV.y;
	float tip_fade = 1.0 - pow(abs(along - 0.5) * 2.0, tip_sharpness);
	float edge_fade = 1.0 - pow(abs(UV.x - 0.5) * 2.0, 2.0);
	float alpha = tip_fade * edge_fade * fade_progress;
	alpha = clamp(alpha, 0.0, 1.0);
	
	ALBEDO = tracer_color.rgb;
	EMISSION = tracer_color.rgb * emission_strength * fade_progress;
	ALPHA = alpha;
}