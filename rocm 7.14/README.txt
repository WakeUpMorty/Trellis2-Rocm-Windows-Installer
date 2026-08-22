# Trellis 2 - ROCm 7.14 installer (RX 9070 XT / gfx1201, Python 3.12)

This folder contains everything to install Microsoft **Trellis 2** on a
native-ROCm **ComfyUI_windows_portable** (or a global Python 3.12) running the
**torch 2.12.0 + ROCm 7.14.0** stack.

================================================================================
0. VERSION REQUIREMENT (IMPORTANT)
================================================================================
Both installers are LOCKED to the major.minor build family:

    torch        == 2.12.x   (major.minor match; 2.12.0, 2.12.1, ... all OK)
    ROCm         == 7.14.x   (major.minor match; any 7.14.0aYYYYMMDD nightly OK)

If your torch reports anything else (e.g. a CUDA build, or a different
torch/ROCm version such as 2.11/2.13 or 7.13/7.15), the installer aborts with
a clear message. Use the torch 2.12 + ROCm 7.14 build family before running it.

================================================================================
1. WHAT'S IN THIS FOLDER
================================================================================
  Trellis 2 Wheels\
      cumesh-1.0-cp312-cp312-win_amd64.whl
      flex_gemm-1.0.0-cp312-cp312-win_amd64.whl
      nvdiffrast-0.4.0-cp312-cp312-win_amd64.whl
      o_voxel-0.0.1-cp312-cp312-win_amd64.whl
      uv_raster-0.1.0-cp312-cp312-win_amd64.whl

  aotriton.images\
      amd-gfx11xx\
      amd-gfx120x\
      (kernel images required by the ROCm 7.14 stack - see step 3)

  install-trellis2.bat          -> portable install (uses python_embeded)
  install-trellis2-global.bat   -> global Python install (python on PATH)

================================================================================
2. THE INSTALL BATCH FILES - WHAT THEY DO
================================================================================
Both .bat files perform the same automated sequence:

  1. git check        - confirms git is available (needed to clone the node).
  2. python detect    - picks python_embeded (portable bat) or python on PATH
                        (global bat), then prints the torch/ROCm version and
                        verifies it is exactly 2.12.0 + 7.14.0.
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

  install-trellis2.bat        : run it from the ComfyUI_windows_portable ROOT
                                (the folder with python_embeded\ and
                                ComfyUI\custom_nodes\). Keep the "Trellis 2
                                Wheels\" folder next to it.
  install-trellis2-global.bat : run it from this folder; it uses whatever
                                "python" is on your PATH.

After either script finishes, do step 3 (aotriton.images) and then restart
ComfyUI.

================================================================================
3. aotriton.images - WHERE TO COPY
================================================================================
The ROCm 7.14 stack needs its AOTriton kernel images placed inside torch's
library folder. Copy the ENTIRE "aotriton.images" folder (the one containing
amd-gfx11xx\ and amd-gfx120x\) so the result looks like:

  PORTABLE (install-trellis2.bat):
    ComfyUI_windows_portable\python_embeded\Lib\site-packages\torch\lib\aotriton.images\
        amd-gfx11xx\
        amd-gfx120x\

  GLOBAL (install-trellis2-global.bat):
    <your python 3.12>\Lib\site-packages\torch\lib\aotriton.images\
        amd-gfx11xx\
        amd-gfx120x\

i.e. you should end up with:
    ...\torch\lib\aotriton.images\amd-gfx120x\...
NOT:
    ...\torch\lib\aotriton.images\aotriton.images\amd-gfx120x\...   (wrong - doubled)

This copy is NOT done by the .bat files; do it manually after install.

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

  :: d) Copy aotriton.images as in step 3, then restart ComfyUI.

================================================================================
5. INSTALLED PACKAGE VERSIONS (7.14 build)
================================================================================
  comfyui                    0.28.0
  rocm                       7.14
  rocm-sdk-core             7.14
  rocm-sdk-libraries        7.14
  rocm-sdk-device-gfx1201   7.14
  torch                      2.12.0+rocm7.14
  torchvision               0.27.0+rocm7.14
  torchaudio                2.10.0+rocm7.14
  amd-torch-device-gfx1201  2.12.0+rocm7.14

  Trellis2 compiled wheels:
  cumesh 1.0 | flex_gemm 1.0.0 | nvdiffrast 0.4.0 | o_voxel 0.0.1 | uv_raster 0.1.0

================================================================================
6. TROUBLESHOOTING
================================================================================
  - "torch/ROCm version mismatch": your torch is not in the 2.12 + 7.14
    family. Install that build family first (step 5 versions above).
  - GLB / texture baking crashes on AMD: ensure uv_raster is installed
    (it auto-patches the ComfyUI-Trellis2 node's rasterization to use the
    native-HIP backend). The o_voxel wheel is used by the standalone app only.
  - Missing aotriton.images at runtime: redo step 3 (copy into torch\lib\).
