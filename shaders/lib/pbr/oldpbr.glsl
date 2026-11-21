#ifndef LIB_PBR_OLDPBR
#define LIB_PBR_OLDPBR

// PbrMaterial exists
// source: labpbr.glsl

// i actually DONT know how oldpbr works so this is a guess
// if it doesnt, my fault bro

vec3 pbrDecodeNormals(vec4 n) {
  vec3 normal = n.rgb * 2.0 - 1.0;
  normal.y = -normal.y;
  return normalize(normal);
}
float pbrDecodeAo(vec4 n) {
  return 1.0;
}
float pbrDecodeHeight(vec4 n) {
  return n.a;
}
float pbrDecodeRoughness(vec4 s) {
  float r = 1.0 - s.r;
  return r * r;
}
float pbrDecodeMetal(vec4 s) {
  return s.g;
}
float pbrDecodePorosity(vec4 s) {
  return 0.0;
}
float pbrDecodeSSS(vec4 s) {
  return 0.0;
}
float pbrDecodeEmission(vec4 s) {
  return s.b;
}
PbrMetalData pbrDecodeMetalOptics(vec4 s, vec3 albedo) {
  return PbrMetalData(mix(vec3(0.04), albedo, s.g), s.g, vec3(1.0), vec3(0.0), vec3(0.0));
}

#endif
