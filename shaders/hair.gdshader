shader_type canvas_item;

uniform vec4 from_color_1 : source_color;
uniform vec4 to_color_1 : source_color;

uniform vec4 from_color_2 : source_color;
uniform vec4 to_color_2 : source_color;

uniform float threshold : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (distance(tex_color.rgb, from_color_1.rgb) < threshold)
        tex_color.rgb = to_color_1.rgb;

    if (distance(tex_color.rgb, from_color_2.rgb) < threshold)
        tex_color.rgb = to_color_2.rgb;

    COLOR = tex_color;
}
