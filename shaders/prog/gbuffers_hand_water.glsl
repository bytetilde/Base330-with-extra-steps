#include "/lib/uniforms.glsl"

#ifdef VSH

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;
}

#endif

#ifdef FSH
#include "/lib/color.glsl"
#include "/lib/lighting.glsl"

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  vec4 tex = texture(gtexture, texcoord);
  color = vec4(tex.rgb * glcolor.rgb, tex.a);
  color.rgb = srgbToLinear(color.rgb);
  color.rgb = calcLighting(color.rgb, lmcoord, glcolor.a);
  if(color.a < alphaTestRef) discard;
}

#endif
