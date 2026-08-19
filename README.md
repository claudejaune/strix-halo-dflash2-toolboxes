# Strix Halo DFlash2 Toolboxes

Pre-built containers for running **DFlash2** speculative decoding (see [release blog post](https://inco.ai/blog/dflash2/)) on AMD Ryzen AI Max "Strix Halo" (gfx1151). Built with llama.cpp PR #27342 (build 10498), adding support for the DFlash2 draft model architecture.

Use these toolboxes until DFlash2 support is merged into stock llama.cpp.

## Running

### Get draft models
Download the DFlash2 models from Hugging Face. Get the Q4 ones:

https://huggingface.co/incoai/Qwen3.8-27B-DFlash2-GGUF

### Build and install a toolbox (choose vulkan or rocm)

```bash
./setup.sh vulkan    # Vulkan RADV — most compatible
./setup.sh rocm      # ROCm 7.14 — best performance
./setup.sh all       # Both
```

### Edit presets file

Inside the toolbox, edit `presets-dflashtest.ini` to point to your model paths, modify the context size (`ctx-size = 200000` by default), and `reasoning effort` (`medium` by default).

### Enter the toolbox

```bash
toolbox enter llama-vulkan-radv-dflash2   # or llama-rocm-7.14-dflash2
```

### Run the llama.cpp server

```bash
llama-server --models-preset presets-dflashtest.ini \
  --host 0.0.0.0 --port 1234 --models-max 1 .
```
