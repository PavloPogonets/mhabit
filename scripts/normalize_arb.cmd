@rem Copyright 2025 Fries_I23
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem     https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_ROOT=%%~fI"
set "PYTHON_SCRIPTS_DIR=%REPO_ROOT%\scripts\python-scripts"
set "L10N_DIR=%REPO_ROOT%\assets\l10n"
set "TEMPLATE_FILE=%L10N_DIR%\en.arb"
set "L10N_REFS_FILE=%REPO_ROOT%\configs\l10n_refs.json"

where poetry >nul 2>nul
if errorlevel 1 (
  echo Poetry is required but not found in PATH.
  exit /b 1
)

pushd "%PYTHON_SCRIPTS_DIR%" >nul
if errorlevel 1 (
  echo Failed to enter directory: %PYTHON_SCRIPTS_DIR%
  exit /b 1
)

set "POETRY_ENV_PATH="
for /f "usebackq delims=" %%I in (`poetry env info --path 2^>nul`) do set "POETRY_ENV_PATH=%%I"
if not defined POETRY_ENV_PATH (
  echo Failed to resolve Poetry environment path.
  popd >nul
  exit /b 1
)

set "POETRY_PYTHON=%POETRY_ENV_PATH%\Scripts\python.exe"
if not exist "%POETRY_PYTHON%" set "POETRY_PYTHON=%POETRY_ENV_PATH%\bin\python"
if not exist "%POETRY_PYTHON%" (
  echo Poetry environment python not found: %POETRY_ENV_PATH%
  popd >nul
  exit /b 1
)

echo Normalizing ARB files from %L10N_DIR%
for %%F in ("%L10N_DIR%\*.arb") do (
  if /I "%%~fF"=="%TEMPLATE_FILE%" (
    "%POETRY_PYTHON%" bin\normalize_arb.py ^
      -i "%%~fF" -t "%TEMPLATE_FILE%" -o "%%~fF" --refs "%L10N_REFS_FILE%" ^
      --indent 4
  ) else (
    "%POETRY_PYTHON%" bin\normalize_arb.py ^
      -i "%%~fF" -t "%TEMPLATE_FILE%" -o "%%~fF" --refs "%L10N_REFS_FILE%" ^
      --indent 4 --ignore-empty-meta
  )

  if errorlevel 1 (
    set "ERR=!errorlevel!"
    exit /b !ERR!
  )

  echo Done[0]: %%~fF
)

popd >nul

exit /b 0