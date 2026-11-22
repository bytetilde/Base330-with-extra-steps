#ifndef LIB_PBR_SHARED
#define LIB_PBR_SHARED
// awful file name i hate it ew

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

#endif
