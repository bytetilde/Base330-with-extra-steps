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
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  color = glcolor * texture(lightmap, lmcoord);
  if(color.a < alphaTestRef) discard;
}

#endif
