#ifndef LIB_PBR_LABPBR
#define LIB_PBR_LABPBR

// PbrMaterial exists
// source: i know it does

PbrMaterial decodeLabPbr(vec4 normalSample, vec4 specularSample, vec3 albedo) {
  PbrMaterial material;
  vec2 normalXY = normalSample.rg * 2.0 - 1.0;
  normalXY.y = -normalXY.y;
  material.normal = normalize(vec3(normalXY, sqrt(max(1.0 - dot(normalXY, normalXY), 0.0))));
  material.ao = normalSample.b;
  material.height = normalSample.a;
  float perceptualRoughness = 1.0 - specularSample.r;
  material.roughness = perceptualRoughness * perceptualRoughness;
  int metal = int(floor(specularSample.g * 255.0 + 0.5));
  material.metalness = metal >= 230 ? 1.0 : 0.0;
  material.f0 = vec3(specularSample.g);
  material.reflectionTint = vec3(1.0);
  material.conductorN = vec3(0.0);
  material.conductorK = vec3(0.0);
  if(metal >= 230) {
    material.f0 = albedo;
    switch(metal) {
      case 230:
        material.conductorN = vec3(2.9114, 2.9497, 2.5845);
        material.conductorK = vec3(3.0893, 2.9318, 2.7670);
        break;
      case 231:
        material.conductorN = vec3(0.18299, 0.42108, 1.3734);
        material.conductorK = vec3(3.4242, 2.3459, 1.7704);
        break;
      case 232:
        material.conductorN = vec3(1.3456, 0.96521, 0.61722);
        material.conductorK = vec3(7.4746, 6.3995, 5.3031);
        break;
      case 233:
        material.conductorN = vec3(3.1071, 3.1812, 2.3230);
        material.conductorK = vec3(3.3314, 3.3291, 3.1350);
        break;
      case 234:
        material.conductorN = vec3(0.27105, 0.67693, 1.3164);
        material.conductorK = vec3(3.6092, 2.6248, 2.2921);
        break;
      case 235:
        material.conductorN = vec3(1.9100, 1.8300, 1.4400);
        material.conductorK = vec3(3.5100, 3.4000, 3.1800);
        break;
      case 236:
        material.conductorN = vec3(2.3757, 2.0847, 1.8453);
        material.conductorK = vec3(4.2655, 3.7153, 3.1365);
        break;
      case 237:
        material.conductorN = vec3(0.15943, 0.14512, 0.13547);
        material.conductorK = vec3(3.9291, 3.1900, 2.3808);
        break;
    }
    if(metal <= 237) {
      vec3 n = material.conductorN;
      vec3 k2 = material.conductorK * material.conductorK;
      material.f0 = ((n - 1.0) * (n - 1.0) + k2) / ((n + 1.0) * (n + 1.0) + k2);
      material.reflectionTint = albedo;
    }
  }
  float blue = specularSample.b * 255.0;
  material.porosity = blue <= 64.0 ? blue / 64.0 : 0.0;
  material.subsurface = blue > 64.0 ? clamp((blue - 65.0) / 190.0, 0.0, 1.0) : 0.0;
  material.emission = specularSample.a < 1.0 ? specularSample.a * (255.0 / 254.0) : 0.0;
  return material;
}
PbrMaterial readLabPbr(sampler2D normalTexture, sampler2D specularTexture, vec2 texcoord, vec3 albedo) {
  return decodeLabPbr(texture(normalTexture, texcoord), texture(specularTexture, texcoord), albedo);
}

#endif
