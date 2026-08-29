# Trellis 2 - ROCm 10.0 installer (AMD, Python 3.12)

This folder contains everything to install Microsoft **Trellis 2** on a
native-ROCm **ComfyUI_windows_portable** (or a global Python 3.12) running the
**torch 2.13.0 + ROCm 10.0.0** stack (TheRock-based build).

================================================================================
0. VERSION REQUIREMENT (IMPORTANT)
================================================================================
Both installers are LOCKED to the major.minor build family:

    torch        == 2.13.x   (major.minor match; 2.13.0, 2.13.1, ... all OK)
    ROCm         == 10.0.x   (major.minor match; any 10.0.0aYYYYMMDD nightly OK)

If your torch reports anything else (e.g. a CUDA build, or a different
torch/ROCm version such as 2.12/2.14 or 7.14/10.1), the installer aborts with
a clear message. Use the torch 2.13 + ROCm 10.0 build family before running it.

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
                        verifies it is exactly 2.13.0 + 10.0.0.
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

   install-trellis2-portable.bat : copy this .bat AND the "Trellis 2 Wheels\"
                                 folder to the ComfyUI_windows_portable ROOT
                                 (the folder with python_embeded\ and
                                 ComfyUI\custom_nodes\). Run it from there.
   install-trellis2-global.bat   : copy this .bat AND the "Trellis 2 Wheels\"
                                 folder to the ComfyUI_windows_portable ROOT and
                                 run it from there; it uses whatever "python" is
                                 on your PATH (must be the ROCm 10 build).

After either script finishes, do step 3 (aotriton.images) if your stack needs
it, then restart ComfyUI.

================================================================================
3. aotriton.images (ONLY IF YOUR STACK NEEDS IT)
================================================================================
The ROCm 10.0 stack uses AOTriton runtime compile (TheRock wheels), so it
usually does NOT need separate kernel images. If required, copy the
aotriton.images folder (the one containing amd-gfx11xx\ and amd-gfx120x\) so
the result looks like:

  PORTABLE (install-trellis2-portable.bat):
    ComfyUI_windows_portable\python_embeded\Lib\site-packages\torch\lib\aotriton.images\
        amd-gfx11xx\
        amd-gfx120x\

  GLOBAL (install-trellis2-global.bat):
    <your python 3.12>\Lib\site-packages\torch\lib\aotriton.images\
        amd-gfx11xx\
        amd-gfx120x\

NOTE: this folder does NOT bundle aotriton.images. If your torch 2.13+/ROCm 10.0
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
5. EXAMPLE INSTALLED PACKAGE VERSIONS (ROCm 10.0 stack)
================================================================================
  torch                      2.13.0+rocm10.0.0   (any 2.13.x/10.0.x accepted)
  torchvision                0.28.0+rocm10.0.0
  torchaudio                 2.11.0.2+rocm10.0.0
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
  - "torch/ROCm version mismatch": your torch is not in the 2.13 + 10.0
    family. Install that build family first (step 5 versions above).
  - GLB / texture baking crashes on AMD: ensure uv_raster is installed
    (it auto-patches the ComfyUI-Trellis2 node's rasterization to use the
    native-HIP backend). The o_voxel wheel is used by the standalone app only.
  - Missing AOTriton kernels at runtime: copy aotriton.images as in step 3.
