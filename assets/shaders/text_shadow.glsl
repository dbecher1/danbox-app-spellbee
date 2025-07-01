// varying vec4 border_pos;

uniform float shadowSize;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position)
{
    vertex_position.xy += vec2(shadowSize);
    return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        return texcolor * color * vec4(0, 0, 0, 0.6);
    }
#endif