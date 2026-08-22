@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Install Trellis2 (Global Python / native ROCm)

rem ============================================================
rem  Trellis2 one-click installer - GLOBAL python build
rem  Target: a system/global Python on PATH (native-ROCm torch)
rem
rem  Place this .bat next to the wheels\ folder.
rem  Edit the PY var below if python is not on your PATH.
rem
rem  - Missing node is auto-cloned (+ requirements.txt installed).
rem  - Wheels are always force-reinstalled (clean re-run).
rem  Global specifics:
rem   - Python = global "python"
rem   - Requires torch >= 2.9.1 built on ROCm >= 7.2.1
rem   - triton-windows IS installed (kept for parity/compat)
rem   - uv_raster wheel provides the AMD-native rasterizer used by
rem     the patched render/extract paths.
rem  IMPORTANT: the wheels must be built for your global
rem  native-ROCm torch.
rem ============================================================

cd /d "%~dp0"

set "WT=.\wheels"

rem ---- git availability ----
where git >nul 2>nul
if errorlevel 1 (
    echo ERROR: git not found on PATH. Install Git for Windows, then re-run.
    pause & exit /b 1
)

rem ---- locate python: global python on PATH ----
set "PY=python"
where "%PY%" >nul 2>nul
if errorlevel 1 (
    echo ERROR: python not found on PATH. Install Python 3.12 or edit the PY var in this file.
    pause & exit /b 1
)
echo.
echo Using python: %PY%
%PY% --version

rem ---- verify torch is a ROCm build >= 2.9.1+rocm7.2.1 ----
echo.
echo === Verifying torch / ROCm version ===
"%PY%" -c "import torch,re,sys; v=torch.__version__; m=re.search(r'rocm([0-9]+\.[0-9]+\.[0-9]+)',v); tv=tuple(int(x) for x in v.split('+')[0].split('.')[:2]); rv=tuple(int(x) for x in m.group(1).split('.'))[:2] if m else (0,0); sys.exit(0) if (m and tv>=(2,9) and rv>=(7,2)) else (print('ERROR: this installer requires torch >= 2.9 built on ROCm >= 7.2.') or print('       found: '+v) or sys.exit(1))"
if errorlevel 1 (
    echo.
    echo ERROR: torch/ROCm version check failed. Install/use a ROCm build of
    echo torch 2.9 or newer (e.g. torch 2.9+rocm7.2) before running this installer.
    pause & exit /b 1
)
echo  torch/ROCm version OK.

rem ---- locate custom_nodes ----
if exist ".\ComfyUI\custom_nodes" ( set "NODES=.\ComfyUI\custom_nodes" ) else ( set "NODES=.\custom_nodes" )
if not exist "%NODES%" ( mkdir "%NODES%" >nul 2>nul )
echo Using custom_nodes: %NODES%
echo.

rem ---- Trellis2 node ----
set "N1=ComfyUI-Trellis2"
set "N1URL=https://github.com/visualbruno/ComfyUI-Trellis2"

echo === Checking/installing node: %N1% ===
if exist "%NODES%\%N1%" (
    echo  Already present: %NODES%\%N1%
) else (
    echo  Not found - cloning %N1% ...
    git clone "%N1URL%" "%NODES%\%N1%"
    if errorlevel 1 (
        echo  ERROR: git clone of %N1% failed. Create it manually:
        echo    git clone %N1URL% "%NODES%\%N1%"
    ) else (
        echo  Cloned %N1%.
        if exist "%NODES%\%N1%\requirements.txt" (
            echo  Installing %N1% requirements ...
            "%PY%" -m pip install -r "%NODES%\%N1%\requirements.txt"
            if errorlevel 1 ( echo  WARNING: %N1% requirements install had errors - continuing. )
        )
    )
)

if not exist "%WT%" (
    echo ERROR: "%WT%" not found next to this file.
    pause & exit /b 1
)

echo.
echo === Installing Trellis2 Python deps ===
"%PY%" -m pip install triton-windows onnxruntime onnxruntime-directml opencv-python trimesh meshlib pymeshlab scipy open3d plotly rembg requests tqdm filelock easydict plyfile zstandard torchsde
if errorlevel 1 (
    echo ERROR: pip install of Trellis2 deps failed.
    pause & exit /b 1
)

echo.
echo === Force-installing Trellis2 wheels ===
call :install_wheel cumesh "%WT%\cumesh-1.0-cp312-cp312-win_amd64.whl"
call :install_wheel flex_gemm "%WT%\flex_gemm-1.0.0-cp312-cp312-win_amd64.whl"
call :install_wheel nvdiffrast "%WT%\nvdiffrast-0.4.0-cp312-cp312-win_amd64.whl"
call :install_wheel o_voxel "%WT%\o_voxel-0.0.1-cp312-cp312-win_amd64.whl"
call :install_wheel uv_raster "%WT%\uv_raster-0.1.0-cp312-cp312-win_amd64.whl"

echo.
echo === Verifying install ===
"%PY%" -c "import cumesh, flex_gemm, nvdiffrast, o_voxel; import uv_raster; print('Trellis2 wheels OK')"
if errorlevel 1 ( echo WARNING: Trellis2 wheels did not import correctly. ) else (
    echo.
    echo ============================================
    echo  Trellis2 (global) install complete!
    echo  Restart ComfyUI and you are good to go.
    echo ============================================
)

echo.
pause

rem ---- helper: always force-reinstall the wheel (no skip) ----
:install_wheel
set "MOD=%~1"
set "WHL=%~2"
echo  Force-installing %MOD% ...
"%PY%" -m pip install --force-reinstall --no-deps "%WHL%"
if errorlevel 1 ( echo  ERROR: failed to install %MOD% & exit /b 1 )
exit /b 0