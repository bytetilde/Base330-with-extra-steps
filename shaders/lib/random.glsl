#ifndef LIB_RANDOM
#define LIB_RANDOM
#include "/lib/uniforms.glsl"

uint hash11(uint v) {
  v += 1013904223u;
  v ^= v >> 16u;
  v *= 0x7feb352du;
  v ^= v >> 15u;
  v *= 0x846ca68bu;
  v ^= v >> 16u;
  return v;
}
uvec2 hash22(uvec2 v) {
  v += uvec2(1013904223u, 2891336453u);
  v *= uvec2(0x7feb352du, 0x846ca68bu);
  v.x += v.y;
  v.y += v.x;
  v ^= v >> 16u;
  v *= uvec2(0x846ca68bu, 0x7feb352du);
  v.x += v.y;
  v.y += v.x;
  v ^= v >> 15u;
  v *= uvec2(0x7feb352du, 0x846ca68bu);
  v.x += v.y;
  v.y += v.x;
  v ^= v >> 16u;
  return v;
}
uvec3 hash33(uvec3 v) {
  v ^= uvec3(1013904223u, 2891336453u, 2246822519u);
  v *= uvec3(0x7feb352du, 0x846ca68bu, 0x6d24f0c7u);
  v.z ^= v.y;
  v.y ^= v.x;
  v.x ^= v.z;
  v ^= v.zyx >> uvec3(13u, 14u, 20u);
  v *= uvec3(0x846ca68bu, 0x6d24f0c7u, 0x7feb352du);
  v.x ^= v.y;
  v.y ^= v.z;
  v.z ^= v.x;
  v ^= v >> uvec3(17u, 15u, 12u);
  v *= uvec3(0x6d24f0c7u, 0x7feb352du, 0x846ca68bu);
  v.x ^= v.y;
  v.y ^= v.z;
  v.z ^= v.x;
  v ^= v.xzy >> uvec3(13u, 12u, 16u);
  return v;
}
uvec4 hash44(uvec4 v) {
  v += uvec4(1013904223u, 2891336453u, 2246822519u, 3266489917u);
  v *= uvec4(0x7feb352du, 0x846ca68bu, 0x6d24f0c7u, 0x9c3ab21fu);
  v.x += v.y;
  v.y += v.z;
  v.z += v.w;
  v.w += v.x;
  v ^= v >> 16u;
  v *= uvec4(0x846ca68bu, 0x6d24f0c7u, 0x9c3ab21fu, 0x7feb352du);
  v.x += v.z;
  v.y += v.w;
  v.z += v.x;
  v.w += v.y;
  v ^= v >> 15u;
  v *= uvec4(0x6d24f0c7u, 0x9c3ab21fu, 0x7feb352du, 0x846ca68bu);
  v.x += v.y;
  v.y += v.z;
  v.z += v.w;
  v.w += v.x;
  v ^= v >> 16u;
  return v;
}

uvec2 hash12(uint v) {
  return hash22(uvec2(v, 3804825923u));
}
uvec3 hash13(uint v) {
  return hash33(uvec3(v, 3804825923u, 2415159451u));
}
uvec4 hash14(uint v) {
  return hash44(uvec4(v, 3804825923u, 2415159451u, 277803737u));
}
uint hash21(uvec2 v) {
  return hash22(v).x;
}
uvec3 hash23(uvec2 v) {
  return hash33(uvec3(v, 3804825923u));
}
uvec4 hash24(uvec2 v) {
  return hash44(uvec4(v, 3804825923u, 2415159451u));
}
uint hash31(uvec3 v) {
  return hash33(v).x;
}
uvec2 hash32(uvec3 v) {
  return hash33(v).xy;
}
uvec4 hash34(uvec3 v) {
  return hash44(uvec4(v, 3804825923u));
}
uint hash41(uvec4 v) {
  return hash44(v).x;
}
uvec2 hash42(uvec4 v) {
  return hash44(v).xy;
}
uvec3 hash43(uvec4 v) {
  return hash44(v).xyz;
}

float uintToFloat(uint v) {
  return uintBitsToFloat((v >> 9u) | 0x3f800000u) - 1.0;
}
vec2 uintToFloat(uvec2 v) {
  return uintBitsToFloat((v >> 9u) | 0x3f800000u) - 1.0;
}
vec3 uintToFloat(uvec3 v) {
  return uintBitsToFloat((v >> 9u) | 0x3f800000u) - 1.0;
}
vec4 uintToFloat(uvec4 v) {
  return uintBitsToFloat((v >> 9u) | 0x3f800000u) - 1.0;
}

float uintToSignedFloat(uint v) {
  return uintBitsToFloat((v >> 9u) | 0x3f800000u) * 2.0 - 3.0;
}
vec2 uintToSignedFloat(uvec2 v) {
  return uintBitsToFloat((v >> 9u) | 0x3f800000u) * 2.0 - 3.0;
}
vec3 uintToSignedFloat(uvec3 v) {
  return uintBitsToFloat((v >> 9u) | 0x3f800000u) * 2.0 - 3.0;
}
vec4 uintToSignedFloat(uvec4 v) {
  return uintBitsToFloat((v >> 9u) | 0x3f800000u) * 2.0 - 3.0;
}

