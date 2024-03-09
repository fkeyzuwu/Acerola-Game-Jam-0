shader_type spatial;

uniform vec4 color: source_color;

uniform float y_threshold: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float x_speed: hint_range(0.0, 10.0, 0.01) = 0.01;
uniform float x_amplitude: hint_range(0.0, 10.0, 0.01) = 0.01;

uniform float y_speed: hint_range(0.0, 10.0, 0.01) = 0.01;
uniform float y_amplitude: hint_range(0.0, 10.0, 0.01) = 0.01;

void vertex() {
    if (VERTEX.y < y_threshold)
	{
        float offset = sin(TIME * x_speed) * VERTEX.y * VERTEX.y * 0.1;
		VERTEX.x += offset * x_amplitude;
    }
}

void fragment()
{
	ALBEDO = color.rgb;
}