#ifndef LIB_PBR_LABPBR
#define LIB_PBR_LABPBR
#include "/lib/settings/pbr.glsl"

// PbrMaterial may not exist
// source: ignore/check.sh
#include "/lib/pbr/shared.glsl"

vec3 pbrDecodeNormals(vec4 n) {
  vec2 xy = n.rg * 2.0 - 1.0;
  xy.y = -xy.y;
  float z = sqrt(max(1.0 - dot(xy, xy), 0.0));
  return normalize(vec3(xy * PBR_NORMALS_STRENGTH, max(z, 1e-6)));
}
float pbrDecodeAo(vec4 n) {
  return n.b;
}
float pbrDecodeHeight(vec4 n) {
  return n.a;
}
float pbrDecodeRoughness(vec4 s) {
  float r = 1.0 - s.r;
  return r * r;
}
int labPbrMetalId(vec4 s) {
  return int(floor(s.g * 255.0 + 0.5));
}
float pbrDecodeMetal(vec4 s) {
  return labPbrMetalId(s) >= 230 ? 1.0 : 0.0;
}
float pbrDecodePorosity(vec4 s) {
  float b = s.b * 255.0;
  return b <= 64.0 ? b / 64.0 : 0.0;
}
float pbrDecodeSSS(vec4 s) {
  float b = s.b * 255.0;
  return b > 64.0 ? clamp((b - 65.0) / 190.0, 0.0, 1.0) : 0.0;
}
float pbrDecodeEmission(vec4 s) {
  return s.a < 1.0 ? s.a * (255.0 / 254.0) : 0.0;
}
PbrMetalData pbrDecodeMetalOptics(vec4 s, vec3 albedo) {
  int id = labPbrMetalId(s);
  PbrMetalData m = PbrMetalData(vec3(s.g), id >= 230 ? 1.0 : 0.0, vec3(1.0), vec3(0.0), vec3(0.0));
  if(id < 230) return m;
  m.f0 = albedo;
  switch(id) {
    case 230:
      m.conductorN = vec3(2.9114, 2.9497, 2.5845);
      m.conductorK = vec3(3.0893, 2.9318, 2.7670);
      break;
    case 231:
      m.conductorN = vec3(0.18299, 0.42108, 1.3734);
      m.conductorK = vec3(3.4242, 2.3459, 1.7704);
      break;
    case 232:
      m.conductorN = vec3(1.3456, 0.96521, 0.61722);
      m.conductorK = vec3(7.4746, 6.3995, 5.3031);
      break;
    case 233:
      m.conductorN = vec3(3.1071, 3.1812, 2.3230);
      m.conductorK = vec3(3.3314, 3.3291, 3.1350);
      break;
    case 234:
      m.conductorN = vec3(0.27105, 0.67693, 1.3164);
      m.conductorK = vec3(3.6092, 2.6248, 2.2921);
      break;
    case 235:
      m.conductorN = vec3(1.9100, 1.8300, 1.4400);
      m.conductorK = vec3(3.5100, 3.4000, 3.1800);
      break;
    case 236:
      m.conductorN = vec3(2.3757, 2.0847, 1.8453);
      m.conductorK = vec3(4.2655, 3.7153, 3.1365);
      break;
    case 237:
      m.conductorN = vec3(0.15943, 0.14512, 0.13547);
      m.conductorK = vec3(3.9291, 3.1900, 2.3808);
      break;
    default: return m;
  }
  vec3 n = m.conductorN;
  vec3 k2 = m.conductorK * m.conductorK;
  m.f0 = ((n - 1.0) * (n - 1.0) + k2) / ((n + 1.0) * (n + 1.0) + k2);
  m.reflectionTint = albedo;
  return m;
}

#endif
