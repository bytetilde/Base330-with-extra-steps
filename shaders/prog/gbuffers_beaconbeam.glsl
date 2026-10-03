#include "/lib/uniforms.glsl"

#ifdef VSH

out vec2 texcoord;
out vec4 glcolor;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  glcolor = gl_Color;
}

#endif

#ifdef FSH

in vec2 texcoord;
in vec4 glcolor;
/* RENDERTARGETS: 0,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightData;

void main() {
  vec4 tex = texture(gtexture, texcoord);
  color = vec4(tex.rgb * glcolor.rgb * glcolor.a, tex.a);
  if(color.a < alphaTestRef) discard;
  lightData = vec4(0.0, 0.0, 1.0, 1.0);
}

#endif
