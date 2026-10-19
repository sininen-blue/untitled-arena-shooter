shader_type spatial;
render_mode diffuse_toon, specular_toon, depth_draw_always, cull_disabled;

uniform vec4 wave_color : source_color = vec4(0.4, 0.8, 1.0, 1.0);
uniform vec4 base_color : source_color = vec4(0.1, 0.1, 0.3, 0.0);

uniform float wave_frequency = 6.0;
uniform float wave_sharpness = 8.0;

uniform float noise_scale = 2.0;
uniform float distortion_strength = 0.3;
uniform float breakup_strength : hint_range(0.0, 1.5) = 0.6;

uniform float wave_age : hint_range(0.0, 1.0) = 0.0;

varying vec3 local_pos;

vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(random2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(random2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(random2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(random2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
    local_pos = VERTEX;
}

void fragment() {
    float latitude = normalize(local_pos).y;

    // Starts above sphere at wave_age=0, exits below at wave_age=1
    float ring_center = 1.3 - (wave_age * 2.6);

    vec2 sphere_uv = normalize(local_pos).xz;
    float organic_noise = noise(sphere_uv * noise_scale + TIME * 0.15);

    float wobbly_latitude = latitude + (organic_noise - 0.5) * distortion_strength;

    float dist_from_ring = abs(wobbly_latitude - ring_center);
    float ring_mask = 1.0 - smoothstep(0.0, 1.0 / wave_frequency, dist_from_ring);
    ring_mask = pow(ring_mask, wave_sharpness);

    float hole_threshold = organic_noise * breakup_strength;
    ring_mask *= step(hole_threshold, ring_mask);

    // Fade in on entry, fade out on exit
    float fade_in  = smoothstep(0.0, 0.1, wave_age);
    float fade_out = 1.0 - smoothstep(0.6, 1.0, wave_age);
    float fade = fade_in * fade_out;

    float final_mask = ring_mask * fade;

    ALBEDO = mix(base_color.rgb, wave_color.rgb, final_mask);
    ALPHA  = mix(base_color.a,   wave_color.a,   final_mask);
}