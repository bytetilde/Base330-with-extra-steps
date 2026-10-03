#ifndef LIB_UNIFORMS
#define LIB_UNIFORMS

/*
const int colortex0Format = RGBA16F;
*/

uniform sampler2D colortex0;
uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;
uniform vec4 entityColor;

uniform int renderStage;

uniform float viewHeight;
uniform float viewWidth;

uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;

uniform vec3 fogColor;
uniform vec3 skyColor;

#endif
