#ifndef LIB_PBR_OLDPBR
#define LIB_PBR_OLDPBR

// PbrMaterial exists
// source: labpbr.glsl

// i actually DONT know how oldpbr works so this is a guess
// if it doesnt, my fault bro

PbrMaterial decodeOldPbr(vec4 normalSample, vec4 specularSample, vec3 albedo) {
  PbrMaterial material;
  vec3 normal = normalSample.rgb * 2.0 - 1.0;
  normal.y = -normal.y;
  material.normal = normalize(normal);
  material.ao = 1.0;
  material.height = normalSample.a;
  float perceptualRoughness = 1.0 - specularSample.r;
  material.roughness = perceptualRoughness * perceptualRoughness;
  material.metalness = specularSample.g;
  material.f0 = mix(vec3(0.04), albedo, material.metalness);
  material.reflectionTint = vec3(1.0);
  material.conductorN = vec3(0.0);
  material.conductorK = vec3(0.0);
  material.porosity = 0.0;
  material.subsurface = 0.0;
  material.emission = specularSample.b;
  return material;
}
PbrMaterial readOldPbr(sampler2D normalTexture, sampler2D specularTexture, vec2 texcoord, vec3 albedo) {
  return decodeOldPbr(texture(normalTexture, texcoord), texture(specularTexture, texcoord), albedo);
}

#endif
