//based on tutorial by Michael Walczyk https://michaelwalczyk.com/blog-ray-marching.html
precision mediump float;
uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

#define MAX_STEPS 100
#define MAX_DIST 10000000.
#define SURFACE_DIST 0.0001

float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}

vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}
vec4 permute(vec4 i) {
vec4 im = mod(i, 289.0);

return mod(((im*34.0)+10.0)*im, 289.0);
}

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

#define OCTAVES 7
float fbm(in vec2 st) {
    // Initial values
    float value = 0.;
    float amplitude = 0.5;
    // float frequency = 2.;

    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        st = st * 2.;
        // st = rot*st * 2.9 + shift;

        amplitude *= 0.540;
    }
    return value;
}

float fbm_warp(in vec2 st, in mat2 rot) {
    // Initial values
    float value = 0.;
    float amplitude = 0.5;
    // float frequency = 2.;
    vec2 shift = vec2(100.);
    // mat2 rot = mat2(cos(1.), sin(0.4),
    //             -sin(0.4), cos(0.40));

    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        st = rot * st * 2.1 + shift;
        amplitude *= 0.7;
    }
    return value;
}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

vec3 billow_noise(vec2 st){
    float a = random(vec2(1.4845))+0.5;
    mat2 r = mat2(cos(a), -sin(a), sin(a), cos(a));

    float q,b,d,e,f,g,h;

    q = cnoise(st*(a*0.3)+cnoise(st*(a*0.1)));
    b = cnoise(st*(a*0.1)+cnoise(st*(a*0.1)));

    d = abs(q-b);

    // e = cnoise(st*(a*0.2)+cnoise(st*(a*0.6)));
    // f = cnoise(st*(a*0.21)+cnoise(st*(a*.5)));
    // g = abs(e+f);

    // h = (d*g);

    return d*vec3(1.0, 1.0, 1.0);
}
mat2 rotate(float a){
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}
float getDistSphere(vec3 p, vec3 sphere_pos, float radius){
    vec4 sphere = vec4(sphere_pos,radius);

    return length(p-sphere.xyz)-sphere.w;
}

float getSceneDist(vec3 p, vec2 st){
    float sphere = getDistSphere(p, vec3(0,0,0.), 1.);
    float displacement = sin(2.9 * (p.x+cos(u_time))) *
     sin(2.2* (p.y+cos(u_time))) *
      sin(2.2* (p.z+sin(u_time)))*0.4;


    float plane = p.y+1.5;
    float d = min(sphere+displacement, plane);
    // float d = min(sphere, plane);

    return d;
}

float raymarch(vec3 ro, vec3 rd, vec2 st){
    float distance_traveled = 0.;
    for(int i = 0; i<MAX_STEPS; i++){
        vec3 current_pos = ro +distance_traveled*rd;
        float distance_closest = getSceneDist(current_pos, st);
        distance_traveled += distance_closest;
        if(distance_closest<SURFACE_DIST 
        || distance_traveled>MAX_DIST) break;
    }

    return distance_traveled;
}

vec3 getNormal(vec3 p, vec2 st){
    vec3 e = vec3(.001,0.,0.);
    float d = getSceneDist(p, st);
    vec3 n = d - vec3(
    getSceneDist(p-e.xyy, st),
    getSceneDist(p-e.yxy, st),
    getSceneDist(p-e.yyx, st));
    
    return normalize(n);
}

float getLight(vec3 p, vec3 lightPos, vec2 st){
    vec3 l = normalize(lightPos-p);
    vec3 n = getNormal(p, st);
    float diffuse = clamp(dot(n,l),0.,1.);

    // shadow
    float d = raymarch(p+n, l, st);
    if(d<length(lightPos-p)){
        diffuse *= .1;
    }

    return diffuse;

}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
    //https://www.shadertoy.com/view/Xds3zN
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv =          ( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

vec3 R(vec2 st, vec3 p, vec3 l, float z) {
    //https://www.shadertoy.com/view/3ssGWj
    //camera to world transformation
    vec3 f = normalize(l-p),
        r = normalize(cross(vec3(0,1,0), f)),
        u = cross(f,r),
        c = p+f*z,
        i = c + st.x*r + st.y*u,
        d = normalize(i-p);
    return d;
}



void main(){
    vec2 st = (gl_FragCoord.xy-0.5*u_resolution.xy)/u_resolution.y;
    vec2 mo = u_mouse.xy/u_resolution.xy;

    vec3 col = vec3(0.);

    vec3 ro = vec3(0,0,-5);
    ro.yz *= rotate(mo.y);
    ro.xz *= rotate(mo.x*6.);

    vec3 rd = R(st, ro, vec3(0,0,0), 0.9);

    float d = raymarch(ro, rd, st);

    //Light
    vec3 p  = ro + rd * d;
    float diffuse = getLight(p, vec3(0.,8.,-6.), st);


//sdf visualation
    // col = vec3(d)/10.;
//Normal visualisation
    // col = getNormal(p);
//Light visualisation
    col += diffuse;


    gl_FragColor = vec4(col, 1.);

}