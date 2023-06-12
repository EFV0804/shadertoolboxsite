#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

float Hash21 (in vec2 st) {

    st = fract(st*vec2(125.25,56.2));
    st += dot(st, st+45.32);
    return fract(st.x*st.y);
}
float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}
vec2 random2( vec2 p )
{
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}
vec2 star(in vec2 _st, in float flare_mult){

    float d = length(_st);
    vec2 m;
    m.x = 0.13/d;
    float flare = max(0.,1.-abs(_st.x*_st.y*1000.));
    mat2 rot = mat2(cos(3.14/4.), -sin(3.14/4.), sin(3.14/4.), cos(3.14/4.));
    _st *= rot;
    flare += max(0.,1.-abs(_st.x*_st.y*1000.));
    m.y = flare * flare_mult;
    m.x += smoothstep(0.5,0.3,d);
    // m *= smoothstep(0.5,0.3,d;
    return m;

}
vec3 star_layer(in vec2 st){
    float m;
    float size;
    vec3 color;

    vec2 i_st = floor(st);
    vec2 f_st = fract(st)-0.5;

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            vec2 neighbor = vec2(x,y);
            vec2 point = random2(i_st + neighbor );

            // point = 0.5*sin(u_time + 6.2831*point);
            vec2 diff = neighbor + point - f_st;
            size = fract(Hash21(i_st+neighbor));
            vec2 m = star(diff, 0.1*size);
            color += m.x*vec3(.5*(size*0.4),0.5*(size*0.2),.5*(size*0.2));
            color += m.y*vec3(0.9333, 1.0, 0.0);
        }
    }
    
    color *=vec3(0.2588, 0.2667, 0.2745);


    return color;
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
vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}
vec4 permute(vec4 i) {
vec4 im = mod(i, 289.0);
return mod(((im*34.0)+10.0)*im, 289.0);
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
float psrdnoise(vec2 x, vec2 period, float alpha, out vec2 gradient)
{
	vec2 uv = vec2(x.x+x.y*0.5, x.y);
	vec2 i0 = floor(uv), f0 = fract(uv);
	float cmp = step(f0.y, f0.x);
	vec2 o1 = vec2(cmp, 1.0-cmp);
	vec2 i1 = i0 + o1, i2 = i0 + 1.0;
	vec2 v0 = vec2(i0.x - i0.y*0.5, i0.y);
	vec2 v1 = vec2(v0.x + o1.x - o1.y*0.5, v0.y + o1.y);
	vec2 v2 = vec2(v0.x + 0.5, v0.y + 1.0);
	vec2 x0 = x - v0, x1 = x - v1, x2 = x - v2;
	vec3 iu, iv, xw, yw;
	if(any(greaterThan(period, vec2(0.0)))) {
		xw = vec3(v0.x, v1.x, v2.x);
		yw = vec3(v0.y, v1.y, v2.y);
		if(period.x > 0.0)
			xw = mod(vec3(v0.x, v1.x, v2.x), period.x);
		if(period.y > 0.0)
			yw = mod(vec3(v0.y, v1.y, v2.y), period.y);
		iu = floor(xw + 0.5*yw + 0.5); iv = floor(yw + 0.5);
	} else {
		iu = vec3(i0.x, i1.x, i2.x); iv = vec3(i0.y, i1.y, i2.y);
	}
	vec3 hash = mod(iu, 289.0);
	hash = mod((hash*51.0 + 2.0)*hash + iv, 289.0);
	hash = mod((hash*34.0 + 10.0)*hash, 289.0);
	vec3 psi = hash*0.07482 + alpha;
	vec3 gx = cos(psi); vec3 gy = sin(psi);
	vec2 g0 = vec2(gx.x, gy.x);
	vec2 g1 = vec2(gx.y, gy.y);
	vec2 g2 = vec2(gx.z, gy.z);
	vec3 w = 0.8 - vec3(dot(x0, x0), dot(x1, x1), dot(x2, x2));
	w = max(w, 0.0); vec3 w2 = w*w; vec3 w4 = w2*w2;
	vec3 gdotx = vec3(dot(g0, x0), dot(g1, x1), dot(g2, x2));
	float n = dot(w4, gdotx);
	vec3 w3 = w2*w; vec3 dw = -8.0*w3*gdotx;
	vec2 dn0 = w4.x*g0 + dw.x*x0;
	vec2 dn1 = w4.y*g1 + dw.y*x1;
	vec2 dn2 = w4.z*g2 + dw.z*x2;
	gradient = 10.9*(dn0 + dn1 + dn2);
	return 10.9*n;
}

void main(){

    vec2 st = (gl_FragCoord.xy-0.5*u_resolution.xy)/u_resolution.y;
        vec2 c = gl_FragCoord.xy/u_resolution.xy-.5;

    float scalar = 3.;
    st *= scalar;

    vec2 i_st = floor(st);
    vec2 f_st = fract(st)-0.5;
    vec2 g_st = fract(st)-0.5;


    vec3 color= vec3(0.0, 0.0, 0.0);

    for(float i = 0.; i < 1.; i+= 1./3.){
        // float depth = fract(i+u_time*0.002 );
        float depth = fract(i);
        float scale = mix(2., 0.5, depth);
        color += star_layer(st*scale)*depth;
    }
    
    // color.r += step(.48, f_st.x) + step(.48, f_st.y);

// ----------------------------------------------------

    float q, b, d, e, f, g, h, i;
    // a = modifier for fbm_warp rotation and st scale on cnoise
    //TODO better random
    float a = random(vec2(1.4845))+0.5;
    // float a = 0.5;
    mat2 r = mat2(cos(a), -sin(a), sin(a), cos(a));
    float v;


    float white = fbm_warp(st*(a*.9), r);
    white = smoothstep(0.8, 1.5, white);
    color += white*vec3(0.6471, 0.6392, 0.6392);

    // red volumes

    q = +cnoise(st*(a*4.1)+cnoise(st*(a*2.)));
    b = cnoise(st*(a*.1)+cnoise(st*(a*0.6)));
    //billowing: abs of 2 perlins
    d = abs(q-b);

    e = cnoise(st*(a*0.2)+cnoise(st*(a*0.6)));
    f = cnoise(st*(a*0.21)+cnoise(st*(a*.5)));
    g = abs(e+f);

    h = (d*g);
    h = fbm(st)*(h);

    v = fbm_warp(st*(a*0.5), r);
    v = smoothstep(0.58, 1.1, v);

    // color += v*(h*0.8)*vec3(0.5804, 0.3255, 0.2275);
    // color += v*vec3(0.4667, 0.1765, 0.0118)*0.2;

    // ------------------------------------------

    // space backdrop

    float space_backdrop = fbm_warp(st*(a*1.9), r);
    space_backdrop = smoothstep(0.6, 1.6, space_backdrop);
    color += space_backdrop*vec3(0.0431, 0.2078, 0.3216);

    // yellow volumes
    v = fbm_warp(st*(a*1.3), r);
    v = smoothstep(0.88, 0.2, v);
 
    color += v*vec3(0.4941, 0.298, 0.0078)*(space_backdrop*0.9);


    q = +cnoise(st*(a*.1)+cnoise(st*(a*1.8)));
    b = cnoise(st*(a*.128)+cnoise(st*(a*.6)));
        //billowing: abs of 2 perlins
    d = abs(q-b);

    e = cnoise(st*(a*0.3)+cnoise(st*(a*.2)));
    f = cnoise(st*(a*.4)+cnoise(st*(a*.214)));
    g = abs(e+f);
    h = (d*g);
    h = fbm(st)*(h*a);

    color += (h*3.5)*v*vec3(0.3922, 0.3882, 0.1294);
    color += v*vec3(0.4941, 0.298, 0.0078)*0.7;

    // overall illumination of the scene
    float lightness = cnoise(st*(a*0.3)+fbm(st+0.4));
    color += (lightness*vec3(0.9137, 0.898, 0.898))*0.15;




    gl_FragColor = vec4(color,1.0);

}
