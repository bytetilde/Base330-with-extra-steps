#!/bin/sh
cd "$(dirname "$0")/.." || exit 1
DEFINES="-DMC_RENDER_STAGE_NONE=0 -DMC_RENDER_STAGE_SKY=1 -DMC_RENDER_STAGE_SUNSET=2 -DMC_RENDER_STAGE_CUSTOM_SKY=3 -DMC_RENDER_STAGE_SUN=4 -DMC_RENDER_STAGE_MOON=5 -DMC_RENDER_STAGE_STARS=6 -DMC_RENDER_STAGE_VOID=7 -DMC_RENDER_STAGE_TERRAIN_SOLID=8 -DMC_RENDER_STAGE_TERRAIN_CUTOUT_MIPPED=9 -DMC_RENDER_STAGE_TERRAIN_CUTOUT=10 -DMC_RENDER_STAGE_ENTITIES=11 -DMC_RENDER_STAGE_BLOCK_ENTITIES=12 -DMC_RENDER_STAGE_DESTROY=13 -DMC_RENDER_STAGE_OUTLINE=14 -DMC_RENDER_STAGE_DEBUG=15 -DMC_RENDER_STAGE_HAND_SOLID=16 -DMC_RENDER_STAGE_TERRAIN_TRANSLUCENT=17 -DMC_RENDER_STAGE_TRIPWIRE=18 -DMC_RENDER_STAGE_PARTICLES=19 -DMC_RENDER_STAGE_CLOUDS=20 -DMC_RENDER_STAGE_RAIN_SNOW=21 -DMC_RENDER_STAGE_WORLD_BORDER=22 -DMC_RENDER_STAGE_HAND_TRANSLUCENT=23"
status=0
found=0
for f in shaders/world*/*.vsh shaders/world*/*.fsh; do
  [ -e "$f" ] || continue
  found=$((found + 1))
  case "${f##*.}" in
    vsh) stage=vert ;;
    fsh) stage=frag ;;
  esac
  out=$(glslangValidator -l $DEFINES -P"#extension GL_GOOGLE_include_directive : enable" -Ishaders -S "$stage" "$f" 2>&1) || { echo "$out"; status=1; }
done
tmp=$(mktemp -d)
for f in shaders/lib/*.glsl shaders/lib/*/*.glsl; do
  [ -e "$f" ] || continue
  found=$((found + 1))
  printf '#version 330 compatibility\n#define FSH\n#define OVERWORLD\n#define PROGRAM_GBUFFERS_CHECKLIB\n#include "/%s"\nvoid main() {}\n' "${f#shaders/}" > "$tmp/w.frag"
  out=$(glslangValidator -l $DEFINES -P"#extension GL_GOOGLE_include_directive : enable" -Ishaders -S frag "$tmp/w.frag" 2>&1) || { echo "$out"; status=1; }
done
rm -rf "$tmp"
[ "$found" -gt 0 ] || { echo "no shader sources found (glob matched nothing)"; exit 1; }
[ "$status" -eq 0 ] && echo "$found sources OK"
exit $status
