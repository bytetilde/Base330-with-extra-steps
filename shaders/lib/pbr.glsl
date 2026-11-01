#ifndef LIB_PBR
#define LIB_PBR

#define PBR_FORMAT_NONE 0
#define PBR_FORMAT_LABPBR 1

#ifndef PBR_FORMAT
#define PBR_FORMAT PBR_FORMAT_LABPBR
#endif

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

PbrMaterial decodePbr(vec4 normalSample, vec4 specularSample, vec3 albedo) {
  PbrMaterial material;
  material.normal = vec3(0.0, 0.0, 1.0);
  material.ao = 1.0;
  material.height = 1.0;
  material.roughness = 1.0;
  material.f0 = vec3(0.04);
  material.metalness = 0.0;
  material.reflectionTint = vec3(1.0);
  material.conductorN = vec3(0.0);
  material.conductorK = vec3(0.0);
  material.porosity = 0.0;
  material.subsurface = 0.0;
  material.emission = 0.0;
  return material;
}
PbrMaterial readPbr(sampler2D normalTexture, sampler2D specularTexture, vec2 texcoord, vec3 albedo) {
  return decodePbr(vec4(0.0), vec4(0.0), albedo);
}

#elif PBR_FORMAT == PBR_FORMAT_LABPBR
#include "/lib/pbr/labpbr.glsl"

// normal is y-up tangent space
// albedo is linear rgb
// height is the raw [0, 1] height
PbrMaterial decodePbr(vec4 normalSample, vec4 specularSample, vec3 albedo) {
  return decodeLabPbr(normalSample, specularSample, albedo);
}
PbrMaterial readPbr(sampler2D normalTexture, sampler2D specularTexture, vec2 texcoord, vec3 albedo) {
  return readLabPbr(normalTexture, specularTexture, texcoord, albedo);
}

#else
#error unsupported PBR_FORMAT
#endif

#endif
