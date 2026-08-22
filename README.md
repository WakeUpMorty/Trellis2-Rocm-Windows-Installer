# Trellis2-Rocm-Windows-Installer for https://github.com/visualbruno/ComfyUI-Trellis2
One-click installers for Microsoft TRELLIS 2 on AMD GPUs under Windows — native ROCm build. Includes a portable ComfyUI installer, a global-python installer, all with auto node-clone, force-reinstall wheel installs, and the uv_raster AMD-native rasterizer patches for render/extract.

# You need to have access to facebook dinov3 models in order to use Trellis.2

https://huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m

Clone the repository in ComfyUI models folder under "facebook/dinov3-vitl16-pretrain-lvd1689m"

So in ComfyUI/models/facebook/dinov3-vitl16-pretrain-lvd1689m

As of now Pixal3D-T model, it's working natten package still needs porting 

# Tested on RDNA 4. Compiled with RDNA3, RDNA3.5 and RDNA4 for Rocm 7.2.1+Pytorch 2.9.1 and Rocm 7.14+Pytorch 2.12

Backend needs to be change from Flash Attention--->SDPA as per photo to work

---

<img width="1920" height="980" alt="Image" src="https://github.com/user-attachments/assets/82851a70-aae3-4473-a1c4-f06f1735b45e" />

---

## install-trellis2-portable.bat

**Place the `.bat` and the `wheels\` folder in the ComfyUI_windows_portable ROOT** — the folder containing `python_embeded\python.exe` and `ComfyUI\custom_nodes\`. The `wheels\` folder must be next to the `.bat` (same root), and `python_embeded\python.exe` is detected automatically because the bat checks for it first. If absent, the `ComfyUI-Trellis2` node is auto-cloned into `ComfyUI\custom_nodes\` and its `requirements.txt` is installed. `git` must be on PATH, and wheels are always force-reinstalled, so re-running applies the bundled build cleanly.

```
ComfyUI_windows_portable\
├── install-trellis2-portable.bat   ← here
├── wheels\                        ← WT=.\wheels  (next to the .bat)
│   ├── cumesh-1.0-cp312-cp312-win_amd64.whl
│   ├── flex_gemm-1.0.0-cp312-cp312-win_amd64.whl
│   ├── nvdiffrast-0.4.0-cp312-cp312-win_amd64.whl
│   ├── o_voxel-0.0.1-cp312-cp312-win_amd64.whl
│   └── uv_raster-0.1.0-cp312-cp312-win_amd64.whl
├── python_embeded\
└── ComfyUI\

```

## install-trellis2-global-new.bat

**Place the `.bat` next to a `wheels\` folder** (anywhere, since it uses the global `python` from PATH). The node is cloned into `.\ComfyUI\custom_nodes\ComfyUI-Trellis2` (or `.\custom_nodes\` if that exists) relative to wherever you run the bat — so run it from the ComfyUI install root if you want the node in the right place. `git` must be on PATH, and wheels are always force-reinstalled.

```
some-folder\
├── install-trellis2-global-new.bat   ← here
└── wheels\                          ← WT=.\wheels
    ├── cumesh-...whl
    ├── flex_gemm-...whl
    ├── nvdiffrast-...whl
    ├── o_voxel-...whl
    └── uv_raster-...whl
```

## My startup flags 

```
set PYTORCH_ALLOC_CONF=expandable_segments:True
set HIP_VISIBLE_DEVICES=0
.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build --use-pytorch-cross-attention
```
