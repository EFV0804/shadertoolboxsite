#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define OCTAVES 8
float fbm(in vec2 st) {
    // Initial values
    float value = 0.;
    float amplitude = 0.5;
    float frequency = 2.;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        st *= 2.192;
        amplitude *= 0.48;
    }
    return value;
}

float fbm_ridge(in vec2 st) {
    // Initial values
    float value = 0.;
    float amplitude = .5;
    float frequency = 2.;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * abs(noise(st));
        st *= 2.;
        amplitude *= .5;
    }
    return value;
}

// float pattern(in vec2 p, out vec2 q, out vec2 r){
//     q.x = fbm(p + vec2(0.));
//     q.y = fbm(p + vec2(5.2,1.3));

//     r.x = fbm(p + 4.0*q + vec2(1.7,9.2));
//     r.y = fbm(p + 4.*q + vec2(8.3,2.8));

//     return fmb(p +4.0+r); 
// }

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;


    vec3 color = vec3(0.0);
    color += fbm_ridge(st*3.0);
    gl_FragColor = vec4(color,1.0);
}