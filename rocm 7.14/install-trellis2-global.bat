@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Install Trellis2 (Global Python / ROCm 7.14)

rem ============================================================
rem  Trellis2 one-click installer - GLOBAL python build
rem  Target: a system/global Python on PATH (native-ROCm torch)
rem  LOCKED to torch 2.12.0 + ROCm 7.14.0 (the build shipped in
rem  this folder). Other torch/ROCm versions will be refused.
rem
rem  Place this .bat next to the wheels\ folder.
rem  Edit the PY var below if python is not on your PATH.
rem
rem  - Missing node is auto-cloned (+ requirements.txt installed).
rem  - Wheels are always force-reinstalled (clean re-run).
rem  - triton-windows IS installed (kept for parity/compat).
rem  - uv_raster wheel provides the AMD-native rasterizer used by
rem    the patched render/extract paths.
rem  - After install, copy aotriton.images into torch\lib\ (see README).
rem  IMPORTANT: the wheels must be built for your global
rem  native-ROCm torch 2.12.0 + ROCm 7.14.0.
rem ============================================================

cd /d "%~dp0"

set "WT=.\Trellis 2 Wheels"

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

rem ---- verify torch is EXACTLY 2.12 + ROCm 7.14, x.y check ----
echo.
echo === Verifying torch / ROCm version ===
set "ROCMCHK=%TEMP%\trellis_rocm_check_%RANDOM%.py"
echo import torch, re, sys>"%ROCMCHK%"
echo v = torch.__version__>>"%ROCMCHK%"
echo m = re.search(r'rocm([0-9]+\.[0-9]+\.[0-9]+)', v)>>"%ROCMCHK%"
echo ok = (m is not None) and tuple(int(x) for x in v.split('+')[0].split('.')[:2]) == (2, 12) and tuple(int(x) for x in m.group(1).split('.')[:2]) == (7, 14)>>"%ROCMCHK%"
echo if not ok:>>"%ROCMCHK%"
echo     print('ERROR: locked to torch 2.12 + ROCm 7.14, found: ' + v)>>"%ROCMCHK%"
echo     sys.exit(1)>>"%ROCMCHK%"
echo sys.exit(0)>>"%ROCMCHK%"
"%PY%" "%ROCMCHK%"
set "ROCMERR=%errorlevel%"
if exist "%ROCMCHK%" del /f /q "%ROCMCHK%" >nul 2>nul
if %ROCMERR% neq 0 (
    echo.
    echo ERROR: torch/ROCm version mismatch. Use the torch 2.12 + ROCm 7.14
    echo build family, the one paired with this folder. Other versions are refused.
    pause & exit /b 1
)
echo  torch 2.12 + ROCm 7.14 confirmed.

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
"%PY%" -c "import cumesh, flex_gemm, nvdiffrast, o_voxel, uv_raster"
if errorlevel 1 ( echo WARNING: Trellis2 wheels did not import correctly. ) else (
    echo.
    echo ============================================
    echo  Trellis2 global, ROCm 7.14 install complete!
    echo  Don't forget: copy the aotriton.images folder into
    echo    <python>\Lib\site-packages\torch\lib\
    echo  Restart ComfyUI and you are good to go.
    echo ============================================
)

echo.
pause
goto :eof

rem ---- helper: always force-reinstall the wheel (no skip) ----
:install_wheel
set "MOD=%~1"
set "WHL=%~2"
echo  Force-installing %MOD% ...
"%PY%" -m pip install --force-reinstall --no-deps "%WHL%"
if errorlevel 1 ( echo  ERROR: failed to install %MOD% & exit /b 1 )
exit /b 0