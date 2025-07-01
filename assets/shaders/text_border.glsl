// varying vec4 border_pos;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    //vec4 a = vertex_position + vec4(1, 1, 0, 0);
    float scale = 10.0;
    vec2 screen = love_ScreenSize.xy;
    vec2 normalized = vec2(1.0) / screen;
    mat4 mtx = mat4(
        1.0 + (scale * normalized.x), 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    );
    return transform_projection * (vertex_position * mtx);
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        return texcolor * color * vec4(0, 0, 0, 1);
    }
#endif