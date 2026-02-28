shader_type canvas_item;

uniform vec4 crimson_base : source_color = vec4(0.06, 0.0, 0.01, 1.0); 
uniform vec4 crimson_core : source_color = vec4(0.2, 0.02, 0.03, 1.0); 
uniform vec4 engraving_gold : source_color = vec4(0.95, 0.75, 0.2, 1.0); 
uniform vec4 highlight_gold : source_color = vec4(1.0, 0.95, 0.7, 1.0); 
uniform float pattern_scale = 5.5; 

float dense_royal_pattern(vec2 uv) {

	vec2 warp = vec2(sin(uv.y * 2.0 + TIME * 0.4), cos(uv.x * 2.0 + TIME * 0.3)) * 0.04;
	vec2 p = uv * 3.14159 * 2.0 + warp;
	

	float c1 = sin(p.x * 2.0) * cos(p.y * 2.0);
	float c2 = sin(p.x + p.y) * 1.5;
	float c3 = cos(p.x * 2.5 - p.y * 2.5) * 0.8;
	
	float val = c1 + c2 + c3;
	float outline = abs(val);
	

	float ink = smoothstep(0.18, 0.02, outline); 
	

	float pools = smoothstep(1.8, 2.2, abs(val));
	
	return clamp(ink + pools * 0.5, 0.0, 1.0);
}

void fragment() {
	vec2 uv = UV;
	uv.x *= 1.777; 
	

	vec2 center_uv = UV - vec2(0.5);
	float dist = length(center_uv);
	float pulse = (sin(TIME * 1.2) + 1.0) * 0.5; 
	
	vec3 bg = mix(crimson_core.rgb * (0.7 + pulse * 0.2), crimson_base.rgb, dist * 1.4);


	vec2 p = uv * pattern_scale;
	float ink_mask = dense_royal_pattern(p) * 0.75; 
	

	float wave1 = sin(uv.x * 6.0 - uv.y * 3.0 + TIME * 2.0);
	float wave2 = cos(uv.x * -2.5 - uv.y * 5.0 + TIME * 1.5);
	float wave3 = sin(uv.x * 15.0 + uv.y * 15.0 - TIME * 4.0); 
	
	float glisten = max(0.0, (wave1 + wave2) * 0.5); 
	glisten = pow(glisten, 3.0); 
	float sparkle = max(0.0, wave3) * pow(glisten, 4.0); 
	

	vec3 gold_color = mix(engraving_gold.rgb, highlight_gold.rgb, glisten);
	gold_color += highlight_gold.rgb * sparkle * 2.5; 
	
	float ink_depth = smoothstep(0.0, 1.0, ink_mask) + (glisten * 0.6);
	vec3 final_ink = gold_color * ink_depth;

	bg += engraving_gold.rgb * ink_mask * 0.08 * (1.0 + glisten);
	vec3 final_color = mix(bg, final_ink, ink_mask);
	
	final_color *= (1.15 - dist * 0.9);

	COLOR = vec4(final_color, 1.0);
}