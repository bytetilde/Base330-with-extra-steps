#ifndef LIB_PBR_OLDPBR
#define LIB_PBR_OLDPBR

// PbrMaterial may not exist
// source: labpbr.glsl
#include "/lib/pbr/shared.glsl"
#include "/lib/settings/pbr.glsl"

// i actually DONT know how oldpbr works so this is a guess
// if it doesnt, my fault bro

vec3 pbrDecodeNormals(vec4 n) {
  vec3 normal = n.rgb * 2.0 - 1.0;
  normal.y *= float(PBR_OLDPBR_NORMAL_Y);
  return normalize(vec3(normal.xy * PBR_NORMALS_STRENGTH, max(normal.z, 1e-6)));
}
float pbrDecodeAo(vec4 n) {
  return 1.0;
}
float pbrDecodeHeight(vec4 n) {
  return n.a;
}
float pbrDecodeRoughness(vec4 s) {
  float r = clamp(1.0 - s.r + PBR_ROUGHNESS_BIAS, 0.0, 1.0);
  return r * r;
}
float pbrDecodeMetal(vec4 s) {
#ifdef PBR_OLDPBR_BINARY_METALNESS
  return step(0.5, s.g);
#else
  return s.g;
#endif
}
float pbrDecodePorosity(vec4 s) {
  return 0.0;
}
float pbrDecodeSSS(vec4 s) {
  return 0.0;
}
float pbrDecodeEmission(vec4 s) {
#ifdef PBR_OLDPBR_BLUE_EMISSION
  return s.b;
#else
  return 0.0;
#endif
}
PbrMetalData pbrDecodeMetalOptics(vec4 s, vec3 albedo) {
  float metal = pbrDecodeMetal(s);
  return PbrMetalData(mix(vec3(0.04), albedo, metal), metal, vec3(1.0), vec3(0.0), vec3(0.0));
}

#endif
