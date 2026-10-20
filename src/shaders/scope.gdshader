shader_type canvas_item;

uniform vec4 scope_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 dot_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float radius : hint_range(0.0, 0.5) = 0.22;
uniform float edge : hint_range(0.0, 0.05) = 0.002;
uniform float dot_radius_px = 2.5;

void fragment() {
	vec2 texel = vec2(length(dFdx(UV)), length(dFdy(UV)));
	vec2 from_center_px = (UV - vec2(0.5)) / texel;
	float dist = length(from_center_px);

	float min_side = min(1.0 / texel.x, 1.0 / texel.y);
	float rad = radius * min_side;
	float edge_px = max(edge * min_side, 1.0);
	float outside = smoothstep(rad - edge_px, rad + edge_px, dist);
	float dot_mask = 1.0 - smoothstep(dot_radius_px - 0.75, dot_radius_px + 0.75, dist);
	COLOR = mix(vec4(scope_color.rgb, scope_color.a * outside), dot_color, dot_mask);
}
