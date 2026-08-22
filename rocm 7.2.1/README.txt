# Trellis 2 - ROCm 7.2.1 installer (AMD, Python 3.12)

This folder contains everything to install Microsoft **Trellis 2** on a
native-ROCm **ComfyUI_windows_portable** (or a global Python 3.12) running a
**torch 2.9+ / ROCm 7.2+** stack (e.g. 2.9.1+rocm7.2.1).

================================================================================
0. VERSION REQUIREMENT
================================================================================
Both installers require at least:

    torch        >= 2.9      (2.9.x, and newer 2.x are accepted)
    ROCm         >= 7.2      (7.2.x, and newer 7.x are accepted)

Unlike the 7.14 folder (which is locked to an exact build family), this 7.2.1
folder is a MINIMUM check: any torch 2.9+/ROCm 7.2+ build passes. A CUDA
build, or a torch older than 2.9 / ROCm older than 7.2, is refused.

================================================================================
1. WHAT'S IN THIS FOLDER
================================================================================
  Trellis 2 Wheels\
      cumesh-1.0-cp312-cp312-win_amd64.whl
      flex_gemm-1.0.0-cp312-cp312-win_amd64.whl
      nvdiffrast-0.4.0-cp312-cp312-win_amd64.whl
      o_voxel-0.0.1-cp312-cp312-win_amd64.whl
      uv_raster-0.1.0-cp312-cp312-win_amd64.whl

  install-trellis2-portable.bat   -> portable install (uses python_embeded)
  install-trellis2-global.bat     -> global Python install (python on PATH)

================================================================================
2. THE INSTALL BATCH FILES - WHAT THEY DO
================================================================================
Both .bat files perform the same automated sequence:

  1. git check        - confirms git is available (needed to clone the node).
  2. python detect    - picks python_embeded (portable bat) or python on PATH
                        (global bat), then prints the torch/ROCm version and
                        verifies it is torch >= 2.9 and ROCm >= 7.2.
  3. node install     - if ComfyUI-Trellis2 is not already in
                        ComfyUI\custom_nodes\, it auto-clones it from GitHub
                        and installs its requirements.txt.
  4. PyPI deps        - pip installs: triton-windows, onnxruntime,
                        onnxruntime-directml, opencv-python, trimesh, meshlib,
                        pymeshlab, scipy, open3d, plotly, rembg, requests,
                        tqdm, filelock, easydict, plyfile, zstandard, torchsde.
  5. wheels           - installs the 5 wheels from "Trellis 2 Wheels\".
                         Every wheel is force-reinstalled,
                         so the script applies the bundled build cleanly each run.
  6. verify           - imports all five packages and reports success.

  install-trellis2-portable.bat : run it from the ComfyUI_windows_portable ROOT
                                (the folder with python_embeded\ and
                                ComfyUI\custom_nodes\). Keep the "Trellis 2
                                Wheels\" folder next to it.
  install-trellis2-global.bat   : run it from this folder; it uses whatever
                                "python" is on your PATH.

After either script finishes, do step 3 (aotriton.images) if your stack needs
it, then restart ComfyUI.

================================================================================
3. aotriton.images (ONLY IF YOUR STACK NEEDS IT)
================================================================================
Some ROCm builds need their AOTriton kernel images placed inside torch's
library folder. If required, copy the aotriton.images folder (the one
containing amd-gfx11xx\ and amd-gfx120x\) so the result looks like:

  PORTABLE (install-trellis2-portable.bat):
    ComfyUI_windows_portable\python_embeded\Lib\site-packages\torch\lib\aotriton.images\
        amd-gfx11xx\
        amd-gfx120x\

  GLOBAL (install-trellis2-global.bat):
    <your python 3.12>\Lib\site-packages\torch\lib\aotriton.images\
        amd-gfx11xx\
        amd-gfx120x\

NOTE: this folder does NOT bundle aotriton.images. If your torch 2.9+/ROCm 7.2+
stack already ships them (common with the AMD nightly wheels), skip this step.
If torch fails to find AOTriton proven kernels at runtime, add them here.

================================================================================
4. MANUAL INSTALL (alternative to the .bat files)
================================================================================
From the ComfyUI_windows_portable root, with python_embeded\python.exe:

  :: a) ComfyUI-Trellis2 node (via ComfyUI Manager or git)
  ::    into ComfyUI\custom_nodes\ComfyUI-Trellis2

  :: b) Python deps
  .\python_embeded\python.exe -m pip install triton-windows onnxruntime ^
    onnxruntime-directml opencv-python trimesh meshlib pymeshlab scipy open3d ^
    plotly rembg requests tqdm filelock easydict plyfile zstandard torchsde

  :: c) Wheels (from "Trellis 2 Wheels\")
  .\python_embeded\python.exe -m pip install cumesh-1.0-cp312-cp312-win_amd64.whl ^
    flex_gemm-1.0.0-cp312-cp312-win_amd64.whl nvdiffrast-0.4.0-cp312-cp312-win_amd64.whl ^
    o_voxel-0.0.1-cp312-cp312-win_amd64.whl uv_raster-0.1.0-cp312-cp312-win_amd64.whl

  :: d) Copy aotriton.images if needed (step 3), then restart ComfyUI.

================================================================================
5. EXAMPLE INSTALLED PACKAGE VERSIONS (7.2.1 stack)
================================================================================
  torch                      2.9.1+rocm7.2.1   (any 2.9+/7.2+ accepted)
  torchvision               (matching torch build)
  nvdiffrast                0.4.0
  o_voxel                   0.0.1
  uv_raster                 0.1.0
  cumesh                    1.0
  flex_gemm                 1.0.0

  Trellis2 compiled wheels:
  cumesh 1.0 | flex_gemm 1.0.0 | nvdiffrast 0.4.0 | o_voxel 0.0.1 | uv_raster 0.1.0

================================================================================
6. TROUBLESHOOTING
================================================================================
  - "torch/ROCm version check failed": your torch is older than 2.9 or ROCm
    older than 7.2, or it is a CUDA build. Install a torch 2.9+/ROCm 7.2+
    build first.
  - GLB / texture baking crashes on AMD: ensure uv_raster is installed
    (it auto-patches the ComfyUI-Trellis2 node's rasterization to use the
    native-HIP backend). The o_voxel wheel is used by the standalone app only.
  - Missing AOTriton kernels at runtime: copy aotriton.images as in step 3.
