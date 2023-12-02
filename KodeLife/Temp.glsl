#version 150

uniform float time;
uniform vec2 resolution;
uniform vec3 spectrum;

uniform sampler2D eye;
uniform sampler2D prevFrame;

// Constants

const float PI = 3.14159265359;
const float TAU = PI * 2;
const vec4 C = vec4(1, -1, 0, 0.5);

// Cg-like functions

float saturate(float x) { return clamp(x, 0, 1); }
vec2  saturate(vec2  x) { return clamp(x, 0, 1); }
vec3  saturate(vec3  x) { return clamp(x, 0, 1); }
vec4  saturate(vec4  x) { return clamp(x, 0, 1); }

vec2 sincos(float x) { return vec2(sin(x), cos(x)); }

// Utility functions

vec3 max4(vec3 a, vec3 b, vec3 c, vec3 d)
  { return max(max(max(a, b), c), d); }

vec3 mix4(vec3 a, vec3 b, vec3 c, vec3 d, float t)
{
    t = fract(t / 4) * 4;
    vec3 acc = mix(a, b, saturate(t));
    acc = mix(acc, c, saturate(t - 1));
    acc = mix(acc, d, saturate(t - 2));
    acc = mix(acc, a, saturate(t - 3));
    return acc;
}

// Color functions

vec3 hue2rgb(float h)
{
    h = fract(h) * 6 - 2;
    return saturate(vec3(abs(h - 1) - 1, 2 - abs(h), 2 - abs(h - 2)));
}

// Basic waveform functions

float sinwave(float x, float freq, float lo, float hi)
  { return (sin(TAU * freq * x) * (hi - lo) + hi + lo) / 2; }

vec2 sinwave(vec2 x, vec2 freq, vec2 lo, vec2 hi)
  { return (sin(TAU * freq * x) * (hi - lo) + hi + lo) / 2; }

vec3 sinwave(vec3 x, vec3 freq, vec3 lo, vec3 hi)
  { return (sin(TAU * freq * x) * (hi - lo) + hi + lo) / 2; }

float triwave(float x, float freq, float lo, float hi)
  { return mix(lo, hi, abs(1 - fract(x * freq - 0.25) * 2)); }

vec2 triwave(vec2 x, vec2 freq, vec2 lo, vec2 hi)
  { return mix(lo, hi, abs(1 - fract(x * freq - 0.25) * 2)); }

vec3 triwave(vec3 x, vec3 freq, vec3 lo, vec3 hi)
  { return mix(lo, hi, abs(1 - fract(x * freq - 0.25) * 2)); }

// 2D transform

mat2 rotate(float x)
  { vec2 sc = sincos(x); return mat2(sc.y, sc.x, -sc.x, sc.y); }

vec2 rot90(vec2 v)
  { return v.yx * vec2(1, -1); }

// PRNG

float rand(vec2 uv)
  { return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453); }

float rand(float x, float y)
  { return rand(vec2(x, y)); }

// Gradient noise

float fade(float x) { return x * x * x * (x * (x * 6 - 15) + 10); }
vec2  fade(vec2  x) { return x * x * x * (x * (x * 6 - 15) + 10); }
vec3  fade(vec3  x) { return x * x * x * (x * (x * 6 - 15) + 10); }

float phash(float p)
{
    p = fract(7.8233139 * p);
    p = ((2384.2345 * p - 1324.3438) * p + 3884.2243) * p - 4921.2354;
    return fract(p) * 2 - 1;
}

vec2 phash(vec2 p)
{
    p = fract(mat2(1.2989833, 7.8233198, 6.7598192, 3.4857334) * p);
    p = ((2384.2345 * p - 1324.3438) * p + 3884.2243) * p - 4921.2354;
    return normalize(fract(p) * 2 - 1);
}

vec3 phash(vec3 p)
{
    p = fract(mat3(1.2989833, 7.8233198, 2.3562332,
                   6.7598192, 3.4857334, 8.2837193,
                   2.9175399, 2.9884245, 5.4987265) * p);
    p = ((2384.2345 * p - 1324.3438) * p + 3884.2243) * p - 4921.2354;
    return normalize(fract(p) * 2 - 1);
}

float noise(float p)
{
    float ip = floor(p);
    float fp = fract(p);
    float d0 = phash(ip    ) *  fp;
    float d1 = phash(ip + 1) * (fp - 1);
    return mix(d0, d1, fade(fp));
}

float noise(vec2 p)
{
    vec2 ip = floor(p);
    vec2 fp = fract(p);
    float d00 = dot(phash(ip), fp);
    float d01 = dot(phash(ip + vec2(0, 1)), fp - vec2(0, 1));
    float d10 = dot(phash(ip + vec2(1, 0)), fp - vec2(1, 0));
    float d11 = dot(phash(ip + vec2(1, 1)), fp - vec2(1, 1));
    fp = fade(fp);
    return mix(mix(d00, d01, fp.y), mix(d10, d11, fp.y), fp.x);
}

float noise(vec3 p)
{
    vec3 ip = floor(p);
    vec3 fp = fract(p);
    float d000 = dot(phash(ip), fp);
    float d001 = dot(phash(ip + vec3(0, 0, 1)), fp - vec3(0, 0, 1));
    float d010 = dot(phash(ip + vec3(0, 1, 0)), fp - vec3(0, 1, 0));
    float d011 = dot(phash(ip + vec3(0, 1, 1)), fp - vec3(0, 1, 1));
    float d100 = dot(phash(ip + vec3(1, 0, 0)), fp - vec3(1, 0, 0));
    float d101 = dot(phash(ip + vec3(1, 0, 1)), fp - vec3(1, 0, 1));
    float d110 = dot(phash(ip + vec3(1, 1, 0)), fp - vec3(1, 1, 0));
    float d111 = dot(phash(ip + vec3(1, 1, 1)), fp - vec3(1, 1, 1));
    fp = fade(fp);
    return mix(mix(mix(d000, d001, fp.z), mix(d010, d011, fp.z), fp.y),
               mix(mix(d100, d101, fp.z), mix(d110, d111, fp.z), fp.y), fp.x);
}

