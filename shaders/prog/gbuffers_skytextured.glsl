#include "/lib/uniforms.glsl"

#ifdef VSH

out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

void main() {
  gl_Position = ftransform();
  normal = gl_NormalMatrix * gl_Normal;
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  glcolor = gl_Color;
}

#endif

#ifdef FSH
#include "/lib/color.glsl"
#include "/lib/coordspace.glsl"

in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normalData;
layout(location = 2) out vec4 lightData;

void main() {
  vec4 tex = texture(gtexture, texcoord);
  color = vec4(tex.rgb * glcolor.rgb * glcolor.a, tex.a);
  color.rgb = srgbToLinear(color.rgb);
  if(color.a < alphaTestRef) discard;
  normalData = vec4(octEncode(normalize(normal)), octEncode(normalize(normal)));
  lightData = vec4(0.0, 0.0, 1.0, 1.0);
}

#endif
