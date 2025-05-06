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
    echo Python not found in PATH. Checking installation...
    
    :: Check if Python is installed but not in PATH
    set "pythonPath=C:\Users\%username%\AppData\Local\Programs\Python\Python312\python.exe"
    if exist "%pythonPath%" (
        echo Python found at %pythonPath%. Adding to PATH...
        setx PATH "%PATH%;C:\Users\%username%\AppData\Local\Programs\Python\Python312"
        set "python=%pythonPath%"
    ) else (
        echo Python not found. Downloading and installing...
        powershell -Command "Invoke-WebRequest -OutFile python-installer.exe %pythonInstaller%"
        echo Starting Python installation...
        start /wait python-installer.exe /passive InstallAllUsers=1 PrependPath=1 Include_pip=1
        del python-installer.exe

        :: Verify Python installed successfully
        python --version >nul 2>&1
        if %errorlevel% neq 0 (
            echo Python installation failed. Exiting.
            pause
            exit /b
        )
        
        echo Python installed successfully. Restarting script to apply changes.
        echo.
        echo Press any key to restart the script...
        pause
        call "%~f0"
        exit /b
    )
) else (
    echo Python already installed.
)

:: Check if Python is now recognized
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python still not recognized. Trying to run from installation directory...
    start "" "%pythonPath%" --version
    pause
    exit /b
)

:: Check for Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git not found. Downloading and installing...
    powershell -Command "Invoke-WebRequest -OutFile git-installer.exe %gitInstaller%"
    start /wait git-installer.exe /VERYSILENT /NORESTART
    del git-installer.exe

    :: Verify Git installed successfully
    git --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo Git installation failed. Exiting.
        pause
        exit /b
    )
) else (
    echo Git already installed.
)

:: Install 'licensing' via pip
echo.
echo Installing 'licensing' Python package...
pip show licensing >nul 2>&1
if %errorlevel% neq 0 (
    pip install licensing
) else (
    echo 'licensing' already installed.
)

:: Install additional dependencies via pip
echo Installing other required Python modules...
pip show requests >nul 2>&1
if %errorlevel% neq 0 (
    pip install requests
) else (
    echo 'requests' already installed.
)

:: Clone your program repo
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
