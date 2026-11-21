#ifndef LIB_PBR
#define LIB_PBR

#define PBR_FORMAT_NONE 0
#define PBR_FORMAT_LABPBR 1
#define PBR_FORMAT_OLDPBR 2

#ifndef PBR_FORMAT
#define PBR_FORMAT PBR_FORMAT_LABPBR
#endif

struct PbrNormalData {
  vec3 normal;
  float ao;
  float height;
};
struct PbrSpecularData {
  float roughness;
  vec3 f0;
  float metalness;
  vec3 reflectionTint;
  vec3 conductorN;
  vec3 conductorK;
  float porosity;
  float subsurface;
  float emission;
};
struct PbrMetalData {
  vec3 f0;
  float metalness;
  vec3 reflectionTint;
  vec3 conductorN;
  vec3 conductorK;
};
struct PbrMaterial {
  vec3 normal;
  float ao;
  float height;
  float roughness;
  vec3 f0;
  float metalness;
  vec3 reflectionTint;
  vec3 conductorN;
  vec3 conductorK;
  float porosity;
  float subsurface;
  float emission;
};

#if PBR_FORMAT == PBR_FORMAT_NONE
vec3 pbrDecodeNormals(vec4 n) {
  return vec3(0.0, 0.0, 1.0);
}
float pbrDecodeAo(vec4 n) {
  return 1.0;
}
float pbrDecodeHeight(vec4 n) {
  return 1.0;
}
float pbrDecodeRoughness(vec4 s) {
  return 1.0;
}
float pbrDecodeMetal(vec4 s) {
  return 0.0;
}
float pbrDecodePorosity(vec4 s) {
  return 0.0;
}
float pbrDecodeSSS(vec4 s) {
  return 0.0;
}
float pbrDecodeEmission(vec4 s) {
  return 0.0;
}
PbrMetalData pbrDecodeMetalOptics(vec4 s, vec3 albedo) {
  return PbrMetalData(vec3(0.04), 0.0, vec3(1.0), vec3(0.0), vec3(0.0));
}
#elif PBR_FORMAT == PBR_FORMAT_LABPBR
#include "/lib/pbr/labpbr.glsl"
#elif PBR_FORMAT == PBR_FORMAT_OLDPBR
#include "/lib/pbr/oldpbr.glsl"
#else
#error unsupported PBR_FORMAT
#endif

vec3 pbrDecodeF0(vec4 s, vec3 albedo) {
  return pbrDecodeMetalOptics(s, albedo).f0;
}
vec3 pbrDecodeReflectionTint(vec4 s, vec3 albedo) {
  return pbrDecodeMetalOptics(s, albedo).reflectionTint;
}
vec3 pbrDecodeConductorN(vec4 s) {
  return pbrDecodeMetalOptics(s, vec3(1.0)).conductorN;
}
vec3 pbrDecodeConductorK(vec4 s) {
  return pbrDecodeMetalOptics(s, vec3(1.0)).conductorK;
}

PbrNormalData pbrDecodeN(vec4 n) {
  return PbrNormalData(pbrDecodeNormals(n), pbrDecodeAo(n), pbrDecodeHeight(n));
}
PbrSpecularData pbrDecodeS(vec4 s, vec3 albedo) {
  PbrMetalData metal = pbrDecodeMetalOptics(s, albedo);
  return PbrSpecularData(pbrDecodeRoughness(s), metal.f0, metal.metalness, metal.reflectionTint, metal.conductorN, metal.conductorK, pbrDecodePorosity(s), pbrDecodeSSS(s), pbrDecodeEmission(s));
}
PbrNormalData pbrDecodeN(sampler2D tex, vec2 uv) {
#if PBR_FORMAT == PBR_FORMAT_NONE
  return pbrDecodeN(vec4(0.0));
#else
  return pbrDecodeN(texture(tex, uv));
#endif
}
PbrSpecularData pbrDecodeS(sampler2D tex, vec2 uv, vec3 albedo) {
#if PBR_FORMAT == PBR_FORMAT_NONE
  return pbrDecodeS(vec4(0.0), albedo);
#else
  return pbrDecodeS(texture(tex, uv), albedo);
#endif
}

PbrMaterial decodePbr(vec4 normalSample, vec4 specularSample, vec3 albedo) {
  PbrNormalData n = pbrDecodeN(normalSample);
  PbrSpecularData s = pbrDecodeS(specularSample, albedo);
  return PbrMaterial(n.normal, n.ao, n.height, s.roughness, s.f0, s.metalness, s.reflectionTint, s.conductorN, s.conductorK, s.porosity, s.subsurface, s.emission);
}
PbrMaterial readPbr(sampler2D normalTexture, sampler2D specularTexture, vec2 uv, vec3 albedo) {
#if PBR_FORMAT == PBR_FORMAT_NONE
  return decodePbr(vec4(0.0), vec4(0.0), albedo);
#else
  return decodePbr(texture(normalTexture, uv), texture(specularTexture, uv), albedo);
#endif
}

#endif
