#ifndef LIB_COORDSPACE
#define LIB_COORDSPACE
#include "/lib/uniforms.glsl"

vec3 screenToView(vec3 screenPos) {
  vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
  vec4 tmp = gbufferProjectionInverse * ndcPos;
  return tmp.xyz / tmp.w;
}
vec3 viewToScreen(vec3 viewPos) {
  vec4 tmp = gbufferProjection * vec4(viewPos, 1.0);
  return tmp.xyz / tmp.w * 0.5 + 0.5;
}

vec3 viewToWorld(vec3 viewPos) {
  return (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
}
vec3 worldToView(vec3 worldPos) {
  return (gbufferModelView * vec4(worldPos, 1.0)).xyz;
}
vec3 viewDirToWorld(vec3 viewDir) {
  return (gbufferModelViewInverse * vec4(viewDir, 0.0)).xyz;
}
vec3 worldDirToView(vec3 worldDir) {
  return (gbufferModelView * vec4(worldDir, 0.0)).xyz;
}

vec3 screenToWorld(vec3 screenPos) {
  return viewToWorld(screenToView(screenPos));
}
vec3 worldToScreen(vec3 worldPos) {
  return viewToScreen(worldToView(worldPos));
}

vec3 worldToShadow(vec3 worldPos) {
  vec4 tmp = shadowProjection * shadowModelView * vec4(worldPos, 1.0);
  return tmp.xyz / tmp.w * 0.5 + 0.5;
}
vec3 viewToShadow(vec3 viewPos) {
  return worldToShadow(viewToWorld(viewPos));
}

float linearizeDepth(float depth) {
  return (near * far) / (far + depth * (near - far));
}

vec2 octEncode(vec3 n) {
  n /= abs(n.x) + abs(n.y) + abs(n.z);
  if(n.z < 0.0) n.xy = (vec2(1.0) - abs(n.yx)) * vec2(n.x >= 0.0 ? 1.0 : -1.0, n.y >= 0.0 ? 1.0 : -1.0);
  return n.xy * 0.5 + 0.5;
}
vec3 octDecode(vec2 e) {
  vec2 p = e * 2.0 - 1.0;
  vec3 n = vec3(p.x, p.y, 1.0 - abs(p.x) - abs(p.y));
  if(n.z < 0.0) n.xy = (vec2(1.0) - abs(n.yx)) * vec2(n.x >= 0.0 ? 1.0 : -1.0, n.y >= 0.0 ? 1.0 : -1.0);
  return normalize(n);
}

#endif
