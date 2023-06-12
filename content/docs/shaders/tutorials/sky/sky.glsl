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
mat2 rotate2d(float _angle){

    return mat2(cos(_angle), -sin(_angle), sin(_angle), cos(_angle));
}
#define OCTAVES 7
float fbm(in vec2 st) {
    // Initial values
    float value = 0.;
    float amplitude = 0.5;
    // float frequency = 2.;
    vec2 shift = vec2(100.);
    mat2 rot = mat2(cos(.5), sin(.5),
                -sin(.5), cos(.5));

    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        // st = rotate2d(1.)*st * 2. + shift;
        st = rot*st * 2.4 + shift;

        amplitude *= 0.520;
    }
    return value;
}
float fbm_wrap(in vec2 st) {
    // Initial values
    float value = 0.;
    float amplitude = 0.5;
    float frequency = 2.;
    vec2 shift = vec2(100.);
    mat2 rot = mat2(cos(.5), sin(0.5),
                -sin(0.5), cos(0.50));

    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        st *= 2.192;
        amplitude *= 0.420;
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

float pattern(in vec2 p, out vec2 q, out vec2 r){
    q.x = fbm(p + vec2(0.));
    q.y = fbm(p + vec2(5.2,1.3));

    r.x = fbm(p + 4.0*q + vec2(1.7,9.2));
    r.y = fbm(p + 4.*q + vec2(8.3,2.8));

    return fbm(p +4.0+r); 
}
void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    vec3 color = vec3(0.0);


    //"folded" texture
    vec2 q = vec2(0.);
    q.x = fbm(st+u_time*0.01);
    q.y = fbm(st+u_time*0.01);

    // preview q
    color += vec3(q.x, 0., 0.);

    vec2 r = vec2(0.);
    r.x = fbm(st+q+u_time*0.05);
    r.y = fbm(st+q+vec2(.4,0.7)+u_time*0.08);
    // preview r
    color += vec3(r.x, r.y, 0.);

    float f = fbm(st+r);
    //preview f
    color = vec3(0.);
    color += vec3(f,0.,0.);

    color = mix(vec3(0.6, 0.5255, 0.6078),
                vec3(0.1255, 0.4784, 0.8078),
                clamp((f*f)*1.0,0.08,1.));

    color = mix(color,
                vec3(0.0157, 0.3294, 0.8667),
                clamp(length(q),0.0,1.0));

    color = mix(color,
                vec3(0.9529, 0.9529, 0.9255),
                clamp(length(r.x),0.0,1.0));

    //regular color mapping
    gl_FragColor = vec4(color,1.);
}