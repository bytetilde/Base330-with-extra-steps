#include "/lib/uniforms.glsl"

#ifdef VSH

out vec2 texcoord;

void main() {
  gl_Position = ftransform();
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}

#endif

#ifdef FSH
#include "/lib/color.glsl"

in vec2 texcoord;
/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  vec4 tex = texture(colortex0, texcoord);
  color = vec4(linearToSrgb(tex.rgb), tex.a);
}

#endif
