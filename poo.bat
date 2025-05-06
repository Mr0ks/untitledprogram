@echo off
:: Set working directory to where this batch file is
cd /d "%~dp0"

:: Check if the shortcut already exists
set "startMenuShortcut=C:\ProgramData\Microsoft\Windows\Start Menu\Programs\TODOLauncher.lnk"
if exist "%startMenuShortcut%" (
    echo Shortcut already exists in Start Menu Programs at %startMenuShortcut%.
    goto continue_script
)

echo The shortcut does not exist.
echo Checking if the script is running with Administrator privileges...

NET SESSION >nul 2>&1
if %errorlevel% NEQ 0 (
    echo This script requires Administrator privileges to create the shortcut.
    echo Please run the script as Administrator.
    pause
    exit /b
)

echo Running as Administrator. Continuing the script...

echo Creating shortcut in Start Menu Programs...
powershell -command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%startMenuShortcut%');$s.TargetPath='%~f0';$s.WorkingDirectory='%~dp0';$s.Save()"
echo Shortcut created in Start Menu Programs at %startMenuShortcut%

:continue_script
setlocal

:: Check for Python installation
echo.
echo Checking for Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo Python is not installed.
    echo Downloading Python installer...

    :: Set installer filename
    set "pythonInstaller=python-installer.exe"

    :: Download Python 3.12.3 installer silently (replace URL with the latest if needed)
    powershell -Command "Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe -OutFile '%pythonInstaller%'"

    echo Installing Python silently...
    "%pythonInstaller%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

    echo Python installation complete. Removing installer...
    del /f /q "%pythonInstaller%"

    :: Refresh PATH and verify install
    refreshenv
    python --version >nul 2>&1
    if errorlevel 1 (
        echo Python installation failed or not detected in PATH.
        pause
        exit /b
    )
) else (
    echo Python is already installed.
)

:: List of required Python packages
set packages=cryptolens

echo.
echo Checking and installing required Python packages...
for %%i in (%packages%) do (
    echo Checking for %%i...
    python -c "import %%i" 2>NUL
    if errorlevel 1 (
        echo Installing %%i...
        pip install %%i
    ) else (
        echo %%i is already installed.
    )
)

echo.
echo Checking for Git installation...
git --version >nul 2>&1
if errorlevel 1 (
    echo Git is not installed. Please install Git first.
    pause
    exit /b
)

:: Set repo install directory
set "installDir=C:\ProgramData\untitledprogram"

if not exist "%installDir%" (
    echo Cloning 'untitledprogram' repository into ProgramData...
    git clone https://github.com/Mr0ks/untitledprogram "%installDir%"
) else (
    echo 'untitledprogram' repository already exists. Skipping clone.
)

echo.
echo Running program executable...
"%installDir%\TODO\TODO.exe"

echo.
echo Done.
pause
exit /b
