#ifndef LIB_LIGHTING
#define LIB_LIGHTING
#include "/lib/uniforms.glsl"

vec3 sampleLightmap(vec2 lmcoord) {
#ifdef PROGRAM_DOMAIN_GBUFFERS
  return texture(lightmap, lmcoord).rgb;
#else
  vec2 px = lmcoord * 16.0 - 0.5;
  vec2 f = fract(px);
  vec2 base = (floor(px) + 0.5) / 16.0;
  vec3 s00 = texture(mclightmap, base).rgb;
  vec3 s10 = texture(mclightmap, base + vec2(1.0 / 16.0, 0.0)).rgb;
  vec3 s01 = texture(mclightmap, base + vec2(0.0, 1.0 / 16.0)).rgb;
  vec3 s11 = texture(mclightmap, base + vec2(1.0 / 16.0, 1.0 / 16.0)).rgb;
  return mix(mix(s00, s10, f.x), mix(s01, s11, f.x), f.y);
#endif
}

vec3 calcLighting(vec3 color, vec2 lmcoord, float ao) {
  return color * sampleLightmap(lmcoord) * ao;
}

#endif
