// shader taken from: https://twitter.com/ColugoMusic/status/1504155999741095940

shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 p0 = vec2(0.0);
uniform vec2 p1 = vec2(0.0);
uniform float s0 : hint_range (0.75, 3.0) = 20.0; // MAX RANGE 3.0
uniform float s1 : hint_range (0.75, 3.0) = 20.0; // MAX_RANGE 3.0
uniform int m0: hint_range (1, 5) = 1;
uniform int m1: hint_range (1, 5) = 1;
uniform float twirl0 : hint_range (-10.0, 10.0) = 0.0;
uniform float twirl1 : hint_range (-10.0, 10.0) = 0.0;
uniform float rotate0 : hint_range (0.0, 1.0) = 0.0;
uniform float rotate1 : hint_range (0.0, 1.0) = 0.0;
uniform float blur : hint_range (0.0, 0.2) = 0.0;

uniform vec4 black : source_color = vec4(0.0, 0.0, 0.0, 1.0);

const float SIZE = 5.0;
const float SHRINK = (10.0 - SIZE);
const vec2 CENTER = vec2(0.5, 0.5);
const vec4 BACK_COLOR = vec4(0.0, 0.0, 0.0, 0.0);

float calc_polar_x(float y, float angle, int m, float twirl, float rotate) 
{
	return (sin((angle * float(m)) + (y * twirl) + (PI * rotate * 2.0)) + 1.0) / 2.0;
}

float calc_v(vec2 uv, vec2 p, float s)
{ 
	return 1.0 - smoothstep(0.49 - blur, 0.51 + blur, distance(uv, p) * s);
}

float make_back(vec2 uv)
{
	return 1.0 - smoothstep(0.495, 0.505, distance(CENTER, uv) * (SHRINK / 3.0));
}

void fragment()
{
	float polar_y = distance(CENTER, UV) * SHRINK;
	float angle = atan(UV.y - CENTER.y, UV.x - CENTER.y);
	float polar_x_0 = calc_polar_x(polar_y, angle, m0, twirl0, rotate0);
	float polar_x_1 = calc_polar_x(polar_y, angle, m1, twirl1, rotate1);
	vec2 polar_uv = vec2(polar_x_0 * polar_x_1, polar_y);
	float v0 = calc_v(polar_uv, p0, s0);
	float v1 = calc_v(polar_uv, p1, s1);
	COLOR = mix(BACK_COLOR, color, clamp(v0 + v1, 0.0, 1.0));
	COLOR.a = make_back(UV);
	if(COLOR.r < black.r + 0.05 && COLOR.g < black.g + 0.05 && COLOR.g < black.g + 0.1)
	{
		COLOR.a = 0.0;
	}
}