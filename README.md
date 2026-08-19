# Strix Halo DFlash2 Toolboxes

Pre-built containers for running **DFlash2** speculative decoding (see [release blog post](https://inco.ai/blog/dflash2/)) on AMD Ryzen Strix Halo (AI Max +395 gfx1151).

Built with [llama.cpp PR #27342](https://github.com/ggml-org/llama.cpp/pull/27342), these toolboxes add support for the DFlash2 draft model architecture.

Use these toolboxes until DFlash2 support is merged into stock llama.cpp.

## Running

### Clone repo and enter

```bash
git clone https://github.com/claudejaune/strix-halo-dflash2-toolboxes
cd strix-halo-dflash2-toolboxes
```

### Get draft models
Download the DFlash2 models from Hugging Face. Get the Q4 ones:

https://huggingface.co/incoai/Qwen3.8-27B-DFlash2-GGUF

### Build and install a toolbox (choose Vulkan or ROCm)

```bash
./setup.sh vulkan    # Vulkan RADV — smaller, better performance (RECOMMENDED)
./setup.sh rocm      # ROCm 7.14 — HIP backend
./setup.sh all       # Build both
```

### Edit presets file

Edit `presets-dflashtest.ini` to: 
1. Point to your model paths
2. (Optional) Modify the context size (`ctx-size = 200000` by default)
3. (Optional) Change `reasoning effort` (`medium` by default).

### Enter the toolbox

```bash
toolbox enter llama-vulkan-radv-dflash2   # or llama-rocm-7.14-dflash2
```

### Run the llama.cpp server

```bash
llama-server --models-preset presets-dflashtest.ini \
  --host 0.0.0.0 --port 1234 --models-max 1 .
```
