@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Install Trellis2 (ComfyUI_windows_portable / native ROCm)

rem ============================================================
rem  Trellis2 one-click installer - ComfyUI_windows_portable build
rem  Target: native-ROCm ComfyUI_windows_portable (python_embeded)
rem
rem  Place this .bat in the ComfyUI_windows_portable ROOT folder -
rem  the folder that contains python_embeded\python.exe and
rem  ComfyUI\custom_nodes\.
rem  Keep the wheels\ folder next to it.
rem
rem  - Missing node is auto-cloned (+ requirements.txt installed).
rem  - Wheels are always force-reinstalled (clean re-run).
rem  Native ROCm specifics:
rem   - Python = python_embeded\python.exe (ROCM-native torch)
rem   - triton-windows IS installed (kept for parity/compat)
rem   - uv_raster wheel provides the AMD-native rasterizer used by
rem     the patched render/extract paths.
rem  IMPORTANT: the wheels must be built for the portable's
rem  native-ROCm torch.
rem ============================================================

cd /d "%~dp0"

set "WT=.\Trellis 2 Wheels"

rem ---- git availability ----
where git >nul 2>nul
if errorlevel 1 (
    echo ERROR: git not found on PATH. Install Git for Windows, then re-run.
    pause & exit /b 1
)

rem ---- locate python: portable python_embeded first, then system ----
set "PY="
if exist ".\python_embeded\python.exe" ( set "PY=.\python_embeded\python.exe" )
if not defined PY                       ( set "PY=python" )
echo.
echo Using python: %PY%
%PY% --version

rem ---- verify torch is a ROCm build >= 2.9 + ROCm 7.2, x.y check ----
echo.
echo === Verifying torch / ROCm version ===
set "ROCMCHK=%TEMP%\trellis_rocm_check_%RANDOM%.py"
echo import torch, re, sys>"%ROCMCHK%"
echo v = torch.__version__>>"%ROCMCHK%"
echo m = re.search(r'rocm([0-9]+\.[0-9]+\.[0-9]+)', v)>>"%ROCMCHK%"
echo ok = (m is not None) and tuple(int(x) for x in v.split('+')[0].split('.')[:2]) ^>= (2, 9) and tuple(int(x) for x in m.group(1).split('.')[:2]) ^>= (7, 2)>>"%ROCMCHK%"
echo if not ok:>>"%ROCMCHK%"
echo     print('ERROR: this installer requires torch >= 2.9 built on ROCm >= 7.2, found: ' + v)>>"%ROCMCHK%"
echo     sys.exit(1)>>"%ROCMCHK%"
echo sys.exit(0)>>"%ROCMCHK%"
"%PY%" "%ROCMCHK%"
set "ROCMERR=%errorlevel%"
if exist "%ROCMCHK%" del /f /q "%ROCMCHK%" >nul 2>nul
if %ROCMERR% neq 0 (
    echo.
    echo ERROR: torch/ROCm version check failed. Install/use a ROCm build of
    echo torch 2.9 or newer, e.g. torch 2.9+rocm7.2, before running this installer.
    pause & exit /b 1
)
echo  torch/ROCm version OK.

rem ---- locate custom_nodes (portable ComfyUI\custom_nodes) ----
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
    echo  Trellis2 portable install complete!
    echo  Restart ComfyUI - run ComfyUI\run_nvidia_gpu.bat or equivalent - and you are good to go.
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