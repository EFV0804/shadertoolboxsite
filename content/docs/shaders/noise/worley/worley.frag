#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

vec2 random2( vec2 p )
{
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void main()
{
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    st *= 3.;

    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float d = 1.;
    float min_d;
    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            vec2 neighbour = vec2(x,y);
            vec2 p = random2( i_st + neighbour);
            p = 0.5 + 0.5 * sin(u_time*p);
            min_d = length(neighbour + p - f_st);

            if (min_d < d){
                d = min_d;
            }
        }
    }

    vec3 color = vec3(0.);
    // Draw grid
    // color.r += step(.98, f_st.x) + step(.98, f_st.y);

    // Draw points
    // color += 1. - step(0.02, sqrt(dot(d,d)));


    // color += d;

    // Inverted worley noise
    color += 1. - d;

    gl_FragColor = vec4(color,1.0);
}
