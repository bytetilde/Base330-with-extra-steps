#include "/lib/uniforms.glsl"

#ifdef VSH

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

void main() {
  gl_Position = ftransform();
  normal = gl_NormalMatrix * gl_Normal;
  texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  glcolor = gl_Color;
}

#endif

#ifdef FSH
#include "/lib/color.glsl"
#include "/lib/coordspace.glsl"
#include "/lib/pbr.glsl"

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;
/* RENDERTARGETS: 0,1,2,3,4,5,6,7 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 normalData;
layout(location = 2) out vec4 lightData;
layout(location = 3) out vec4 pbrData0;
layout(location = 4) out vec4 pbrData1;
layout(location = 5) out vec4 pbrData2;
layout(location = 6) out vec4 pbrData3;
layout(location = 7) out vec4 pbrData4;

void main() {
  vec4 tex = texture(gtexture, texcoord);
  color = vec4(tex.rgb * glcolor.rgb, tex.a);
  color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
  color.rgb = srgbToLinear(color.rgb);
  if(color.a < alphaTestRef) discard;
  PbrMaterial material = readPbr(normals, specular, texcoord, color.rgb);
  normalData = vec4(octEncode(normalize(normal)), octEncode(material.normal));
  lightData = vec4(lmcoord, 0.0, glcolor.a);
  pbrData0 = vec4(material.ao, material.height, material.roughness, material.f0.r);
  pbrData1 = vec4(material.f0.gb, material.metalness, material.reflectionTint.r);
  pbrData2 = vec4(material.reflectionTint.gb, material.conductorN.rg);
  pbrData3 = vec4(material.conductorN.b, material.conductorK);
  pbrData4 = vec4(material.porosity, material.subsurface, material.emission, 0.0);
}

#endif
