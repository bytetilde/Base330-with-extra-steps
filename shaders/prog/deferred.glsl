#include "/lib/uniforms.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH
#include "/lib/lighting.glsl"

in vec2 texcoord;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  vec4 albedo = texture(colortex0, texcoord);
  vec4 lightData = texture(colortex2, texcoord);
  if(lightData.b > 0.5) color = albedo;
  else color = vec4(calcLighting(albedo.rgb, lightData.xy, lightData.a), albedo.a);
}

#endif