float uintToSignedFloatPrecise(uint v) {
  float f = uintBitsToFloat((v >> 8) | 0x3f800000u) - 1.0;
  return uintBitsToFloat(floatBitsToUint(f) ^ (v & 0x80000000u));
}
vec2 uintToSignedFloatPrecise(uvec2 v) {
  vec2 f = uintBitsToFloat((v >> 8) | 0x3f800000u) - 1.0;
  return uintBitsToFloat(floatBitsToUint(f) ^ (v & 0x80000000u));
}
vec3 uintToSignedFloatPrecise(uvec3 v) {
  vec3 f = uintBitsToFloat((v >> 8) | 0x3f800000u) - 1.0;
  return uintBitsToFloat(floatBitsToUint(f) ^ (v & 0x80000000u));
}
vec4 uintToSignedFloatPrecise(uvec4 v) {
  vec4 f = uintBitsToFloat((v >> 8) | 0x3f800000u) - 1.0;
  return uintBitsToFloat(floatBitsToUint(f) ^ (v & 0x80000000u));
}

uint rngNext(inout uint rng) {
  // pcg
  rng = rng * 747796405u + 2891336453u;
  uint w = ((rng >> ((rng >> 28u) + 4u)) ^ rng) * 277803737u;
  return (w >> 22u) ^ w;
}
float rand1(inout uint rng) {
  return uintToFloat(rngNext(rng));
}
vec2 rand2(inout uint rng) {
  return vec2(rand1(rng), rand1(rng));
}
vec3 rand3(inout uint rng) {
  return vec3(rand1(rng), rand1(rng), rand1(rng));
}

float ign(vec2 p) {
  return fract(52.9829189 * fract(0.06711056 * p.x + 0.00583715 * p.y));
}
float ign(vec2 p, int frame) {
  return ign(p + vec2(5.588238 * float(frame & 63)));
}

// NVIDIA STBN
float blueNoiseST(ivec2 p, int frame, uint dimension) {
  ivec2 offset = int(dimension & 127u) * ivec2(53, 37);
  float v = texelFetch(blueNoiseTex, ivec3((p + offset) & 127, frame & 63), 0).r;
  return v * (255.0 / 256.0) + (0.5 / 256.0);
}
float blueNoise(ivec2 p, uint dimension) {
  return blueNoiseST(p, 0, dimension);
}

// it kinda sucks
float blueNoiseSTTexless(ivec2 p, int frame, uint dimension) {
  uint pixel = uint(p.x) + (uint(p.y) << 16u);
  uint t = uint(frame);
  uint key = t * 0x9e3779b9u + dimension * 0x85ebca6bu;
  uint prevKey = key - 0x9e3779b9u;
  uint stride = 1u << ((t & 1u) << 4u);
  uint prevStride = 1u << (((t ^ 1u) & 1u) << 4u);
  float a = uintToFloat(hash11(pixel + key));
  float b = uintToFloat(hash11(pixel + stride + key));
  float c = uintToFloat(hash11(pixel + prevKey));
  float d = uintToFloat(hash11(pixel + prevStride + prevKey));
  float v = (a - b) - (c - d);
  float x = 2.0 - abs(v);
  float y = max(x - 1.0, 0.0);
  x *= x;
  y *= y;
  float tail = (x * x - 4.0 * y * y) * (1.0 / 24.0);
  float u = v < 0.0 ? tail : 1.0 - tail;
  return clamp(u, 5.96046448e-8, 0.99999994);
}
float blueNoiseTexless(ivec2 p, uint dimension) {
  return blueNoiseSTTexless(p, 0, dimension);
}

vec3 uvToUnitVector(float u, float v) {
  float phi = 2.0 * PI * u;
  float z = v * 2.0 - 1.0;
  float r = sqrt(1.0 - z * z);
  return vec3(r * cos(phi), r * sin(phi), z);
}
vec3 uvToUnitVector(uint u, uint v) {
  return uvToUnitVector(uintToFloat(u), uintToFloat(v));
}

vec2 uvToDisk(vec2 uv) {
  vec2 p = uv * 2.0 - 1.0;
  if(p.x == 0.0 && p.y == 0.0) return vec2(0.0);
  float r, phi;
  if(abs(p.x) > abs(p.y)) {
    r = p.x;
    phi = p.y / p.x;
  } else {
    r = p.y;
    phi = 2.0 - p.x / p.y;
  }
  phi *= 0.25 * PI;
  return r * vec2(cos(phi), sin(phi));
}
float cosineHemispherePdf(float cosTheta) {
  return max(cosTheta, 0.0) * INVPI;
}

#endif