////////////////////////////////////////////////////////////////////////////////
// Texture

vec2 get_uv() { return gl_FragCoord.xy / resolution; }
vec2 vflip(vec2 p) { return vec2(p.x, 1 - p.y); }

vec2   fix_aspect(vec2 uv) { return vec2(uv.x * resolution.x / resolution.y, uv.y); }
vec2 apply_aspect(vec2 uv) { return vec2(uv.x * resolution.y / resolution.x, uv.y); }

vec3 sample(sampler2D t, vec2 uv) { return texture(t, vflip(uv)).rgb; }
vec3 feedback(vec2 offs) { return texture(prevFrame, get_uv() + apply_aspect(offs)).rgb; }

////////////////////////////////////////////////////////////////////////////////
// Coordinate system

vec2 uv2rect(vec2 p) { return fix_aspect(p * 2 - 1); }
vec2 rect2uv(vec2 p) { return (apply_aspect(p) + 1) / 2; }

vec2 uv2polar(vec2 uv)
{
    vec2 p = uv2rect(uv);
    return vec2(atan(p.y, p.x) / TAU + 0.5, length(p));
}

vec2 polar2uv(vec2 p)
{ 
    p = sincos((p.x - 0.5) * TAU).yx * p.y;
    p.x *= resolution.y / resolution.x;
    return (p + 1) / 2;
}

vec2 uv2spiral(vec2 uv, float repeat, float offset)
{
    vec2 p = uv2polar(uv);
    p.x += offset;
    p.y = p.x + p.y * repeat;
    p.x = ceil(p.y) - p.x;
    return vec2(p.x * p.x, p.y);
}

vec2 uv2hex(vec2 uv)
{
    vec2 p = uv * 2 - 1;
    p.x *= resolution.x / resolution.y;
    float seg = floor(fract(atan(p.y, p.x) / PI / 2 + 0.5 / 6) * 6);
    vec2 v1 = sincos(seg / 6 * PI * 2).yx;
    vec2 v2 = vec2(-v1.y, v1.x);
    return vec2(dot(p, v2) * 0.5 + 0.5 + seg, dot(p, v1));
}

////////////////////////////////////////////////////////////////////////////////
// One pass CFD

const int cfd_angles = 7;

float cfd_outflow(vec2 uv, float l, float phi)
{
    float acc = 0;
    for (int i = 0; i < cfd_angles; i++)
    {
        vec2 dir = sincos(TAU / cfd_angles * (i + phi)).yx;
        acc += dot(dir, texture(prevFrame, uv + dir * l).xy - 0.5);
    }
    return acc / cfd_angles;
}

vec2 cfd(vec2 uv)
{
    float delta = 2.0 / resolution.x;
    float phi = mod(time, TAU);
    vec2 acc = vec2(0.0);
    float l = delta;

    for(int i = 0; i < 8; i++)
    {
        for(int j = 0; j < cfd_angles; j++)
        {
            vec2 dir = sincos(TAU / cfd_angles * (j + phi)).yx;
            acc += rot90(dir) * cfd_outflow(uv + dir * l, l, phi);
        }
        l *= 2;
    }

    return acc * delta / cfd_angles;
}

vec3 cfd_feedback(float freq, float amp)
{
    vec2 uv = get_uv();
    return texture(prevFrame, uv + cfd(uv * freq) * amp).rgb;
}

////////////////////////////////////////////////////////////////////////////////
// Snippets

/*  // Rotating sine gradient 
    {
        vec2 p = uv2rect(uv);
        for (int i = 1; i < 4; i++)
        {
            p *= rotate(time * 0.1 * i);
            p *= sin(p.x) / dot(p + 0.5, p);
        }
    }
*/

/*  // Kali set fractal
    {
        vec3 z = vec3(uv2rect(uv), 2 * sin(time * 0.0134));
        vec3 c = vec3(0.9, 0.3, sinwave(time, 0.015, 0.2, 0.8));
        for (int i = 0; i < 12; i++)
            z = abs(z) / dot(z, z) - c;
    }
*/











//   ____  __.         .___     .____    .__  _____       
//  |    |/ _|____   __| _/____ |    |   |__|/ ____\____  
//  |      < /  _ \ / __ |/ __ \|    |   |  \   __\/ __ \ 
//  |    |  (  <_> ) /_/ \  ___/|    |___|  ||  | \  ___/ 
//  |____|__ \____/\____ |\___  >_______ \__||__|  \___  >
//          \/          \/    \/        \/             \/                  
//                        ____ ___      .__  __           
//              .__      |    |   \____ |__|/  |_ ___.__. 
//            __|  |___  |    |   /    \|  \   __<   |  | 
//           /__    __/  |    |  /   |  \  ||  |  \___  | 
//              |__|     |______/|___|  /__||__|  / ____| 
//                                    \/          \/      

out vec4 fragColor;

void main(void)
{
    vec2 uv = get_uv();
    
    vec3 c1, c2, c3, c4;
    
    {
        vec2 p = uv2rect(uv) * 20;
        c1 = sin(p.xxx + time);
    }
    
    fragColor = vec4(mix4(c1, c1, c1, c1, time), 1);
}








