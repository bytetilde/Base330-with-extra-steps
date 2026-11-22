# Base-330 with extra steps

[Base-330](https://github.com/shaderLABS/Base-330) template pack with more stuff on top of it

- Linearized RGB
- Folder structure & dimension stubs
- Hybrid rendering (opaque deferred, translucent forward)
- Uniforms in that one file right there
- PBR support (labPBR and hopefully correct oldPBR)
  Only normals are written for now, in colortex1, octahedral encoding:
  - colortex1.rg: face normals
  - colortex1.ba: also face normals but with the PBR normal map applied (perturbed?)
  Decoding for the other fields is implemented
- Extra code for stuff like coordinate space conversion

**Iris-only**, this does not support OptiFine

It's the structure I tend to converge on

Public domain (Unlicense) I think
