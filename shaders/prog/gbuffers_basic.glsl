#include "/lib/uniforms.glsl"

#ifdef VSH

out vec2 lmcoord;
out vec4 glcolor;

void main() {
  gl_Position = ftransform();
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;
}

#endif

#ifdef FSH

in vec2 lmcoord;
in vec4 glcolor;
/* RENDERTARGETS: 0,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightData;

void main() {
  color = vec4(glcolor.rgb * glcolor.a, 1.0);
  if(color.a < alphaTestRef) discard;
  lightData = vec4(lmcoord, 0.0, 1.0);
}

#endif
