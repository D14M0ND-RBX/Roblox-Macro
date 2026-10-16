@goto :start
r"""
:start
@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Build Diamond TD Macro
rem Put this file in the SAME folder as Diamond_TD_Macro.bat, then double-click it.
rem It installs everything it needs (Python, PyInstaller, pywebview, OpenCV, WebView2) by itself.
if not exist "%~dp0Diamond_TD_Macro.bat" (
    echo [ERROR] Diamond_TD_Macro.bat was not found next to this file.
    pause
    exit /b 1
)

set "PYEXE="
call :try_python py -3
call :try_python python
if not defined PYEXE call :find_installed
if defined PYEXE goto :have_python

echo [INFO] Python not found. Installing Python 3.12...
where winget >nul 2>&1
if not errorlevel 1 winget install --id Python.Python.3.12 --exact --source winget --silent --accept-source-agreements --accept-package-agreements
call :find_installed
if not defined PYEXE call :try_python py -3
if defined PYEXE goto :have_python

echo [INFO] Downloading the Python installer from python.org...
set "PY_SETUP=%TEMP%\tdrec_python_setup.exe"
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing 'https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe' -OutFile '%PY_SETUP%'"
if exist "%PY_SETUP%" (
    start /wait "" "%PY_SETUP%" /quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1 Include_tcltk=1 Include_test=0 Shortcuts=0
    del "%PY_SETUP%" >nul 2>&1
)
call :find_installed
if not defined PYEXE call :try_python py -3
if defined PYEXE goto :have_python
echo [ERROR] Python could not be installed automatically.
echo         Install Python 3.12 from https://www.python.org/downloads/windows/ (tick "Add to PATH") and run this again.
pause
exit /b 1

:have_python
echo [INFO] Using Python: %PYEXE%
rem WebView2 is needed for the sign-in window. Windows 10/11 normally has it; install it if not.
reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" >nul 2>&1
if errorlevel 1 reg query "HKCU\Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Installing Microsoft Edge WebView2 Runtime...
    winget install --id Microsoft.EdgeWebView2Runtime --exact --silent --accept-source-agreements --accept-package-agreements
)
%PYEXE% -x "%~f0"
echo.
pause
exit /b 0

:try_python
if defined PYEXE exit /b 0
%* -c "import sys, tkinter; sys.exit(0 if sys.version_info >= (3, 9) else 1)" >nul 2>&1
if not errorlevel 1 set "PYEXE=%*"
exit /b 0

:find_installed
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do call :try_python "%%D\python.exe"
for /d %%D in ("%ProgramFiles%\Python3*") do call :try_python "%%D\python.exe"
exit /b 0
"""
import os, re, sys, shutil, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "Diamond_TD_Macro.bat")
WORK = os.path.join(HERE, "_diamond_build")


def run(cmd, **kw):
    print(">", " ".join(cmd))
    r = subprocess.run(cmd, **kw)
    if r.returncode:
        sys.exit("\n[ERROR] A build step failed (see above).")


def extract_python(text):
    """Drop the batch launcher: keep everything from after the closing triple quote."""
    text = text.replace("\r\n", "\n")
    m = re.search(r'\n"""\n', text)
    if not m:
        sys.exit("[ERROR] Could not find where the Python code starts in Diamond_TD_Macro.bat.")
    return text[m.end():]


def main():
    with open(SRC, "r", encoding="utf-8") as f:
        raw = f.read()
    code = extract_python(raw)
    name = "Diamond_TD_Macro"  # exe name
    shutil.rmtree(WORK, ignore_errors=True)
    os.makedirs(WORK)
    py_file = os.path.join(WORK, "Diamond_TD_Macro.py")
    with open(py_file, "w", encoding="utf-8", newline="\n") as f:
        f.write(code)
    if "--extract-only" in sys.argv:
        print("Wrote", py_file)
        return

    print("[1/4] Installing everything the macro needs (PyInstaller, pywebview, OpenCV, mss, OCR)...")
    run([sys.executable, "-m", "pip", "install", "--disable-pip-version-check", "-q",
         "pyinstaller", "pywebview", "opencv-python-headless", "numpy", "mss"])
    # Windows OCR (reads coins/XP). Optional - the macro still works without it.
    subprocess.run([sys.executable, "-m", "pip", "install", "--disable-pip-version-check", "-q", "winsdk"])

    print("[2/4] Making the icon...")
    run([sys.executable, py_file, "--export-icon"], cwd=WORK)
    ico = os.path.join(WORK, "app.ico")
    if not os.path.exists(ico):
        sys.exit("[ERROR] Icon was not created.")

    print("[3/4] Building the exe (a minute or two)...")
    run([sys.executable, "-m", "PyInstaller", "--noconfirm", "--onefile", "--noconsole",
         "--icon", ico, "--name", name, "--collect-all", "webview",
         "--collect-all", "winsdk", "--hidden-import", "mss.windows",
         "--distpath", os.path.join(WORK, "dist"), "--workpath", os.path.join(WORK, "work"),
         "--specpath", WORK, py_file], cwd=WORK)

    print("[4/4] Finishing up...")
    exe = os.path.join(WORK, "dist", name + ".exe")
    if not os.path.exists(exe):
        sys.exit("[ERROR] " + name + ".exe was not produced.")
    shutil.copy2(exe, os.path.join(HERE, name + ".exe"))
    shutil.rmtree(WORK, ignore_errors=True)
    print("\nDone! " + name + ".exe is next to this file.")
    print("Open it, then right-click its taskbar icon > Pin to taskbar.")


if __name__ == "__main__":
    main()
