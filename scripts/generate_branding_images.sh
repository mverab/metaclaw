#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/assets/branding/generated"
MODEL="${OPENAI_IMAGE_MODEL:-gpt-image-1}"

if [[ -f "$ROOT_DIR/.env" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.env"
fi

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "ERROR: OPENAI_API_KEY is missing. Export it or set it in .env"
  exit 1
fi

mkdir -p "$OUT_DIR/logo" "$OUT_DIR/banner" "$OUT_DIR/social"

NEGATIVE='literal claw icon, mascot, gaming logo, cyberpunk overload, noisy texture, photorealism, long text blocks, stock photo look, heavy glow, lens flare, low contrast, watermark'

generate_png() {
  local prompt="$1"
  local size="$2"
  local output="$3"

  local payload
  payload=$(jq -n \
    --arg model "$MODEL" \
    --arg prompt "$prompt" \
    --arg size "$size" \
    '{model:$model, prompt:$prompt, size:$size}')

  local response
  response=$(curl -sS https://api.openai.com/v1/images/generations \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$payload")

  local b64
  b64=$(echo "$response" | jq -r '.data[0].b64_json // empty')

  if [[ -z "$b64" ]]; then
    echo "ERROR generating $output"
    echo "$response" | jq -r '.error.message // "Unknown API error"'
    exit 1
  fi

  echo "$b64" | base64 -d > "$output"
  echo "Generated: $output"
}

LOGO_01="Abstract premium B2B tech logo for \"MetaClaw\", metalayer orchestration concept, geometric layered monogram, flat vector-like style, dark navy background, cyan and lime accents, strong silhouette, scalable at 32px, minimal text, transparent-feel composition. Avoid: ${NEGATIVE}."
LOGO_02="Minimal founder-grade product logo for \"MetaClaw\", stacked rectangular layers forming a precise abstract mark, clean negative space, modern geometric sans wordmark optional, high contrast, no decorative details. Avoid: ${NEGATIVE}."
LOGO_03="Enterprise AI infrastructure brand mark for \"MetaClaw\", abstract orchestration layers and directional flow, crisp edges, restrained palette, premium and serious tone, no literal symbols. Avoid: ${NEGATIVE}."

BANNER_01="GitHub repository hero banner for \"MetaClaw Setup Architect\", founder-focused product identity, abstract metalayer geometry, minimal typography only \"MetaClaw\" and \"Setup Architect\", left-aligned text-safe region, dark professional palette with cyan/lime accents, clean premium composition. Avoid: ${NEGATIVE}."
BANNER_02="Product launch banner for \"MetaClaw\", abstract orchestration layers flowing across canvas, subtle grid structure, minimal copy \"MetaClaw\" and \"Setup Architect\", high readability, no clutter. Avoid: ${NEGATIVE}."
BANNER_03="B2B AI systems banner, concept: meta-layer for multi-agent execution, geometric depth with simple flat forms, serious enterprise visual tone, minimal typographic lockup. Avoid: ${NEGATIVE}."

SOCIAL_01="Open Graph social card for \"MetaClaw Setup Architect\", premium founder-tech branding, abstract layered geometry, minimal text only \"MetaClaw\" and \"Setup Architect\", strong readability in feed preview, dark palette with cyan/lime accents. Avoid: ${NEGATIVE}."
SOCIAL_02="Social launch card for \"MetaClaw\", abstract orchestration visual metaphor, clean product-brand layout, minimal text lockup, high contrast, consistent with enterprise AI tooling brand. Avoid: ${NEGATIVE}."

generate_png "$LOGO_01" "1024x1024" "$OUT_DIR/logo/logo-01.png"
generate_png "$LOGO_02" "1024x1024" "$OUT_DIR/logo/logo-02.png"
generate_png "$LOGO_03" "1024x1024" "$OUT_DIR/logo/logo-03.png"

generate_png "$BANNER_01" "1536x1024" "$OUT_DIR/banner/banner-01.png"
generate_png "$BANNER_02" "1536x1024" "$OUT_DIR/banner/banner-02.png"
generate_png "$BANNER_03" "1536x1024" "$OUT_DIR/banner/banner-03.png"

generate_png "$SOCIAL_01" "1536x1024" "$OUT_DIR/social/social-01.png"
generate_png "$SOCIAL_02" "1536x1024" "$OUT_DIR/social/social-02.png"

echo "All candidate images generated under: $OUT_DIR"
