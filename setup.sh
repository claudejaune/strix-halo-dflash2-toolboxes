#!/usr/bin/env bash
set -euo pipefail

# ─── Strix Halo DFlash2 Toolboxes ──────────────────────────────────────
# Builds and installs a toolbox with llama.cpp build 10498 (PR #27342)
# supporting DFlash2 speculative decoding on AMD gfx1151.
#
# Usage:
#   ./setup.sh vulkan    # Vulkan RADV backend (most compatible)
#   ./setup.sh rocm      # ROCm 7.14 HIP backend
#   ./setup.sh both      # Build both

# ─── Interactive menu (no args) or direct mode (with arg) ──────────────
if [ $# -eq 0 ]; then
  echo "Choose a backend:"
  echo "  1) Vulkan    — smaller, similar performance (RECOMMENDED)"
  echo "  2) ROCm 7.14 — HIP backend"
  echo "  3) Both      — build both"
  echo -n "Selection [1-3]: "
  read -r choice
  case "$choice" in
    1) BACKEND="vulkan" ;;
    2) BACKEND="rocm" ;;
    3) BACKEND="all" ;;
    *) echo "Invalid selection. Please choose 1, 2, or 3."; exit 1 ;;
  esac
else
  BACKEND="${1}"
fi

# ─── Pre-flight checks ────────────────────────────────────────────────
for cmd in podman toolbox; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' is required but not found."
    exit 1
  fi
done

TOOLBOX_CMD="toolbox"
if [ -f /etc/os-release ] && grep -q "^ID=ubuntu\|^ID=debian" /etc/os-release; then
  TOOLBOX_CMD="distrobox"
fi

# ─── Build function ───────────────────────────────────────────────────
build_toolbox() {
  local name="$1"
  local dockerfile="$2"
  echo "🔨 Building $name ..."
  podman build --no-cache -t "$name" \
    -f "$(dirname "$0")/$dockerfile" .
  echo "✅ Image built: $name"

  # Check if toolbox already exists; skip creation if so
  if $TOOLBOX_CMD list 2>/dev/null | grep -q "^${name} "; then
    echo "ℹ️  Toolbox '$name' already exists, skipping."
  else
    local extra_args=""
    if [[ "$name" == *rocm* ]]; then
      extra_args="--device /dev/dri --device /dev/kfd \
        --group-add video --group-add render"
    else
      extra_args="--device /dev/dri --group-add video"
    fi
    $TOOLBOX_CMD create "$name" \
      --image "localhost/$name" \
      -- --security-opt seccomp=unconfined $extra_args
    echo "✅ Toolbox created: enter with '$TOOLBOX_CMD enter $name'"
  fi
}

# ─── Build requested backends ─────────────────────────────────────────
case "$BACKEND" in
  vulkan|all)
    build_toolbox llama-vulkan-radv-dflash2 Dockerfile.vulkan-radv-dflash2
    ;;
  rocm|all)
    build_toolbox llama-rocm-7.14-dflash2 Dockerfile.rocm-7.14-dflash2
    ;;
  *)
    echo "Usage: $0 {vulkan|rocm|both}"
    exit 1
    ;;
esac

echo ""
echo "─── Done ─────────────────────────────────────────────────────────────"
echo "1. Enter the toolbox:"
echo ""
echo "  \`$TOOLBOX_CMD enter llama-vulkan-radv-dflash2\` OR \`$TOOLBOX_CMD llama-rocm-7.14-dflash2\`"
echo ""
echo "    (depending on which one you built)"
echo ""
echo "2. Edit presets-dflashtest.ini to point to your model paths, then run:"
echo ""
echo "  llama-server --models-preset ./presets-dflashtest.ini \\"
echo "    --host 0.0.0.0 --port 1235 --models-max 1"
echo ""
