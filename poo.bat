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

:: Set repo install directory
set "installDir=C:\ProgramData\untitledprogram"
set "pythonInstaller=https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe"
set "gitInstaller=https://github.com/git-for-windows/git/releases/download/v2.45.1.windows.1/Git-2.45.1-64-bit.exe"

:: Check for Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python not found. Downloading and installing...
    powershell -Command "Invoke-WebRequest -OutFile python-installer.exe %pythonInstaller%"
    start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_pip=1
    del python-installer.exe
) else (
    echo Python already installed.
)

:: Check for Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git not found. Downloading and installing...
    powershell -Command "Invoke-WebRequest -OutFile git-installer.exe %gitInstaller%"
    start /wait git-installer.exe /VERYSILENT /NORESTART
    del git-installer.exe
) else (
    echo Git already installed.
)

:: Install Cryptolens dependencies via pip
echo Installing Cryptolens Python dependencies...
pip show cryptolens >nul 2>&1
if %errorlevel% neq 0 (
    pip install cryptolens
) else (
    echo 'cryptolens' already installed.
)

pip show requests >nul 2>&1
if %errorlevel% neq 0 (
    pip install requests
) else (
    echo 'requests' already installed.
)

:: Clone repository
if not exist "%installDir%" (
    echo Cloning 'untitledprogram' repository into ProgramData...
    git clone https://github.com/Mr0ks/untitledprogram "%installDir%"
) else (
    echo 'untitledprogram' repository already exists. Skipping clone.
)

:: Run program executable
echo.
echo Running program executable...
"%installDir%\TODO\TODO.exe"

echo.
echo Done.
pause
exit /b
