#include "/lib/uniforms.glsl"

#ifdef VSH

out vec4 glcolor;

void main() {
  gl_Position = ftransform();
  glcolor = gl_Color;
}

#endif

#ifdef FSH

in vec4 glcolor;
/* RENDERTARGETS: 0,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightData;

float fogify(float x, float w) {
  return w / (x * x + w);
}
vec3 calcSkyColor(vec3 pos) {
  float upDot = dot(pos, gbufferModelView[1].xyz);
  return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
}
vec3 screenToView(vec3 screenPos) {
  vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0;
  vec4 tmp = gbufferProjectionInverse * ndcPos;
  return tmp.xyz / tmp.w;
}

void main() {
  if(renderStage == MC_RENDER_STAGE_STARS) {
    color = glcolor;
  } else {
    vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
    color = vec4(calcSkyColor(normalize(pos)), 1.0);
  }
  lightData = vec4(0.0, 0.0, 1.0, 1.0);
}

#endif
