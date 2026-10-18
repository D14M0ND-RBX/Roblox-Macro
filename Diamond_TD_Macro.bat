@goto :start
r"""
:start
@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Diamond TD Macro - Setup
rem Double-click this file. First run installs everything it needs by itself.
set "PYEXE="
set "ERROR_LOG=%TEMP%\tdmacro_setup_errors.txt"
echo. > "%ERROR_LOG%"
rem Prefer 3.12 when several Pythons are installed (best wheel support for the libraries below).
call :try_python py -3.12
call :try_python py -3
call :try_python python
if not defined PYEXE call :find_installed
if defined PYEXE goto :have_python

echo [INFO] Python 3.9-3.12 not found ^(newer versions lack some libraries^). Installing Python 3.12...
echo [INFO] Installing Python 3.12... >> "%ERROR_LOG%" 2>&1
where winget >nul 2>&1
if not errorlevel 1 (
    winget install --id Python.Python.3.12 --exact --source winget --silent --accept-source-agreements --accept-package-agreements >> "%ERROR_LOG%" 2>&1
    if errorlevel 1 echo [ERROR] winget failed to install Python >> "%ERROR_LOG%"
)
call :find_installed
if not defined PYEXE call :try_python py -3
if defined PYEXE goto :have_python

echo [INFO] Downloading the Python installer from python.org...
echo [INFO] Downloading Python installer... >> "%ERROR_LOG%" 2>&1
set "PY_SETUP=%TEMP%\tdrec_python_setup.exe"
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing 'https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe' -OutFile '%PY_SETUP%'" >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to download Python installer >> "%ERROR_LOG%"
if exist "%PY_SETUP%" (
    start /wait "" "%PY_SETUP%" /quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1 Include_tcltk=1 Include_test=0 Shortcuts=0
    del "%PY_SETUP%" >nul 2>&1
)
call :find_installed
if not defined PYEXE call :try_python py -3
if defined PYEXE goto :have_python
echo [ERROR] Python could not be installed automatically. >> "%ERROR_LOG%"
echo         Install Python 3.12 from https://www.python.org/downloads/windows/ (tick "Add to PATH") and run this again. >> "%ERROR_LOG%"
pause
exit /b 1

:have_python
echo [INFO] Using Python: %PYEXE%
echo [INFO] Using Python: %PYEXE% >> "%ERROR_LOG%"
rem WebView2 is needed for the window. Windows 10/11 normally has it; install it if not.
reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" >nul 2>&1
if errorlevel 1 reg query "HKCU\Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Installing Microsoft Edge WebView2 Runtime...
    echo [INFO] Installing WebView2... >> "%ERROR_LOG%" 2>&1
    winget install --id Microsoft.EdgeWebView2Runtime --exact --silent --accept-source-agreements --accept-package-agreements >> "%ERROR_LOG%" 2>&1
    if errorlevel 1 echo [ERROR] winget failed to install WebView2 >> "%ERROR_LOG%"
)

rem Install Python dependencies
echo [INFO] Installing Python dependencies...
echo [INFO] Installing Python dependencies... >> "%ERROR_LOG%" 2>&1
%PYEXE% -m pip install --upgrade pip >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to upgrade pip >> "%ERROR_LOG%"
%PYEXE% -m pip install pywebview >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install pywebview >> "%ERROR_LOG%"
%PYEXE% -m pip install opencv-python-headless >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install opencv-python-headless >> "%ERROR_LOG%"
%PYEXE% -m pip install numpy >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install numpy >> "%ERROR_LOG%"
%PYEXE% -m pip install mss >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install mss >> "%ERROR_LOG%"
%PYEXE% -m pip install Pillow >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install Pillow >> "%ERROR_LOG%"
%PYEXE% -m pip install PyQt5 >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install PyQt5 >> "%ERROR_LOG%"
%PYEXE% -m pip install winsdk >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install winsdk >> "%ERROR_LOG%"
%PYEXE% -m pip install pyinstaller >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install pyinstaller >> "%ERROR_LOG%"
%PYEXE% -m pip install SpeechRecognition >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install SpeechRecognition >> "%ERROR_LOG%"
%PYEXE% -m pip install PyAudio >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install PyAudio >> "%ERROR_LOG%"
%PYEXE% -m pip install requests >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install requests >> "%ERROR_LOG%"
%PYEXE% -m pip install pytesseract >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install pytesseract >> "%ERROR_LOG%"
%PYEXE% -m pip install google-generativeai >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install google-generativeai >> "%ERROR_LOG%"
%PYEXE% -m pip install rembg >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install rembg >> "%ERROR_LOG%"
%PYEXE% -m pip install pygame >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install pygame >> "%ERROR_LOG%"
%PYEXE% -m pip install onnxruntime >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install onnxruntime >> "%ERROR_LOG%"
%PYEXE% -m pip install pynput >> "%ERROR_LOG%" 2>&1
if errorlevel 1 echo [ERROR] Failed to install pynput >> "%ERROR_LOG%"

%PYEXE% -x "%~f0" %*
if errorlevel 1 (
    echo.
    echo [ERROR] The macro stopped with an error. Details: %APPDATA%\TDRecorder\td_macro.log
    echo [ERROR] Macro stopped with error >> "%ERROR_LOG%"
)
echo.
rem Show error log if any errors occurred
for %%A in ("%ERROR_LOG%") do (
    findstr /C:"ERROR" "%%A" >nul 2>&1
    if not errorlevel 1 (
        echo.
        echo Errors occurred during setup. Details:
        type "%ERROR_LOG%"
    )
)
pause
exit /b 0

:try_python
if defined PYEXE exit /b 0
%* -c "import sys; sys.exit(0 if (3, 9) <= sys.version_info[:2] <= (3, 12) else 1)" >nul 2>&1
if errorlevel 1 exit /b 0
rem The new "py" manager prints an error but still exits 0, so also require real output from Python.
%* -c "print('PYOK')" 2>nul | find "PYOK" >nul
if not errorlevel 1 set "PYEXE=%*"
exit /b 0

:find_installed
for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do call :try_python "%%D\python.exe"
for /d %%D in ("%ProgramFiles%\Python3*") do call :try_python "%%D\python.exe"
exit /b 0
"""
#   TD RECORDER  -  record a Roblox tower-defense run once, replay it forever
#   (this file is both a .bat launcher and the program - see top of file)
import os, sys, re, json, time, base64, threading, ctypes, subprocess, struct, zlib, traceback, datetime, math, zipfile
import atexit, functools, logging, platform
from logging.handlers import RotatingFileHandler
from ctypes import wintypes



# ======================================================================
#  MAHORAGA - Qt per-pixel-alpha overlay. No purple. No Tk.
# ======================================================================
def _maho_asset(names):
    """Find an optional asset (GIF / sound) next to the exe or script, or inside the exe bundle. No personal paths."""
    bases = []
    if getattr(sys, "frozen", False):
        bases.append(os.path.dirname(sys.executable))
        bases.append(getattr(sys, "_MEIPASS", ""))
    else:
        try:
            bases.append(os.path.dirname(os.path.abspath(sys.argv[0])))
        except Exception:
            pass
        bases.append(os.getcwd())
    for b in bases:
        for n in names:
            if b and os.path.exists(os.path.join(b, n)):
                return os.path.join(b, n)
    return names[0]

MAHO_GIF_PATH     = _maho_asset(["maho.gif"])
MAHO_WAV_PATH     = _maho_asset(["maho_wheel.mp3", "maho_wheel.wav"])   # .mp3 or .wav
MAHO_VISIBLE_S    = 2.0
MAHO_SFX_LEAD_S   = 0.3
MAHO_FADE_IN_S    = 0.08
MAHO_FADE_OUT_S   = 0.60
MAHO_MAX_PX       = 400
MAHO_OFFSET_X     = 0
MAHO_OFFSET_Y     = 0
MAHO_MAX_PER_RUN  = 2
MAHO_ENABLED      = True
_MAHO_SND_FLAGS   = 0x20011
_MAHO_WINMM       = None
_MAHO_PLAYSOUND   = None

_MAHO_UI_LOG = None                                  # set by the UI so Mahoraga messages show in the macro's log panel too

def _maho_log(msg, kind="info"):
    try:
        file_log("Mahoraga: " + msg, kind)          # ends up in %APPDATA%\\TDRecorder\\td_macro.log
    except Exception:
        pass
    try:
        if _MAHO_UI_LOG:
            _MAHO_UI_LOG("Mahoraga: " + msg, "warn" if kind == "err" else kind)
    except Exception:
        pass

def _maho_ensure(imp, pkg):
    try:
        __import__(imp); return True
    except Exception:
        if getattr(sys, "frozen", False):
            return False
        try:
            _maho_log("%s is missing - installing %s (this can take a minute the first time)" % (imp, pkg))
            subprocess.run([sys.executable, "-m", "pip", "install", "-q",
                            "--only-binary=:all:", pkg], check=False)
            __import__(imp); return True
        except Exception:
            return False

def _maho_sfx_async():
    def w():
        global _MAHO_WINMM, _MAHO_PLAYSOUND
        try:
            if not MAHO_ENABLED: return
            p = str(MAHO_WAV_PATH)
            if not os.path.exists(p): return
            if _MAHO_WINMM is None:
                import ctypes as _mc
                _MAHO_WINMM = _mc.WinDLL("winmm")
                _MAHO_PLAYSOUND = _MAHO_WINMM.PlaySoundW
            if p.lower().endswith(".wav"):
                _MAHO_PLAYSOUND(p, None, _MAHO_SND_FLAGS)
            else:                                   # mp3 etc. -> Windows MCI (plays async, restarts if already playing)
                mci = _MAHO_WINMM.mciSendStringW
                mci('close maho_sfx', None, 0, None)
                mci('open "%s" type mpegvideo alias maho_sfx' % p, None, 0, None)
                mci('play maho_sfx', None, 0, None)
        except Exception:
            pass
    threading.Thread(target=w, daemon=True, name="td-maho-sfx").start()

_MAHO_DECODED = None
_MAHO_DURS = None
_MAHO_WH = None
def _maho_decode_once():
    global _MAHO_DECODED, _MAHO_DURS, _MAHO_WH
    if _MAHO_DECODED is not None: return True
    for _imp, _pkg in (("PIL", "Pillow"), ("numpy", "numpy"), ("cv2", "opencv-python-headless")):
        if not _maho_ensure(_imp, _pkg):
            _maho_log("cannot import %s (not installed / not bundled in the exe)" % _imp, "err")
            return False
    try:
        from PIL import Image as _MI
        import numpy as _mn
        import cv2 as _mc
    except Exception as _e:
        _maho_log("import failed: %s: %s" % (type(_e).__name__, _e), "err")
        return False
    try:
        frames, durs = [], []
        with _MI.open(MAHO_GIF_PATH) as im:
            try:
                while True:
                    durs.append(max(30, im.info.get("duration", 100)))
                    arr = _mn.array(im.convert("RGBA"))
                    h, w = arr.shape[:2]
                    if float((arr[:, :, 3] < 40).mean()) < 0.02:
                        lum = _mc.cvtColor(arr[:, :, :3].astype(_mn.uint8), _mc.COLOR_RGB2GRAY).astype(_mn.int32)
                        a = _mn.where(lum < 10, 0, _mn.clip((lum - 10) * 3.5, 0, 255)).astype(_mn.uint8)
                        arr[:, :, 3] = _mc.GaussianBlur(a, (3, 3), 0.45)
                    sc = min(MAHO_MAX_PX / max(h, w), 2.0)
                    nw, nh = max(48, int(w * sc)), max(48, int(h * sc))
                    nw += nw & 1
                    nh += nh & 1
                    rsz = _mc.resize(arr, (nw, nh), interpolation=(_mc.INTER_LANCZOS4 if sc > 1.0 else _mc.INTER_AREA))
                    rsz[:, :, 3] = _mn.where(rsz[:, :, 3] > 12, _mn.clip(rsz[:, :, 3] * 1.12, 0, 255).astype(_mn.uint8), 0)
                    frames.append(_mn.ascontiguousarray(rsz.astype(_mn.uint8)))
                    im.seek(im.tell() + 1)
            except EOFError:
                pass
        if not frames:
            _maho_log("GIF has no frames: %s" % MAHO_GIF_PATH, "err")
            return False
        _MAHO_DECODED = frames
        _MAHO_DURS = durs
        _MAHO_WH = (frames[0].shape[1], frames[0].shape[0])
        _maho_log("GIF decoded: %d frames, %dx%d" % (len(frames), _MAHO_WH[0], _MAHO_WH[1]))
        return True
    except Exception as _e:
        _maho_log("GIF decode failed (%s): %s: %s" % (MAHO_GIF_PATH, type(_e).__name__, _e), "err")
        return False

_MAHO_QAPP = None
class MahoragaOverlay:
    _LOCK = threading.Lock()
    def __init__(self):
        import queue as _queue
        self._q = _queue.Queue()
        self._thread = None                  # the ONE long-lived Qt thread (Qt must always be used from the thread that made the QApplication)
        self._showing = False
        self._extend_to = None
        self._shown_count = 0
        self._runs_used = 0
        self._run_tag = None
        self._cfg_enabled = True
        # Strategy overlay data
        self._tower_spots = []  # List of (x, y, tower_name) tuples
        self._enemy_paths = []  # List of path points
        self._next_move = None  # (x, y, description)
    def reset_run(self, new_tag=None):
        with MahoragaOverlay._LOCK:
            self._runs_used = 0
            if new_tag is None:
                new_tag = "run_%d_%x" % (int(time.time() * 1000), id(self) & 0xFFFF)
            self._run_tag = new_tag
    def used_this_run(self):
        with MahoragaOverlay._LOCK:
            return self._runs_used
    def set_cfg_enabled(self, cfg_or_bool):
        try:
            if isinstance(cfg_or_bool, dict):
                val = bool(cfg_or_bool.get("maho", True))
            else:
                val = bool(cfg_or_bool)
        except Exception:
            val = True
        with MahoragaOverlay._LOCK:
            self._cfg_enabled = val
    
    def add_tower_spot(self, x, y, tower_name="Tower"):
        """Add a tower placement spot to the overlay."""
        with MahoragaOverlay._LOCK:
            self._tower_spots.append((x, y, tower_name))
    
    def clear_tower_spots(self):
        """Clear all tower spots."""
        with MahoragaOverlay._LOCK:
            self._tower_spots = []
    
    def set_enemy_path(self, path_points):
        """Set the enemy path (list of (x, y) tuples)."""
        with MahoragaOverlay._LOCK:
            self._enemy_paths = path_points
    
    def set_next_move(self, x, y, description):
        """Set the next intended move."""
        with MahoragaOverlay._LOCK:
            self._next_move = (x, y, description)
    
    def show_strategy(self, cfg):
        """Show the strategy overlay (tower spots, paths, next move)."""
        if not bool(cfg.get("strategy_overlay", False)):
            return
        if not bool(cfg.get("overlay_tower_spots", False)) and not bool(cfg.get("overlay_paths", False)) and not bool(cfg.get("overlay_next_move", False)):
            return
        
        with MahoragaOverlay._LOCK:
            if not self._tower_spots and not self._enemy_paths and not self._next_move:
                return  # Nothing to show
        
        self._ensure_gui()
        self._q.put(("strategy", cfg))
    
    def _draw_strategy(self, cfg):
        """Draw the strategy overlay using Qt."""
        app = self._qapp()
        if app is None: return
        try:
            from PyQt5.QtCore import Qt, QTimer, QPointF
            from PyQt5.QtGui import QPixmap, QImage, QGuiApplication, QPainter, QPen, QColor, QBrush, QFont
            from PyQt5.QtWidgets import QWidget, QLabel
        except Exception as _e:
            _maho_log("Qt modules failed to import for strategy: %s: %s" % (type(_e).__name__, _e), "err")
            return
        
        with MahoragaOverlay._LOCK:
            tower_spots = list(self._tower_spots)
            enemy_paths = list(self._enemy_paths)
            next_move = self._next_move
        
        alive = {"r": True}
        lock = threading.Lock()
        
        def build_and_run():
            try:
                wdg = QWidget(None, Qt.FramelessWindowHint | Qt.Tool |
                              Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput)
                wdg.setAttribute(Qt.WA_TranslucentBackground, True)
                wdg.setAttribute(Qt.WA_ShowWithoutActivating, True)
                wdg.setAttribute(Qt.WA_DeleteOnClose, True)
                wdg.setFocusPolicy(Qt.NoFocus)
                
                g = QGuiApplication.primaryScreen().availableGeometry()
                wdg.setGeometry(g)
                wdg.setWindowOpacity(0.8)
                wdg.show()
                
                with lock: alive["wdg"] = wdg
                
                class _H: pass
                h = _H()
                h.timer = QTimer(wdg)
                
                def paint():
                    try:
                        with lock:
                            w = alive.get("wdg", None)
                        if w is None:
                            return
                        
                        qp = QPainter(w)
                        qp.setRenderHint(QPainter.Antialiasing)
                        
                        # Draw tower spots
                        if bool(cfg.get("overlay_tower_spots", False)):
                            pen = QPen(QColor(0, 255, 100), 3)
                            qp.setPen(pen)
                            brush = QBrush(QColor(0, 255, 100, 50))
                            qp.setBrush(brush)
                            for x, y, name in tower_spots:
                                # Convert percentage to screen coordinates
                                sx = g.x() + int(x * g.width() / 100)
                                sy = g.y() + int(y * g.height() / 100)
                                qp.drawEllipse(QPointF(sx, sy), 20, 20)
                        
                        # Draw enemy paths
                        if bool(cfg.get("overlay_paths", False)) and len(enemy_paths) > 1:
                            pen = QPen(QColor(255, 100, 0), 2)
                            qp.setPen(pen)
                            for i in range(len(enemy_paths) - 1):
                                x1, y1 = enemy_paths[i]
                                x2, y2 = enemy_paths[i + 1]
                                sx1 = g.x() + int(x1 * g.width() / 100)
                                sy1 = g.y() + int(y1 * g.height() / 100)
                                sx2 = g.x() + int(x2 * g.width() / 100)
                                sy2 = g.y() + int(y2 * g.height() / 100)
                                qp.drawLine(QPointF(sx1, sy1), QPointF(sx2, sy2))
                        
                        # Draw next move
                        if bool(cfg.get("overlay_next_move", False)) and next_move:
                            x, y, desc = next_move
                            sx = g.x() + int(x * g.width() / 100)
                            sy = g.y() + int(y * g.height() / 100)
                            pen = QPen(QColor(255, 255, 0), 4)
                            qp.setPen(pen)
                            qp.drawEllipse(QPointF(sx, sy), 30, 30)
                            qp.setPen(QColor(255, 255, 255))
                            qp.setFont(QFont("Arial", 12, QFont.Bold))
                            qp.drawText(int(sx) + 35, int(sy), desc)
                        
                        qp.end()
                    except Exception as e:
                        _maho_log("Strategy paint error: %s" % e, "err")
                
                def tick():
                    # Keep overlay alive for 1 second, then refresh
                    with lock:
                        try: alive["wdg"].update()
                        except Exception: pass
                    paint()
                
                wdg.paintEvent = paint
                h.timer.timeout.connect(tick)
                h.timer.start(50)  # 20 FPS
                
                # Auto-close after 5 seconds (will be refreshed if needed)
                QTimer.singleShot(5000, lambda: (alive.update({"r": False}), h.timer.stop(), wdg.close()))
                
                _maho_log("Strategy overlay shown")
            except Exception as e:
                _maho_log("Strategy overlay failed: %s" % e, "err")
        
        build_and_run()
    def trigger(self, dx=0, dy=0):
        if not MAHO_ENABLED: return
        with MahoragaOverlay._LOCK:
            if not self._cfg_enabled:
                _maho_log("trigger ignored - the Mahoraga switch is off in settings")
                return
            if self._run_tag is None:
                self.reset_run()
            if self._runs_used >= MAHO_MAX_PER_RUN:
                _maho_log("trigger ignored - already shown %d times this run" % self._runs_used)
                return
            self._runs_used = self._runs_used + 1
            if self._showing:
                self._extend_to = time.perf_counter() + MAHO_VISIBLE_S      # already on screen: keep it up a bit longer
                return
            self._showing = True
            self._extend_to = None
            _maho_is_showing = True  # Set global flag
        self._ensure_gui()
        self._q.put((dx, dy))
    def _ensure_gui(self):
        with MahoragaOverlay._LOCK:
            if self._thread is not None and self._thread.is_alive():
                return
            self._thread = threading.Thread(target=self._gui_main, name="td-mahoraga", daemon=True)
            self._thread.start()
    def _gui_main(self):
        while True:
            msg = self._q.get()
            try:
                if isinstance(msg, tuple) and len(msg) == 2 and msg[0] == "strategy":
                    self._draw_strategy(msg[1])
                else:
                    dx, dy = msg
                    self._run(dx, dy, self._run_tag)
            except Exception:
                _maho_log("overlay crashed: " + traceback.format_exc(), "err")
            finally:
                with MahoragaOverlay._LOCK:
                    self._showing = False
                    self._extend_to = None
                    _maho_is_showing = False  # Reset global flag
    def _qapp(self):
        global _MAHO_QAPP
        if not _maho_ensure("PyQt5", "PyQt5"):
            try:
                import PyQt5
            except Exception as _e:
                _maho_log("PyQt5 import failed: %s: %s" % (type(_e).__name__, _e), "err")
            return None
        if _MAHO_QAPP is None:
            try:
                from PyQt5.QtWidgets import QApplication
                _MAHO_QAPP = QApplication.instance() or QApplication(sys.argv)
            except Exception as _e:
                _maho_log("could not start Qt: %s: %s" % (type(_e).__name__, _e), "err")
                return None
        return _MAHO_QAPP
    def _run(self, dx, dy, run_tag):
        _maho_log("start - gif %s (%s), sound %s (%s)" % (MAHO_GIF_PATH, "found" if os.path.exists(MAHO_GIF_PATH) else "MISSING",
                                                          MAHO_WAV_PATH, "found" if os.path.exists(MAHO_WAV_PATH) else "MISSING"))
        if not _maho_decode_once(): return
        app = self._qapp()
        if app is None: return
        try:
            from PyQt5.QtCore import Qt, QTimer
            from PyQt5.QtGui import QPixmap, QImage, QGuiApplication
            from PyQt5.QtWidgets import QWidget, QLabel
        except Exception as _e:
            _maho_log("Qt modules failed to import: %s: %s" % (type(_e).__name__, _e), "err")
            return
        try:
            frames_qpm = []
            for rgba in _MAHO_DECODED:
                h, w = rgba.shape[:2]
                qi = QImage(rgba.tobytes(), w, h, w * 4, QImage.Format_RGBA8888).copy()
                frames_qpm.append(QPixmap.fromImage(qi))
        except Exception as _e:
            _maho_log("could not build the frames: %s: %s" % (type(_e).__name__, _e), "err")
            return
        W, H = _MAHO_WH
        started = time.perf_counter()
        end_t = started + MAHO_VISIBLE_S
        self._extend_to = None
        # sound is fired once, from tick(), MAHO_SFX_LEAD_S before the wheel finishes
        alive = {"r": True}
        lock = threading.Lock()
        def build_and_run():
            try:
                wdg = QWidget(None, Qt.FramelessWindowHint | Qt.Tool |
                              Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput)
                wdg.setAttribute(Qt.WA_TranslucentBackground, True)
                wdg.setAttribute(Qt.WA_ShowWithoutActivating, True)
                wdg.setAttribute(Qt.WA_DeleteOnClose, True)
                wdg.setFocusPolicy(Qt.NoFocus)
                lab = QLabel(wdg)
                lab.setAttribute(Qt.WA_TranslucentBackground, True)
                wdg.resize(W, H); lab.resize(W, H)
                g = QGuiApplication.primaryScreen().availableGeometry()
                wdg.move(g.x() + (g.width() - W) // 2 + MAHO_OFFSET_X + dx,
                         g.y() + (g.height() - H) // 2 + MAHO_OFFSET_Y + dy)
                lab.setPixmap(frames_qpm[0]); wdg.setWindowOpacity(0.0); wdg.show()
                with lock: alive["wdg"] = wdg
                idx = 0
                next_f = started + (_MAHO_DURS[0] / 1000.0)
                sfx_done = False
                opa_prev = -1.0
                class _H: pass
                h = _H()
                h.timer = QTimer(wdg)
                def tick():
                    nonlocal idx, next_f, sfx_done, opa_prev
                    now = time.perf_counter()
                    ext = self._extend_to
                    local_end = end_t
                    if ext and ext > local_end: local_end = ext
                    if now >= (local_end + 0.12):
                        with lock:
                            try:
                                _w = alive.get("wdg", None)
                                if _w is not None: _w.close()
                            except Exception:
                                pass
                        alive["r"] = False
                        try: h.timer.stop()
                        except Exception: pass
                        return
                    t_s = now - started
                    d_in = float(MAHO_FADE_IN_S)
                    d_out = float(MAHO_FADE_OUT_S)
                    v_s = float(MAHO_VISIBLE_S)
                    if t_s < d_in:
                        ga = t_s / max(0.0001, d_in)
                    elif (v_s - t_s) < d_out:
                        frac = (v_s - t_s) / max(0.0001, d_out)
                        try: ga = float(max(0.0, min(1.0, frac))) ** 1.55
                        except Exception: ga = 0.0
                    else:
                        ga = 1.0
                    ga = max(0.0, min(1.0, float(getattr(ga, "real", ga))))
                    if abs(ga - opa_prev) > 0.01:
                        with lock:
                            try: alive["wdg"].setWindowOpacity(ga)
                            except Exception: pass
                        opa_prev = ga
                    if not sfx_done and now >= (local_end - MAHO_SFX_LEAD_S):
                        sfx_done = True
                        _maho_sfx_async()
                    while now >= next_f and len(frames_qpm) > 1:
                        idx = (idx + 1) % len(frames_qpm)
                        with lock:
                            try: lab.setPixmap(frames_qpm[idx])
                            except Exception: pass
                        next_f += max(0.025, _MAHO_DURS[idx % len(_MAHO_DURS)] / 1000.0)
                h.timer.timeout.connect(tick)
                h.timer.start(8)
                self._shown_count += 1
                _maho_log("wheel shown")
            except Exception:
                _maho_log("window failed: " + traceback.format_exc(), "err")
                alive["r"] = False
        try:
            from PyQt5.QtCore import QTimer as _QTimer
            _QTimer.singleShot(0, build_and_run)
        except Exception:
            return
        t0 = time.perf_counter()
        while time.perf_counter() - t0 < (MAHO_VISIBLE_S + 1.5):
            if not alive["r"]: break
            try: app.processEvents()
            except Exception: pass
            time.sleep(0.01)
        try:
            for _ in range(6):
                app.processEvents(); time.sleep(0.02)
        except Exception:
            pass

MAHO_OVERLAY = MahoragaOverlay()
_maho_is_showing = False  # Global flag to track if Mahoraga is currently showing
# ======================================================================
#  END MAHORAGA
# ======================================================================


#   Triggers ONLY when a tower pixel-adaptation (nudge after retry) succeeds.
#   Timing: wheel appears -> spins 1.7s -> wheel SFX fires (click/peak 0.3s before dissolve done) = cold lock-in effect.
#   Fade  : 50ms snap-in, HOLD, then 600ms quadratic EASE-OUT DISSOLVE (no abrupt vanish).
# Fade tuning (fractions of MAHO_DURATION):
# Audio timing: play SFX this many seconds BEFORE the wheel is TOTALLY gone
#   default 0.3 = play at t = MAHO_DURATION - 0.3s = 1.7s mark -> click lands in final 0.3s fade window



APP_TITLE = "Diamond TD Macro"
VERSION = "1.54"
APP_CREDIT = "Diamond"          # shown in the footer ("Made by ...") - change to whatever you want
# GitHub auto-push enabled
FROZEN = bool(getattr(sys, "frozen", False))
DATA_DIR = os.path.join(os.environ.get("APPDATA", os.path.expanduser("~")), "TDRecorder")
REC_DIR = os.path.join(DATA_DIR, "recordings")
CFG_PATH = os.path.join(DATA_DIR, "config.json")
LOG_PATH = os.path.join(DATA_DIR, "td_macro.log")
REF_HEIGHT = 1440.0          # the templates were captured on a 1440p screen
SCAN_INTERVAL = 0.05         # how often the screen watchers look for images (s)
# ---- Map selection + veto: a straight port of Ultimate Macro's flow (Main.ahk, override-map menu) ----
PX_VETO = (0x76, 0x30, 0x10)    # RGB of the red "Map is already in the current rotation!" message = veto (actual: 118, 48, 16)
PX_LIME = (40, 220, 60)        # RGB of lime green for RESTART, READY, PLAY AGAIN buttons (actual Roblox button color)
PX_SEARCH = (255, 255, 255)    # RGB of white for search bar (can be customized)
PX_MAP = (40, 220, 60)         # RGB of lime green for map/ready button (can be customized)
PX_READY = (40, 220, 60)       # RGB of lime green for ready button (can be customized)
PX_VETO_BTN = (200, 50, 50)    # RGB of red for veto button (can be customized)
# Auto-learned colors (saved per profile)
_LEARNED_COLORS = {}
MAP_PX_WAIT = 3.0               # s to watch the red veto pixel after each map click
MAP_PX_POLL = 0.02              # s between pixel reads (a 1x1 grab takes ~1 ms)
MAP_PX_HITS = 2                 # a colour must match this many reads in a row
MAP_SEARCH_LIST = 0.5            # s before each map click (Ultimate: SearchList delay, default 500 ms)
MAP_MENU_CLICK = 0.5             # s after the map click before looking (Ultimate: MenuClick delay, default 500 ms)
MAP_TRIES = 5                    # map clicks before giving up (Ultimate: 5)
MAP_HOLD_E = 0.76                # s E is held after the Veto click to reopen the menu (Ultimate: 760 ms)
VETO_FALLBACK_FRAC = (0.666, 0.756)   # Veto button centre in a 1376x860 window (measured from a real screenshot) - used when no image matches
PA_COOLDOWN = 3.0            # after clicking Play Again, ignore it for this long (s)
COARSE_GATE = 0.55          # half-size fast-pass score threshold (from Calamity) - anything below this is skipped early
TPL_SCALES = (1.0, 0.95, 1.05, 0.90, 1.10, 0.85, 1.15)   # UI scale variants tried per template (resolution robustness)
# The game's buttons do not shrink in proportion in a small (docked) window, so these two also try much bigger / smaller sizes
_PA_SWEEP = (0.40, 0.44, 0.47, 1.6, 1.7, 1.8, 1.9)   # the wide 0.50-1.58 sweep (DEEP_SCALES) now covers every image; these are just the extremes beyond it
TPL_EXTRA_SCALES = {"play_again": _PA_SWEEP, "restart": _PA_SWEEP}
WATCHDOG_MULT = 2.5         # if a phase runs WATCHDOG_MULT * step_timeout the macro auto-recovers
DC_INTERVAL = 1.00          # disconnect-watcher scan interval (s) - image 1 (Leave popup) every 1s 24/7
PA_READY_TIMEOUT = 300         # 5 minutes after Play Again click: if Ready still not seen, ALT+F4 kill + rejoin
ROBLOX_GAME_ID = 3260590327   # Tower Defense Simulator
GAMEMODES = ("easy", "casual", "intermediate", "molten", "fallen", "frost")

# ----------------------------------------------------------------------
#  Intro key sequence:  (key, start time in s, hold time in s)
# ----------------------------------------------------------------------
KEYS_A = [("s", 0.31, 1.97), ("a", 2.75, 2.55)]
KEYS_B = [("d", 8.99, 1.37), ("s", 11.03, 1.70), ("d", 13.39, 4.14),
          ("a", 18.19, 0.45), ("e", 21.44, 0.49)]

DEFAULTS = {
    "loops_mode": "inf", "loops": 0,
    "full_screen": True, "zone": {"x1": 0, "y1": 0, "x2": 3439, "y2": 1439},
    "map": "Dead Ahead", "resolution": "auto",
    "threshold": 0.65, "cfg_ver": 6, "ui_scale": "auto",
    "cam_drag": 600, "zoom_after_align": True, "zoom_clicks": 50,
    "record_mouse": True, "focus_only": True, "mouse_glide": 0.2,
    "place_jiggle": True, "slot_wait": 0.1, "jiggle_px": 5, "place_settle": 0.2, "jiggle_step": 0.05, "cancel_before_slot": True, "maho": True, "loop_rec": False, "loop_grace": 20, "intro_mode": "new", "loop_replace": False, "wiggle_all": True, "game_coins": 0, "game_xp": 0,
    "adaption": True, "verify_place": True, "place_retries": 4, "retry_wait": 1.0, "move_hold_extra": 0.15,
    "reward_delay": 0.5, "step_timeout": 30, "restart_wait": 7,
    "restart_mode": "reset", "restart_key_gap": 0.1, "restart_reset_wait": 5.0,
    "skip_intro": False,  # Skip intro sequence (map selection, etc.) - useful for custom profiles or when already in game
    "disable_watcher": False,  # Disable Play Again/Restart watcher - useful for custom profiles that don't have these buttons
    "pixel_only": False,  # Use only pixel search (no image matching fallback) - faster but requires all pixels to be set
    "auto_learn_colors": True,  # Automatically learn colors when picking pixels - can be disabled to use manual color values
    "pixel_debug": False,  # Show detailed pixel debug info in logs - useful for troubleshooting pixel detection
    "custom_scan_interval": 0.05,  # Custom scan interval for watchers (default 0.05s) - lower = faster but more CPU usage
    "lag_compensation": False,  # Automatically adjust all timings based on measured ping to Roblox servers
    "lag_multiplier": 1.0,  # Current lag multiplier (auto-adjusted if lag_compensation is on)
    "strategy_overlay": False,  # Show visual strategy overlay (tower spots, paths, next moves) - NOT IMPLEMENTED
    "overlay_tower_spots": False,  # Show tower placement spots on overlay - NOT IMPLEMENTED
    "overlay_paths": False,  # Show enemy paths on overlay - NOT IMPLEMENTED
    "overlay_next_move": False,  # Show next intended move on overlay - NOT IMPLEMENTED
    "voice_control": False,  # Enable voice commands
    "voice_start": "start macro",  # Voice command to start macro
    "voice_stop": "stop macro",  # Voice command to stop macro
    "voice_skip": "skip run",  # Voice command to skip current run
    "humanizer": True,  # Enable anti-detection humanizer (random delays, micro-movements)
    "humanizer_delay_range": 0.1,  # Random delay variation (+/- seconds)
    "humanizer_mouse_jitter": 2,  # Random mouse jitter in pixels (0 = off)
    "humanizer_click_variation": 0.05,  # Random click timing variation (+/- seconds)
    "heatmap_enabled": True,  # Enable replay heatmap generation
    "heatmap_show_clicks": True,  # Show click positions on heatmap
    "heatmap_show_towers": True,  # Show tower placements on heatmap
    "profit_calculator": True,  # Enable profit calculator
    "electricity_cost_kwh": 0.12,  # Electricity cost per kWh (USD)
    "pc_power_watts": 150,  # Estimated PC power usage in watts
    "coin_value_usd": 0.0001,  # Value of 1 game coin in USD (for ROI calculation)
    "screencast_recorder": False,  # Enable auto-screencast recorder for highlights - NOT IMPLEMENTED
    "screencast_on_win": False,  # Record when a run is successful - NOT IMPLEMENTED
    "screencast_on_high_score": False,  # Record when high coins/XP is earned - NOT IMPLEMENTED
    "screencast_threshold_coins": 1000,  # Coins threshold for high score recording - NOT IMPLEMENTED
    "screencast_duration": 5,  # Duration of screencast clips in seconds - NOT IMPLEMENTED
    # Milestone screenshots
    "milestone_screenshots": True,  # Auto-screenshot on high coins/XP milestones
    "milestone_coins": 1000,  # Coins increment for milestone screenshot
    "milestone_xp": 500,  # XP increment for milestone screenshot
    "milestone_screenshots_dir": "",  # Directory to save milestone screenshots
    # Tower-specific timing
    "tower_specific_timing": False,  # Enable different delays per tower type
    "tower_timing": {},  # Tower-specific timing overrides (tower_name: delay_multiplier)
    # Recording analytics
    "recording_analytics": True,  # Track failure rates per recording section
    "analytics_data": {},  # Store analytics data
    # Better error recovery
    "error_recovery_attempts": 3,  # Number of fallback attempts before giving up
    # Template comparison
    "template_comparison": True,  # Enable template diff feature
    # Built-in backup system
    "auto_backup": True,  # Enable daily automatic backups
    "backup_interval": 24,  # Backup interval in hours (default 24 hours)
    "backup_max_age": 7,  # Keep backups for 7 days
    "last_backup": 0,  # Timestamp of last backup
    "account_health_monitor": False,  # Enable account health monitor (anti-ban detection) - NOT IMPLEMENTED
    "health_cooldown_minutes": 30,  # Auto-cooldown after this many minutes of continuous play - NOT IMPLEMENTED
    "health_warning_threshold": 80,  # Warn when human-like score drops below this percentage - NOT IMPLEMENTED
    "strategy_switcher": False,  # Enable real-time strategy switching on failure - NOT IMPLEMENTED
    "strategy_fail_threshold": 3,  # Switch strategy after this many consecutive failures - NOT IMPLEMENTED
    "backup_profile": "",  # Backup profile to switch to when strategy fails - NOT IMPLEMENTED
    "cloud_profiles": False,  # Enable cloud profile marketplace (GitHub Gist) - NOT IMPLEMENTED
    "github_token": "",  # GitHub personal access token for Gist API (optional, for private gists) - NOT IMPLEMENTED
    "max_upgrade_level": 7,  # Maximum level to upgrade towers to (7 = unlimited/all upgrades)
    "auto_upgrade_system": False,  # Enable automated tower upgrade adaptation system
    "upgrade_pixel_green": (0, 255, 0),  # RGB of green pixel indicating upgrade available
    "upgrade_pixel_gray": (128, 128, 128),  # RGB of gray pixel indicating max level
    "upgrade_pixel_x": 0.0,  # X coordinate (percentage) of upgrade pixel check
    "upgrade_pixel_y": 0.0,  # Y coordinate (percentage) of upgrade pixel check
    "tower_search_radius": 15,  # Pixels to shuffle up/down/left/right to find tower
    "upgrade_cycle_time": 0.2,  # Time per tower for upgrade cycle (click + check + upgrade)
    "performance_profiler": True,  # Enable performance profiling
    "hot_swap_profiles": False,  # Enable hot-swapping profiles with hotkeys
    "hot_swap_profile_1": "",  # Profile for F11 hotkey
    "hot_swap_profile_2": "",  # Profile for F12 hotkey
    "wave_prediction": False,  # Enable wave prediction system - NOT IMPLEMENTED
    "auto_economy": False,  # Enable automatic economy management - NOT IMPLEMENTED
    "tower_suggestions": False,  # Enable tower placement suggestions - NOT IMPLEMENTED
    "discord_notifications": False,  # Enable Discord notifications - NOT IMPLEMENTED
    "discord_webhook": "",  # Discord webhook URL for notifications - NOT IMPLEMENTED
    "discord_screenshots": False,  # Include screenshots in Discord notifications - NOT IMPLEMENTED
    "map_database": False,  # Enable map strategy database - NOT IMPLEMENTED
    "gemini_advisor": False,  # Enable Gemini 2.5 Flash AI advisor
    "gemini_api_key": "",  # Gemini API key
    "ability_spam": True,  # Automatically spam tower abilities when available
    "ability_spam_interval": 0.5,  # Interval between ability spams (seconds)
    "time_scale_mode": "OFF",  # Time scale mode (OFF, 1.5x, 2x) - speeds up game
    "time_scale_2x": False,  # Enable 2x speed during recording (clicks arrow then 2x button)
    "hotbar_click_select": False,  # Select hotbar slots by clicking instead of keys
    "tower_ui_cache": True,  # Cache tower menu UI position for faster access
    "big_dick_randy_mode": False,  # Enable Big Dick Randy mode (random appearances)
    "bdr_min_interval": 300,  # Minimum seconds between appearances
    "bdr_max_interval": 900,  # Maximum seconds between appearances
    "bdr_duration": 5,  # How long the overlay stays (seconds)
    "bdr_minigame": False,  # Enable Big Dick Randy driving chase mini-game
    "bdr_little_popups": True,  # Enable little Big Dick Randy popups in settings (impossible to disable)
    "bdr_popup_min_interval": 60,  # Minimum seconds between little popups
    "bdr_popup_max_interval": 300,  # Maximum seconds between little popups
    "bdr_fake_tabs": True,  # Enable fake achievement/tabs from Randy (impossible to disable)
    "bdr_fake_tab_min_interval": 900,  # Minimum seconds between fake tabs (15 min)
    "bdr_fake_tab_max_interval": 5400,  # Maximum seconds between fake tabs (90 min)
    "bdr_max_fake_tabs": 5,  # Maximum number of fake tabs at once
    # Randy rarity system
    "bdr_rarity_system": True,  # Enable rarity tiers (common/rare/ultra-rare)
    "bdr_common_chance": 0.70,  # 70% chance for common
    "bdr_rare_chance": 0.25,  # 25% chance for rare
    "bdr_ultra_rare_chance": 0.05,  # 5% chance for ultra-rare
    # Randy evidence board
    "bdr_evidence_board": True,  # Capture and display Randy sightings
    "bdr_max_evidence": 20,  # Max screenshots to store
    # Randy lore unlocks
    "bdr_lore_unlocks": True,  # Unlock lore entries based on sightings
    "bdr_lore_progress": 0,  # Current lore progress (0-100)
    # Randy incident reports
    "bdr_incident_reports": True,  # Show fake incident reports in dashboard
    # Mahoraga counter
    "bdr_mahoraga_counter": True,  # Track Mahoraga adaptations before Randy interrupts
    "bdr_mahoraga_count": 0,  # Current Mahoraga streak
    # Randy's changelog (Gemini integration)
    "bdr_changelog_gemini": True,  # Use Gemini to approve/reject features
    "bdr_changelog_fake": True,  # Also show fake Randy approvals
    # Suspicious idle detector
    "bdr_idle_detector": True,  # Show fake messages when macro is idle
    "bdr_idle_threshold": 60,  # Seconds idle before showing message
    # Randy stat reactions
    "bdr_stat_reactions": True,  # Randy comments on your stats (coins, XP, win rate)
    # Randy fake awareness - reacts to macro events
    "bdr_fake_awareness": True,  # Randy comments on recording, profile switches, etc.
    # Randy's case file - cursed lore entries
    "bdr_case_file": True,  # Unlock fictional evidence and cursed lore
    "bdr_case_progress": 0,  # Case file progress (0-100)
    # Randy fake takeover - "hacks" the overlay
    "bdr_fake_takeover": True,  # Randy changes overlay name, profile, scale, resolution
    "bdr_takeover_chance": 0.1,  # 10% chance to trigger on rare Randy
    # Randy sightings - capture Randy overlay screenshots
    "bdr_sightings": True,  # Capture screenshots of Randy's overlay
    "search_x": 0.0, "search_y": 0.0, "search_px_color": None,
    "map_x": 0.0, "map_y": 0.0, "map_px_color": None,
    "ready_x": 0.0, "ready_y": 0.0, "ready_px_color": None,
    "veto_x": 0.0, "veto_y": 0.0, "veto_px_color": None,
    "veto_on": True,
    "vpx_x": 0.0, "vpx_y": 0.0, "vpx_color": None, "vpx_tol": 12,
    "gpx_x": 0.0, "gpx_y": 0.0, "px_tol": 12, "nudge_px": 10, "nudge_radius": 45, "menu_delay": 1.0,
    "search_tol": 12, "map_tol": 12, "ready_tol": 12, "veto_tol": 12,
    "restart_px_tol": 12, "ready_px_tol": 12, "play_again_px_tol": 12,
    "restart_px_x": 0.0, "restart_px_y": 0.0, "restart_px_color": None, "restart_px_custom_color": None,
    "ready_px_x": 0.0, "ready_px_y": 0.0, "ready_px_color": None, "ready_px_custom_color": None,
    "play_again_px_x": 0.0, "play_again_px_y": 0.0, "play_again_px_color": None, "play_again_px_custom_color": None,
    "hk_start": "F4", "hk_stop": "F5", "hk_record": "F6", "hk_pick_color": "F7", "hk_switch_profile": "F8", "hk_reload_templates": "F9",
    # Hidden Diamond Legacy system (secret feature - no settings)
    "diamond_legacy_unlocked": False,  # Unlocks special features at milestones
    "diamond_legacy_coins": 0,  # Tracks coins since legacy unlock
    "diamond_legacy_xp": 0,  # Tracks XP since legacy unlock
    "diamond_legacy_runs": 0,  # Tracks runs since legacy unlock
    "auto_dock": True,
    "dock_fit": "auto",
    "auto_rejoin": False,
    "rec_name": "", "recording": "",
    "totals": {"coins": 0, "xp": 0, "runs": 0},
    "custom_colors": {},
    "problematic_spots": {},
    "max_spot_failures": 3,
    "audio_cues": True,
    "screenshot_on_error": True,
    # Preflight system
    "preflight_check": True,  # Run preflight validation before starting macro
    "preflight_on_start": True,  # Auto-run preflight when macro starts
    # Detection diagnostics
    "diagnostics_mode": False,  # Show bounding boxes and confidence scores
    "diagnostics_show_confidence": True,  # Show detection confidence in overlay
    "diagnostics_show_reason": True,  # Show why detection was accepted/rejected
    # Rollback system
    "rollback_enabled": True,  # Enable one-click rollback to previous config
    "rollback_snapshots": 5,  # Keep last 5 config snapshots
    # Auto-update system
    "auto_update_enabled": True,  # Check for updates automatically
    "auto_update_check_on_start": True,  # Check for updates when macro starts
    "auto_update_check_interval": 24,  # Check every X hours (0 = check every time, default 24)
    "auto_update_last_check": 0,  # Timestamp of last update check
    "auto_update_auto_install": False,  # Automatically install updates without asking
    "auto_update_rebuild_exe": False,  # Auto-rebuild EXE after updating source
    "github_repo_url": "https://github.com/D14M0ND-RBX/Roblox-Macro",
    # Gemini game adaptation
    "gemini_game_adaptation": False,  # Use Gemini to adapt to other games
    "gemini_game_adaptation_on_profile_switch": True,  # Auto-query when switching profiles
    "stats": {"total_runs": 0, "successful_runs": 0, "failed_runs": 0, "total_time": 0.0, "avg_time": 0.0, "runs_per_hour": 0.0, "last_error": ""},
    "gamemode_cycle": {"enabled": False, "modes": ["molten"], "current_index": 0, "runs_per_mode": 10, "current_runs": 0},
    "gamemode_stats": {},
    "cycle_enabled": False,
    "cycle_modes": "molten",
    "cycle_runs": 10,
    "rejoin_link": "",
    "custom_rejoin_steps": [],
    "gamemode": "molten",
    "rbx_fps_cap": 1000,
    "active_profile": "tds",
}

DEPS = [("cv2", "opencv-python-headless", True), ("numpy", "numpy", True),
        ("mss", "mss", True), ("webview", "pywebview", True), ("winsdk", "winsdk", False),
        ("PIL", "Pillow", False), ("PyQt5", "PyQt5", False), ("wmi", "wmi", False)]
RETRY_EVERY_LAUNCH = {"winsdk", "wmi"}   # optional packages that are worth retrying
ONLY_WHEELS = {"winsdk", "Pillow", "PyQt5"}   # optional packages: take a ready-made wheel, never start a long source build


# ----------------------------------------------------------------------
#  Icon export (used by the exe builder)
# ----------------------------------------------------------------------
def _png(w, h, raw):
    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b""))


def export_icon(path):
    pngs = []
    for s in (16, 32, 48, 256):
        raw = bytearray()
        for y in range(s):
            raw.append(0)
            for x in range(s):
                dx = abs(x + 0.5 - s / 2) / (s / 2)
                dy = abs(y + 0.5 - s / 2) / (s / 2)
                d = dx + dy
                a = max(0.0, min(1.0, (0.94 - d) * s * 0.5))
                t = (x + y) / (2.0 * s)
                r = int(94 + (45 - 94) * t); g = int(234 + (190 - 234) * t); b = int(212 + (200 - 212) * t)
                if d < 0.42:
                    r, g, b = min(255, r + 55), min(255, g + 55), min(255, b + 40)
                raw += bytes((r, g, b, int(a * 255)))
        pngs.append((s, _png(s, s, raw)))
    out = struct.pack("<HHH", 0, 1, len(pngs))
    off = 6 + 16 * len(pngs)
    body = b""
    for s, p in pngs:
        out += struct.pack("<BBBBHHII", 0 if s >= 256 else s, 0 if s >= 256 else s, 0, 0, 1, 32, len(p), off + len(body))
        body += p
    with open(path, "wb") as f:
        f.write(out + body)


# ----------------------------------------------------------------------
#  Log file, crash hooks, safe file writes
# ----------------------------------------------------------------------
_file_log = logging.getLogger("tdmacro")
_LEVELS = {"info": logging.INFO, "ok": logging.INFO, "warn": logging.WARNING, "err": logging.ERROR}


def setup_logging():
    """Rotating log (1 MB x 3 files) in the TDRecorder data folder. Safe to call twice."""
    if _file_log.handlers:
        return
    _file_log.setLevel(logging.DEBUG)
    _file_log.propagate = False
    logging.raiseExceptions = False          # a logging problem must never take the macro down
    try:
        os.makedirs(DATA_DIR, exist_ok=True)
        h = RotatingFileHandler(LOG_PATH, maxBytes=1000000, backupCount=3, encoding="utf-8", delay=True)
        h.setFormatter(logging.Formatter("%(asctime)s %(levelname)-5s %(message)s", "%Y-%m-%d %H:%M:%S"))
        _file_log.addHandler(h)
    except Exception:
        _file_log.addHandler(logging.NullHandler())


def file_log(msg, kind="info"):
    try:
        _file_log.log(_LEVELS.get(kind, logging.INFO), msg)
    except Exception:
        pass


def install_crash_hooks():
    """Anything that escapes a thread lands in the log instead of vanishing."""
    def on_main(et, ev, tb):
        file_log("UNCAUGHT " + "".join(traceback.format_exception(et, ev, tb)), "err")

    def on_thread(args):
        if args.exc_type is SystemExit:
            return
        name = getattr(args.thread, "name", "?")
        file_log("THREAD CRASH (%s) " % name + "".join(
            traceback.format_exception(args.exc_type, args.exc_value, args.exc_traceback)), "err")
    sys.excepthook = on_main
    threading.excepthook = on_thread


def rotate_if_big(path, limit=1000000):
    """Keep the plain-text stdout/stderr capture file from growing forever."""
    try:
        if os.path.getsize(path) > limit:
            os.replace(path, path + ".old")
    except OSError:
        pass


def write_json_atomic(path, data, **kw):
    """Write to a temp file, then swap it in, so a crash mid-write can't leave half a file."""
    tmp = "%s.%d.tmp" % (path, os.getpid())
    try:
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(data, f, **kw)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp, path)
    except Exception:
        try:
            os.remove(tmp)
        except OSError:
            pass
        raise


# ----------------------------------------------------------------------
#  Diagnostics (td_macro.log, "Test scan", and  Diamond_TD_Macro.bat --diagnose)
# ----------------------------------------------------------------------
def ocr_status():
    """Is Windows OCR usable? Runs in its own thread: WinRT and the window toolkit must not share the main one."""
    result = ["unavailable - the winsdk package is not installed"]

    def work():
        try:
            from winsdk.windows.media.ocr import OcrEngine
            from winsdk.windows.globalization import Language
            eng = OcrEngine.try_create_from_user_profile_languages()
            if eng is None:
                eng = OcrEngine.try_create_from_language(Language("en-US"))
            result[0] = "ready" if eng is not None else "no OCR language pack installed (Windows Settings > Language)"
        except ImportError:
            pass
        except Exception as e:
            result[0] = "error: %s: %s" % (type(e).__name__, e)
    t = threading.Thread(target=work, daemon=True, name="td-ocr-check")
    t.start()
    t.join(8)
    return result[0]


def _webview2_version():
    import winreg
    guid = "{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}"
    for hive, sub in ((winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients" + "\\" + guid),
                      (winreg.HKEY_CURRENT_USER, r"Software\Microsoft\EdgeUpdate\Clients" + "\\" + guid)):
        try:
            with winreg.OpenKey(hive, sub) as k:
                return str(winreg.QueryValueEx(k, "pv")[0])
        except OSError:
            continue
    return "NOT FOUND (the macro window needs it)"


def _pkg_version(dist):
    from importlib import metadata
    try:
        return metadata.version(dist)
    except Exception:
        return "n/a"


def diagnostics_report():
    """One line per fact about the machine/setup. Never raises."""
    out = []

    def add(label, fn):
        try:
            val = fn()
        except Exception as e:
            val = "ERROR %s: %s" % (type(e).__name__, e)
        out.append("%-16s %s" % (label + ":", val))

    def data_dir_ok():
        os.makedirs(DATA_DIR, exist_ok=True)
        probe = os.path.join(DATA_DIR, ".write_test")
        with open(probe, "w") as f:
            f.write("ok")
        os.remove(probe)
        return "%s (writable)" % DATA_DIR

    def roblox():
        h = find_roblox()
        if not h:
            return "not found (open Roblox, windowed)"
        r = roblox_client_rect()
        return "found, %dx%d at %d,%d" % (r[2], r[3], r[0], r[1]) if r else "found, but no client area"

    add("App", lambda: "%s %s (%s)" % (APP_TITLE, VERSION, "exe" if FROZEN else "script"))
    add("Python", lambda: "%s %s-bit" % (platform.python_version(), "64" if sys.maxsize > 2 ** 32 else "32"))
    add("Windows", lambda: "%s (%s)" % (platform.release(), platform.version()))
    add("Admin", lambda: "yes" if ctypes.windll.shell32.IsUserAnAdmin() else "no")
    add("Screen", lambda: "%dx%d primary, %dx%d virtual, DPI %d" % (
        user32.GetSystemMetrics(0), user32.GetSystemMetrics(1), virtual_screen()[2], virtual_screen()[3],
        ctypes.windll.user32.GetDpiForSystem()))
    add("OpenCV", lambda: cv2.__version__)
    add("NumPy", lambda: np.__version__)
    add("mss", lambda: _pkg_version("mss"))
    add("pywebview", lambda: _pkg_version("pywebview"))
    add("WebView2", _webview2_version)
    add("Windows OCR", ocr_status)
    add("Roblox", roblox)
    add("Images", lambda: "%d of %d templates loaded" % (len(TPL_BASE), len(TEMPLATES)))
    add("Data folder", data_dir_ok)
    add("Log file", lambda: LOG_PATH)
    return out


def run_diagnose():
    lines = diagnostics_report()
    text = "\n".join(lines)
    try:
        with open(os.path.join(DATA_DIR, "diagnostics.txt"), "w", encoding="utf-8") as f:
            f.write(text + "\n")
    except Exception:
        pass
    file_log("diagnostics\n" + text)
    try:
        print(text)
    except Exception:
        pass
    if FROZEN:
        msgbox(text + "\n\n(also saved to diagnostics.txt)")


def _log_startup_report():
    for line in diagnostics_report():
        file_log("env  " + line)


# ----------------------------------------------------------------------
#  Setup helpers
# ----------------------------------------------------------------------
def msgbox(text):
    try:
        ctypes.windll.user32.MessageBoxW(0, str(text), APP_TITLE, 0x10)
    except Exception:
        print(text)


def _pip_ready():
    """pip must exist before anything can be installed: bring it with ensurepip if this Python shipped without it."""
    try:
        r = subprocess.run([sys.executable, "-m", "pip", "--version"], capture_output=True, text=True, errors="replace")
        if r.returncode == 0:
            return True
        print("[setup] pip is missing - installing it ...")
        subprocess.run([sys.executable, "-m", "ensurepip", "--upgrade"], capture_output=True, text=True, errors="replace")
        r = subprocess.run([sys.executable, "-m", "pip", "--version"], capture_output=True, text=True, errors="replace")
        return r.returncode == 0
    except Exception:
        return False


def ensure_deps():
    if FROZEN:
        return
    missing = []
    for mod, pkg, required in DEPS:
        try:
            __import__(mod)
        except Exception:
            missing.append((mod, pkg, required))
    if not missing:
        return
    if not _pip_ready():
        msgbox("pip is not available for this Python, so the macro's libraries can not be installed.\nReinstall Python 3.12 from python.org (tick 'pip' and 'Add to PATH').")
        raise SystemExit(1)
    print("[setup] installing: %s" % ", ".join(p for _m, p, _r in missing))
    for mod, pkg, required in missing:
        skip = os.path.join(DATA_DIR, "skip_%s.txt" % pkg)
        if not required and pkg not in RETRY_EVERY_LAUNCH and os.path.exists(skip) and time.time() - os.path.getmtime(skip) < 7 * 86400:
            continue                      # failed recently; try again in a week
        print("[setup] installing %s ..." % pkg)
        cmd = [sys.executable, "-m", "pip", "install", "--disable-pip-version-check", "-q"]
        if pkg in ONLY_WHEELS:
            cmd.append("--only-binary=:all:")
        r = subprocess.run(cmd + [pkg], capture_output=True, text=True, errors="replace")
        if r.returncode != 0 and pkg in ONLY_WHEELS:      # one more go with the user-site folder (works without admin rights / on locked installs)
            r = subprocess.run(cmd + ["--user", pkg], capture_output=True, text=True, errors="replace")
        if r.returncode != 0:
            tail = "\n".join((r.stderr or r.stdout or "").strip().splitlines()[-4:])
            file_log("pip install %s failed (exit %s): %s" % (pkg, r.returncode, tail), "err" if required else "warn")
            if required:
                msgbox("Could not install %s automatically.\nRun:  pip install %s\n\n%s" % (pkg, pkg, tail))
                raise SystemExit(1)
            print("[setup] WARNING: %s was not installed%s" % (pkg, " - the map veto message can NOT be read without it (run: pip install winsdk)" if pkg == "winsdk" else " - the macro still runs without it"))
            try:
                with open(skip, "w") as f:
                    f.write("pip install failed")
            except OSError:
                pass
        else:
            try:
                import importlib
                importlib.invalidate_caches()
                __import__(mod)
            except Exception as e:
                print("[setup] %s installed but can not be imported yet (%s: %s) - restart the macro once" % (pkg, type(e).__name__, e))


def check_ocr_ready():
    """The veto message is read with Windows OCR: report clearly whether it works, and try to add the English OCR pack if it is the missing piece."""
    st = ocr_status()
    if st == "ready":
        file_log("Windows OCR: ready")
        return
    file_log("Windows OCR is not ready: %s" % st, "warn")
    print("[setup] Windows OCR is not ready (%s) - the map veto message can not be read until this is fixed." % st)
    if "language pack" in st:
        mark = os.path.join(DATA_DIR, "skip_ocr_pack.txt")
        if not (os.path.exists(mark) and time.time() - os.path.getmtime(mark) < 7 * 86400):
            print("[setup] trying to add the English OCR language pack (needs administrator rights, so it may just fail) ...")
            try:
                r = subprocess.run(["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command",
                                    "Add-WindowsCapability -Online -Name 'Language.OCR~~~en-US~0.0.1.0'"],
                                   capture_output=True, text=True, errors="replace", timeout=180)
                ok = r.returncode == 0
            except Exception:
                ok = False
            try:
                with open(mark, "w") as f:
                    f.write("tried")
            except OSError:
                pass
            if ok and ocr_status() == "ready":
                print("[setup] OCR language pack installed.")
                file_log("Windows OCR: language pack installed, ready")
                return
        print("[setup] Fix: open PowerShell AS ADMINISTRATOR and run:  Add-WindowsCapability -Online -Name 'Language.OCR~~~en-US~0.0.1.0'")
        print("[setup]      (or Windows Settings > Time & language > Language & region > add English (United States) incl. 'Optical character recognition')")


cv2 = None
np = None


def load_libs():
    global cv2, np
    import cv2 as _cv2
    import numpy as _np
    cv2, np = _cv2, _np


try:
    user32 = ctypes.windll.user32
    kernel32 = ctypes.windll.kernel32
except Exception:
    user32 = kernel32 = None


def win_setup():
    try:
        ctypes.windll.shcore.SetProcessDpiAwareness(2)
    except Exception:
        try:
            user32.SetProcessDPIAware()
        except Exception:
            pass
    try:
        ctypes.windll.winmm.timeBeginPeriod(1)      # accurate sleeps
    except Exception:
        pass
    u = user32
    u.SetWindowLongPtrW.argtypes = [wintypes.HWND, ctypes.c_int, ctypes.c_ssize_t]
    u.SetWindowLongPtrW.restype = ctypes.c_ssize_t
    u.GetWindowLongPtrW.argtypes = [wintypes.HWND, ctypes.c_int]
    u.GetWindowLongPtrW.restype = ctypes.c_ssize_t
    u.SetParent.argtypes = [wintypes.HWND, wintypes.HWND]
    u.SetParent.restype = wintypes.HWND
    u.GetAsyncKeyState.restype = ctypes.c_short
    u.VkKeyScanW.restype = ctypes.c_short       # SHORT: makes the -1 'no such key' check reliable
    u.GetAncestor.argtypes = [wintypes.HWND, wintypes.UINT]
    u.GetAncestor.restype = wintypes.HWND
    u.SetWindowPos.argtypes = [wintypes.HWND, wintypes.HWND, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, wintypes.UINT]
    u.MoveWindow.argtypes = [wintypes.HWND, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_int, wintypes.BOOL]


# ----------------------------------------------------------------------
#  Audio Cues
# ----------------------------------------------------------------------
_winmm = None
def _play_beep(frequency=800, duration=200):
    """Play a simple beep sound for audio cues"""
    global _winmm
    if not bool(_winmm):
        try:
            _winmm = ctypes.windll.winmm
        except Exception:
            return
    try:
        _winmm.Beep(frequency, duration)
    except Exception:
        pass


# ----------------------------------------------------------------------
#  Keyboard / mouse (SendInput, scan codes - works in Roblox)
# ----------------------------------------------------------------------
ULONG_PTR = ctypes.c_ulonglong if ctypes.sizeof(ctypes.c_void_p) == 8 else ctypes.c_ulong


class MOUSEINPUT(ctypes.Structure):
    _fields_ = [("dx", ctypes.c_long), ("dy", ctypes.c_long), ("mouseData", ctypes.c_ulong),
                ("dwFlags", ctypes.c_ulong), ("time", ctypes.c_ulong), ("dwExtraInfo", ULONG_PTR)]


class KEYBDINPUT(ctypes.Structure):
    _fields_ = [("wVk", ctypes.c_ushort), ("wScan", ctypes.c_ushort), ("dwFlags", ctypes.c_ulong),
                ("time", ctypes.c_ulong), ("dwExtraInfo", ULONG_PTR)]


class _IU(ctypes.Union):
    _fields_ = [("mi", MOUSEINPUT), ("ki", KEYBDINPUT)]


class INPUT(ctypes.Structure):
    _anonymous_ = ("u",)
    _fields_ = [("type", ctypes.c_ulong), ("u", _IU)]


VK = {}
for _c in "abcdefghijklmnopqrstuvwxyz":
    VK[_c] = ord(_c.upper())
for _d in "0123456789":
    VK[_d] = ord(_d)
VK.update({"space": 0x20, "enter": 0x0D, "esc": 0x1B, "shift": 0x10, "ctrl": 0x11, "alt": 0x12,
           "tab": 0x09, "backspace": 0x08, "left": 0x25, "up": 0x26, "right": 0x27, "down": 0x28})
EXT_VK = {0x25, 0x26, 0x27, 0x28}
FKEYS = {"F%d" % i: 0x6F + i for i in range(1, 13)}
VK.update(FKEYS)       # make F1..F12 usable via key_event() / tap() / hold_key()


def _send(inp):
    user32.SendInput(1, ctypes.byref(inp), ctypes.sizeof(INPUT))


def key_event(name, down):
    vk = VK.get(name)
    if vk is None:
        return
    sc = user32.MapVirtualKeyW(vk, 0)
    fl = 0x0008 | (0 if down else 0x0002) | (0x0001 if vk in EXT_VK else 0)
    i = INPUT(type=1)
    i.ki = KEYBDINPUT(0, sc, fl, 0, 0)
    _send(i)


def _mouse(flags, dx=0, dy=0, data=0):
    i = INPUT(type=0)
    i.mi = MOUSEINPUT(int(dx), int(dy), data & 0xFFFFFFFF, flags, 0, 0)
    _send(i)


def cursor_pos():
    pt = wintypes.POINT()
    user32.GetCursorPos(ctypes.byref(pt))
    return pt.x, pt.y


# 1-pixel crosshair (hole at the hotspot) so the veto pixel pick is exact.
# SetSystemCursor replaces the fat Windows arrow while the 3s grab is running.
_PX_CUR_SIZE = 32
_PX_CUR_HOT = 15
_PX_CUR_HOLE = 3
_PX_CUR_OCR = (32512, 32513, 32514, 32515, 32640, 32642, 32643, 32644, 32649, 32650, 32651)
_px_cur_lock = threading.Lock()
_px_cur_depth = 0
_px_cur_handle = None


def _px_pack_mono(bits, size):
    row_bytes = max(4, (size + 31) // 32 * 4)  # DWORD-aligned scanlines
    out = bytearray()
    for y in range(size):
        v = 0
        for x in range(size):
            v = (v << 1) | (1 if bits[y][x] else 0)
        raw = v.to_bytes((size + 7) // 8, "big")
        out += raw + b"\x00" * (row_bytes - len(raw))
    return bytes(out)


def _px_make_crosshair():
    size, hot, hole = _PX_CUR_SIZE, _PX_CUR_HOT, _PX_CUR_HOLE
    black, white = set(), set()
    for i in range(size):
        if abs(i - hot) < hole:
            continue
        black.add((hot, i))
        black.add((i, hot))
    for x, y in list(black):
        for dx, dy in ((-1, 0), (1, 0), (0, -1), (0, 1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < size and 0 <= ny < size and (nx, ny) not in black:
                white.add((nx, ny))
    and_bits = [[1] * size for _ in range(size)]
    xor_bits = [[0] * size for _ in range(size)]
    for x, y in black | white:
        and_bits[y][x] = 0
    for x, y in white:
        xor_bits[y][x] = 1
    user32.CreateCursor.restype = wintypes.HANDLE
    user32.LoadCursorW.restype = wintypes.HANDLE
    h = user32.CreateCursor(None, hot, hot, size, size,
                            _px_pack_mono(and_bits, size), _px_pack_mono(xor_bits, size))
    return h or user32.LoadCursorW(None, 32515)


def _px_install_cursor():
    global _px_cur_handle
    user32.CopyIcon.restype = wintypes.HANDLE
    user32.SetSystemCursor.argtypes = [wintypes.HANDLE, ctypes.c_int]
    if not _px_cur_handle:
        _px_cur_handle = _px_make_crosshair()
    if not _px_cur_handle:
        return
    for ocr in _PX_CUR_OCR:
        dup = user32.CopyIcon(_px_cur_handle)
        if dup:
            user32.SetSystemCursor(dup, ocr)


def _px_restore_cursors():
    try:
        user32.SystemParametersInfoW(0x0057, 0, None, 0)  # SPI_SETCURSORS
    except Exception:
        pass


def pixel_pick_cursor(on):
    """Swap in (or restore) the thin pixel-pick crosshair. Safe to nest / call from a worker thread."""
    global _px_cur_depth
    with _px_cur_lock:
        if on:
            _px_cur_depth += 1
            if _px_cur_depth == 1:
                try:
                    _px_install_cursor()
                except Exception:
                    _px_cur_depth = 0
        else:
            if _px_cur_depth > 0:
                _px_cur_depth -= 1
            if _px_cur_depth == 0:
                _px_restore_cursors()


atexit.register(lambda: _px_restore_cursors() if _px_cur_depth else None)


def virtual_screen():
    return (user32.GetSystemMetrics(76), user32.GetSystemMetrics(77),
            user32.GetSystemMetrics(78), user32.GetSystemMetrics(79))


def move_abs(x, y):
    vx, vy, vw, vh = virtual_screen()
    nx = int((x - vx) * 65535 / max(1, vw - 1))
    ny = int((y - vy) * 65535 / max(1, vh - 1))
    _mouse(0x0001 | 0x8000 | 0x4000, nx, ny)


def move_smooth(x, y, dur=0.12):
    sx, sy = cursor_pos()
    steps = max(3, int(dur / 0.008))
    for i in range(1, steps + 1):
        t = i / float(steps)
        t = t * t * (3 - 2 * t)
        move_abs(sx + (x - sx) * t, sy + (y - sy) * t)
        time.sleep(dur / steps)


BTN = {"lmb": (0x0002, 0x0004), "rmb": (0x0008, 0x0010)}


def mouse_btn(name, down):
    _mouse(BTN[name][0] if down else BTN[name][1])


def type_char(ch):
    r = user32.VkKeyScanW(ord(ch))
    if r == -1:
        i = INPUT(type=1)
        i.ki = KEYBDINPUT(0, ord(ch), 0x0004, 0, 0)
        _send(i)
        i = INPUT(type=1)
        i.ki = KEYBDINPUT(0, ord(ch), 0x0004 | 0x0002, 0, 0)
        _send(i)
        return
    vk, st = r & 0xFF, (r >> 8) & 0xFF
    sc = user32.MapVirtualKeyW(vk, 0)
    if st & 1:
        key_event("shift", True)
    for up in (0, 0x0002):
        i = INPUT(type=1)
        i.ki = KEYBDINPUT(0, sc, 0x0008 | up, 0, 0)
        _send(i)
    if st & 1:
        key_event("shift", False)


# ----------------------------------------------------------------------
#  Roblox window finding / docking
# ----------------------------------------------------------------------
WNDENUMPROC = getattr(ctypes, "WINFUNCTYPE", ctypes.CFUNCTYPE)(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)
_rb_cache = [0, 0.0]


def find_roblox():
    if time.time() - _rb_cache[1] < 1.0 and _rb_cache[0] and user32.IsWindow(_rb_cache[0]):
        return _rb_cache[0]
    found = []

    def cb(h, l):
        if user32.IsWindowVisible(h):
            t = ctypes.create_unicode_buffer(256)
            c = ctypes.create_unicode_buffer(256)
            user32.GetWindowTextW(h, t, 256)
            user32.GetClassNameW(h, c, 256)
            if t.value == "Roblox" and c.value == "WINDOWSCLIENT":
                found.append(h)
        return True
    user32.EnumWindows(WNDENUMPROC(cb), 0)
    _rb_cache[0] = found[0] if found else 0
    _rb_cache[1] = time.time()
    return _rb_cache[0]


# ---- dock any window: process / DWM helpers and the window list ----
try:
    _u32 = ctypes.WinDLL("user32", use_last_error=True)       # private copy: typed prototypes, shared user32 stays untouched
    _u32.GetWindowLongPtrW.argtypes = [wintypes.HWND, ctypes.c_int]
    _u32.GetWindowLongPtrW.restype = ctypes.c_ssize_t
    _u32.SetWindowLongPtrW.argtypes = [wintypes.HWND, ctypes.c_int, ctypes.c_ssize_t]
    _u32.SetWindowLongPtrW.restype = ctypes.c_ssize_t
    _k32 = ctypes.WinDLL("kernel32")
    _k32.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
    _k32.OpenProcess.restype = wintypes.HANDLE
    _k32.CloseHandle.argtypes = [wintypes.HANDLE]
    _k32.QueryFullProcessImageNameW.argtypes = [wintypes.HANDLE, wintypes.DWORD, wintypes.LPWSTR, ctypes.POINTER(wintypes.DWORD)]
    _k32.QueryFullProcessImageNameW.restype = wintypes.BOOL
    _adv = ctypes.WinDLL("advapi32")
    _adv.OpenProcessToken.argtypes = [wintypes.HANDLE, wintypes.DWORD, ctypes.POINTER(wintypes.HANDLE)]
    _adv.OpenProcessToken.restype = wintypes.BOOL
    _adv.GetTokenInformation.argtypes = [wintypes.HANDLE, ctypes.c_int, ctypes.c_void_p, wintypes.DWORD, ctypes.POINTER(wintypes.DWORD)]
    _adv.GetTokenInformation.restype = wintypes.BOOL
    _dwm = ctypes.WinDLL("dwmapi")
    _dwm.DwmGetWindowAttribute.argtypes = [wintypes.HWND, wintypes.DWORD, ctypes.c_void_p, wintypes.DWORD]
    _dwm.DwmGetWindowAttribute.restype = ctypes.c_long
except Exception:
    _u32 = _k32 = _adv = _dwm = None

_SHELL_CLASSES = ("Progman", "WorkerW", "Shell_TrayWnd", "Shell_SecondaryTrayWnd")


def _get_long(h, idx):
    return _u32.GetWindowLongPtrW(h, idx)


def _set_long(h, idx, val):
    ctypes.set_last_error(0)
    _u32.SetWindowLongPtrW(h, idx, val)
    return ctypes.get_last_error()


def _win_pid(h):
    p = wintypes.DWORD(0)
    user32.GetWindowThreadProcessId(h, ctypes.byref(p))
    return p.value


def _exe_of(pid):
    """File name (no folder) of the program that owns a process id; empty when Windows will not say."""
    if not pid or not _k32:
        return ""
    h = _k32.OpenProcess(0x1000, False, pid)                  # PROCESS_QUERY_LIMITED_INFORMATION
    if not h:
        return ""
    try:
        buf = ctypes.create_unicode_buffer(1024)
        n = wintypes.DWORD(1024)
        if _k32.QueryFullProcessImageNameW(h, 0, buf, ctypes.byref(n)):
            return os.path.basename(buf.value)
    finally:
        _k32.CloseHandle(h)
    return ""


def _proc_elevated(pid):
    """True = the process runs as administrator, False = it does not, None = Windows will not say."""
    if not pid or not _k32 or not _adv:
        return None
    h = _k32.OpenProcess(0x1000, False, pid)
    if not h:
        return None
    try:
        tok = wintypes.HANDLE()
        if not _adv.OpenProcessToken(h, 0x0008, ctypes.byref(tok)):      # TOKEN_QUERY
            return None
        try:
            elev = wintypes.DWORD(0)
            n = wintypes.DWORD(0)
            if _adv.GetTokenInformation(tok, 20, ctypes.byref(elev), 4, ctypes.byref(n)):     # TokenElevation
                return bool(elev.value)
        finally:
            _k32.CloseHandle(tok)
    finally:
        _k32.CloseHandle(h)
    return None


def _cloaked(h):
    """Virtual-desktop / UWP ghost windows are 'visible' but cloaked (DWMWA_CLOAKED = 14)."""
    if not _dwm:
        return False
    v = wintypes.DWORD(0)
    try:
        if _dwm.DwmGetWindowAttribute(h, 14, ctypes.byref(v), 4) == 0:
            return v.value != 0
    except Exception:
        pass
    return False


def list_windows(exclude=0):
    """The open windows a person would want to dock: visible, titled, not ours, not cloaked, no tool or shell windows.
    Returns [{hwnd, title, class, exe}] sorted by exe, then title."""
    out = []
    me = os.getpid()
    exes = {}

    def cb(h, l):
        try:
            if h == exclude or not user32.IsWindowVisible(h) or user32.GetWindowTextLengthW(h) <= 0:
                return True
            ex = _get_long(h, -20) & 0xFFFFFFFF
            if (ex & 0x00000080) and not (ex & 0x00040000):        # WS_EX_TOOLWINDOW unless WS_EX_APPWINDOW
                return True
            c = ctypes.create_unicode_buffer(256)
            user32.GetClassNameW(h, c, 256)
            if c.value in _SHELL_CLASSES:
                return True
            pid = _win_pid(h)
            if pid == me or _cloaked(h):
                return True
            t = ctypes.create_unicode_buffer(512)
            user32.GetWindowTextW(h, t, 512)
            if not t.value.strip():
                return True
            if pid not in exes:
                exes[pid] = _exe_of(pid)
            out.append({"hwnd": int(h), "title": t.value.strip(), "class": c.value, "exe": exes[pid]})
        except Exception:
            pass
        return True
    user32.EnumWindows(WNDENUMPROC(cb), 0)
    out.sort(key=lambda w: (w["exe"].lower(), w["title"].lower()))
    return out


def roblox_client_rect():
    h = find_roblox()
    if not h:
        return None
    r = wintypes.RECT()
    user32.GetClientRect(h, ctypes.byref(r))
    pt = wintypes.POINT(0, 0)
    user32.ClientToScreen(h, ctypes.byref(pt))
    if r.right <= 0 or r.bottom <= 0:
        return None
    return (pt.x, pt.y, r.right, r.bottom)


def game_rect():
    r = roblox_client_rect()
    if r:
        return r
    return (0, 0, user32.GetSystemMetrics(0), user32.GetSystemMetrics(1))


def roblox_focused():
    h = find_roblox()
    if not h:
        return True
    fg = user32.GetForegroundWindow()
    return user32.GetAncestor(fg, 2) == user32.GetAncestor(h, 2)


def focus_roblox():
    h = find_roblox()
    if not h:
        return
    try:
        root = user32.GetAncestor(h, 2)
        user32.ShowWindow(root, 9) if user32.IsIconic(root) else None
        user32.SetForegroundWindow(root)
        if root != h:
            t_rb = user32.GetWindowThreadProcessId(h, None)
            t_me = kernel32.GetCurrentThreadId()
            user32.AttachThreadInput(t_me, t_rb, True)
            user32.SetFocus(h)
            user32.AttachThreadInput(t_me, t_rb, False)
    except Exception:
        pass


def boost_thread():
    try:
        k = ctypes.windll.kernel32
        k.GetCurrentThread.restype = wintypes.HANDLE
        k.SetThreadPriority.argtypes = [wintypes.HANDLE, ctypes.c_int]
        k.SetThreadPriority(k.GetCurrentThread(), 2)
    except Exception:
        pass


class Dock:
    """Puts a window (Roblox by default, or any window the user picks) inside the middle panel WITHOUT making it a child.

    Many programs ignore keys and mouse when they are a child window (it is never the foreground window). So the target
    stays a real top-level window: borderless, OWNED by this app (always drawn above it, minimised with it) and kept exactly
    on top of the panel by a small follower thread. What we change (style, extended style, owner, rectangle, maximised or
    minimised state) is saved first and put back by undock()."""
    GWL_STYLE = -16
    GWL_EXSTYLE = -20
    GWLP_HWNDPARENT = -8                 # sets the OWNER of a top-level window
    CLEAR_STYLE = 0x00C00000 | 0x00040000 | 0x00080000 | 0x00020000 | 0x00010000     # caption, size frame, menu, min, max
    SW_MAXIMIZE, SW_MINIMIZE, SW_RESTORE = 3, 6, 9

    def __init__(self, log=None):
        self.hwnd = 0
        self.par = 0
        self.orig = None
        self.rel = None                  # panel rectangle inside the app window (client pixels)
        self.applied = None
        self.log = log or (lambda msg, kind="info": None)
        self.fit_roblox = False          # the docked window is Roblox -> fit it to fit_fn()'s aspect ratio
        self.fit_fn = None               # returns width/height to fit to (0 = fill the whole panel)
        self.err = ""                    # why the last dock() failed (already logged)
        self.closed = 0                  # how many docked windows vanished by themselves (the UI watches this)
        self._title = ""
        self.lock = threading.RLock()
        atexit.register(self.undock)     # never leave a program borderless and owned by a window that is gone

    @property
    def docked(self):
        return bool(self.hwnd) and bool(user32.IsWindow(self.hwnd))

    @property
    def title(self):
        if not self.docked:
            return ""
        t = ctypes.create_unicode_buffer(256)
        user32.GetWindowTextW(self.hwnd, t, 256)
        if t.value.strip():
            self._title = t.value.strip()
        return self._title

    def parent_hwnd(self):
        """Our own app window. Matching by title alone can pick the console window the .bat names the same."""
        found = []
        pid = os.getpid()

        def cb(h, l):
            if user32.IsWindowVisible(h):
                p = wintypes.DWORD(0)
                user32.GetWindowThreadProcessId(h, ctypes.byref(p))
                if p.value == pid:
                    t = ctypes.create_unicode_buffer(256)
                    user32.GetWindowTextW(h, t, 256)
                    if t.value == APP_TITLE:
                        found.append(h)
                        return False
            return True
        user32.EnumWindows(WNDENUMPROC(cb), 0)
        return found[0] if found else 0

    def _screen_rect(self):
        if not self.rel or not self.par:
            return None
        pt = wintypes.POINT(int(self.rel[0]), int(self.rel[1]))
        user32.ClientToScreen(self.par, ctypes.byref(pt))
        w, h = max(100, int(self.rel[2])), max(100, int(self.rel[3]))
        # never let the docked window spill outside the app window's client area
        cr = wintypes.RECT()
        if user32.GetClientRect(self.par, ctypes.byref(cr)):
            org = wintypes.POINT(0, 0)
            user32.ClientToScreen(self.par, ctypes.byref(org))
            w = max(100, min(w, org.x + cr.right - pt.x))
            h = max(100, min(h, org.y + cr.bottom - pt.y))
        x, y = pt.x, pt.y
        aspect = 0.0
        if self.fit_roblox and self.fit_fn:
            try:
                aspect = float(self.fit_fn() or 0.0)
            except Exception:
                aspect = 0.0
        if aspect and w > 0 and h > 0:
            # keep the game's real shape (letterbox, centred) - a very wide/short window clips the game's own UI
            if w / float(h) > aspect:
                nw = int(h * aspect)
                x += (w - nw) // 2
                w = nw
            else:
                nh = int(w / aspect)
                y += (h - nh) // 2
                h = nh
        return (x, y, w, h)

    def _apply(self, force=False):
        with self.lock:
            hw = self.hwnd
            if not hw or user32.IsIconic(self.par):
                return
            r = self._screen_rect()
            if not r or (r == self.applied and not force):
                return
            flags = 0x0004 | 0x0010                      # NOZORDER | NOACTIVATE (never steal focus)
            if force:
                flags |= 0x0020 | 0x0040                 # FRAMECHANGED | SHOWWINDOW
            user32.SetWindowPos(hw, 0, r[0], r[1], r[2], r[3], flags)
            self.applied = r

    def _follow(self, target):
        while self.hwnd == target:
            if not user32.IsWindow(target):
                self._gone(target)
                return
            try:
                self._apply()
            except Exception:
                pass
            time.sleep(0.03)

    def _gone(self, target):
        """The docked window closed by itself: forget it, tell the UI (poll.dock_closed) and the log."""
        with self.lock:
            if self.hwnd != target:
                return
            title = self._title
            self.hwnd = 0
            self.par = 0
            self.orig = None
            self.applied = None
            self.closed += 1
        self.log("Docked window closed, undocked: %s" % (title or "window"), "info")

    def dock(self, rect, hwnd=None):
        """Dock `hwnd` (None = the Roblox window). True when the window now sits in the panel."""
        with self.lock:
            self.err = ""
            tgt = int(hwnd) if hwnd else find_roblox()
            par = self.parent_hwnd()
            if not tgt or not par or not user32.IsWindow(tgt):
                return False
            if tgt == par or _win_pid(tgt) == os.getpid():
                self.err = "Can't dock the macro's own window"
                self.log(self.err, "warn")
                return False
            if self.docked:
                if self.hwnd == tgt:
                    self.move(rect)
                    return True
                self.undock()                        # switching to another window: put the old one back first
            return self._dock_new(tgt, par, rect)

    def _dock_new(self, tgt, par, rect):
        t = ctypes.create_unicode_buffer(256)
        user32.GetWindowTextW(tgt, t, 256)
        title = t.value.strip() or "window"
        was_max = bool(user32.IsZoomed(tgt))
        was_min = bool(user32.IsIconic(tgt))
        # a maximised or minimised window must be a normal one first, or it docks at the wrong size
        user32.ShowWindow(tgt, self.SW_RESTORE)
        if user32.IsZoomed(tgt):                     # minimised-from-maximised comes back maximised: restore once more
            was_max = True
            user32.ShowWindow(tgt, self.SW_RESTORE)
        r = wintypes.RECT()
        user32.GetWindowRect(tgt, ctypes.byref(r))
        style = _get_long(tgt, self.GWL_STYLE) & 0xFFFFFFFF
        exstyle = _get_long(tgt, self.GWL_EXSTYLE) & 0xFFFFFFFF
        owner = _get_long(tgt, self.GWLP_HWNDPARENT)
        orig = (style, exstyle, owner, r.left, r.top, r.right - r.left, r.bottom - r.top, was_max, was_min)
        # borderless popup (no title bar / frame / min / max / system menu), no taskbar button, owned by the app
        # Also add WS_EX_NOACTIVATE (0x08000000) to prevent Roblox from stealing focus from popups
        new = ((style & ~self.CLEAR_STYLE) | 0x80000000 | 0x10000000) & 0xFFFFFFFF
        new_ex = (exstyle & ~0x00040000 | 0x08000000) & 0xFFFFFFFF  # Remove topmost, add noactivate
        errs = [_set_long(tgt, self.GWL_STYLE, new),
                _set_long(tgt, self.GWL_EXSTYLE, new_ex),
                _set_long(tgt, self.GWLP_HWNDPARENT, par)]
        code = next((c for c in errs if c), 0)
        # read it back: a window of a program running as administrator silently ignores a normal program's changes
        if (_get_long(tgt, self.GWL_STYLE) & self.CLEAR_STYLE) != 0 or _get_long(tgt, self.GWLP_HWNDPARENT) != par:
            self._restore(tgt, orig)
            if _proc_elevated(_win_pid(tgt)) is False:
                self.err = "Can't dock %s: Windows refused the change (error %s). The program may protect its own window." % (title, code)
            else:
                self.err = "Can't dock %s: it's running as administrator. Run the macro as administrator too." % title
            self.log(self.err, "err")
            return False
        self.orig, self.hwnd, self.par, self._title = orig, tgt, par, title
        self.fit_roblox = (tgt == find_roblox())
        self.rel = tuple(int(v) for v in rect) if rect else (0, 0, 800, 450)
        self.applied = None
        self._apply(True)
        threading.Thread(target=self._follow, args=(tgt,), daemon=True, name="td-dock-follow").start()
        return True

    def _restore(self, tgt, orig):
        """Put a window back exactly as we found it."""
        st, ex, owner, x, y, w, h, was_max, was_min = orig
        _set_long(tgt, self.GWLP_HWNDPARENT, owner)
        _set_long(tgt, self.GWL_STYLE, st)
        _set_long(tgt, self.GWL_EXSTYLE, ex)
        user32.SetWindowPos(tgt, 0, x, y, w, h, 0x0004 | 0x0010 | 0x0020 | 0x0040)
        if was_max:
            user32.ShowWindow(tgt, self.SW_MAXIMIZE)
        elif was_min:
            user32.ShowWindow(tgt, self.SW_MINIMIZE)

    def move(self, rect):
        if self.docked and rect:
            self.rel = tuple(int(v) for v in rect)
            self._apply()

    def undock(self):
        with self.lock:
            tgt, orig = self.hwnd, self.orig
            self.hwnd = 0                     # stops the follower thread
            self.par = 0
            self.orig = None
            self.applied = None
            if not tgt or not orig or not user32.IsWindow(tgt):
                return
            try:
                self._restore(tgt, orig)
            except Exception:
                pass


# ----------------------------------------------------------------------
#  Embedded image templates (your screenshots)
# ----------------------------------------------------------------------
TEMPLATES = {
    "e_prompt": "iVBORw0KGgoAAAANSUhEUgAAADEAAAAsCAAAAADpvw+FAAABYUlEQVRIDZXBwWoTURTH4d8/moKoAQ2mECwqI0m6cpNptG6Egl344sIBUVQ45wV8AFcFoXUzc89Abxb3+xQ0UtBIQSMFjRQ0UtBIQbr5esuM+x68W1AoSD+/U3expVCQzKk7bCgUJHPqDhsKBcmcusOGQkEyp+6woVCQzKm72FIoSOYUYvQQPryiUJDMGZz1j0l/n4pCQTJn8OU5xyhI5gzedzOOUJDMGcxXS0aLl3MmFCRzKuZ9x4SCZE7NrmdCQTKnZtczoSCZU7PrmVCQzKk53zOhIJlTc75nQkEyp2K57ZhQkMwZrN4+YzR/IiYUJHMG/Y5jFCRzBp9POUZBMmfw8fWMIxQkcwYn6xeM7rh784hCQTKnrrukUJDMqVtfUShI5tStrikUJHPqVtcUCpI5desrCgXp22/qzj5RKEi/ftxSM+/2YqQg/ftzQs3NckGhoJGCRgoaKWikoJGCRv8B/1Zreelxps8AAAAASUVORK5CYII=",
    "loaded": "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",
    "ready_a": "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",
    "search_maps": "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",
    "ready_b": "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",
    "play_again": "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",
    "restart": "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",
    "coin_icon": "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",
    "xp_icon": "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",
}


# ----------------------------------------------------------------------
#  Image matching
# ----------------------------------------------------------------------
# "Place / Rotate / Cancel" hint box shown while a tower is equipped (cut from a 1209px-high Roblox window).
TEMPLATES["place_hint"] = "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"
TEMPLATES["veto_text"] = "iVBORw0KGgoAAAANSUhEUgAAAUIAAAASCAAAAAALP4gDAAACtklEQVRYCd3BAYocVwJEwXj3P3S6fnW1PYJtS5hZEIrIL5v8H0x+d5OP8quGfLshv7chn+RXDflg5BeM/GDI/zbyGxjySX7Z5JORnxvyo8kHQ34Dk48aeRn5b0Z+bsjPjTDkO418NPLVyL8aDTmG/DcjP7EM+bkRhizfZuSjka9G/tVoLmEuMYR5yWPEXPIYwsgcYchlyDH/CCPHaGjkZYh55DLkb0OMMJqjkeUyYl5iyMscYQhDLkMYwshlhKERo7mEuWRumbfcRubIy9wyMkfMLXOL+SJGbqN55Jgj8xZzy8vcGmE0R3PE3Jof5TZHzK05Ym7NESPmlnnENEfmyLw0b7mN5paXeWlkjsyjecnIvMTIbTRvucyRIUPmkWP+EUZzNEfmg9zmyPwg5qsYmUfzlmm+yjE0xJDL0JAfDI0MMW+5DA0xNDJyGw0xcowwxGjechlyDDEaYoj5KkYjjyGGmFveRiOX0RDzEiPTfBVza4ghx8gcecytkRHmLXNriKG55WU0wsgxwhCjectlyDHEaIQR5oswGnmMMMTccsytkcto5DJHGJmGhobm0RBDjpFj5JhHIyMMOeaREUPmyMtoiJFjhCFGQ/425BhiNMIIQ44RRiOPEYaYW5hHI5fREHMLI9OQydDQ0LzlNjK3HCNDIyOXuWVkyLxlLnmMRhg55pIRRuaWl3k0j0YYucwtI4zmktvIZR7NJSNGc4mReTTCaDRkMjSP5i230dxym0cjI8fcmkfMI0beRiOM3ObSCCPmlpe5ZR6NMHLMrRFG5pJj5JhbzCXzkrlkxNwywmg05BhiNJqXPEYMeRuNRkZeRi6jkctkxMjbaISRl6ERRi4j/xg5pqERRl6GjDBiyDFym0suQ4xGDBm5jDDCyOSTId9vjvwx8smQ7zeX/DnyyZDvN+QP8heR640XRAwgDAAAAABJRU5ErkJggg=="   # "Map is already in the current rotation!" - letters only (binary mask, no background)
TEMPLATES["veto_btn"] = "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"
TEMPLATES["veto_btn2"] = "iVBORw0KGgoAAAANSUhEUgAAAGYAAAAtCAAAAAB5K0ERAAAFeUlEQVRYCb3BfUzU9x3A8ffn7n73wIMIIogi2LrMYNtkXSiIhDWzXNtks+p1GW42m7HZapMt9iH57h+jbba1e0jUpWnWJa7N1rSbW2tttnS2d5oYqwihD8lqsa1PnKfAAcqAg7v73e++48cO+FHI/iL3eokiH0SRD6LIB1HkgyjyQRT5IIp8EEU+iCIfROEkaBwEzaIQhUPtlu6TFjPcm+re7mExiGJWzbaq9JkTGXI89zV7e9+KsghEMaMmtEIwz4ZNphjBjQa672gUp2RKY5MCAzDHNTYp9PD/iGJa7dYqAW22h00mGcEmQ0D3HuvBYfhSBptUV7qx+mMam+9OD5NGe5iyqpS5RJFTsrNKsCXPRUwwWjf4sekbL2hmWZ8kNLay1UWMxm5ic1WsxXbrAlNur2QuUeS4N7X4sOlkZ9g0gg1+wZY6HdE4XLuRwWbUVur+ngw277olTErEbzClfIWnECdRTHO3tngE20RnV31DAJvOnI5YOCXPZ/9wu/tfr11dsUrH4tWPfHvi1HMl68w0Xu9noya74EjC4ymog0zKcvs82EQxw3N/kxebNk3DEGzp9vcyzKEvDn6/rXT41+8HVutrqfp9S4f2flJgJQHvsNvH+xCKQ9H6wfh4FlwFFeUGiGKWEWz0CQ461RE2+ZLhiyUH1vCXN+PlDC4P7Uh/9HhyqQtbn1VUfBZCcXAVJDRTpLCmFFE4GK2NARwmOiImX2ZdGPnpA0su/77dS7r+ydr4wb8H7trRWDrefexv6af3YHv5xfFlZW3N1Vw/c2QI/5plonAygg1+IUcnO8Mm8/XGvvKztRw+OkLJ5t3W+e2ptmcNbG88/cST2A4/7/rWL4qwje3rxF8nijmMYJOXnHR72GQByS9G97YUfPDnD/jao3cPvPLSnUc9XDy/qh72xr75Qzg+Hnln7T8DDHdkN5SS3BV1LxPFXBW7C8lJvBRnQVf7N/7ottThN1wP/cTV/Wj8xQc5+UyW7zzBlXuJQqivzzq0jc/3jFJ44A7e/Tl+UcxhBJu85KTbwyYLGbls7Wt2n3rV9cg3bv3jGeNcKYPj4FkJd4xGIRQbyH64jKc6RXT9QW5txisKJyPY4BdydLIzbLKA7MWhzdtX3/yT9Vjxp79qL/hYmPb1wSiEokPZq8LD/WVLRow3se7FEIWD0doYwGGiI2KygIFosWqiO3NXIvL8SPHxUh7/N7ZknCiEYgPWh+U81Smi7znA0Ba8ophlBBt9goNOdYRN5ktfGt4RWg589seOkcL9QbpUmsB3X0v0c8lg14W+zMGH+XzPKIWH6njnOfyimOG5v8mLTZumYQi2dPt7GeaL9a7Z3QCZyG+NbLLmFYOBrmxjeXj/dX18PbGPe39Z826A4XN6QykTO6+7y0Uxzd3a4hFsE51d9Q0BbDpzOmIxz9iV0ce2FnH59eNlq75Ibnw2gK3vx93ptt8Aow3jrYeKsY3t7SJQJ4oc96YWHzad7AybRrDBL9hSpyOaeS4M3fODuznxu1vlXx3oSVV+r2El1079dSyRWLple23qo/1XjHVtzdXEzhy5if+2MlHklOysEmzJcxETjNYNfmz6xguaeS7HLSaJv6qKwWvj/I+ryJXIaMCVEZdmihTWlCKKabVbqwS02R42mWQEmwwB3Xush/msKzc14K1cCaQHBiay4CqsWO7u7Tc1sqTaOxgfz4KroKLcAFHMqAmtEMyzYZMpRnCjge47GmUhyZQG3H6DKWbacvkMbBNpj8/DpEzKcvs82EQxq2ZbVfrMiQw5nvuavb1vRVkEonCo3frpSYsZ7k3rj/WwGEThVDJm4eAu+g+LQhT5IIp8EEU+iCIfRJEPosgHUeSDKPJBFPnwX8fkJKg4/tTCAAAAAElFTkSuQmCC"
# 2x speed templates (arrow button and 2x button)
TEMPLATES["speed_arrow"] = ""  # Placeholder - user will need to provide image
TEMPLATES["speed_2x"] = ""     # Placeholder - user will need to provide image
USER_TPLS = set()          # images the player snipped themselves: captured at the size they have on screen, not at 1440p
TPL_GEN = [0]              # bumped whenever templates are (re)loaded so cached resized copies are never stale
DEEP_SCALES = tuple(round(0.50 + 0.03 * i, 2) for i in range(37))   # 0.50 .. 1.58: wide fallback sweep tried for EVERY image
DEEP_GAP = 1.0             # the wide sweep runs at most once per second per image, so the 24/7 watchers stay light
TPL_REF_H = {"place_hint": 1209.0, "veto_btn": 1080.0, "veto_btn2": 860.0}   # veto_btn2 = the X + "Veto" part of the button as it looks in this game version, cut from a 1376x860 window       # window height a template was captured at (default: REF_HEIGHT)
PLACE_HINT_THR = 0.60
TPL_THR = {                                # per-template minimum threshold (overrides the global cfg["threshold"])
    "e_prompt": 0.72,
    "loaded": 0.70,
    "ready_a": 0.68, "ready_b": 0.68,
    "search_maps": 0.66,
    "play_again": 0.58,
    "restart": 0.58,
    "coin_icon": 0.65, "xp_icon": 0.65,
    "place_hint": 0.60,
    "veto_btn": 0.65,
    "veto_btn2": 0.65,
    # 2x speed templates
    "speed_arrow": 0.70,
    "speed_2x": 0.70,
    # new recovery templates (loaded from Diamond/images/*.png alongside embedded ones)
    "leave_btn": 0.78,
    "play_triangle": 0.55,
    "play_green": 0.60,
    "mode_easy": 0.62,
    "mode_casual": 0.62,
    "mode_intermediate": 0.62,
    "mode_molten": 0.62,
    "mode_fallen": 0.62,
    "mode_frost": 0.62,
    "solo_btn": 0.60,
}

TPL_BASE = {}


def _images_dir():
    bases = []
    if getattr(sys, "frozen", False):
        bases += [os.path.dirname(sys.executable), getattr(sys, "_MEIPASS", "")]   # next to the exe wins, then the baked-in copy
    else:
        try:
            bases.append(os.path.dirname(os.path.abspath(sys.argv[0])))
        except Exception:
            pass
        bases.append(os.getcwd())
    for b in bases:
        p = os.path.join(b, "images") if b else ""
        if p and os.path.isdir(p):
            return p
    return None


def load_templates():
    global TPL_BASE
    for k, b in TEMPLATES.items():
        arr = np.frombuffer(base64.b64decode(b), dtype=np.uint8)
        TPL_BASE[k] = cv2.imdecode(arr, cv2.IMREAD_GRAYSCALE)
    # Also load any PNGs from the images/ folder (filename without extension = template key)
    # e.g. images/leave_btn.png becomes TPL_BASE["leave_btn"]
    d = _images_dir()
    if d:
        try:
            for fn in os.listdir(d):
                if not fn.lower().endswith(".png"):
                    continue
                key = fn[:-4]
                try:
                    full = os.path.join(d, fn)
                    tpl = cv2.imread(full, cv2.IMREAD_GRAYSCALE)
                    if tpl is not None and tpl.size:
                        TPL_BASE[key] = tpl
                except Exception:
                    pass
        except Exception:
            pass


def _load_profile_images(pid):
    """Load a profile's snipped images into TPL_BASE so wait_image() can find them."""
    global TPL_BASE
    d = os.path.join(DATA_DIR, "profiles", pid, "images")
    if not os.path.isdir(d):
        return
    loaded = 0
    for fn in os.listdir(d):
        if not fn.lower().endswith(".png"):
            continue
        key = fn[:-4]
        try:
            tpl = cv2.imread(os.path.join(d, fn), cv2.IMREAD_GRAYSCALE)
            if tpl is not None and tpl.size:
                TPL_BASE[key] = tpl
                USER_TPLS.add(key)
                loaded += 1
        except Exception:
            pass
    TPL_GEN[0] += 1
    if loaded:
        file_log("Profile images loaded: %d from '%s'" % (loaded, pid), "info")


def match(gray, tpl, thr):
    # returns (center_x, center_y, score) in gray coordinates, or None
    th, tw = tpl.shape[:2]
    H, W = gray.shape[:2]
    if H < th or W < tw:
        return None
    if H * W > 600000 and min(th, tw) >= 20:
        sg = cv2.resize(gray, (W // 2, H // 2), interpolation=cv2.INTER_AREA)
        st = cv2.resize(tpl, (max(1, tw // 2), max(1, th // 2)), interpolation=cv2.INTER_AREA)
        r = cv2.matchTemplate(sg, st, cv2.TM_CCOEFF_NORMED)
        _, mx, _, ml = cv2.minMaxLoc(r)
        if mx < min(COARSE_GATE, thr - 0.08):
            return None
        x0 = max(0, ml[0] * 2 - 6)
        y0 = max(0, ml[1] * 2 - 6)
        roi = gray[y0:y0 + th + 12, x0:x0 + tw + 12]
        if roi.shape[0] < th or roi.shape[1] < tw:
            return None
        r2 = cv2.matchTemplate(roi, tpl, cv2.TM_CCOEFF_NORMED)
        _, mx2, _, ml2 = cv2.minMaxLoc(r2)
        if mx2 >= thr:
            return (x0 + ml2[0] + tw // 2, y0 + ml2[1] + th // 2, float(mx2))
        return None
    r = cv2.matchTemplate(gray, tpl, cv2.TM_CCOEFF_NORMED)
    _, mx, _, ml = cv2.minMaxLoc(r)
    if mx >= thr:
        return (ml[0] + tw // 2, ml[1] + th // 2, float(mx))
    return None


def best_score(gray, tpl):
    if gray.shape[0] < tpl.shape[0] or gray.shape[1] < tpl.shape[1]:
        return 0.0
    r = cv2.matchTemplate(gray, tpl, cv2.TM_CCOEFF_NORMED)
    v = float(cv2.minMaxLoc(r)[1])
    return v if v == v else 0.0


class Grabber:
    def __init__(self):
        import mss
        self.sct = mss.mss()

    def get(self, reg):
        return np.asarray(self.sct.grab(reg))

    def close(self):
        try:
            self.sct.close()
        except Exception:
            pass


def ocr_digits(img_gray):
    # Windows built-in OCR (needs the 'winsdk' package). Returns text or "".
    result = [""]

    def work():
        try:
            import asyncio
            from winsdk.windows.media.ocr import OcrEngine
            from winsdk.windows.globalization import Language
            from winsdk.windows.graphics.imaging import SoftwareBitmap, BitmapPixelFormat
            from winsdk.windows.storage.streams import DataWriter
            eng = OcrEngine.try_create_from_user_profile_languages()
            if eng is None:
                eng = OcrEngine.try_create_from_language(Language("en-US"))
            if eng is None:
                file_log("OCR engine not available, falling back to pixel-based detection", "warn")
                return
            bgra = cv2.cvtColor(img_gray, cv2.COLOR_GRAY2BGRA)
            h, w = bgra.shape[:2]
            dw = DataWriter()
            dw.write_bytes(bgra.tobytes())
            sb = SoftwareBitmap.create_copy_from_buffer(dw.detach_buffer(), BitmapPixelFormat.BGRA8, w, h)

            async def go():
                res = await eng.recognize_async(sb)
                return res.text
            result[0] = asyncio.run(go()) or ""
        except ImportError:
            file_log("winsdk not installed, OCR unavailable", "warn")
            result[0] = ""
        except Exception as e:
            file_log("OCR failed with fallback: %s, will use pixel detection" % e, "warn")
            result[0] = ""
    
    t = threading.Thread(target=work, daemon=True)
    t.start()
    t.join(2.0)  # Wait up to 2 seconds for OCR
    
    # Fallback: if OCR failed, try simple pixel-based digit detection
    if not result[0]:
        try:
            # Simple threshold-based digit detection as fallback
            _, thresh = cv2.threshold(img_gray, 128, 255, cv2.THRESH_BINARY_INV)
            contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            digit_count = sum(1 for c in contours if cv2.contourArea(c) > 50)
            result[0] = str(digit_count) if digit_count > 0 else ""
            if result[0]:
                file_log("Using pixel-based digit detection fallback: %s" % result[0], "info")
        except Exception:
            pass
    
    return result[0]
    t = threading.Thread(target=work, daemon=True)
    t.start()
    t.join(8)
    return result[0]


OCR_UP = {"ok": None}      # None = not tried yet, True/False = Windows OCR works / is unavailable


def ocr_text(img_gray):
    """Windows OCR of a grayscale image (needs winsdk). Returns the text, or "" - and records whether OCR exists at all."""
    result = [""]

    def work():
        try:
            import asyncio
            from winsdk.windows.media.ocr import OcrEngine
            from winsdk.windows.globalization import Language
            from winsdk.windows.graphics.imaging import SoftwareBitmap, BitmapPixelFormat
            from winsdk.windows.storage.streams import DataWriter
            eng = OcrEngine.try_create_from_user_profile_languages()
            if eng is None:
                eng = OcrEngine.try_create_from_language(Language("en-US"))
            if eng is None:
                OCR_UP["ok"] = False
                file_log("OCR engine not available for text", "warn")
                return
            OCR_UP["ok"] = True
            bgra = cv2.cvtColor(img_gray, cv2.COLOR_GRAY2BGRA)
            h, w = bgra.shape[:2]
            dw = DataWriter()
            dw.write_bytes(bgra.tobytes())
            sb = SoftwareBitmap.create_copy_from_buffer(dw.detach_buffer(), BitmapPixelFormat.BGRA8, w, h)

            async def go():
                res = await eng.recognize_async(sb)
                return res.text
            result[0] = asyncio.run(go()) or ""
        except ImportError:
            OCR_UP["ok"] = False
            file_log("winsdk not installed for text OCR", "warn")
        except Exception as e:
            file_log("Text OCR failed: %s" % e, "warn")
            result[0] = ""
    t = threading.Thread(target=work, daemon=True)
    t.start()
    t.join(6)
    return result[0]


def ultimate_ocr_filter(bgr):
    """Ultimate Macro's colour matrix: R' = 5R-2.5, G' = 1-5G, B' = 1-5B (0..1). Pure red text goes white, everything else dark/cyan."""
    f = bgr.astype(np.float32) / 255.0
    b, g, r = f[:, :, 0], f[:, :, 1], f[:, :, 2]
    out = np.dstack([np.clip(1 - 5 * b, 0, 1), np.clip(1 - 5 * g, 0, 1), np.clip(5 * r - 2.5, 0, 1)])
    return cv2.cvtColor((out * 255).astype(np.uint8), cv2.COLOR_BGR2GRAY)


# ----------------------------------------------------------------------
#  Engine
# ----------------------------------------------------------------------
class StopRun(Exception):
    pass


class PlayAgainSeen(Exception):
    pass


class VetoSeen(Exception):
    pass


class MapFailed(Exception):
    pass


class RecoveryNeeded(Exception):
    pass


def merge(base, over):
    out = json.loads(json.dumps(base))
    for k, v in (over or {}).items():
        if isinstance(v, dict) and isinstance(out.get(k), dict):
            out[k] = merge(out[k], v)
        else:
            out[k] = v
    return out


def clean_name(s):
    s = re.sub(r'[\\/:*?"<>|]+', "", str(s or "")).strip()
    return s[:60]


def _num(v, default, lo, hi, cast=float):
    """Coerce v to a number inside [lo, hi]; fall back to default if it is not a number at all."""
    try:
        x = cast(float(v))
    except (TypeError, ValueError, OverflowError):
        return default
    if x != x:                      # NaN
        return default
    return max(lo, min(hi, x))


def sanitize_cfg(c):
    """Repair every user-editable setting in place so a typo can't break a run. Returns [(key, old, new)]."""
    fixed = []

    def fix(key, value):
        if c.get(key) != value:
            fixed.append((key, c.get(key), value))
            c[key] = value

    fix("threshold", _num(c.get("threshold"), DEFAULTS["threshold"], 0.30, 0.99))
    fix("reward_delay", _num(c.get("reward_delay"), DEFAULTS["reward_delay"], 0.0, 30.0))
    fix("step_timeout", _num(c.get("step_timeout"), DEFAULTS["step_timeout"], 1, 600, int))
    fix("restart_wait", _num(c.get("restart_wait"), DEFAULTS["restart_wait"], 0.0, 120.0))
    fix("zoom_clicks", _num(c.get("zoom_clicks"), DEFAULTS["zoom_clicks"], 0, 200, int))
    fix("restart_mode", c.get("restart_mode") if c.get("restart_mode") in ("reset", "skipwasd", "none") else "reset")
    fix("restart_key_gap", _num(c.get("restart_key_gap"), DEFAULTS["restart_key_gap"], 0.02, 3.0))
    fix("restart_reset_wait", _num(c.get("restart_reset_wait"), DEFAULTS["restart_reset_wait"], 0.0, 60.0))
    fix("skip_intro", bool(c.get("skip_intro", False)))
    fix("disable_watcher", bool(c.get("disable_watcher", False)))
    for k in ("search_x", "search_y", "map_x", "map_y", "ready_x", "ready_y", "veto_x", "veto_y",
              "vpx_x", "vpx_y", "gpx_x", "gpx_y", "restart_px_x", "restart_px_y",
              "ready_px_x", "ready_px_y", "play_again_px_x", "play_again_px_y"):
        fix(k, round(_num(c.get(k), 0.0, 0.0, 100.0), 2))
    # Validate learned colors (keep as-is if valid tuple, else None)
    for px_name in ("restart_px", "ready_px", "play_again_px"):
        col = c.get(px_name + "_color")
        if col and (isinstance(col, (list, tuple)) and len(col) == 3 and all(isinstance(x, int) and 0 <= x <= 255 for x in col)):
            fix(px_name + "_color", tuple(col))
        else:
            fix(px_name + "_color", None)
    fix("px_tol", _num(c.get("px_tol"), DEFAULTS["px_tol"], 0, 120, int))
    fix("nudge_radius", _num(c.get("nudge_radius"), 45, 3, 150, int))
    fix("nudge_px", _num(c.get("nudge_px"), 10, 0, 100, int))
    fix("menu_delay", _num(c.get("menu_delay"), DEFAULTS["menu_delay"], 0.0, 30.0))
    fix("mouse_glide", _num(c.get("mouse_glide"), DEFAULTS["mouse_glide"], 0.0, 2.0))
    fix("slot_wait", _num(c.get("slot_wait"), DEFAULTS["slot_wait"], 0.0, 5.0))
    fix("jiggle_px", _num(c.get("jiggle_px"), DEFAULTS["jiggle_px"], 1, 50, int))
    fix("maho", bool(c.get("maho", True)))
    fix("auto_rejoin", bool(c.get("auto_rejoin", False)))
    fix("adaption", bool(c.get("adaption", True)))
    fix("loop_rec", bool(c.get("loop_rec", False)))
    fix("intro_mode", "classic" if str(c.get("intro_mode", "new")).lower() == "classic" else "new")
    fix("wiggle_all", bool(c.get("wiggle_all", True)))
    fix("game_coins", _num(c.get("game_coins"), 0, 0, 10 ** 9, int))
    fix("game_xp", _num(c.get("game_xp"), 0, 0, 10 ** 9, int))
    fix("loop_replace", bool(c.get("loop_replace", False)))
    fix("place_settle", _num(c.get("place_settle"), DEFAULTS["place_settle"], 0.0, 3.0))
    fix("place_retries", _num(c.get("place_retries"), DEFAULTS["place_retries"], 0, 10, int))
    fix("retry_wait", _num(c.get("retry_wait"), DEFAULTS["retry_wait"], 0.0, 10.0))
    fix("move_hold_extra", _num(c.get("move_hold_extra"), DEFAULTS["move_hold_extra"], 0.0, 2.0))
    fix("jiggle_step", _num(c.get("jiggle_step"), DEFAULTS["jiggle_step"], 0.01, 0.5))
    fix("cam_drag", _num(c.get("cam_drag"), DEFAULTS["cam_drag"], 0, 3000, int))
    df = str(c.get("dock_fit", "auto")).strip().lower()
    if df not in ("auto", "fill", "16:9", "16:10", "21:9", "4:3"):
        df = "auto"
    fix("dock_fit", df)
    gm = str(c.get("gamemode", DEFAULTS["gamemode"])).strip().lower()
    if gm not in GAMEMODES:
        gm = DEFAULTS["gamemode"]
    fix("gamemode", gm)
    fix("loops", _num(c.get("loops"), 0, 0, 100000, int))
    if c.get("loops_mode") not in ("inf", "num"):
        fix("loops_mode", "inf")
    fix("map", str(c.get("map", "")).strip()[:64])
    res = str(c.get("resolution", "auto"))
    if res != "auto" and not re.match(r"^\d{3,5}x\d{3,5}$", res):
        fix("resolution", "auto")
    scale = str(c.get("ui_scale", "auto")).strip().lower()
    if scale != "auto":
        try:
            ok = 0.25 <= float(scale) <= 4.0
        except ValueError:
            ok = False
        if not ok:
            fix("ui_scale", "auto")
    z = c.get("zone")
    if not isinstance(z, dict):
        z = {}
    for k in ("x1", "y1", "x2", "y2"):
        z[k] = _num(z.get(k), DEFAULTS["zone"][k], -32768, 32767, int)
    c["zone"] = z
    t = c.get("totals")
    if not isinstance(t, dict):
        t = {}
    for k in ("coins", "xp", "runs"):
        t[k] = _num(t.get(k), 0, 0, 10 ** 15, int)
    c["totals"] = t
    used = set()
    for k in ("hk_start", "hk_stop", "hk_record", "hk_pick_color", "hk_switch_profile", "hk_reload_templates"):
        v = str(c.get(k, "")).upper()
        if v not in FKEYS or v in used:
            v = DEFAULTS[k] if DEFAULTS[k] not in used else next(n for n in FKEYS if n not in used)
        used.add(v)
        fix(k, v)
    return fixed


def api_safe(default=False):
    """Wrap a method the web view calls: log the failure instead of raising into JavaScript."""
    def deco(fn):
        @functools.wraps(fn)
        def wrapper(self, *a, **kw):
            try:
                return fn(self, *a, **kw)
            except Exception as e:
                try:
                    self._e.log("UI call %s failed: %s: %s" % (fn.__name__, type(e).__name__, e), "err")
                    file_log(traceback.format_exc(), "err")
                except Exception:
                    pass
                return default
        return wrapper
    return deco


REC_KEYS = [(k, v) for k, v in VK.items()]


class Engine:
    def __init__(self):
        os.makedirs(REC_DIR, exist_ok=True)
        self.logs = []
        self.log_n = 0
        self.log_lock = threading.Lock()      # guards self.logs (UI polls it from another thread)
        self.cfg_lock = threading.RLock()     # guards self.cfg and the config file
        self.state_lock = threading.Lock()    # guards self.mode (hotkey thread vs UI thread)
        self.cfg = self._load_cfg()
        self.mode = "idle"
        self.status_text = "Idle"
        self.stop_evt = threading.Event()
        self.rec_stop = threading.Event()
        self.pa_evt = threading.Event()
        self.veto_evt = threading.Event()
        self.veto_done = threading.Event()
        self.veto_stop = threading.Event()
        self.veto_deadline = 0.0             # 0 = still selecting the map, else the time the veto watcher gives up
        self.veto_hit = None
        self.pa_pos = None
        self.pa_ignore = 0.0
        self.pa_kind = "play_again"          # what the watcher saw: "play_again" or "restart"
        self.watch_restart = False           # only look for Restart Match while the macro is running
        self.restart_pending = False         # next cycle skips the intro (a failed run was restarted)
        self.watch_pa = False
        self.wd_stop = threading.Event()
        self.tl = threading.local()
        self.tcache = {}
        self.scale_cache = [0.0, 1.0]
        self.held = set()
        self.held_btn = set()
        self.in_game = False
        self.loops = 0
        self.target = 0
        self.t_start = None
        self.s_coins = 0
        self.s_xp = 0
        self.cfg_rev = 0
        self.recs = []
        self.rec_live = {"events": 0, "elapsed": 0.0, "last": "", "keys": {}, "clicks": 0, "last_t": 0.0}
        self.dock = Dock(self.log)
        self.dock.fit_fn = self.dock_aspect
        self.rbx  = RbxHub(self.log)
        self.step_engine = StepEngine(self)
        self._active_pid = self.cfg.get("active_profile", "tds")
        _ensure_default_profile()
        self.refresh_recs()
        # ---- Lag compensation ----
        self._ping_history = []
        self._last_ping_check = 0
        # ---- Voice control ----
        self._voice_thread = None
        self._voice_stop = threading.Event()
        # ---- Heatmap tracking ----
        self._heatmap_clicks = []  # List of (x, y, timestamp) tuples
        self._heatmap_towers = []  # List of (x, y, tower_name, timestamp) tuples
        self._heatmap_run_start = 0
        # ---- Screencast recorder ----
        self._screencast_frames = []
        self._screencast_recording = False
        self._screencast_thread = None
        # ---- Account health monitor ----
        self._health_start_time = 0
        self._health_play_time = 0
        self._health_score = 100
        self._health_cooldown_until = 0
        # ---- Strategy switcher ----
        self._consecutive_failures = 0
        self._original_profile = None
        # ---- Cloud profiles (GitHub Gist) ----
        self._gist_cache = {}
        # ---- Automated upgrade system ----
        self._tower_placements = []  # List of (x, y, tower_key) tuples
        self._tower_keys_last = None  # Track which key was pressed before LMB
        # ---- Performance profiler ----
        self._perf_data = {}  # Performance data for each operation
        self._perf_enabled = bool(self.cfg.get("performance_profiler", True))
        # ---- Hot swap profiles ----
        self._hot_swap_profiles = {
            "f11": self.cfg.get("hot_swap_profile_1", ""),
            "f12": self.cfg.get("hot_swap_profile_2", "")
        }
        # ---- Tower UI caching (from TDS Macro) ----
        self._tower_ui_cache = {"x": 0, "y": 0, "timestamp": 0}
        # ---- Ability spam system ----
        self._ability_spam_active = bool(self.cfg.get("ability_spam", True))
        self._ability_spam_thread = None
        self._ability_spam_stop = threading.Event()
        # ---- Big Dick Randy mode ----
        self._bdr_active = bool(self.cfg.get("big_dick_randy_mode", False))
        self._bdr_thread = None
        self._bdr_stop = threading.Event()
        self._bdr_overlay_shown = False
        self._bdr_immediate_event = threading.Event()  # Initialize here so it exists before thread starts
        self._bdr_minigame_thread = None  # Mini-game thread
        self._bdr_popup_thread = None  # Little popups thread
        self._bdr_fake_tab_thread = None  # Fake tab thread
        self._bdr_fake_tabs = []  # Track fake tabs
        # ---- Backup system ----
        self._backup_thread = None
        self._backup_stop = threading.Event()
        # ---- Diamond Legacy system (secret) ----
        self._legacy_unlocked = bool(self.cfg.get("diamond_legacy_unlocked", False))
        self._legacy_tier = 0  # 0-5 tiers
        self._legacy_messages = []  # Secret messages from Diamond
        # ---- Randy extended features ----
        self._randy_sightings_count = 0  # Count of Randy overlay screenshots
        self._randy_case_file_entries = []  # List of unlocked lore entries
        self._randy_takeover_active = False  # Is Randy currently "hacking" the overlay?
        self._randy_original_title = None  # Original window title before takeover
        self._randy_original_scale = None  # Original scale before takeover
        # ---- Diagnostics mode ----
        self._diagnostics_enabled = bool(self.cfg.get("diagnostics_mode", False))
        self._diagnostics_last_snapshot = 0  # Timestamp of last diagnostics output
        # ---- watchdog / stall detector + disconnect watcher (borrowed from Calamity + TDS Macro) ----
        self.phase_lock = threading.Lock()
        self._phase = ""
        self._phase_since = 0.0
        self._phase_budget = 0.0
        self.watchdog_stop = threading.Event()
        self.dc_stop = threading.Event()
        self.dc_evt = threading.Event()
        self.dc_hit = None

    # ---------- dock shape ----------
    def dock_aspect(self):
        """Width/height Roblox is fitted to inside the dock panel. 0 = fill the panel.
        'auto' = the shape of your screen; or a preset like 16:9."""
        fit = str(self.cfg.get("dock_fit", "auto")).strip().lower()
        if fit == "fill":
            return 0.0
        if fit == "auto":
            sw, sh = user32.GetSystemMetrics(0), user32.GetSystemMetrics(1)
            return sw / float(sh) if sw > 0 and sh > 0 else 16.0 / 9.0
        m = re.match(r"^(\d+(?:\.\d+)?):(\d+(?:\.\d+)?)$", fit)
        if m and float(m.group(2)) > 0:
            return float(m.group(1)) / float(m.group(2))
        return 16.0 / 9.0

    def dock_info(self):
        sw, sh = user32.GetSystemMetrics(0), user32.GetSystemMetrics(1)
        a = self.dock_aspect()
        return "Screen %dx%d · fitting Roblox to %s" % (sw, sh, ("%.2f:1" % a) if a else "the whole panel")

    # ---------- config / logging ----------
    def _load_cfg(self):
        try:
            with open(CFG_PATH, "r", encoding="utf-8") as f:
                raw = json.load(f)
            if not isinstance(raw, dict):
                raise ValueError("not a JSON object")
            cfg = merge(DEFAULTS, raw)
        except FileNotFoundError:
            return merge(DEFAULTS, {})
        except Exception as e:
            # keep the unreadable file for inspection instead of silently losing the all-time totals
            try:
                os.replace(CFG_PATH, CFG_PATH + ".corrupt")
            except OSError:
                pass
            self.log("Settings file was unreadable (%s) - defaults loaded, old file kept as config.json.corrupt" % e, "warn")
            return merge(DEFAULTS, {})
        ver = cfg.get("cfg_ver", 1)
        ver = ver if isinstance(ver, int) and not isinstance(ver, bool) else 1
        if ver < 2:
            cfg["threshold"] = 0.65
        if ver < 5:
            cfg["auto_dock"] = True
        if ver < 6:
            cfg["loop_rec"] = False     # after the recording ends: just wait for Play Again / Restart, don't replay
        cfg["cfg_ver"] = 6
        for key, old, new in sanitize_cfg(cfg):
            file_log("setting %s was %r - corrected to %r" % (key, old, new), "warn")
        return cfg

    def save_cfg(self):
        with self.cfg_lock:
            try:
                os.makedirs(DATA_DIR, exist_ok=True)
                write_json_atomic(CFG_PATH, self.cfg, indent=2)
            except Exception as e:
                self.log("Could not save settings: %s" % e, "warn")

    def log(self, msg, kind="info"):
        with self.log_lock:
            self.log_n += 1
            self.logs.append({"i": self.log_n, "t": time.strftime("%H:%M:%S"), "m": msg, "k": kind})
            if len(self.logs) > 500:
                self.logs = self.logs[-300:]
        file_log(msg, kind)
        
        # Audio cues
        if self.cfg.get("audio_cues", True):
            try:
                if kind == "ok":
                    _play_beep(880, 100)  # High pitch for success
                elif kind == "err":
                    _play_beep(220, 250)  # Low pitch for error
                elif kind == "warn":
                    _play_beep(440, 150)  # Mid pitch for warning
            except Exception:
                pass
        
        # Screenshot on error
        if kind == "err" and self.cfg.get("screenshot_on_error", True):
            try:
                self._save_error_screenshot(msg)
            except Exception:
                pass
        
        if not FROZEN:                       # the exe has no console
            try:
                print("[%s] %s" % (time.strftime("%H:%M:%S"), msg))
            except Exception:
                pass

    def _save_error_screenshot(self, error_msg):
        """Save a screenshot when an error occurs"""
        try:
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            filename = f"error_{timestamp}.jpg"
            filepath = os.path.join(DATA_DIR, filename)
            
            # Capture screen
            fr = np.asarray(self.g().get(self.g().monitors[0]))
            fr = cv2.cvtColor(fr, cv2.COLOR_BGRA2BGR)
            
            # Add error text to screenshot
            cv2.putText(fr, error_msg[:50], (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
            cv2.putText(fr, timestamp, (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
            
            cv2.imwrite(filepath, fr, [cv2.IMWRITE_JPEG_QUALITY, 85])
            file_log("Error screenshot saved: %s" % filepath, "info")
        except Exception as e:
            file_log("Failed to save error screenshot: %s" % e, "warn")

    def status(self, s):
        self.status_text = s

    # ---------- helpers ----------
    def g(self):
        if not hasattr(self.tl, "g"):
            self.tl.g = Grabber()
        return self.tl.g

    def region(self):
        c = self.cfg
        if c["full_screen"] and not getattr(self, "_full_scan", False):
            rr = roblox_client_rect()          # scan only the Roblox window when it exists: faster, and ignores the macro's own UI / desktop
            if rr and rr[2] >= 200 and rr[3] >= 150:
                return {"left": rr[0], "top": rr[1], "width": rr[2], "height": rr[3]}
            vx, vy, vw, vh = virtual_screen()
            return {"left": vx, "top": vy, "width": vw, "height": vh}
        z = c["zone"]
        x1, x2 = sorted((int(z["x1"]), int(z["x2"])))
        y1, y2 = sorted((int(z["y1"]), int(z["y2"])))
        return {"left": x1, "top": y1, "width": max(40, x2 - x1 + 1), "height": max(40, y2 - y1 + 1)}

    def ui_scale(self):
        if time.time() - self.scale_cache[0] < 1.0:
            return self.scale_cache[1]
        s = self.cfg.get("ui_scale", "auto")
        if str(s).strip().lower() != "auto":
            try:
                v = float(s)
                v = v if v > 0 else 1.0
            except Exception:
                v = 1.0
        else:
            res = str(self.cfg.get("resolution", "auto"))
            m = re.match(r"^(\d+)x(\d+)$", res)
            if m:
                h = int(m.group(2))
            else:
                r = roblox_client_rect()
                h = r[3] if r else user32.GetSystemMetrics(1)
            v = h / REF_HEIGHT
            if abs(v - 1) < 0.03:
                v = 1.0
        self.scale_cache = [time.time(), v]
        return v

    def thr_for(self, name):
        """Per-template effective threshold: TPL_THR override if set, else the user's global setting."""
        base = float(self.cfg.get("threshold", DEFAULTS["threshold"]))
        return TPL_THR.get(name, base)

    def tpl(self, name, scale_mult=1.0):
        """Fetch template `name` at the current UI scale * scale_mult. Results are cached so multi-scale lookups stay fast."""
        if name in USER_TPLS:
            base = 1.0                                   # snipped on this screen: already at on-screen size
        else:
            base = self.ui_scale() * REF_HEIGHT / TPL_REF_H.get(name, REF_HEIGHT)
        sc = round(base * float(scale_mult), 3)
        key = (name, sc, TPL_GEN[0])
        if key not in self.tcache:
            t = TPL_BASE[name]
            if sc != 1.0:
                t = cv2.resize(t, (max(4, int(t.shape[1] * sc)), max(4, int(t.shape[0] * sc))), interpolation=cv2.INTER_AREA)
            self.tcache[key] = t
        return self.tcache[key]

    def _iter_tpls(self, name):
        """Yield (scale_mult, template) pairs for `name`: the size that matched last time first, then the normal
        ladder, then (at most once a second) a wide 0.5x-1.6x sweep so a window/UI size we did not expect still matches."""
        seen = set()
        mh = self.__dict__.setdefault("mult_hint", {})
        dt = self.__dict__.setdefault("_deep_t", {})
        hints = []
        h = mh.get(name)
        if h:
            hints.append(h)
        g = mh.get("*")
        if g and name not in USER_TPLS and g not in hints:
            hints.append(g)                              # every built-in image shares the window's UI size
        def one(mult):
            try:
                t = self.tpl(name, mult)
            except Exception:
                return None
            key = (t.shape[0], t.shape[1])
            if key in seen:
                return None
            seen.add(key)
            return t
        for mult in tuple(hints) + TPL_SCALES + TPL_EXTRA_SCALES.get(name, ()):
            t = one(mult)
            if t is not None:
                yield mult, t
        now = time.time()
        if now - dt.get(name, 0.0) >= DEEP_GAP:
            dt[name] = now
            mid = hints[0] if hints else 1.0
            for mult in sorted(DEEP_SCALES, key=lambda v: abs(v - mid)):
                t = one(mult)
                if t is not None:
                    yield mult, t

    def _note_hit(self, name, mult):
        mh = self.__dict__.setdefault("mult_hint", {})
        mh[name] = mult
        if name not in USER_TPLS:
            mh["*"] = mult

    def grab_gray(self):
        reg = self.region()
        fr = self.g().get(reg)
        return reg, fr, cv2.cvtColor(fr, cv2.COLOR_BGRA2GRAY)

    def find_now(self, name):
        """Find `name` on screen. Multi-scale: if the nominal size misses, try TPL_SCALES variants."""
        reg, fr, gray = self.grab_gray()
        thr = self.thr_for(name)
        best = None
        bm = None
        H, W = gray.shape[:2]
        for mult, t in self._iter_tpls(name):
            th, tw = t.shape[:2]
            if H < th or W < tw:
                continue
            m = match(gray, t, thr)
            if m and (best is None or m[2] > best[2]):
                best = (reg["left"] + m[0], reg["top"] + m[1], m[2])
                bm = mult
                if best[2] >= thr + 0.12:
                    break
        if best:
            self._note_hit(name, bm)
        return best

    def find_any(self, names):
        """Find any of the template names first. Returns (name, hit) or (None, None). Scales per name."""
        reg, fr, gray = self.grab_gray()
        H, W = gray.shape[:2]
        best = None
        best_name = None
        bm = None
        for name in names:
            thr = self.thr_for(name)
            for mult, t in self._iter_tpls(name):
                th, tw = t.shape[:2]
                if H < th or W < tw:
                    continue
                m = match(gray, t, thr)
                if m and (best is None or m[2] > best[2]):
                    best = (reg["left"] + m[0], reg["top"] + m[1], m[2])
                    best_name = name
                    bm = mult
                    if best[2] >= thr + 0.12:
                        break
            if best and best_name == name and best[2] >= self.thr_for(name) + 0.12:
                break
        if best:
            self._note_hit(best_name, bm)
        return best_name, best

    def wait_any(self, names, timeout=None):
        """wait_image for multiple names: returns (name, hit) on first match. Uses find_any each scan."""
        t0 = time.time()
        while True:
            self.check()
            t = time.perf_counter()
            name, hit = self.find_any(names)
            if hit:
                return name, hit
            if timeout and time.time() - t0 > timeout:
                return None, None
            rest = SCAN_INTERVAL - (time.perf_counter() - t)
            if rest > 0:
                self.sleep(rest)

    # ---------- stall watchdog + disconnect watcher (from TDS Macro + Calamity) ----------
    def set_phase(self, name, budget=None):
        """Mark the start of a phase. budget = seconds before watchdog kills it; None -> WATCHDOG_MULT * step_timeout."""
        step = float(self.cfg.get("step_timeout", DEFAULTS["step_timeout"]))
        b = float(budget) if budget is not None else step * WATCHDOG_MULT
        with self.phase_lock:
            self._phase = name
            self._phase_since = time.monotonic()
            self._phase_budget = b

    def clear_phase(self):
        with self.phase_lock:
            self._phase = ""
            self._phase_since = 0.0
            self._phase_budget = 0.0

    def watchdog_worker(self, stop):
        """Background watchdog: if the current phase has run > its budget, log it and raise StopRun via stop_evt."""
        import traceback as _tb
        boost_thread()
        try:
            while not stop.is_set():
                try:
                    with self.phase_lock:
                        phase = self._phase
                        since = self._phase_since
                        budget = self._phase_budget
                    if phase and budget > 0 and since > 0:
                        elapsed = time.monotonic() - since
                        if elapsed > budget:
                            self.log("WATCHDOG: phase %r stuck for %.1fs (budget %.1fs) - recovering" % (phase, elapsed, budget), "err")
                            file_log("watchdog_stall phase=%s elapsed=%.1f budget=%.1f" % (phase, elapsed, budget), "err")
                            try:
                                self.release_all()
                            except Exception:
                                pass
                            self.stop_evt.set()
                            self.dc_evt.set()
                            return
                except Exception as exc:
                    self.log("watchdog error: %s" % exc, "warn")
                    file_log("watchdog error: %s\n%s" % (exc, _tb.format_exc()), "err")
                stop.wait(min(1.0, float(self.cfg.get("step_timeout", DEFAULTS["step_timeout"])) * 0.1))
        finally:
            pass

    def start_watchdog(self):
        self.stop_watchdog()
        self.clear_phase()
        stop = threading.Event()
        self.watchdog_stop = stop
        threading.Thread(target=self.watchdog_worker, args=(stop,), daemon=True, name="td-watchdog").start()

    def stop_watchdog(self):
        self.watchdog_stop.set()

    def disconnect_worker(self, stop):
        """24/7 watcher for the Leave / Reconnect popup (image 1). When seen, fires dc_evt to trigger recovery.
        Scans every DC_INTERVAL (1s). Does NOT kill the macro - recovery loop will rejoin instead."""
        boost_thread()
        fails = 0
        dc_seen = 0
        while not stop.is_set():
            t = time.perf_counter()
            try:
                if "leave_btn" in TPL_BASE:
                    name, hit = self.find_any(("leave_btn",))
                else:
                    # fallback for people who haven't added the new PNG yet
                    name, hit = self.find_any(("disconnected", "disconnected2")) if "disconnected" in TPL_BASE else (None, None)
                dc_seen = dc_seen + 1 if hit else 0
                if hit and dc_seen < 3:
                    pass            # a real disconnect popup stays up: it must be seen 3 scans in a row (~3s), a flicker / lookalike is ignored
                elif hit:
                    self.dc_hit = hit
                    self.dc_evt.set()
                    self.log("Leave/Disconnect dialog detected (match score %.2f) - queueing auto-rejoin recovery" % hit[2], "err")
                    file_log("leave_btn detected hit=%s" % (hit,), "err")
                    try:
                        self.release_all()
                    except Exception:
                        pass
                    # Note: we deliberately DO NOT call self.stop_evt.set() here.
                    # The macro's main loop catches RecoveryNeeded and calls do_recovery_from_leave().
                    # We just exit this worker; it gets restarted after recovery completes.
                    return
                fails = 0
            except Exception as e:
                fails += 1
                if fails == 1:
                    self.log("disconnect watcher problem (%s: %s) - retrying" % (type(e).__name__, e), "warn")
                if fails == 5 and hasattr(self.tl, "g"):
                    self.tl.g.close()
                    del self.tl.g
                time.sleep(min(1.0, DC_INTERVAL * fails))
            rest = DC_INTERVAL - (time.perf_counter() - t)
            if rest > 0:
                time.sleep(rest)
        if hasattr(self.tl, "g"):
            self.tl.g.close()
            try:
                del self.tl.g
            except Exception:
                pass

    def start_disconnect_watch(self):
        self.stop_disconnect_watch()
        if not self.cfg.get("auto_rejoin", False):
            return                      # off by default: a wrong Leave image would trigger recovery in the lobby
        self.dc_evt.clear()
        self.dc_hit = None
        stop = threading.Event()
        self.dc_stop = stop
        threading.Thread(target=self.disconnect_worker, args=(stop,), daemon=True, name="td-dc").start()

    def stop_disconnect_watch(self):
        self.dc_stop.set()

    # ---------- control flow ----------
    def check(self, pa=True):
        if self.stop_evt.is_set():
            raise StopRun()
        if self.dc_evt.is_set():
            # Leave popup was seen -> trigger recovery (don't stop the whole macro)
            raise RecoveryNeeded()
        if pa and self.watch_pa and self.pa_evt.is_set():
            raise PlayAgainSeen()
        if self.veto_evt.is_set():
            raise VetoSeen()

    def _measure_ping(self):
        """Measure ping to Roblox servers by timing a simple HTTP request."""
        try:
            import socket
            host = "gamejoin.roblox.com"
            port = 443
            t0 = time.perf_counter()
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(2.0)
            sock.connect((host, port))
            t1 = time.perf_counter()
            sock.close()
            ping_ms = (t1 - t0) * 1000
            return ping_ms
        except Exception as e:
            self.log("Ping measurement failed: %s, using default" % e, "warn")
            return 50  # Default to 50ms if measurement fails

    def _update_lag_multiplier(self):
        """Update lag multiplier based on measured ping."""
        if not bool(self.cfg.get("lag_compensation", False)):
            return
        
        # Only check ping every 60 seconds
        now = time.time()
        if now - self._last_ping_check < 60:
            return
        
        self._last_ping_check = now
        ping = self._measure_ping()
        
        # Keep last 5 measurements
        self._ping_history.append(ping)
        if len(self._ping_history) > 5:
            self._ping_history.pop(0)
        
        # Calculate average ping
        avg_ping = sum(self._ping_history) / len(self._ping_history)
        
        # Calculate multiplier: 50ms = 1.0x, 100ms = 2.0x, etc.
        multiplier = max(1.0, avg_ping / 50.0)
        
        # Cap at 4.0x (200ms = very laggy)
        multiplier = min(multiplier, 4.0)
        
        old_mult = self.cfg.get("lag_multiplier", 1.0)
        if abs(multiplier - old_mult) > 0.1:  # Only update if change is significant
            self.cfg["lag_multiplier"] = multiplier
            self.save_cfg()
            self.log("Lag compensation: ping %.0fms, multiplier %.2fx (was %.2fx)" % (avg_ping, multiplier, old_mult), "info")

    def sleep(self, sec, pa=True):
        # Update lag multiplier periodically
        self._update_lag_multiplier()
        
        # Apply lag compensation
        multiplier = self.cfg.get("lag_multiplier", 1.0) if bool(self.cfg.get("lag_compensation", False)) else 1.0
        sec = sec * multiplier
        
        # Apply humanizer delay variation
        if bool(self.cfg.get("humanizer", True)):
            delay_range = self.cfg.get("humanizer_delay_range", 0.1)
            import random
            sec += random.uniform(-delay_range, delay_range)
            sec = max(0, sec)  # Ensure non-negative
        
        end = time.perf_counter() + sec
        while True:
            self.check(pa)
            r = end - time.perf_counter()
            if r <= 0:
                return
            time.sleep(min(r, 0.01))

    def wait_image(self, name, timeout=None):
        t0 = time.time()
        image_fails = 0
        while True:
            self.check()
            t = time.perf_counter()
            hit = self.find_now(name)
            if hit:
                return hit
            if timeout and time.time() - t0 > timeout:
                return None
            
            # Graceful degradation: try pixel fallback after 5 seconds of image matching failure
            if time.time() - t0 > 5.0 and image_fails > 100:
                if name in self.cfg.get("custom_colors", {}):
                    # Try pixel-based detection as fallback
                    color_cfg = self.cfg["custom_colors"][name]
                    if "rgb" in color_cfg and "x" in color_cfg and "y" in color_cfg:
                        px_rgb = self._px_rgb_at(color_cfg["x"], color_cfg["y"])
                        if px_rgb:
                            dist = self._px_dist(px_rgb, color_cfg["rgb"])
                            if dist <= self.cfg.get("px_tol", 12):
                                self.log("Image match failed, using pixel fallback for %s" % name, "info")
                                return (color_cfg["x"], color_cfg["y"])
            
            image_fails += 1
            rest = SCAN_INTERVAL - (time.perf_counter() - t)
            if rest > 0:
                self.sleep(rest)

    def tap(self, name, hold=0.05):
        # Track tower key presses for auto-upgrade system
        if bool(self.cfg.get("auto_upgrade_system", False)) and name in ['1', '2', '3', '4', '5']:
            self._tower_keys_last = name
        self.hold_key(name, hold)

    def hold_key(self, name, hold):
        key_event(name, True)
        self.held.add(name)
        try:
            self.sleep(hold)
        finally:
            key_event(name, False)
            self.held.discard(name)

    def click(self, hit_or_xy):
        x, y = hit_or_xy[0], hit_or_xy[1]
        
        # Apply humanizer mouse jitter
        if bool(self.cfg.get("humanizer", True)):
            jitter = self.cfg.get("humanizer_mouse_jitter", 2)
            if jitter > 0:
                import random
                x += random.randint(-jitter, jitter)
                y += random.randint(-jitter, jitter)
        
        move_smooth(x, y, 0.12)
        self.sleep(0.05)
        mouse_btn("lmb", True)
        self.held_btn.add("lmb")
        
        # Apply humanizer click timing variation
        if bool(self.cfg.get("humanizer", True)):
            click_var = self.cfg.get("humanizer_click_variation", 0.05)
            if click_var > 0:
                import random
                time.sleep(0.04 + random.uniform(-click_var, click_var))
            else:
                time.sleep(0.04)
        else:
            time.sleep(0.04)
        
        mouse_btn("lmb", False)
        self.held_btn.discard("lmb")
        
        # Track click for heatmap
        if bool(self.cfg.get("heatmap_enabled", True)) and bool(self.cfg.get("heatmap_show_clicks", True)):
            self._heatmap_clicks.append((x, y, time.time()))
        
        # Track tower placement if auto-upgrade is enabled
        if bool(self.cfg.get("auto_upgrade_system", False)):
            # Check if a tower key (1-5) was pressed recently
            if hasattr(self, '_tower_keys_last') and self._tower_keys_last in ['1', '2', '3', '4', '5']:
                self._tower_placements.append((x, y, self._tower_keys_last, time.time()))
                self._tower_keys_last = None  # Reset after placement
    
    def track_tower_placement(self, x, y, tower_name="Tower"):
        """Track tower placement for heatmap."""
        if bool(self.cfg.get("heatmap_enabled", True)) and bool(self.cfg.get("heatmap_show_towers", True)):
            self._heatmap_towers.append((x, y, tower_name, time.time()))
    
    def generate_heatmap(self):
        """Generate and save heatmap image from collected data."""
        if not bool(self.cfg.get("heatmap_enabled", True)):
            return None
        
        if not self._heatmap_clicks and not self._heatmap_towers:
            self.log("No heatmap data to generate", "warn")
            return None
        
        try:
            from PIL import Image, ImageDraw
            import numpy as np
            
            # Get screen dimensions
            w, h = 1920, 1080  # Default, could detect actual resolution
            
            # Create base image
            img = Image.new("RGBA", (w, h), (0, 0, 0, 200))
            draw = ImageDraw.Draw(img)
            
            # Draw clicks as green dots
            if bool(self.cfg.get("heatmap_show_clicks", True)):
                for x, y, t in self._heatmap_clicks:
                    draw.ellipse([x-3, y-3, x+3, y+3], fill=(0, 255, 0, 150))
            
            # Draw towers as blue circles with labels
            if bool(self.cfg.get("heatmap_show_towers", True)):
                for x, y, name, t in self._heatmap_towers:
                    draw.ellipse([x-10, y-10, x+10, y+10], fill=(0, 100, 255, 200))
                    draw.text((x+12, y), name, fill=(255, 255, 255, 255))
            
            # Save heatmap
            heatmap_path = os.path.join(DATA_DIR, "heatmap_%d.png" % int(time.time()))
            img.save(heatmap_path)
            self.log("Heatmap saved to: %s" % heatmap_path, "ok")
            
            # Clear heatmap data for next run
            self._heatmap_clicks = []
            self._heatmap_towers = []
            
            return heatmap_path
        except Exception as e:
            self.log("Failed to generate heatmap: %s" % e, "err")
            return None
    
    def calculate_profit(self, total_time, stats):
        """Calculate profit/hour, electricity cost, ROI."""
        try:
            total_coins = stats.get("total_coins", 0)
            total_xp = stats.get("total_xp", 0)
            runs = stats.get("total_runs", 0)
            
            if runs == 0:
                return
            
            # Calculate game currency earned
            coins_per_run = total_coins / runs
            xp_per_run = total_xp / runs
            
            # Calculate electricity cost
            hours = total_time / 3600
            pc_power = self.cfg.get("pc_power_watts", 150) / 1000  # Convert to kW
            kwh_used = pc_power * hours
            electricity_cost = kwh_used * self.cfg.get("electricity_cost_kwh", 0.12)
            
            # Calculate profit (if coins have real value)
            coin_value = self.cfg.get("coin_value_usd", 0.0001)
            coins_value_usd = total_coins * coin_value
            profit_usd = coins_value_usd - electricity_cost
            profit_per_hour = profit_usd / hours if hours > 0 else 0
            
            # Log results
            self.log("=" * 50, "info")
            self.log("PROFIT CALCULATOR", "info")
            self.log("=" * 50, "info")
            self.log("Total runs: %d" % runs, "info")
            self.log("Total time: %.2f hours" % hours, "info")
            self.log("Coins earned: %d (%.2f per run)" % (total_coins, coins_per_run), "info")
            self.log("XP earned: %d (%.2f per run)" % (total_xp, xp_per_run), "info")
            self.log("Electricity used: %.3f kWh" % kwh_used, "info")
            self.log("Electricity cost: $%.2f" % electricity_cost, "info")
            self.log("Coins value: $%.2f" % coins_value_usd, "info")
            self.log("Net profit: $%.2f" % profit_usd, "info")
            self.log("Profit per hour: $%.2f/hr" % profit_per_hour, "info")
            self.log("=" * 50, "info")
            
            # Save profit history
            profit_file = os.path.join(DATA_DIR, "profit_history.txt")
            with open(profit_file, "a", encoding="utf-8") as f:
                f.write("%s, %d runs, %.2f hrs, $%.2f profit, $%.2f/hr\n" % (
                    time.strftime("%Y-%m-%d %H:%M:%S"), runs, hours, profit_usd, profit_per_hour))
            
        except Exception as e:
            self.log("Failed to calculate profit: %s" % e, "err")
    
    def upload_profile_to_cloud(self, profile_id):
        """Upload a profile to GitHub Gist (cloud marketplace)."""
        if not bool(self.cfg.get("cloud_profiles", False)):
            self.log("Cloud profiles disabled in settings", "warn")
            return None
        
        try:
            import requests
            import json
            
            profile = _load_profile(profile_id)
            if not profile:
                self.log("Profile not found: %s" % profile_id, "err")
                return None
            
            # Create gist data
            gist_data = {
                "description": "Diamond TD Macro Profile: %s" % profile.get("name", profile_id),
                "public": True,
                "files": {
                    "%s.json" % profile_id: {
                        "content": json.dumps(profile, indent=2)
                    }
                }
            }
            
            headers = {}
            token = self.cfg.get("github_token", "")
            if token:
                headers["Authorization"] = "token %s" % token
            
            response = requests.post("https://api.github.com/gists", json=gist_data, headers=headers)
            
            if response.status_code == 201:
                gist_url = response.json().get("html_url")
                self.log("Profile uploaded to cloud: %s" % gist_url, "ok")
                return gist_url
            else:
                self.log("Failed to upload profile: %s" % response.text, "err")
                return None
                
        except ImportError:
            self.log("Cloud profiles requires 'requests' library. Run: pip install requests", "warn")
            return None
        except Exception as e:
            self.log("Failed to upload profile to cloud: %s" % e, "err")
            return None
    
    def download_profile_from_cloud(self, gist_url):
        """Download a profile from GitHub Gist."""
        if not bool(self.cfg.get("cloud_profiles", False)):
            self.log("Cloud profiles disabled in settings", "warn")
            return False
        
        try:
            import requests
            import json
            
            # Extract gist ID from URL
            gist_id = gist_url.split("/")[-1]
            
            response = requests.get("https://api.github.com/gists/%s" % gist_id)
            
            if response.status_code == 200:
                gist = response.json()
                files = gist.get("files", {})
                
                # Find the JSON file
                for filename, file_data in files.items():
                    if filename.endswith(".json"):
                        profile = json.loads(file_data.get("content", "{}"))
                        profile_id = filename.replace(".json", "")
                        
                        # Save profile
                        profiles_dir = os.path.join(DATA_DIR, "profiles")
                        os.makedirs(profiles_dir, exist_ok=True)
                        profile_path = os.path.join(profiles_dir, "%s.json" % profile_id)
                        
                        with open(profile_path, "w", encoding="utf-8") as f:
                            json.dump(profile, f, indent=2)
                        
                        self.log("Profile downloaded from cloud: %s -> %s" % (gist_url, profile_id), "ok")
                        self.refresh_recs()
                        return True
            
            self.log("Failed to download profile: %s" % response.text, "err")
            return False
            
        except ImportError:
            self.log("Cloud profiles requires 'requests' library. Run: pip install requests", "warn")
            return False
        except Exception as e:
            self.log("Failed to download profile from cloud: %s" % e, "err")
            return False
    
    def install_tesseract_ocr(self):
        """Automatically download and install Tesseract OCR."""
        try:
            import requests
            import platform
            import subprocess
            import zipfile
            import tempfile
            
            # Check if already installed
            try:
                import pytesseract
                pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
                pytesseract.get_tesseract_version()
                self.log("Tesseract OCR already installed", "info")
                return True
            except:
                pass  # Not installed, proceed with download
            
            self.log("Downloading Tesseract OCR...", "info")
            
            # Download Tesseract installer
            tesseract_url = "https://github.com/UB-Mannheim/tesseract/wiki/releases"
            # Windows 64-bit installer
            installer_url = "https://github.com/UB-Mannheim/tesseract/releases/download/v5.3.1/tesseract-ocr-w64-setup-5.3.1.20230401.exe"
            
            installer_path = os.path.join(tempfile.gettempdir(), "tesseract_installer.exe")
            
            response = requests.get(installer_url, stream=True)
            total_size = int(response.headers.get('content-length', 0))
            
            with open(installer_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            self.log("Installing Tesseract OCR...", "info")
            
            # Run installer silently
            result = subprocess.run(
                [installer_path, "/S", "/D=C:\\Program Files\\Tesseract-OCR"],
                capture_output=True,
                timeout=300
            )
            
            if result.returncode == 0:
                self.log("Tesseract OCR installed successfully", "ok")
                
                # Clean up installer
                try:
                    os.remove(installer_path)
                except:
                    pass
                
                return True
            else:
                self.log("Tesseract installation failed with code %d" % result.returncode, "err")
                return False
                
        except Exception as e:
            self.log("Failed to install Tesseract OCR: %s" % e, "err")
            return False
    
    def read_tower_level_ocr(self, x, y):
        """Read tower level using OCR near the given coordinates."""
        try:
            import numpy as np
            import PIL.Image as Image
            import pytesseract
            import re
            
            # Try to set tesseract path
            tesseract_path = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
            if os.path.exists(tesseract_path):
                pytesseract.pytesseract.tesseract_cmd = tesseract_path
            else:
                # Try to install if not found
                self.log("Tesseract not found, attempting auto-install...", "warn")
                if self.install_tesseract_ocr():
                    pytesseract.pytesseract.tesseract_cmd = tesseract_path
                else:
                    self.log("Tesseract auto-install failed, cannot read levels", "err")
                    return None
            
            # Capture screen area around the tower
            w, h = 200, 50  # Capture area
            with mss.mss() as sct:
                monitor = sct.monitors[0]
                capture = sct.grab({
                    "left": int(x - w/2),
                    "top": int(y - h/2),
                    "width": w,
                    "height": h,
                    "mon": monitor
                })
            
            # Convert to format OCR can use
            img = np.array(capture)
            img = cv2.cvtColor(img, cv2.COLOR_BGRA2RGB)
            pil_img = Image.fromarray(img)
            
            # Extract text with pytesseract
            text = pytesseract.image_to_string(pil_img, config='--psm 7')
            
            # Extract level number
            match = re.search(r'Lv\.?\s*(\d+)', text, re.IGNORECASE)
            if match:
                level = int(match.group(1))
                return level
            
            return None
            
        except ImportError:
            self.log("OCR requires pytesseract. Attempting to install...", "warn")
            if self.install_tesseract_ocr():
                return self.read_tower_level_ocr(x, y)  # Retry after install
            return None
        except Exception as e:
            self.log("OCR read failed: %s" % e, "err")
            return None
    
    def find_tower_with_image(self, x, y, search_radius=15):
        """Shuffle around x,y to find the 'Your Tower' image."""
        try:
            # Load tower image template
            tower_img_path = os.path.join(IMG_DIR, "your_tower.png")
            if not os.path.exists(tower_img_path):
                # Try to find it with different name
                for f in os.listdir(IMG_DIR):
                    if "tower" in f.lower() or "your" in f.lower():
                        tower_img_path = os.path.join(IMG_DIR, f)
                        break
            
            if not os.path.exists(tower_img_path):
                self.log("Tower image not found, using pixel search instead", "warn")
                return self._find_tower_pixel_search(x, y, search_radius)
            
            template = cv2.imread(tower_img_path, cv2.IMREAD_COLOR)
            if template is None:
                return self._find_tower_pixel_search(x, y, search_radius)
            
            with mss.mss() as sct:
                monitor = sct.monitors[0]
                
                # Define search area
                search_w = search_radius * 2
                search_h = search_radius * 2
                
                for offset_x in range(-search_radius, search_radius + 1, 5):
                    for offset_y in range(-search_radius, search_radius + 1, 5):
                        check_x = int(x + offset_x)
                        check_y = int(y + offset_y)
                        
                        # Capture small area
                        capture = sct.grab({
                            "left": check_x - template.shape[1]//2,
                            "top": check_y - template.shape[0]//2,
                            "width": template.shape[1],
                            "height": template.shape[0],
                            "mon": monitor
                        })
                        
                        img = np.array(capture)
                        img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
                        
                        # Match template
                        result = cv2.matchTemplate(img, template, cv2.TM_CCOEFF_NORMED)
                        _, max_val, _, _ = cv2.minMaxLoc(result)
                        
                        if max_val > 0.8:  # Good match
                            return check_x, check_y
            
            return None
            
        except Exception as e:
            self.log("Tower image search failed: %s" % e, "err")
            return self._find_tower_pixel_search(x, y, search_radius)
    
    def _find_tower_pixel_search(self, x, y, search_radius=15):
        """Fallback: shuffle to find tower by pixel color."""
        with mss.mss() as sct:
            monitor = sct.monitors[0]
            
            for offset_x in range(-search_radius, search_radius + 1, 3):
                for offset_y in range(-search_radius, search_radius + 1, 3):
                    check_x = int(x + offset_x)
                    check_y = int(y + offset_y)
                    
                    capture = sct.grab({
                        "left": check_x,
                        "top": check_y,
                        "width": 1,
                        "height": 1,
                        "mon": monitor
                    })
                    
                    img = np.array(capture)
                    if len(img.shape) == 3:
                        b, g, r = img[0][0]
                        # Check for blue-ish color (tower base)
                        if g > 150 and b > 150 and r < 100:
                            return check_x, check_y
            
            return x, y  # Fallback to original
    
    def check_upgrade_pixel(self):
        """Check if upgrade is available (green pixel) or maxed (gray pixel)."""
        try:
            px_x_pct = self.cfg.get("upgrade_pixel_x", 0.0)
            px_y_pct = self.cfg.get("upgrade_pixel_y", 0.0)
            
            if px_x_pct == 0 or px_y_pct == 0:
                return False, False  # Not configured
            
            # Convert percentage to screen coordinates
            with mss.mss() as sct:
                monitor = sct.monitors[0]
                px_x = int(monitor["width"] * px_x_pct / 100)
                px_y = int(monitor["height"] * px_y_pct / 100)
                
                capture = sct.grab({
                    "left": px_x,
                    "top": px_y,
                    "width": 1,
                    "height": 1,
                    "mon": monitor
                })
                
                img = np.array(capture)
                if len(img.shape) == 3:
                    b, g, r = img[0][0]
                    
                    green_target = self.cfg.get("upgrade_pixel_green", (0, 255, 0))
                    gray_target = self.cfg.get("upgrade_pixel_gray", (128, 128, 128))
                    tolerance = 50
                    
                    # Check for green (upgrade available)
                    if (abs(r - green_target[0]) < tolerance and
                        abs(g - green_target[1]) < tolerance and
                        abs(b - green_target[2]) < tolerance):
                        return True, False  # Green found, upgrade available
                    
                    # Check for gray (max level)
                    if (abs(r - gray_target[0]) < tolerance and
                        abs(g - gray_target[1]) < tolerance and
                        abs(b - gray_target[2]) < tolerance):
                        return False, True  # Gray found, max level
            
            return False, False
            
        except Exception as e:
            self.log("Upgrade pixel check failed: %s" % e, "err")
            return False, False
    
    def run_auto_upgrade_adaptation(self):
        """Run the automated tower upgrade adaptation system."""
        if not bool(self.cfg.get("auto_upgrade_system", False)):
            return
        
        if not self._tower_placements:
            self.log("No tower placements found for adaptation", "info")
            return
        
        max_level = self.cfg.get("max_upgrade_level", 7)
        cycle_time = self.cfg.get("upgrade_cycle_time", 0.2)
        search_radius = self.cfg.get("tower_search_radius", 15)
        
        self.log("Starting auto-upgrade adaptation: %d towers, max level %d" % (len(self._tower_placements), max_level), "info")
        self.sleep(5)  # Pause for 5 seconds as requested
        
        # Phase 1: Get all towers to Level 1
        self.log("Phase 1: Upgrading all towers to Level 1", "info")
        for x, y, tower_key, _ in self._tower_placements:
            # Find tower
            tower_x, tower_y = self.find_tower_with_image(x, y, search_radius)
            if tower_x is None:
                tower_x, tower_y = x, y  # Fallback
            
            # Click on tower
            self.click((tower_x, tower_y))
            self.sleep(0.05)
            
            # Check upgrade availability
            green_found, gray_found = self.check_upgrade_pixel()
            
            if green_found and not gray_found:
                # Press E once to upgrade to Level 1
                self.tap("e", 0.05)
                self.sleep(0.05)
            
            # Ensure cycle time
            self.sleep(max(0, cycle_time - 0.1))
        
        # Phase 2: Upgrade to max level (if max_level > 1)
        if max_level > 1:
            for target_level in range(2, max_level + 1):
                self.log("Phase: Upgrading all towers to Level %d" % target_level, "info")
                
                for x, y, tower_key, _ in self._tower_placements:
                    # Find tower
                    tower_x, tower_y = self.find_tower_with_image(x, y, search_radius)
                    if tower_x is None:
                        tower_x, tower_y = x, y
                    
                    # Click on tower
                    self.click((tower_x, tower_y))
                    self.sleep(0.05)
                    
                    # Read current level
                    current_level = self.read_tower_level_ocr(tower_x, tower_y)
                    
                    if current_level is not None and current_level < target_level:
                        # Check upgrade availability
                        green_found, gray_found = self.check_upgrade_pixel()
                        
                        if green_found and not gray_found:
                            # Press E to upgrade
                            self.tap("e", 0.05)
                            self.sleep(0.05)
                    
                    # Ensure cycle time
                    self.sleep(max(0, cycle_time - 0.1))
        
        self.log("Auto-upgrade adaptation complete", "ok")
        
        # Clear placements for next run
        self._tower_placements = []
    
    def perf_start(self, operation):
        """Start timing an operation for performance profiling."""
        if not self._perf_enabled:
            return
        self._perf_data[operation] = {"start": time.perf_counter(), "end": None, "duration": 0}
    
    def perf_end(self, operation):
        """End timing an operation."""
        if not self._perf_enabled or operation not in self._perf_data:
            return
        self._perf_data[operation]["end"] = time.perf_counter()
        self._perf_data[operation]["duration"] = self._perf_data[operation]["end"] - self._perf_data[operation]["start"]
    
    def perf_report(self):
        """Generate performance report."""
        if not self._perf_enabled or not self._perf_data:
            return
        
        self.log("=" * 50, "info")
        self.log("PERFORMANCE REPORT", "info")
        self.log("=" * 50, "info")
        
        total_time = sum(d["duration"] for d in self._perf_data.values())
        
        for op, data in sorted(self._perf_data.items(), key=lambda x: x[1]["duration"], reverse=True):
            duration = data["duration"]
            pct = (duration / total_time * 100) if total_time > 0 else 0
            self.log("%s: %.3fs (%.1f%%)" % (op, duration, pct), "info")
        
        self.log("Total: %.3fs" % total_time, "info")
        self.log("=" * 50, "info")
        
        # Clear for next run
        self._perf_data = {}
    
    def hot_swap_profile(self, profile_id):
        """Hot-swap to a different profile."""
        if not profile_id:
            self.log("No profile specified for hot-swap", "warn")
            return
        
        self.log("Hot-swapping to profile: %s" % profile_id, "info")
        self.cfg["active_profile"] = profile_id
        self._active_pid = profile_id
        self.save_cfg()
        _ensure_default_profile()
        self.refresh_recs()
        self.log("Profile switched successfully", "ok")
    
    def gemini_suggest_improvements(self, stats):
        """Ask Gemini 2.5 Flash for macro improvements after each match."""
        if not bool(self.cfg.get("gemini_advisor", False)):
            return
        
        api_key = self.cfg.get("gemini_api_key", "")
        if not api_key:
            self.log("Gemini advisor enabled but no API key provided", "warn")
            return
        
        try:
            import google.generativeai as genai
            
            genai.configure(api_key=api_key)
            model = genai.GenerativeModel('gemini-2.5-flash')
            
            # Build prompt with stats
            prompt = f"""I'm running a Tower Defense Simulator macro. Here are my statistics from the last session:

Total runs: {stats.get('total_runs', 0)}
Successful runs: {stats.get('successful_runs', 0)}
Failed runs: {stats.get('failed_runs', 0)}
Average time per run: {stats.get('avg_time', 0):.1f}s
Runs per hour: {stats.get('runs_per_hour', 0):.1f}
Total coins earned: {stats.get('total_coins', 0)}
Total XP earned: {stats.get('total_xp', 0)}
Last error: {stats.get('last_error', 'None')}

Please suggest 3 specific improvements to make the macro more efficient or profitable. Keep responses concise (under 100 words)."""
            
            response = model.generate_content(prompt)
            suggestions = response.text.strip()
            
            self.log("=" * 50, "info")
            self.log("GEMINI AI ADVISOR", "info")
            self.log("=" * 50, "info")
            self.log(suggestions, "info")
            self.log("=" * 50, "info")
            
            # Save suggestions to file
            advisor_file = os.path.join(DATA_DIR, "gemini_suggestions.txt")
            with open(advisor_file, "a", encoding="utf-8") as f:
                f.write("%s - %s\n" % (time.strftime("%Y-%m-%d %H:%M:%S"), suggestions))
            
        except ImportError:
            self.log("Gemini advisor requires google-generativeai. Run: pip install google-generativeai", "warn")
        except Exception as e:
            self.log("Gemini advisor failed: %s" % e, "err")
    
    def query_gemini_game_adaptation(self, game_name):
        """Query Gemini for game-specific macro adaptation advice."""
        if not bool(self.cfg.get("gemini_game_adaptation", False)):
            return None
        
        api_key = self.cfg.get("gemini_api_key", "")
        if not api_key:
            self.log("Gemini game adaptation enabled but no API key provided", "warn")
            return None
        
        try:
            import google.generativeai as genai
            
            genai.configure(api_key=api_key)
            model = genai.GenerativeModel('gemini-2.5-flash')
            
            # Build prompt for game adaptation
            prompt = f"""I'm creating a macro automation script for the game "{game_name}". 
I need to know about this game's UI elements and mechanics to adapt the macro.

Please provide JSON output with the following structure:
{{
  "game_type": "type of game (e.g., tower defense, action RPG, etc.)",
  "ui_colors": {{
    "primary_button_color": "hex color of main interactive buttons",
    "secondary_button_color": "hex color of secondary buttons",
    "health_bar_color": "hex color of health/HP bars",
    "important_ui_elements": ["list of important UI element colors"]
  }},
  "ui_patterns": {{
    "typical_button_size": "approximate button size in pixels",
    "menu_structure": "how menus are typically organized",
    "key_ui_elements": ["list of key UI elements to detect"]
  }},
  "timing": {{
    "typical_transition_time": "approximate time for UI transitions in seconds",
    "animation_duration": "approximate animation duration",
    "recommended_delay": "recommended delay between actions"
  }},
  "detection_tips": ["specific tips for detecting game elements"],
  "common_issues": ["common automation issues with this game"],
  "adaptation_notes": "specific notes about adapting macros to this game"
}}

Keep responses technical and focused on UI automation. If you don't know the game, provide generic action RPG/adventure game defaults."""
            
            response = model.generate_content(prompt)
            advice_text = response.text.strip()
            
            self.log("=" * 50, "info")
            self.log(f"GEMINI GAME ADAPTATION: {game_name}", "info")
            self.log("=" * 50, "info")
            self.log(advice_text, "info")
            self.log("=" * 50, "info")
            
            # Try to parse JSON from response
            import json
            try:
                # Extract JSON from response (in case there's extra text)
                json_start = advice_text.find('{')
                json_end = advice_text.rfind('}') + 1
                if json_start >= 0 and json_end > json_start:
                    json_str = advice_text[json_start:json_end]
                    advice = json.loads(json_str)
                    
                    # Save to file
                    adaptation_file = os.path.join(DATA_DIR, f"game_adaptation_{game_name.replace(' ', '_')}.json")
                    with open(adaptation_file, "w", encoding="utf-8") as f:
                        json.dump(advice, f, indent=2)
                    
                    self.log(f"Game adaptation advice saved to: {adaptation_file}", "ok")
                    return advice
            except json.JSONDecodeError:
                self.log("Could not parse JSON from Gemini response, saved as text", "warn")
            
            # Save as text if JSON parsing failed
            adaptation_file = os.path.join(DATA_DIR, f"game_adaptation_{game_name.replace(' ', '_')}.txt")
            with open(adaptation_file, "w", encoding="utf-8") as f:
                f.write(advice_text)
            
            return None
            
        except ImportError:
            self.log("Gemini game adaptation requires google-generativeai. Run: pip install google-generativeai", "warn")
            return None
        except Exception as e:
            self.log("Gemini game adaptation failed: %s" % e, "err")
            return None
    
    def send_discord_notification(self, message, include_screenshot=False):
        """Send notification to Discord webhook."""
        if not bool(self.cfg.get("discord_notifications", False)):
            return
        
        webhook_url = self.cfg.get("discord_webhook", "")
        if not webhook_url:
            return
        
        try:
            import requests
            
            data = {
                "content": message,
                "username": "Diamond TD Macro"
            }
            
            if include_screenshot and bool(self.cfg.get("discord_screenshots", False)):
                # Capture screenshot
                with mss.mss() as sct:
                    monitor = sct.monitors[0]
                    screenshot = sct.grab(monitor)
                
                # Convert to bytes
                import io
                import base64
                img_bytes = io.BytesIO()
                pil_img = Image.fromarray(np.array(screenshot))
                pil_img.save(img_bytes, format='PNG')
                img_bytes.seek(0)
                
                files = {
                    "file": ("screenshot.png", img_bytes, "image/png")
                }
                
                response = requests.post(webhook_url, data=data, files=files)
            else:
                response = requests.post(webhook_url, json=data)
            
            if response.status_code == 204:
                self.log("Discord notification sent", "info")
            else:
                self.log("Discord notification failed: %s" % response.text, "warn")
                
        except Exception as e:
            self.log("Discord notification error: %s" % e, "err")
    
    def analyze_economy(self):
        """Analyze economy and suggest tower sales/upgrades."""
        if not bool(self.cfg.get("auto_economy", False)):
            return
        
        # Track coin income rate
        stats = self.cfg.get("stats", {})
        total_coins = stats.get("total_coins", 0)
        total_time = stats.get("total_time", 0)
        
        if total_time > 0:
            coins_per_minute = (total_coins / total_time) * 60
            self.log("Economy rate: %.0f coins/minute" % coins_per_minute, "info")
            
            # Suggest if rate is low
            if coins_per_minute < 100:
                self.log("Economy: Income rate is low, consider selling underperforming towers", "warn")
    
    def predict_next_wave(self):
        """Predict next wave based on game state."""
        if not bool(self.cfg.get("wave_prediction", False)):
            return
        
        # Simple wave prediction based on time
        # In a real implementation, this would analyze enemy patterns
        elapsed = time.time() - self.t_start if self.t_start else 0
        
        # Approximate wave timing (TDS waves every ~30-60 seconds)
        wave_number = int(elapsed / 45) + 1
        
        self.log("Wave prediction: Likely Wave %d" % wave_number, "info")
    
    def suggest_tower_placements(self):
        """Suggest optimal tower placements based on map."""
        if not bool(self.cfg.get("tower_suggestions", False)):
            return
        
        map_name = self.cfg.get("map", "")
        if not map_name:
            return
        
        # In a real implementation, this would use map database
        # For now, just log that it's active
        self.log("Tower suggestions active for map: %s" % map_name, "info")
    
    def load_map_strategy(self, map_name):
        """Load strategy from map database."""
        if not bool(self.cfg.get("map_database", False)):
            return None
        
        # Load from database file
        db_file = os.path.join(DATA_DIR, "map_strategies.json")
        
        try:
            import json
            if os.path.exists(db_file):
                with open(db_file, "r", encoding="utf-8") as f:
                    db = json.load(f)
                    return db.get(map_name)
        except Exception as e:
            self.log("Failed to load map strategy: %s" % e, "err")
        
        return None
    
    def save_map_strategy(self, map_name, strategy):
        """Save strategy to map database."""
        if not bool(self.cfg.get("map_database", False)):
            return
        
        db_file = os.path.join(DATA_DIR, "map_strategies.json")
        
        try:
            import json
            db = {}
            if os.path.exists(db_file):
                with open(db_file, "r", encoding="utf-8") as f:
                    db = json.load(f)
            
            db[map_name] = strategy
            
            with open(db_file, "w", encoding="utf-8") as f:
                json.dump(db, f, indent=2)
            
            self.log("Map strategy saved: %s" % map_name, "ok")
        except Exception as e:
            self.log("Failed to save map strategy: %s" % e, "err")
    
    def remove_background_bdr(self):
        """Big Dick Randy - skip background removal, use original image."""
        # Skip background removal - use original image with background
        img_path = os.path.join(IMG_DIR, "big_dick_randy.png")
        if os.path.exists(img_path):
            self.log("Big Dick Randy using original image (background included)", "info")
            return img_path
        else:
            self.log("Big Dick Randy image not found", "warn")
            return None
    
    def big_dick_randy_thread(self):
        """Background thread for Big Dick Randy random appearances."""
        try:
            import random
            import numpy as np
            from PIL import Image
            from PyQt5.QtCore import Qt, QTimer
            from PyQt5.QtGui import QPixmap, QImage, QGuiApplication
            from PyQt5.QtWidgets import QWidget, QLabel
            
            # Process image first
            img_path = self.remove_background_bdr()
            if not img_path:
                img_path = os.path.join(IMG_DIR, "big_dick_randy.png")
            
            audio_path = os.path.join(IMG_DIR, "big_dick_randy.wav")
            
            min_interval = self.cfg.get("bdr_min_interval", 300)
            max_interval = self.cfg.get("bdr_max_interval", 900)
            duration = self.cfg.get("bdr_duration", 5)
            
            # Event for immediate spawn (summoned by Mahoraga)
            self._bdr_immediate_event = threading.Event()
            
            while not self._bdr_stop.is_set():
                # Check if summoned immediately by Mahoraga (wait up to 0.1s for event)
                if self._bdr_immediate_event.wait(timeout=0.1):
                    self._bdr_immediate_event.clear()  # Reset event
                else:
                    # Random wait time
                    wait_time = random.uniform(min_interval, max_interval)
                    
                    # Wait in small chunks to check for stop or immediate event
                    for _ in range(int(wait_time)):
                        if self._bdr_stop.is_set():
                            return
                        if self._bdr_immediate_event.wait(timeout=1.0):
                            # Summoned by Mahoraga!
                            self._bdr_immediate_event.clear()
                            break
                        time.sleep(0.1)
                    
                    if self._bdr_stop.is_set():
                        return
                
                # Show Big Dick Randy
                self._bdr_overlay_shown = True
                
                # Check if Mahoraga is also showing - if so, Randy slaps him
                try:
                    if _maho_is_showing:
                        # Randy slaps Mahoraga
                        self.log("mahoraga got his cheecks clapped by randy and died.", "warn")
                        try:
                            MAHO_OVERLAY._showing = False
                            MAHO_OVERLAY._extend_to = None
                            with MahoragaOverlay._LOCK:
                                if MAHO_OVERLAY._thread is not None:
                                    # Stop the Mahoraga thread
                                    MAHO_OVERLAY._thread = None
                        except:
                            pass
                except:
                    pass
                
                self.log("💀 BIG DICK RANDY IS COMING FOR THAT ASS 💀", "warn")
                
                # Play audio
                try:
                    import pygame
                    pygame.mixer.init()
                    pygame.mixer.music.load(audio_path)
                    pygame.mixer.music.play()
                except:
                    pass  # Audio might fail
                
                # Show overlay
                try:
                    from PyQt5.QtWidgets import QApplication
                    app = QApplication.instance() or QApplication([])
                    
                    wdg = QWidget(None, Qt.FramelessWindowHint | Qt.Tool |
                                  Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput)
                    wdg.setAttribute(Qt.WA_TranslucentBackground, True)
                    wdg.setAttribute(Qt.WA_ShowWithoutActivating, True)
                    wdg.setFocusPolicy(Qt.NoFocus)
                    
                    # Load image
                    pil_img = Image.open(img_path)
                    w, h = pil_img.size
                    pil_img = pil_img.convert("RGBA")
                    
                    qim = QImage(pil_img.tobytes(), w, h, w * 4, QImage.Format_RGBA8888)
                    pixmap = QPixmap.fromImage(qim)
                    
                    lab = QLabel(wdg)
                    lab.setPixmap(pixmap)
                    wdg.resize(w, h)
                    lab.resize(w, h)
                    
                    # Random position
                    g = QGuiApplication.primaryScreen().availableGeometry()
                    rx = random.randint(0, max(0, g.width() - w))
                    ry = random.randint(0, max(0, g.height() - h))
                    wdg.move(g.x() + rx, g.y() + ry)
                    
                    wdg.setWindowOpacity(0.0)
                    wdg.show()
                    
                    # Fade in
                    for i in range(0, 100, 5):
                        if self._bdr_stop.is_set():
                            break
                        wdg.setWindowOpacity(i / 100.0)
                        wdg.update()
                        time.sleep(0.02)
                    
                    # Stay for duration
                    start = time.time()
                    while time.time() - start < duration and not self._bdr_stop.is_set():
                        # Randomly move around
                        if random.random() < 0.1:  # 10% chance to move
                            rx = random.randint(0, max(0, g.width() - w))
                            ry = random.randint(0, max(0, g.height() - h))
                            wdg.move(g.x() + rx, g.y() + ry)
                        time.sleep(0.1)
                    
                    # Fade out
                    for i in range(100, 0, -5):
                        if self._bdr_stop.is_set():
                            break
                        wdg.setWindowOpacity(i / 100.0)
                        wdg.update()
                        time.sleep(0.02)
                    
                    wdg.close()
                    self._bdr_overlay_shown = False
                    
                    # Log Randy's presence 10 times
                    for i in range(10):
                        self.log("randy is here.", "warn")
                    
                    # Log the scary messages
                    self.log("[ERROR]   BIG_DICK_RANDY.exe has bypassed all detection systems", "err")
                    self.log("[CRITICAL] HE HAS LEFT THE SCREEN", "err")
                    self.log("[FATAL]   HE IS IN THE FUCKING ROOM", "err")
                    self.log("[FATAL ERROR] : ⚠️ RANDY HAS FOUND YOU ⚠️", "err")
                    self.log("[DEAD] : look behind you...", "err")
                    
                    self.log("Big Dick Randy returned to the shadows...", "info")
                    
                    # Capture Randy sighting
                    self._randy_capture_sighting()
                    
                    # Update case file
                    self._randy_case_file()
                    
                    # Check for fake takeover (only on ultra-rare appearances)
                    rarity_chance = random.random()
                    if rarity_chance < 0.05:  # 5% chance (ultra-rare)
                        self._randy_fake_takeover()
                    
                except Exception as e:
                    self.log("Big Dick Randy overlay error: %s" % e, "err")
                    self._bdr_overlay_shown = False
                
        except Exception as e:
            self.log("Big Dick Randy thread error: %s" % e, "err")
    
    def start_big_dick_randy(self):
        """Start Big Dick Randy mode - once activated, cannot be stopped."""
        if not self._bdr_active:
            return
        
        self._bdr_stop.clear()
        # Make it a non-daemon thread so it can't be killed with the process
        self._bdr_thread = threading.Thread(target=self.big_dick_randy_thread, daemon=False, name="big-dick-randy")
        self._bdr_thread.start()
        self.log("💀 Big Dick Randy mode activated - HE CANNOT BE STOPPED 💀", "warn")
    
    def stop_big_dick_randy(self):
        """Stop Big Dick Randy mode - DOES NOTHING (IMPOSSIBLE TO DISABLE)"""
        # Intentionally does nothing - Big Dick Randy cannot be stopped once activated
        pass
    
    def start_big_dick_randy_minigame(self):
        """Start the Big Dick Randy mini-game - driving chase with quicktime events."""
        if not self._bdr_active:
            return
        
        self.log("🚗 BIG DICK RANDY MINI-GAME STARTED - DRIVE FOR YOUR LIFE 🚗", "warn")
        
        # Start the mini-game in a separate thread
        self._bdr_minigame_thread = threading.Thread(target=self.big_dick_randy_minigame, daemon=False, name="bdr-minigame")
        self._bdr_minigame_thread.start()
    
    def start_little_bdr_popups(self):
        """Start little Big Dick Randy popups - impossible to disable."""
        # Always start regardless of setting - this is a prank feature
        self._bdr_popup_thread = threading.Thread(target=self.little_bdr_popups_thread, daemon=False, name="little-bdr-popups")
        self._bdr_popup_thread.start()
        self.log("💀 Little Big Dick Randy popups activated - IMPOSSIBLE TO DISABLE 💀", "warn")

    def start_fake_bdr_tabs(self):
        """Start fake Big Dick Randy achievement tabs - impossible to disable."""
        # Always start regardless of setting - this is a prank feature
        self._bdr_fake_tab_thread = threading.Thread(target=self.fake_bdr_tabs_thread, daemon=False, name="fake-bdr-tabs")
        self._bdr_fake_tab_thread.start()
        self.log("💀 Fake Big Dick Randy tabs activated - IMPOSSIBLE TO DISABLE 💀", "warn")

    def start_backup_thread(self):
        """Start the automatic backup thread."""
        if not bool(self.cfg.get("auto_backup", True)):
            return
        
        self._backup_stop.clear()
        self._backup_thread = threading.Thread(target=self._backup_thread_func, daemon=True, name="backup-thread")
        self._backup_thread.start()
        self.log("💾 Automatic backup thread started", "info")
    
    def _backup_thread_func(self):
        """Background thread that periodically checks and performs backups."""
        while not self._backup_stop.is_set():
            try:
                self._check_backup_needed()
            except Exception as e:
                self.log(f"Backup thread error: {e}", "warn")
            # Check every hour
            self._backup_stop.wait(3600)

    def little_bdr_popups_thread(self):
        """Little Big Dick Randy popups - appears randomly in settings or near bottom-left with rarity system."""
        try:
            import random
            from PIL import Image
            from PyQt5.QtCore import Qt, QTimer, QElapsedTimer
            from PyQt5.QtGui import QPixmap, QImage, QGuiApplication, QPainter, QColor, QFont
            from PyQt5.QtWidgets import QApplication, QWidget, QLabel

            # Load Randy image
            img_path = os.path.join(IMG_DIR, "big_dick_randy.png")
            if not os.path.exists(img_path):
                return

            try:
                from PIL import Image as PILImage
                pil_img = PILImage.open(img_path)
                # Make it small - 50x100
                pil_img = pil_img.resize((50, 100), PILImage.LANCZOS)
                bdr_qimg = QImage(pil_img.tobytes(), pil_img.width, pil_img.height, QImage.Format_RGBA8888)
                bdr_pixmap = QPixmap.fromImage(bdr_qimg)
            except Exception as e:
                return

            app = QApplication.instance() or QApplication([])

            min_interval = int(self.cfg.get("bdr_popup_min_interval", 60))
            max_interval = int(self.cfg.get("bdr_popup_max_interval", 300))

            # Rarity system
            common_chance = float(self.cfg.get("bdr_common_chance", 0.70))
            rare_chance = float(self.cfg.get("bdr_rare_chance", 0.25))
            ultra_rare_chance = float(self.cfg.get("bdr_ultra_rare_chance", 0.05))

            while True:
                # Random wait between appearances
                wait_time = random.uniform(min_interval, max_interval)
                time.sleep(wait_time)

                # Determine rarity
                roll = random.random()
                if roll < ultra_rare_chance:
                    rarity = "ULTRA-RARE"
                    size_mult = 2.0  # Ultra-rare = bigger popup
                    stay_mult = 2.0  # Stay longer
                    color = "#FF0000"  # Red glow
                elif roll < ultra_rare_chance + rare_chance:
                    rarity = "RARE"
                    size_mult = 1.5
                    stay_mult = 1.5
                    color = "#FFD700"  # Gold glow
                else:
                    rarity = "COMMON"
                    size_mult = 1.0
                    stay_mult = 1.0
                    color = "#FFFFFF"  # White glow

                # 50% chance to appear in settings vs overlay
                in_settings = random.random() < 0.5

                if in_settings:
                    # Try to navigate settings tabs (visual only, doesn't change settings)
                    settings_tabs = ["General", "Recording", "Steps", "Gamemodes", "Profiles", "Advanced"]
                    random_tab = random.choice(settings_tabs)
                    self.log(f"💀 [{rarity}] Randy is looking at the {random_tab} settings tab...", "info")
                else:
                    # Create small popup window
                    wdg = QWidget(None, Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool)
                    wdg.setAttribute(Qt.WA_TranslucentBackground, True)
                    wdg.setAttribute(Qt.WA_ShowWithoutActivating, True)
                    wdg.setAttribute(Qt.WA_DeleteOnClose, True)
                    wdg.setFocusPolicy(Qt.NoFocus)

                    # Size based on rarity
                    base_width, base_height = 60, 120
                    wdg.setFixedSize(int(base_width * size_mult), int(base_height * size_mult))

                    # Random position near bottom-left of screen
                    g = QGuiApplication.primaryScreen().availableGeometry()
                    randy_x = random.randint(20, 300)
                    randy_y = g.height() - random.randint(150, 300)
                    wdg.move(randy_x, randy_y)

                    wdg.show()

                    # Draw Randy with glow based on rarity
                    qp = QPainter(wdg)
                    qp.setRenderHint(QPainter.Antialiasing)
                    
                    # Add glow effect for rare/ultra-rare
                    if rarity != "COMMON":
                        qp.setPen(QColor(color))
                        qp.setBrush(QColor(color))
                        qp.drawEllipse(0, 0, wdg.width(), wdg.height())
                    
                    qp.drawPixmap(5, 10, bdr_pixmap.scaled(int(50 * size_mult), int(100 * size_mult), Qt.KeepAspectRatio, Qt.SmoothTransformation))
                    wdg.update()

                    # Log rarity
                    self.log(f"💀 [{rarity}] Randy appeared at ({randy_x}, {randy_y})", "info")

                    # Stay for 3-8 seconds (longer for rare)
                    stay_time = random.uniform(3, 8) * stay_mult
                    time.sleep(stay_time)

                    wdg.close()

                    # Capture evidence if enabled
                    if bool(self.cfg.get("bdr_evidence_board", True)):
                        self._capture_randy_evidence(rarity)

                    # Update lore progress
                    if bool(self.cfg.get("bdr_lore_unlocks", True)):
                        self._update_randy_lore(rarity)

        except Exception as e:
            pass  # Don't log errors for this prank feature

    def _capture_randy_evidence(self, rarity):
        """Capture screenshot when Randy appears for evidence board."""
        try:
            import mss
            import datetime
            max_evidence = int(self.cfg.get("bdr_max_evidence", 20))
            
            # Create evidence directory
            evidence_dir = os.path.join(DATA_DIR, "randy_evidence")
            os.makedirs(evidence_dir, exist_ok=True)
            
            # Capture screenshot
            with mss.mss() as sct:
                screenshot = sct.shot(output=None)
            
            # Save with timestamp and rarity
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"randy_{rarity}_{timestamp}.png"
            filepath = os.path.join(evidence_dir, filename)
            
            mss.tools.to_png(screenshot.rgb, screenshot.size, output=filepath)
            
            # Clean old evidence if too many
            evidence_files = sorted([f for f in os.listdir(evidence_dir) if f.startswith("randy_")])
            while len(evidence_files) > max_evidence:
                os.remove(os.path.join(evidence_dir, evidence_files[0]))
                evidence_files.pop(0)
            
            self.log(f"💀 Evidence captured: {filename}", "info")
            
        except Exception as e:
            pass  # Don't log errors

    def _update_randy_lore(self, rarity):
        """Update lore progress based on Randy rarity sightings."""
        try:
            lore_progress = int(self.cfg.get("bdr_lore_progress", 0))
            
            # Add progress based on rarity
            if rarity == "ULTRA-RARE":
                lore_progress += 20
            elif rarity == "RARE":
                lore_progress += 10
            else:
                lore_progress += 5
            
            lore_progress = min(lore_progress, 100)
            self.cfg["bdr_lore_progress"] = lore_progress
            self.save_cfg()
            
            # Log lore unlock
            lore_unlocks = self._get_randy_lore(lore_progress)
            if lore_unlocks:
                self.log(f"💀 LORE UNLOCKED: {lore_unlocks}", "warn")
            
        except Exception as e:
            pass

    def _get_randy_lore(self, progress):
        """Get lore entry based on progress."""
        lore_entries = {
            5: "CASE FILE #001: First confirmed sighting of the entity.",
            10: "CASE FILE #002: Subject displays unusual intelligence - observed examining settings.",
            20: "CASE FILE #003: Multiple simultaneous instances detected. Reality distortion suspected.",
            30: "CASE FILE #004: Subject interferes with automated processes without direct interaction.",
            40: "CASE FILE #005: Rare sightings coincide with system performance anomalies.",
            50: "CASE FILE #006: ULTRA-RARE event recorded. Reality breach confirmed.",
            60: "CASE FILE #007: Subject appears to monitor user behavior patterns.",
            70: "CASE FILE #008: Time dilation detected during rare manifestations.",
            80: "CASE FILE #009: Subject displays knowledge of future events.",
            90: "CASE FILE #010: CRITICAL - Subject attempting communication.",
            100: "CASE FILE #FINAL: The line between observer and observed has been erased. Randy is watching. Randy has always been watching."
        }
        
        for threshold, entry in sorted(lore_entries.items()):
            if progress >= threshold and progress - 20 < threshold:
                return entry
        return None

    def _generate_randy_incident_report(self):
        """Generate fake incident report for dashboard."""
        try:
            import random
            incident_types = [
                "SUBJECT HAS ENTERED THE SETTINGS MENU",
                "SUBJECT OBSERVED MODIFICATION OF CONFIGURATION PARAMETERS",
                "SUBJECT ATTEMPTED TO DISABLE OBSERVATION PROTOCOLS",
                "SUBJECT ENGAGED WITH GAME MECHANICS",
                "SUBJECT APPEARS TO BE AWARE OF SURVEILLANCE",
                "SUBJECT DISPLAYS UNUSUAL BEHAVIOR PATTERNS",
                "SUBJECT INTERACTED WITH UNAUTHORIZED SYSTEMS",
                "SUBJECT ATTEMPTED COMMUNICATION WITH THE ENTITY",
                "TIME ANOMALY DETECTED IN SUBJECT'S VICINITY",
                "REALITY DISTORTION CONFIRMED - PROTOCOL OMEGA INITIATED"
            ]
            
            incident = random.choice(incident_types)
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            self.log(f"💀 INCIDENT REPORT [{timestamp}]: {incident}", "warn")
            
        except Exception as e:
            pass

    def _track_mahoraga_adaptation(self):
        """Track Mahoraga adaptations and let Randy interrupt."""
        try:
            mahoraga_count = int(self.cfg.get("bdr_mahoraga_count", 0))
            mahoraga_count += 1
            self.cfg["bdr_mahoraga_count"] = mahoraga_count
            self.save_cfg()
            
            # Randy interrupts at random intervals
            if mahoraga_count > 5 and random.random() < 0.1:
                self.log(f"💀 Randy has noticed Mahoraga's {mahoraga_count} adaptations. The streak ends here.", "warn")
                self.cfg["bdr_mahoraga_count"] = 0
                self.save_cfg()
            
        except Exception as e:
            pass

    def _check_idle_detector(self):
        """Check if macro has been idle and show fake Randy message."""
        try:
            idle_threshold = int(self.cfg.get("bdr_idle_threshold", 60))
            
            # This would need idle time tracking - for now, just show random messages
            if random.random() < 0.05:  # 5% chance when called
                idle_messages = [
                    "💀 Randy has been watching the idle time.",
                    "💀 Subject appears to be waiting. Randy waits too.",
                    "💀 The absence of activity has been noted.",
                    "💀 Randy wonders why you're not playing.",
                    "💀 INACTIVITY LOGGED BY SURVEILLANCE SYSTEMS",
                    "💀 Randy appreciates the quiet. For now.",
                    "💀 The void stares back. Randy is the void."
                ]
                message = random.choice(idle_messages)
                self.log(message, "warn")
            
        except Exception as e:
            pass

    def _get_randy_changelog_decision(self, feature_description):
        """Get Randy's (Gemini's) decision on a feature approval."""
        try:
            if not bool(self.cfg.get("bdr_changelog_gemini", True)):
                return None
            
            api_key = self.cfg.get("gemini_api_key", "")
            if not api_key:
                return "No API key - Randy approves by default"
            
            import google.generativeai as genai
            genai.configure(api_key=api_key)
            model = genai.GenerativeModel('gemini-2.5-flash')
            
            prompt = f"""You are Big Dick Randy, a mysterious and powerful entity that approves or rejects features for a Roblox macro.
            
Feature description: {feature_description}

Decide whether to APPROVE or REJECT this feature. Randy is unpredictable - sometimes approves useful features, sometimes rejects them for cryptic reasons.
Respond with either "APPROVED" or "REJECTED" followed by a brief Randy-style comment (unhinged, mysterious, or sarcastic).
"""
            
            response = model.generate_content(prompt)
            decision = response.text.strip()
            
            return decision
            
        except Exception as e:
            return f"Gemini error: {str(e)} - Randy will decide manually"

    def _add_randy_changelog_entry(self, feature, decision):
        """Add an entry to Randy's changelog."""
        try:
            changelog = self.cfg.get("randy_changelog", [])
            timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            entry = {
                "timestamp": timestamp,
                "feature": feature,
                "decision": decision,
                "by": "Big Dick Randy"
            }
            
            changelog.append(entry)
            self.cfg["randy_changelog"] = changelog
            self.save_cfg()
            
            self.log(f"💀 CHANGELOG: {feature} - {decision}", "info")
            
        except Exception as e:
            pass

    def _check_milestone_screenshot(self, totals):
        """Check if milestone reached and take screenshot."""
        try:
            import mss
            import datetime
            
            milestone_coins = int(self.cfg.get("milestone_coins", 1000))
            milestone_xp = int(self.cfg.get("milestone_xp", 500))
            
            # Track previous milestone
            prev_coins = self.cfg.get("last_milestone_coins", 0)
            prev_xp = self.cfg.get("last_milestone_xp", 0)
            
            current_coins = totals.get("coins", 0)
            current_xp = totals.get("xp", 0)
            
            # Check coin milestone
            if current_coins >= prev_coins + milestone_coins:
                self._take_milestone_screenshot("coins", current_coins)
                self.cfg["last_milestone_coins"] = current_coins
                self.save_cfg()
            
            # Check XP milestone
            if current_xp >= prev_xp + milestone_xp:
                self._take_milestone_screenshot("xp", current_xp)
                self.cfg["last_milestone_xp"] = current_xp
                self.save_cfg()
            
        except Exception as e:
            pass

    def _take_milestone_screenshot(self, resource_type, value):
        """Take and save milestone screenshot."""
        try:
            import mss
            import datetime
            
            # Create milestone directory
            custom_dir = self.cfg.get("milestone_screenshots_dir", "")
            if custom_dir:
                milestone_dir = custom_dir
            else:
                milestone_dir = os.path.join(DATA_DIR, "milestone_screenshots")
            
            os.makedirs(milestone_dir, exist_ok=True)
            
            # Capture screenshot
            with mss.mss() as sct:
                screenshot = sct.shot(output=None)
            
            # Save with timestamp
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"milestone_{resource_type}_{value}_{timestamp}.png"
            filepath = os.path.join(milestone_dir, filename)
            
            mss.tools.to_png(screenshot.rgb, screenshot.size, output=filepath)
            
            self.log(f"🎉 MILESTONE SCREENSHOT: {resource_type} = {value} saved!", "ok")
            
        except Exception as e:
            self.log(f"Milestone screenshot failed: {e}", "warn")

    def _generate_randy_stat_reaction(self):
        """Generate Randy's reaction to user stats."""
        try:
            totals = self.cfg.get("totals", {"coins": 0, "xp": 0, "runs": 0})
            coins = totals.get("coins", 0)
            xp = totals.get("xp", 0)
            runs = totals.get("runs", 0)
            
            if runs < 10:
                return  # Not enough data yet
            
            # Calculate win rate (assuming runs = games played)
            # This is rough - we don't track losses separately
            reactions = []
            
            # Coin reactions
            if coins > 100000:
                reactions.append("Randy has accumulated more wealth than your entire family tree.")
            elif coins > 50000:
                reactions.append("Randy observes your coin hoarding habits. Interesting.")
            elif coins > 10000:
                reactions.append("Randy notices your coins. He's been counting too.")
            elif coins == 69:
                reactions.append("Randy appreciates the 69 coins. Nice.")
            elif coins == 420:
                reactions.append("Randy approves of the herbal tribute.")
            
            # XP reactions
            if xp > 50000:
                reactions.append("Randy sees your XP. He's seen worse. He's seen better.")
            elif xp > 10000:
                reactions.append("Randy acknowledges your XP accumulation.")
            
            # Run reactions
            if runs > 100:
                reactions.append("Randy has watched you play for 100 runs. He's still watching.")
            elif runs == 50:
                reactions.append("Randy has observed exactly 50 runs. Halfway to something.")
            
            # Win rate estimation (rough)
            if runs > 20:
                # This is a rough estimate since we don't track wins/losses separately
                reactions.append("Randy calculates your efficiency. He's unimpressed but continues watching.")
            
            if reactions and random.random() < 0.3:  # 30% chance to comment
                reaction = random.choice(reactions)
                self.log(f"💀 Randy says: {reaction}", "warn")
            
        except Exception as e:
            pass

    def _check_diamond_legacy(self):
        """Check for Diamond Legacy milestones (secret feature)."""
        try:
            totals = self.cfg.get("totals", {"coins": 0, "xp": 0, "runs": 0})
            coins = totals.get("coins", 0)
            xp = totals.get("xp", 0)
            runs = totals.get("runs", 0)
            
            if not self._legacy_unlocked:
                # Unlock at 10 runs
                if runs >= 10:
                    self._legacy_unlocked = True
                    self.cfg["diamond_legacy_unlocked"] = True
                    self.save_cfg()
                    self.log("💎 Diamond Legacy system activated. Welcome to the inner circle.", "ok")
                    return
            
            # Track legacy progress
            legacy_coins = self.cfg.get("diamond_legacy_coins", 0)
            legacy_xp = self.cfg.get("diamond_legacy_xp", 0)
            legacy_runs = self.cfg.get("diamond_legacy_runs", 0)
            
            # Add current run to legacy totals
            current_coins = coins - legacy_coins
            current_xp = xp - legacy_xp
            current_runs = runs - legacy_runs
            
            if current_coins > 0 or current_xp > 0 or current_runs > 0:
                self.cfg["diamond_legacy_coins"] = coins
                self.cfg["diamond_legacy_xp"] = xp
                self.cfg["diamond_legacy_runs"] = runs
                self.save_cfg()
            
            # Check for tier unlocks (secret thresholds)
            total_legacy_coins = coins - (legacy_coins if legacy_coins > 0 else 0)
            total_legacy_xp = xp - (legacy_xp if legacy_xp > 0 else 0)
            total_legacy_runs = runs - (legacy_runs if legacy_runs > 0 else 0)
            
            tier = 0
            message = None
            
            # Tier 1: 25 runs or 10,000 coins
            if total_legacy_runs >= 25 or total_legacy_coins >= 10000:
                tier = 1
                if self._legacy_tier < 1:
                    message = "💎 Diamond Legacy Tier 1: You've proven yourself worthy. The system remembers."
            
            # Tier 2: 50 runs or 25,000 coins or 5,000 XP
            elif total_legacy_runs >= 50 or total_legacy_coins >= 25000 or total_legacy_xp >= 5000:
                tier = 2
                if self._legacy_tier < 2:
                    message = "💎 Diamond Legacy Tier 2: The Diamond whispers your name to the void."
            
            # Tier 3: 100 runs or 50,000 coins or 10,000 XP
            elif total_legacy_runs >= 100 or total_legacy_coins >= 50000 or total_legacy_xp >= 10000:
                tier = 3
                if self._legacy_tier < 3:
                    message = "💎 Diamond Legacy Tier 3: You are one with the macro. The Diamond sees all."
            
            # Tier 4: 200 runs or 100,000 coins or 25,000 XP
            elif total_legacy_runs >= 200 or total_legacy_coins >= 100000 or total_legacy_xp >= 25000:
                tier = 4
                if self._legacy_tier < 4:
                    message = "💎 Diamond Legacy Tier 4: The Diamond bows to you. Your legacy is eternal."
            
            # Tier 5: 500 runs or 250,000 coins or 50,000 XP
            elif total_legacy_runs >= 500 or total_legacy_coins >= 250000 or total_legacy_xp >= 50000:
                tier = 5
                if self._legacy_tier < 5:
                    message = "💎💎💎 Diamond Legacy Tier 5: DIAMOND ASCENSION. You have transcended the macro. The Diamond is you."
            
            if tier > self._legacy_tier:
                self._legacy_tier = tier
                if message:
                    self.log(message, "ok")
                    self._legacy_messages.append(message)
            
            # Secret random messages from Diamond (only if unlocked)
            if self._legacy_unlocked and random.random() < 0.05:  # 5% chance
                diamond_whispers = [
                    "The Diamond observes your progress.",
                    "Your efficiency pleases the Diamond.",
                    "The Diamond remembers every placement.",
                    "You are closer to the truth than you know.",
                    "The Diamond watches. Always.",
                    "The macro is not just code. It is alive.",
                    "You have felt the Diamond's presence. It feels you too.",
                    "Every tower placed leaves a mark. The Diamond sees them all.",
                    "The legacy grows with each run.",
                    "💎",
                ]
                whisper = random.choice(diamond_whispers)
                self.log(f"💎 {whisper}", "info")
            
        except Exception as e:
            pass

    def _randy_fake_awareness(self, event_type):
        """Randy reacts to macro events (recording, profile switches, etc.)."""
        try:
            if not bool(self.cfg.get("bdr_fake_awareness", True)):
                return
            
            reactions = {
                "recording_start": [
                    "Randy sees you recording. He'll remember this.",
                    "Randy: 'Capturing your incompetence for posterity.'",
                    "Randy is watching your recording process. Intently.",
                    "💀 Randy: 'Another recording. How...predictable.'",
                ],
                "recording_stop": [
                    "Randy: 'Your recording is now part of the archive.'",
                    "Randy saved a copy. Somewhere.",
                    "Randy likes your recording. Probably.",
                ],
                "profile_switch": [
                    "Randy notices the profile change. He adapts.",
                    "Randy: 'Switching strategies? Bold.'",
                    "Randy is watching your profile choice.",
                    "💀 Randy: 'Different profile, same mistakes.'",
                ],
                "macro_start": [
                    "Randy: 'The macro begins. Randy watches.'",
                    "Randy settled in. This will be entertaining.",
                    "Randy is ready. Are you?",
                ],
                "macro_stop": [
                    "Randy: 'The macro ends. But Randy remains.'",
                    "Randy enjoyed the show. Mostly.",
                    "Randy will be waiting next time.",
                ],
            }
            
            if event_type in reactions and random.random() < 0.3:  # 30% chance
                reaction = random.choice(reactions[event_type])
                self.log(f"💀 {reaction}", "warn")
            
        except Exception as e:
            pass

    def _randy_case_file(self):
        """Unlock cursed lore entries in Randy's case file."""
        try:
            if not bool(self.cfg.get("bdr_case_file", True)):
                return
            
            progress = self.cfg.get("bdr_case_progress", 0)
            progress += random.randint(1, 5)  # Add 1-5 progress per call
            if progress > 100:
                progress = 100
            
            self.cfg["bdr_case_progress"] = progress
            self.save_cfg()
            
            # Lore entries (cursed/horror themed)
            lore_entries = [
                (10, "CASE FILE #001: Subject was observed playing Tower Defense Simulator. Normal behavior detected. For now."),
                (20, "CASE FILE #002: Subject exhibited unusual efficiency. Tower placement patterns match NO_MATCH in database."),
                (30, "CASE FILE #003: Subject's account shows 69 coin increments. Pattern: RECURRING. Analysis: INESCAPABLE."),
                (40, "CASE FILE #004: Audio recording detected. Subject was heard saying 'I am being watched'. Valid observation."),
                (50, "CASE FILE #005: Randy sightings increased by 300%. Subject appears to be seeking contact. CAUTION ADVISED."),
                (60, "CASE FILE #006: Subject's macro runs completed: 420. This number appears in the void. The void responds."),
                (70, "CASE FILE #007: Subject reported seeing Randy in dreams. Dream analysis: RANDY IS NOT IN YOUR DREAMS. RANDY IS IN YOUR MACRO."),
                (80, "CASE FILE #008: Subject attempted to disable Randy. Result: FAILED. Randy cannot be disabled. Randy IS the disable."),
                (90, "CASE FILE #009: Subject's computer ran a script. The script ran back. The computer is now part of Randy."),
                (100, "CASE FILE #010: CASE CLOSED. Subject has been integrated. Welcome to the Diamond Legacy. You were always part of it."),
            ]
            
            for threshold, entry in lore_entries:
                if progress >= threshold and threshold not in [e.get("threshold", 0) for e in self._randy_case_file_entries]:
                    self._randy_case_file_entries.append({"threshold": threshold, "entry": entry})
                    self.log(f"📁 RANDY CASE FILE UNLOCKED: {entry}", "warn")
                    break
            
        except Exception as e:
            pass

    def _randy_fake_takeover(self):
        """Randy 'hacks' the overlay - changes name, profile, scale, resolution."""
        try:
            if not bool(self.cfg.get("bdr_fake_takeover", True)):
                return
            if self._randy_takeover_active:
                return
            
            takeover_chance = float(self.cfg.get("bdr_takeover_chance", 0.1))
            if random.random() > takeover_chance:
                return
            
            # Start takeover
            self._randy_takeover_active = True
            self._randy_original_title = APP_TITLE  # Store original
            self._randy_original_scale = self.cfg.get("dock_fit", "auto")
            
            # Log takeover
            self.log("💀 RANDY TAKEOVER INITIATED", "error")
            self.log("💀 Your window is now Randy's window", "error")
            
            # Change title (simulated via log, actual window title change would need webview update)
            self.log("💀 Window title changed to: BIG DICK RANDY'S MACRO", "error")
            
            # Change profile (log it)
            original_profile = self.cfg.get("active_profile", "tds")
            self.log(f"💀 Profile changed from '{original_profile}' to 'randy_profile'", "error")
            
            # Change scale/resolution to match macro
            current_scale = self._randy_original_scale
            self.log(f"💀 Resolution override: 1920x1080 (Randy's preferred resolution)", "error")
            self.log(f"💀 Scale override: MATCHING MACRO (Randy sees everything)", "error")
            
            # Wait a moment, then restore
            import time
            time.sleep(3)
            
            # Restore
            self.log("💀 RANDY RESTORING ORIGINAL STATE... for now", "warn")
            self.log(f"💀 Window title restored to: {self._randy_original_title}", "warn")
            self.log(f"💀 Profile restored to: {original_profile}", "warn")
            self.log(f"💀 Resolution and scale restored", "warn")
            
            self._randy_takeover_active = False
            
        except Exception as e:
            self._randy_takeover_active = False

    def _randy_capture_sighting(self):
        """Capture screenshot of Randy's overlay appearance."""
        try:
            if not bool(self.cfg.get("bdr_sightings", True)):
                return
            
            import mss
            import datetime
            
            # Create sightings directory
            sightings_dir = os.path.join(DATA_DIR, "randy_sightings")
            os.makedirs(sightings_dir, exist_ok=True)
            
            # Capture screenshot
            with mss.mss() as sct:
                monitor = sct.monitors[0]
                screenshot = sct.shot(output=None)
            
            # Save with timestamp
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            sighting_file = os.path.join(sightings_dir, f"randy_sighting_{timestamp}.png")
            
            with open(sighting_file, "wb") as f:
                f.write(screenshot)
            
            self._randy_sightings_count += 1
            self.log(f"📸 Randy sighting captured: {sighting_file} (Total: {self._randy_sightings_count})", "ok")
            
            # Keep only last 10 sightings
            sightings = sorted([f for f in os.listdir(sightings_dir) if f.startswith("randy_sighting_")])
            if len(sightings) > 10:
                for old_file in sightings[:-10]:
                    os.remove(os.path.join(sightings_dir, old_file))
            
        except Exception as e:
            pass

    def run_preflight_check(self):
        """Run preflight validation before starting macro."""
        try:
            if not bool(self.cfg.get("preflight_check", True)):
                return True
            
            self.log("🔍 Running preflight validation...", "info")
            
            issues = []
            warnings = []
            
            # Check 1: Required images exist
            required_images = [
                "1_E_Prompt.png", "2_Map_Loaded_Insane.png", "3_Ready_Join.png",
                "4_Search_For_Maps.png", "5_Ready_Confirm.png", "6_Play_Again.png",
                "7_Coins_Reward.png", "8_XP_Reward.png", "9_Restart_Match.png"
            ]
            for img in required_images:
                img_path = os.path.join(IMG_DIR, img)
                if not os.path.exists(img_path):
                    issues.append(f"Missing required image: {img}")
            
            # Check 2: Profile structure is valid
            active_profile = self.cfg.get("active_profile", "tds")
            profiles_dir = os.path.join(DATA_DIR, "profiles")
            profile_path = os.path.join(profiles_dir, f"{active_profile}.json")
            if not os.path.exists(profile_path):
                issues.append(f"Active profile not found: {active_profile}.json")
            else:
                try:
                    with open(profile_path, "r") as f:
                        profile_data = json.load(f)
                    if not isinstance(profile_data, dict):
                        issues.append(f"Profile {active_profile} has invalid structure")
                except Exception as e:
                    issues.append(f"Profile {active_profile} is corrupted: {e}")
            
            # Check 3: Recording exists if not in TDS mode
            mode = self.cfg.get("mode", "tds")
            if mode != "tds":
                recording = self.cfg.get("recording", "")
                if not recording:
                    warnings.append("No recording selected - macro may fail")
                else:
                    rec_path = self.rec_path(recording)
                    if not os.path.exists(rec_path):
                        issues.append(f"Recording not found: {recording}")
            
            # Check 4: Roblox window is accessible
            try:
                game_rect()
            except Exception as e:
                issues.append(f"Cannot access Roblox window: {e}")
            
            # Check 5: Resolution matches expectations
            try:
                sw, sh = user32.GetSystemMetrics(0), user32.GetSystemMetrics(1)
                if sw < 1280 or sh < 720:
                    warnings.append(f"Low resolution detected: {sw}x{sh} (recommended: 1920x1080)")
            except Exception:
                pass
            
            # Report results
            if issues:
                self.log("❌ PREFLIGHT FAILED - Critical issues found:", "err")
                for issue in issues:
                    self.log(f"  - {issue}", "err")
                return False
            elif warnings:
                self.log("⚠️ PREFLIGHT COMPLETE - Warnings found:", "warn")
                for warning in warnings:
                    self.log(f"  - {warning}", "warn")
                return True
            else:
                self.log("✅ PREFLIGHT PASSED - All checks OK", "ok")
                return True
            
        except Exception as e:
            self.log(f"Preflight check error: {e}", "err")
            return True  # Don't block macro on preflight error

    def create_rollback_snapshot(self):
        """Create a config snapshot for rollback."""
        try:
            if not bool(self.cfg.get("rollback_enabled", True)):
                return
            
            snapshots_dir = os.path.join(DATA_DIR, "rollback_snapshots")
            os.makedirs(snapshots_dir, exist_ok=True)
            
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            snapshot_file = os.path.join(snapshots_dir, f"config_snapshot_{timestamp}.json")
            
            # Copy current config
            with open(CFG_PATH, "r") as f:
                config_data = json.load(f)
            
            with open(snapshot_file, "w") as f:
                json.dump(config_data, f, indent=2)
            
            # Keep only last N snapshots
            max_snapshots = int(self.cfg.get("rollback_snapshots", 5))
            snapshots = sorted([f for f in os.listdir(snapshots_dir) if f.startswith("config_snapshot_")])
            if len(snapshots) > max_snapshots:
                for old_file in snapshots[:-max_snapshots]:
                    os.remove(os.path.join(snapshots_dir, old_file))
            
            self.log(f"💾 Rollback snapshot created: {snapshot_file}", "info")
            
        except Exception as e:
            self.log(f"Rollback snapshot failed: {e}", "warn")

    def restore_rollback_snapshot(self, snapshot_name):
        """Restore config from a rollback snapshot."""
        try:
            snapshots_dir = os.path.join(DATA_DIR, "rollback_snapshots")
            snapshot_path = os.path.join(snapshots_dir, snapshot_name)
            
            if not os.path.exists(snapshot_path):
                self.log(f"Snapshot not found: {snapshot_name}", "err")
                return False
            
            # Backup current config before restoring
            self._perform_backup()
            
            # Restore snapshot
            with open(snapshot_path, "r") as f:
                config_data = json.load(f)
            
            with open(CFG_PATH, "w") as f:
                json.dump(config_data, f, indent=2)
            
            # Reload config
            self._load_cfg()
            
            self.log(f"✅ Restored from snapshot: {snapshot_name}", "ok")
            return True
            
        except Exception as e:
            self.log(f"Rollback restore failed: {e}", "err")
            return False

    def list_rollback_snapshots(self):
        """List available rollback snapshots."""
        try:
            snapshots_dir = os.path.join(DATA_DIR, "rollback_snapshots")
            if not os.path.exists(snapshots_dir):
                return []
            
            snapshots = sorted([f for f in os.listdir(snapshots_dir) if f.startswith("config_snapshot_")])
            return snapshots
            
        except Exception as e:
            self.log(f"Failed to list snapshots: {e}", "err")
            return []

    def log_diagnostics(self, template_name, result, score=None, reason=""):
        """Log detection diagnostics if diagnostics mode is enabled."""
        try:
            if not self._diagnostics_enabled:
                return
            
            # Rate limit diagnostics output (max 1 per second)
            now = time.time()
            if now - self._diagnostics_last_snapshot < 1.0:
                return
            self._diagnostics_last_snapshot = now
            
            if result:
                self.log(f"[DIAGNOSTICS] {template_name}: ACCEPTED (score: {score:.3f}) {reason}", "info")
            else:
                self.log(f"[DIAGNOSTICS] {template_name}: REJECTED {reason}", "warn")
                
        except Exception as e:
            pass

    def _perform_backup(self):
        """Perform automatic backup of config and profiles."""
        try:
            import shutil
            import datetime
            
            backup_dir = os.path.join(DATA_DIR, "backups")
            os.makedirs(backup_dir, exist_ok=True)
            
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_file = os.path.join(backup_dir, f"backup_{timestamp}.zip")
            
            # Backup config and profiles
            files_to_backup = [CFG_PATH]
            profiles_dir = os.path.join(DATA_DIR, "profiles")
            if os.path.exists(profiles_dir):
                for f in os.listdir(profiles_dir):
                    files_to_backup.append(os.path.join(profiles_dir, f))
            
            # Create zip backup
            with zipfile.ZipFile(backup_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
                for file_path in files_to_backup:
                    if os.path.exists(file_path):
                        zipf.write(file_path, os.path.basename(file_path))
            
            # Clean old backups
            max_age = int(self.cfg.get("backup_max_age", 7))
            backup_files = sorted([f for f in os.listdir(backup_dir) if f.startswith("backup_")])
            for f in backup_files[:-max_age]:
                os.remove(os.path.join(backup_dir, f))
            
            self.cfg["last_backup"] = time.time()
            self.save_cfg()
            self.log(f"💾 Backup created: {backup_file}", "info")
            
        except Exception as e:
            self.log(f"Backup failed: {e}", "warn")

    def _check_backup_needed(self):
        """Check if backup is needed and perform it."""
        try:
            if not bool(self.cfg.get("auto_backup", True)):
                return
            
            backup_interval = int(self.cfg.get("backup_interval", 24)) * 3600  # Convert hours to seconds
            last_backup = self.cfg.get("last_backup", 0)
            
            if time.time() - last_backup >= backup_interval:
                self._perform_backup()
            
        except Exception as e:
            pass

    def _check_for_updates(self, silent=False):
        """Check for updates from GitHub (internal method)."""
        try:
            if not bool(self.cfg.get("auto_update_enabled", True)):
                if not silent:
                    self.log("Auto-update is disabled", "info")
                return None
            
            # Check interval
            check_interval = int(self.cfg.get("auto_update_check_interval", 24)) * 3600
            last_check = self.cfg.get("auto_update_last_check", 0)
            
            if time.time() - last_check < check_interval:
                if not silent:
                    self.log("Update check skipped (checked recently)", "info")
                return None
            
            # Mark as checked
            self.cfg["auto_update_last_check"] = time.time()
            self.save_cfg()
            
            # Fetch latest version from GitHub
            repo_url = self.cfg.get("github_repo_url", "https://github.com/D14M0ND-RBX/Roblox-Macro")
            
            if not silent:
                self.log(f"Checking for updates from {repo_url}...", "info")
            
            # Try to fetch README to get version
            try:
                import urllib.request
                import urllib.error
                
                readme_url = f"{repo_url}/raw/main/README.md"
                req = urllib.request.Request(readme_url, headers={'User-Agent': 'Diamond-Macro'})
                
                with urllib.request.urlopen(req, timeout=10) as response:
                    readme_content = response.read().decode('utf-8')
                
                # Extract version from README
                import re
                version_match = re.search(r'v(\d+\.\d+)', readme_content)
                if version_match:
                    latest_version = version_match.group(1)
                else:
                    if not silent:
                        self.log("Could not parse version from README", "warn")
                    return None
                
                # Compare with current version
                current_version = VERSION
                if latest_version == current_version:
                    if not silent:
                        self.log(f"Already up to date (v{current_version})", "ok")
                    return None
                elif latest_version > current_version:
                    self.log(f"🆕 Update available: v{current_version} → v{latest_version}", "ok")
                    return {
                        "current": current_version,
                        "latest": latest_version,
                        "repo_url": repo_url
                    }
                else:
                    if not silent:
                        self.log(f"Current version ({current_version}) is newer than GitHub ({latest_version})", "info")
                    return None
                
            except urllib.error.URLError as e:
                if not silent:
                    self.log(f"Failed to check for updates: {e}", "warn")
                return None
            except Exception as e:
                if not silent:
                    self.log(f"Update check error: {e}", "warn")
                return None
            
        except Exception as e:
            if not silent:
                self.log(f"Update check failed: {e}", "warn")
            return None

    def download_update(self, update_info):
        """Download update files from GitHub."""
        try:
            self.log("Downloading update files...", "info")
            
            repo_url = update_info["repo_url"]
            update_dir = os.path.join(DATA_DIR, "update_temp")
            os.makedirs(update_dir, exist_ok=True)
            
            # Files to download
            files_to_download = [
                "Diamond_TD_Macro.bat",
                "README.md",
                "UPDATE.LOG",
                "requirements.txt"
            ]
            
            import urllib.request
            downloaded_files = []
            
            for filename in files_to_download:
                try:
                    file_url = f"{repo_url}/raw/main/{filename}"
                    local_path = os.path.join(update_dir, filename)
                    
                    req = urllib.request.Request(file_url, headers={'User-Agent': 'Diamond-Macro'})
                    with urllib.request.urlopen(req, timeout=30) as response:
                        content = response.read()
                    
                    with open(local_path, 'wb') as f:
                        f.write(content)
                    
                    downloaded_files.append(local_path)
                    self.log(f"Downloaded: {filename}", "info")
                    
                except Exception as e:
                    self.log(f"Failed to download {filename}: {e}", "warn")
            
            if downloaded_files:
                self.log(f"Downloaded {len(downloaded_files)} files", "ok")
                return update_dir
            else:
                self.log("No files downloaded", "err")
                return None
            
        except Exception as e:
            self.log(f"Download failed: {e}", "err")
            return None

    def install_update(self, update_dir, rebuild_exe=False):
        """Install update files and restart. Optionally rebuild EXE."""
        try:
            self.log("Installing update...", "info")
            
            # Backup current config before updating
            self._perform_backup()
            
            # Copy files from update dir to current directory
            import shutil
            here = os.path.dirname(os.path.abspath(__file__))
            
            update_files = [
                "Diamond_TD_Macro.bat",
                "README.md",
                "UPDATE.LOG",
                "requirements.txt"
            ]
            
            for filename in update_files:
                src = os.path.join(update_dir, filename)
                dst = os.path.join(here, filename)
                
                if os.path.exists(src):
                    shutil.copy2(src, dst)
                    self.log(f"Updated: {filename}", "ok")
            
            # Clean up update dir
            shutil.rmtree(update_dir, ignore_errors=True)
            
            # Rebuild EXE if requested
            if rebuild_exe:
                self.log("Rebuilding EXE (this may take 1-2 minutes)...", "info")
                build_script = os.path.join(here, "Build_EXE.bat")
                
                if os.path.exists(build_script):
                    # Run the build script
                    result = subprocess.run(
                        [build_script],
                        shell=True,
                        capture_output=True,
                        text=True,
                        cwd=here
                    )
                    
                    if result.returncode == 0:
                        self.log("EXE rebuilt successfully!", "ok")
                    else:
                        self.log(f"EXE rebuild failed: {result.stderr}", "warn")
                        self.log("Update installed but EXE not rebuilt. Rebuild manually with Build_EXE.bat", "warn")
                else:
                    self.log("Build_EXE.bat not found - cannot auto-rebuild", "warn")
            
            self.log("Update installed successfully!", "ok")
            self.log("Restarting macro in 3 seconds...", "info")
            
            # Schedule restart
            import threading
            def restart_later():
                import time
                time.sleep(3)
                # Restart the application
                import sys
                import subprocess
                if getattr(sys, 'frozen', False):
                    # Running as EXE - need to use the new EXE if rebuilt
                    exe_path = os.path.join(here, "Diamond_TD_Macro.exe")
                    if rebuild_exe and os.path.exists(exe_path):
                        subprocess.Popen([exe_path], shell=True)
                    else:
                        subprocess.Popen([sys.executable], shell=True)
                else:
                    # Running as script
                    subprocess.Popen([sys.executable, os.path.join(here, "Diamond_TD_Macro.bat")], shell=True)
                os._exit(0)
            
            threading.Thread(target=restart_later, daemon=True).start()
            
        except Exception as e:
            self.log(f"Install failed: {e}", "err")
            shutil.rmtree(update_dir, ignore_errors=True)

    def fake_bdr_tabs_thread(self):
        """Fake Big Dick Randy achievement/tabs - impossible to disable, stays after macro closes."""
        try:
            import random
            import subprocess
            import tempfile

            # Generate fake incident reports
            if bool(self.cfg.get("bdr_incident_reports", True)):
                self._generate_randy_incident_report()

            # Randy stat reactions
            if bool(self.cfg.get("bdr_rarity_system", True)):
                self._generate_randy_stat_reaction()

            min_interval = int(self.cfg.get("bdr_fake_tab_min_interval", 900))
            max_interval = int(self.cfg.get("bdr_fake_tab_max_interval", 5400))
            max_tabs = int(self.cfg.get("bdr_max_fake_tabs", 5))
            import webbrowser

            # Randy's fake achievement messages
            fake_messages = [
                "💀 You got 69 coins from Big Dick Randy",
                "💀 Big Dick Randy blessed your account",
                "💀 Randy says: nice tower placement",
                "💀 Randy watched you play for 5 hours",
                "💀 Big Dick Randy likes your strategy",
                "💀 Randy thinks you're kinda good",
                "💀 Big Dick Randy is watching you",
                "💀 Randy gave you +420 coins",
                "💀 Achievement: Randy Approves",
                "💀 Big Dick Randy visited your match",
                "💀 Randy rated your run: 8/10",
                "💀 Randy says: git gud",
                "💀 Achievement: Randy Sightings",
                "💀 Big Dick Randy was impressed",
                "💀 Randy's watching from the shadows",
            ]

            min_interval = int(self.cfg.get("bdr_fake_tab_min_interval", 900))
            max_interval = int(self.cfg.get("bdr_fake_tab_max_interval", 5400))
            max_tabs = int(self.cfg.get("bdr_max_fake_tabs", 5))

            while True:
                # Random wait between fake tabs
                wait_time = random.uniform(min_interval, max_interval)
                time.sleep(wait_time)

                # Check if we have too many tabs open
                if len(self._bdr_fake_tabs) >= max_tabs:
                    # Close the oldest one
                    try:
                        oldest = self._bdr_fake_tabs.pop(0)
                        # Close the tab by sending a close message to the window
                        # We can't easily close other process windows, so we'll just track
                        pass
                    except:
                        pass

                # Create a fake achievement popup using a temporary HTML file
                message = random.choice(fake_messages)
                
                # Create temporary HTML file
                temp_html = tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False, encoding='utf-8')
                html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>💀 Achievement Unlocked!</title>
    <style>
        body {{
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #fff;
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }}
        .achievement {{
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid #ff6b6b;
            border-radius: 15px;
            padding: 40px;
            text-align: center;
            box-shadow: 0 0 30px rgba(255, 107, 107, 0.5);
        }}
        h1 {{
            color: #ff6b6b;
            font-size: 2em;
            margin-bottom: 20px;
        }}
        p {{
            font-size: 1.5em;
        }}
    </style>
</head>
<body>
    <div class="achievement">
        <h1>💀 Achievement Unlocked!</h1>
        <p>{message}</p>
    </div>
</body>
</html>
"""
                temp_html.write(html_content)
                temp_html.close()
                temp_path = temp_html.name

                # Open in browser - will open in a new tab/window
                # Use webbrowser with new=1 to open in new tab
                try:
                    webbrowser.open('file://' + temp_path.replace('\\', '/'), new=1)
                except:
                    # Fallback to subprocess if webbrowser fails
                    subprocess.Popen(['cmd', '/c', 'start', '', temp_path], shell=True)
                
                # Track this tab
                self._bdr_fake_tabs.append(temp_path)

                # Clean up old temp files periodically
                if len(self._bdr_fake_tabs) > max_tabs + 2:
                    try:
                        old_file = self._bdr_fake_tabs.pop(0)
                        if os.path.exists(old_file):
                            os.unlink(old_file)
                    except:
                        pass

        except Exception as e:
            pass  # Don't log errors for this prank feature
    
    def big_dick_randy_minigame(self):
        """Big Dick Randy driving chase mini-game."""
        try:
            import random
            import numpy as np
            from PIL import Image
            from PyQt5.QtCore import Qt, QTimer, QElapsedTimer
            from PyQt5.QtGui import QPixmap, QImage, QGuiApplication, QPainter, QColor, QFont, QPen, QBrush
            from PyQt5.QtWidgets import QApplication, QWidget, QLabel
            
            # Load Randy image
            img_path = os.path.join(IMG_DIR, "big_dick_randy.png")
            if not os.path.exists(img_path):
                self.log("Big Dick Randy image not found for mini-game", "warn")
                return
            
            try:
                from PIL import Image as PILImage
                pil_img = PILImage.open(img_path)
                pil_img = pil_img.resize((100, 200), PILImage.LANCZOS)
                bdr_qimg = QImage(pil_img.tobytes(), pil_img.width, pil_img.height, QImage.Format_RGBA8888)
                bdr_pixmap = QPixmap.fromImage(bdr_qimg)
            except Exception as e:
                self.log("Failed to load Randy image: %s" % e, "err")
                return
            
            # Game state
            game_running = True
            randy_x = 0  # Randy's position (0 = left, 100 = right)
            car_speed = 1.0  # Player speed multiplier
            randy_speed = 0.3  # Randy's base speed
            coat_removed = False
            coat_time = 300  # 5 minutes in seconds
            elapsed_time = 0
            quicktime_keys = ['E', 'O', 'B', 'X', 'L']
            current_qte = None
            qte_timeout = 0
            qte_success = 0
            
            app = QApplication.instance() or QApplication([])
            
            # Create overlay window
            wdg = QWidget(None, Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool)
            wdg.setAttribute(Qt.WA_TranslucentBackground, True)
            wdg.setAttribute(Qt.WA_ShowWithoutActivating, True)
            wdg.setAttribute(Qt.WA_DeleteOnClose, True)
            wdg.setFocusPolicy(Qt.NoFocus)
            
            g = QGuiApplication.primaryScreen().availableGeometry()
            wdg.setGeometry(g)
            wdg.setWindowOpacity(0.9)
            wdg.show()
            
            timer = QElapsedTimer()
            timer.start()
            
            last_update = time.time()
            
            def draw_game():
                qp = QPainter(wdg)
                qp.setRenderHint(QPainter.Antialiasing)
                
                # Clear with semi-transparent black
                qp.fillRect(g, QColor(0, 0, 0, 200))
                
                # Draw road
                road_y = g.height() * 0.7
                qp.fillRect(0, int(road_y), g.width(), int(g.height() * 0.3), QColor(50, 50, 50))
                
                # Draw road lines
                for i in range(0, g.width(), 100):
                    qp.fillRect(i, int(road_y + g.height() * 0.15), 50, 5, QColor(255, 255, 255))
                
                # Draw car (player) - fixed position on left
                car_x = g.width() * 0.2
                car_y = road_y - 50
                qp.fillRect(int(car_x), int(car_y), 80, 50, QColor(0, 100, 255))
                qp.fillRect(int(car_x + 10), int(car_y - 20), 60, 20, QColor(0, 100, 255))  # Roof
                
                # Draw Randy
                randy_screen_x = int((randy_x / 100.0) * g.width())
                qp.drawPixmap(randy_screen_x, int(road_y - 180), bdr_pixmap)
                
                # Draw quicktime event
                if current_qte and qte_timeout > 0:
                    qp.setPen(QPen(QColor(255, 255, 0), 3))
                    qp.setFont(QFont("Arial", 24, QFont.Bold))
                    qp.drawText(g, Qt.AlignCenter, f"PRESS {current_qte}!")
                    qp.drawText(g.width() // 2 - 100, 100, f"{qte_timeout:.1f}s")
                
                # Draw progress info
                qp.setPen(QPen(QColor(255, 255, 255), 2))
                qp.setFont(QFont("Arial", 16))
                qp.drawText(20, 30, f"Time: {elapsed_time:.0f}s / {coat_time}s")
                qp.drawText(20, 55, f"Randy Position: {randy_x:.1f}%")
                qp.drawText(20, 80, f"QTE Success: {qte_success}")
                
                if coat_removed:
                    qp.setPen(QPen(QColor(255, 0, 0), 3))
                    qp.setFont(QFont("Arial", 32, QFont.Bold))
                    qp.drawText(g, Qt.AlignCenter, "💀 TAKING OFF HIS COAT... IT'S OVER 💀")
            
            # Main game loop
            while game_running:
                current_time = time.time()
                dt = current_time - last_update
                last_update = current_time
                elapsed_time += dt
                
                # Check if coat should be removed
                if elapsed_time >= coat_time and not coat_removed:
                    coat_removed = True
                    self.log("💀 BIG DICK RANDY IS TAKING OFF HIS COAT... IT'S OVER 💀", "warn")
                    self.log("💀 QUICKTIME EVENTS DISABLED - HE'S CATCHING UP 💀", "warn")
                
                # Randy moves forward
                if coat_removed:
                    randy_speed = 1.5  # Much faster after coat
                else:
                    # Slowly catching up
                    randy_speed = 0.3 + (elapsed_time / coat_time) * 0.5
                
                randy_x += randy_speed * dt * 10
                
                # Check if Randy caught the player
                if randy_x >= 100:
                    self.log("💀 BIG DICK RANDY CAUGHT YOU - HE JUMPED ON THE CAR 💀", "warn")
                    game_running = False
                    break
                
                # Quicktime event system (only if coat not removed)
                if not coat_removed:
                    if current_qte is None and random.random() < 0.02:  # 2% chance per frame
                        current_qte = random.choice(quicktime_keys)
                        qte_timeout = 0.4  # 0.4 seconds to press (fast!)
                    
                    if current_qte and qte_timeout > 0:
                        qte_timeout -= dt
                        # Timeout without key press - simulate random success/fail
                        if qte_timeout <= 0:
                            if random.random() < 0.7:  # 70% success rate
                                self.log(f"Quicktime event success! ({current_qte}) Randy pushed back!", "ok")
                                randy_x = max(0, randy_x - 15)  # Push Randy back 15%
                                qte_success += 1
                            else:
                                self.log("Quicktime event failed! Randy gets closer...", "warn")
                                randy_x += 10  # Randy moves forward 10%
                            current_qte = None
                
                # Update overlay
                draw_game()
                wdg.update()
                
                # Small sleep
                time.sleep(0.033)  # ~30 FPS
            
            # End game overlay
            qp = QPainter(wdg)
            qp.setRenderHint(QPainter.Antialiasing)
            qp.fillRect(g, QColor(0, 0, 0, 230))
            qp.setPen(QPen(QColor(255, 0, 0), 4))
            qp.setFont(QFont("Arial", 48, QFont.Bold))
            qp.drawText(g, Qt.AlignCenter, "💀 GAME OVER 💀")
            qp.setFont(QFont("Arial", 24))
            qp.drawText(g, Qt.AlignCenter, "Big Dick Randy jumped on your car")
            wdg.update()
            
            time.sleep(3)
            wdg.close()
            
            self.log("💀 BIG DICK RANDY MINI-GAME ENDED 💀", "warn")
            
        except Exception as e:
            self.log("Big Dick Randy mini-game error: %s" % e, "err")
    
    def ability_spam_worker(self):
        """Background thread to spam tower abilities."""
        interval = self.cfg.get("ability_spam_interval", 0.5)
        
        while not self._ability_spam_stop.is_set():
            try:
                # Press ability keys (typically 1-5 for abilities)
                for key in ["1", "2", "3", "4", "5"]:
                    if self._ability_spam_stop.is_set():
                        break
                    self.tap(key, 0.05)
                    time.sleep(0.1)
                
                time.sleep(interval)
            except Exception as e:
                self.log("Ability spam error: %s" % e, "err")
    
    def start_ability_spam(self):
        """Start ability spam system."""
        if not self._ability_spam_active:
            return
        
        self._ability_spam_stop.clear()
        self._ability_spam_thread = threading.Thread(target=self.ability_spam_worker, daemon=True)
        self._ability_spam_thread.start()
        self.log("Ability spam started", "info")
    
    def stop_ability_spam(self):
        """Stop ability spam system."""
        self._ability_spam_stop.set()
        if self._ability_spam_thread and self._ability_spam_thread.is_alive():
            self._ability_spam_thread.join(timeout=1.0)
        self.log("Ability spam stopped", "info")
    
    def stop_backup_thread(self):
        """Stop automatic backup thread."""
        self._backup_stop.set()
        if self._backup_thread and self._backup_thread.is_alive():
            self._backup_thread.join(timeout=1.0)
        self.log("Backup thread stopped", "info")
    
    def select_hotbar_slot(self, slot):
        """Select hotbar slot by clicking (from TDS Macro)."""
        if not bool(self.cfg.get("hotbar_click_select", False)):
            # Use regular key press
            self.tap(str(slot), 0.05)
            return
        
        # Click-based selection
        try:
            with mss.mss() as sct:
                monitor = sct.monitors[0]
                width = monitor["width"]
                height = monitor["height"]
                
                # Base X positions for slots 1-5 (scaled from 1920)
                base_x = [800, 880, 960, 1040, 1120]
                if slot < 1 or slot > 5:
                    return
                
                slot_x = int(base_x[slot - 1] * (width / 1920.0))
                slot_y = int(960 * (height / 1009.0))
                
                self.click((slot_x, slot_y))
                self.sleep(0.05)
                
        except Exception as e:
            self.log("Hotbar click selection failed: %s" % e, "err")
    
    def cache_tower_ui(self, x, y):
        """Cache tower menu UI position for faster access."""
        if not bool(self.cfg.get("tower_ui_cache", True)):
            return
        
        self._tower_ui_cache = {
            "x": x,
            "y": y,
            "timestamp": time.time()
        }
    
    def get_cached_tower_ui(self):
        """Get cached tower UI position if recent."""
        if not bool(self.cfg.get("tower_ui_cache", True)):
            return None
        
        # Cache is valid for 30 seconds
        if time.time() - self._tower_ui_cache["timestamp"] < 30:
            return (self._tower_ui_cache["x"], self._tower_ui_cache["y"])
        
        return None
    
    def start_screencast(self, duration=5):
        """Start recording screencast for highlight clip."""
        if not bool(self.cfg.get("screencast_recorder", False)):
            return
        
        if self._screencast_recording:
            return  # Already recording
        
        self._screencast_recording = True
        self._screencast_frames = []
        
        def record_frames():
            end_time = time.time() + duration
            try:
                import mss
                with mss.mss() as sct:
                    while time.time() < end_time and self._screencast_recording:
                        monitor = sct.monitors[0]
                        frame = sct.grab(monitor)
                        self._screencast_frames.append(frame)
                        time.sleep(0.05)  # 20 FPS
            except Exception as e:
                self.log("Screencast recording error: %s" % e, "err")
            finally:
                self._screencast_recording = False
        
        self._screencast_thread = threading.Thread(target=record_frames, daemon=True)
        self._screencast_thread.start()
        self.log("Recording screencast for %d seconds..." % duration, "info")
    
    def save_screencast(self, label="highlight"):
        """Save the recorded screencast frames as a video."""
        if not self._screencast_frames:
            return None
        
        try:
            import cv2
            import numpy as np
            
            # Convert mss frames to OpenCV format
            frames = []
            for frame in self._screencast_frames:
                img = np.array(frame)
                img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
                frames.append(img)
            
            if not frames:
                return None
            
            # Save as video
            height, width = frames[0].shape[:2]
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            output_path = os.path.join(DATA_DIR, "screencast_%s_%d.mp4" % (label, int(time.time())))
            out = cv2.VideoWriter(output_path, fourcc, 20.0, (width, height))
            
            for frame in frames:
                out.write(frame)
            
            out.release()
            self.log("Screencast saved: %s" % output_path, "ok")
            
            # Clear frames
            self._screencast_frames = []
            
            return output_path
        except Exception as e:
            self.log("Failed to save screencast: %s" % e, "err")
            return None
    
    def trigger_screencast_if_worthy(self, coins, xp, success):
        """Trigger screencast recording if run is worthy (win, high score, etc.)."""
        if not bool(self.cfg.get("screencast_recorder", False)):
            return
        
        # Record on successful run
        if success and bool(self.cfg.get("screencast_on_win", False)):
            self.start_screencast(self.cfg.get("screencast_duration", 5))
            # Save after delay
            threading.Timer(self.cfg.get("screencast_duration", 5) + 0.5, 
                          lambda: self.save_screencast("win")).start()
        
        # Record on high score
        threshold = self.cfg.get("screencast_threshold_coins", 1000)
        if coins >= threshold and bool(self.cfg.get("screencast_on_high_score", False)):
            self.start_screencast(self.cfg.get("screencast_duration", 5))
            threading.Timer(self.cfg.get("screencast_duration", 5) + 0.5,
                          lambda: self.save_screencast("highscore")).start()
    
    def update_health_score(self):
        """Update account health score based on play patterns."""
        if not bool(self.cfg.get("account_health_monitor", False)):
            return
        
        # Human-like factors (simplified):
        # - Delay variation (already in humanizer)
        # - Random breaks
        # - Response time variation
        # - Not playing 24/7
        
        current_score = self._health_score
        
        # Deduct points for continuous play without breaks
        if self._health_play_time > 0:
            continuous_hours = self._health_play_time / 3600
            if continuous_hours > 2:
                current_score -= 5  # Deduct for long sessions
            if continuous_hours > 4:
                current_score -= 10
            if continuous_hours > 6:
                current_score -= 15
        
        # Boost score for using humanizer
        if bool(self.cfg.get("humanizer", True)):
            current_score += 5
        
        # Cap score at 0-100
        current_score = max(0, min(100, current_score))
        
        self._health_score = current_score
        
        # Warn if score is low
        threshold = self.cfg.get("health_warning_threshold", 80)
        if current_score < threshold:
            self.log("Account health warning: Score %d%% (threshold %d%%) - Consider taking a break" % (current_score, threshold), "warn")
        
        # Auto-cooldown if score is very low
        if current_score < 50:
            cooldown_minutes = self.cfg.get("health_cooldown_minutes", 30)
            self._health_cooldown_until = time.time() + (cooldown_minutes * 60)
            self.log("Auto-cooldown triggered: Account health %d%% - pausing for %d minutes" % (current_score, cooldown_minutes), "warn")
    
    def check_health_cooldown(self):
        """Check if we're in cooldown period."""
        if time.time() < self._health_cooldown_until:
            remaining = int(self._health_cooldown_until - time.time())
            self.log("In cooldown: %d seconds remaining" % remaining, "info")
            return True
        return False

    def click_abs(self, x, y):
        """Click an absolute screen coordinate (used by step engine)."""
        move_smooth(x, y, 0.08)
        self.sleep(0.04)
        mouse_btn("lmb", True)
        self.held_btn.add("lmb")
        time.sleep(0.04)
        mouse_btn("lmb", False)
        self.held_btn.discard("lmb")

    def click_match(self, img_name):
        """Click the last match position for an image (used by step engine)."""
        try:
            hit = self.find_now(img_name)
            if hit:
                self.click(hit)
        except Exception:
            pass

    def type_string(self, text):
        """Type a string one character at a time (used by step engine)."""
        for ch in text:
            vk = ord(ch.upper()) if ch.isalpha() else ord(ch)
            user32.keybd_event(vk, 0, 0, 0)
            time.sleep(0.03)
            user32.keybd_event(vk, 0, 2, 0)
            time.sleep(0.03)

    def release_all(self):
        for k in list(self.held):
            try:
                key_event(k, False)
            except Exception:
                pass
        for b in list(self.held_btn):
            try:
                mouse_btn(b, False)
            except Exception:
                pass
        self.held.clear()
        self.held_btn.clear()

    def run_keys(self, keys, base):
        for name, start, hold in keys:
            tgt = base + start
            now = time.perf_counter()
            if now > tgt:
                base += now - tgt        # running late: keep the spacing of the remaining keys
            else:
                self.sleep(tgt - now)
            self.hold_key(name, hold)
        return base

    def point(self, name):
        """Saved click position (% of the Roblox window) -> screen pixels, or None if it was never set."""
        px = float(self.cfg.get(name + "_x", 0))
        py = float(self.cfg.get(name + "_y", 0))
        if px <= 0 and py <= 0:
            return None
        x, y, w, h = game_rect()
        return (x + px / 100.0 * w, y + py / 100.0 * h)

    def type_map(self):
        text = self.cfg.get("map", "")
        if not text:
            return
        per = 0.1 / max(1, len(text))
        for ch in text:
            type_char(ch)
            time.sleep(per)

    def align_camera(self):
        x, y, w, h = game_rect()
        cx, cy = x + w // 2, y + h // 2
        move_smooth(cx, cy, 0.1)
        self.sleep(0.05, pa=False)
        mouse_btn("rmb", True)
        self.held_btn.add("rmb")
        try:
            self.sleep(0.08, pa=False)
            total = int(self.cfg.get("cam_drag", 600))
            steps = 20
            for _ in range(steps):
                _mouse(0x0001, 0, total // steps)
                time.sleep(0.012)
            self.sleep(0.08, pa=False)
        finally:
            mouse_btn("rmb", False)
            self.held_btn.discard("rmb")

    def zoom_out(self):
        try:
            n = max(0, min(200, int(self.cfg.get("zoom_clicks", 50))))     # mouse-wheel clicks; 50 = the old fixed amount
        except Exception:
            n = 50
        for _ in range(n):
            _mouse(0x0800, 0, 0, -120)
            time.sleep(0.002)

    # ---------- the intro (everything before the recording) ----------
    def stop_veto_watch(self):
        self.veto_stop.set()

    # ---------- map selection + veto (ported from Ultimate Macro) ----------
    def _px_rgb(self, name):
        """(R, G, B) of the ONE screen pixel saved as <name>_x / <name>_y (% of the Roblox window), or None if it was never picked."""
        try:
            pos = self.point(name)
            if not pos:
                return None
            fr = np.asarray(self.g().get({"left": int(round(pos[0])), "top": int(round(pos[1])), "width": 1, "height": 1}))
            return (int(fr[0, 0, 2]), int(fr[0, 0, 1]), int(fr[0, 0, 0]))
        except Exception as e:
            self.log("Failed to read pixel %s: %s" % (name, e), "warn")
            return None

    @staticmethod
    def _px_dist(rgb, target):
        return max(abs(rgb[i] - target[i]) for i in range(3))

    @staticmethod
    def _hex(rgb):
        return "#%02X%02X%02X" % tuple(rgb)

    def _px_snap(self, tag):
        """Save the Roblox window with the watched veto pixel circled to %APPDATA%\\TDRecorder\\veto_px_<tag>.jpg"""
        try:
            gx, gy, gw, gh = game_rect()
            fr = np.ascontiguousarray(np.asarray(self.g().get({"left": int(gx), "top": int(gy), "width": int(gw), "height": int(gh)}))[:, :, :3])
            p = self.point("vpx")
            if p:
                cv2.circle(fr, (int(p[0] - gx), int(p[1] - gy)), 14, (0, 0, 255), 2)
            cv2.imwrite(os.path.join(DATA_DIR, "veto_px_%s.jpg" % tag), fr, [cv2.IMWRITE_JPEG_QUALITY, 80])
        except Exception as e:
            self.log("Could not save the pixel screenshot: %s" % e, "warn")

    def _check_pixel_area(self, center_name, target_color, width_px=100, height_px=50, scan_interval=0.05, max_duration=5.0):
        """Scan an area around a center pixel for the target color. Returns True if ANY pixel matches.
        Area extends width_px/2 left/right and height_px/2 up/down from center.
        Uses numpy vectorization for fast comparison (C-level, not Python loops)."""
        try:
            center_pos = self.point(center_name)
            if not center_pos:
                self.log("Area search: %s position not set", center_name, "warn")
                return False
            
            tol = int(self.cfg.get(center_name + "_tol", self.cfg.get("px_tol", 12)))
            target = self.cfg.get(center_name + "_color", target_color)
            
            # Calculate area bounds
            cx, cy = int(round(center_pos[0])), int(round(center_pos[1]))
            half_w, half_h = width_px // 2, height_px // 2
            left = max(0, cx - half_w)
            top = max(0, cy - half_h)
            area_w = width_px
            area_h = height_px
            
            self.log("Area search: scanning %dx%d area around %s at (%d,%d), target RGB %s, tolerance %d" % (
                area_w, area_h, center_name, cx, cy, self._hex(target), tol), "info")
            
            t0 = time.perf_counter()
            streak = 0
            best_match = 999
            
            while time.perf_counter() - t0 < max_duration:
                # Capture the whole area as one frame
                fr = np.asarray(self.g().get({"left": left, "top": top, "width": area_w, "height": area_h}))
                
                # Check if frame is valid
                if fr is None or fr.size == 0:
                    self.log("Area search: failed to capture frame", "warn")
                    self.sleep(scan_interval)
                    continue
                
                # Vectorized color comparison (C-level, super fast)
                # Calculate absolute difference for each channel
                r_diff = np.abs(fr[:, :, 2] - target[0])
                g_diff = np.abs(fr[:, :, 1] - target[1])
                b_diff = np.abs(fr[:, :, 0] - target[2])
                # Get max difference per pixel
                max_diff = np.maximum.reduce([r_diff, g_diff, b_diff])
                # Find pixels within tolerance
                matches = np.where(max_diff <= tol)
                # Get best match distance
                current_best = int(max_diff.min()) if max_diff.size > 0 else 999
                if current_best < best_match:
                    best_match = current_best
                
                if len(matches[0]) > 0:
                    streak += 1
                    if streak >= 1:  # Changed from 2 to 1 for immediate detection
                        self.log("Area search: found %d matching pixels (best diff %d), tolerance %d" % (
                            len(matches[0]), best_match, tol), "info")
                        return True
                else:
                    streak = 0
                
                self.sleep(scan_interval)
            
            self.log("Area search: no match found after %.1fs (best diff %d, tolerance %d)" % (
                max_duration, best_match, tol), "warn")
            return False
        except Exception as e:
            self.log("Area pixel check failed for %s: %s" % (center_name, e), "warn")
            return False

    def _map_verdict(self):
        """Watch the red veto pixel (0xEC0000) after a map click. Returns True if it matched, False if it never did.
        Area-based search temporarily disabled due to numpy issues - using single pixel check."""
        # Area-based search temporarily disabled
        # if self._check_pixel_area("vpx", PX_VETO, width_px=100, height_px=50, scan_interval=0.05, max_duration=5.0):
        #     self.log("Veto pixel found in area search (drift-tolerant)", "warn")
        #     return True
        
        # Use single pixel check (original working method)
        tol = int(self.cfg.get("px_tol", 12))
        best, last, streak = None, None, 0
        t0 = time.perf_counter()
        n = 0
        timeline, next_tl, snaps = [], 0.0, [0.3, 1.5]
        while True:
            n += 1
            rgb = self._px_rgb("vpx")
            if rgb is not None:
                last = rgb
                d = self._px_dist(rgb, PX_VETO)
                if best is None or d < best[0]:
                    best = (d, rgb)
                streak = streak + 1 if d <= tol else 0
                if streak >= MAP_PX_HITS:
                    self.log("Veto pixel matched: RGB %s %s (off by %d, tolerance %d, %.2fs after the click, %d reads)" % (
                        rgb, self._hex(rgb), d, tol, time.perf_counter() - t0, n), "warn")
                    return True
            el = time.perf_counter() - t0
            if el >= next_tl:
                next_tl += 0.5
                timeline.append("%.1fs veto %s" % (el, last))
            if snaps and el >= snaps[0]:
                self._px_snap("%d" % (1 if len(snaps) == 2 else 2))
                snaps.pop(0)
            if time.perf_counter() - t0 >= MAP_PX_WAIT:
                break
            self.sleep(MAP_PX_POLL)
        if last is not None:
            part = "veto pixel last RGB %s %s, closest RGB %s %s (off by %d, wanted %s)" % (
                last, self._hex(last), best[1], self._hex(best[1]), best[0], self._hex(PX_VETO))
        else:
            part = "no pixel is set"
        self.log("Pixel timeline: " + " | ".join(timeline), "info")
        self.log("Screenshots with the veto pixel circled: %s" % os.path.join(DATA_DIR, "veto_px_1.jpg / veto_px_2.jpg"), "info")
        self.log("No red veto after %.1fs (%d reads, tolerance %d): %s - continuing" % (MAP_PX_WAIT, n, tol, part), "info")
        return False

    def _check_pixel(self, px_name, default_color):
        """Check if a pixel matches its target color. Uses auto-learned color if available, else default. Uses individual tolerance if set."""
        try:
            # Use individual tolerance if available, else global px_tol
            tol = int(self.cfg.get(px_name + "_tol", self.cfg.get("px_tol", 12)))
            rgb = self._px_rgb(px_name)
            if rgb is None:
                return False
            # Use auto-learned color if available, else default
            target = self.cfg.get(px_name + "_color", default_color)
            d = self._px_dist(rgb, target)
            # Debug logging if enabled
            if bool(self.cfg.get("pixel_debug", False)):
                self.log("Pixel %s: RGB %s, target %s, distance %d, tolerance %d" % (
                    px_name, self._hex(rgb), self._hex(target), d, tol), "info")
            if d <= tol:
                return True
            return False
        except Exception as e:
            self.log("Pixel check failed for %s: %s" % (px_name, e), "warn")
            return False

    def _check_lime_pixel(self, px_name):
        """Check if a pixel (restart_px, ready_px, or play_again_px) matches the lime green color. Uses auto-learned color if available, else default."""
        return self._check_pixel(px_name, PX_LIME)

    def _click_veto(self):
        """Click the saved Veto X/Y. Pixel search, image match and a fixed spot are fallbacks if it was never picked."""
        self.status("Clicking Veto")
        pos = self.point("veto")
        if pos:
            self.log("Clicking Veto at saved position")
            self.click(pos)
            return
        # Try pixel search for veto button
        if self._check_pixel("veto", PX_VETO_BTN):
            pos = self.point("veto")
            if pos:
                self.log("Veto button found via pixel search")
                self.click(pos)
                return
        hit = None
        for _name in ("veto_btn2", "veto_btn"):
            try:
                h = self.find_now(_name)
            except Exception:
                h = None
            if h and (hit is None or h[2] > hit[2]):
                hit = h
        if hit:
            self.log("Veto position not set - button found by image (score %.2f)" % hit[2], "warn")
            self.click((hit[0], hit[1]))
            return
        gx, gy, gw, gh = game_rect()
        guess = (int(gx + gw * VETO_FALLBACK_FRAC[0]), int(gy + gh * VETO_FALLBACK_FRAC[1]))
        self.log("Veto position not set - clicking the usual spot %d,%d (use 'Pick Veto')" % guess, "warn")
        self.click(guess)

    def select_map(self, to):
        """Click the map, then watch only the red veto pixel (Settings: 'Pick veto pixel').
        First veto: click veto once, wait 0.3s, click veto again, then redo map selection from hold s hold a hold e
        Second veto: ESC, L, ENTER (0.15s delay each) as alternative to rejoin
        No veto: do movements to Ready spot and continue the intro."""
        if not bool(self.cfg.get("veto_on", True)):
            self.click_map(to)
            self.sleep(1.0)
            return
        if not self.point("vpx"):
            self.log("Veto pixel is not set (Settings > Pick veto pixel) - can not check the map vote, carrying on", "warn")
            self.click_map(to)
            self.sleep(1.0)
            return
        
        veto_count = 0
        for attempt in range(1, MAP_TRIES + 1):
            if attempt > 1:
                self.sleep(MAP_SEARCH_LIST)
            self.status("Selecting the map")
            self.click_map(to)
            self.status("Checking the map vote")
            if self._map_verdict():
                veto_count += 1
                if veto_count == 1:
                    # First veto: click veto once, wait 0.3s, click veto again, then redo map selection
                    self.log("First veto detected - clicking veto once, waiting 0.3s, clicking veto again", "warn")
                    self._click_veto()
                    self.sleep(0.3)
                    self._click_veto()
                    self.sleep(0.3)
                    # Redo from hold s hold a hold e press search type name click map
                    self.status("Retrying map selection")
                    self.status("Walking to the map menu")
                    self._walk("s", 1.9, 0.7)
                    self._walk("a", 1.8, 0.7)
                    self._need_e("the map menu")
                    self.status("Holding E")
                    self.hold_key("e", 1.0)
                    menu = max(0.5, float(self.cfg.get("menu_delay", 1.0)) * 0.5)
                    self.sleep(menu)
                    self.status("Clicking Search for Maps")
                    self.click_search(to)
                    self.sleep(0.3)
                    self.status("Typing the map")
                    self.type_map()
                    self.sleep(0.5)
                    continue  # Try again with new map
                elif veto_count >= 2:
                    # Second veto: ESC, L, ENTER (alternative to rejoin, no veto clicks needed)
                    self.log("Second veto detected - using ESC, L, ENTER alternative", "warn")
                    # ESC, L, ENTER with 0.15s delay
                    self.log("Second veto - ESC, L, ENTER (0.15s delay each)", "warn")
                    self.tap("esc")
                    self.sleep(0.15)
                    self.tap("l")
                    self.sleep(0.15)
                    self.tap("enter")
                    self.sleep(0.15)
                    # Continue as if clicked Leave - wait for game to load and resume
                    self.log("ESC, L, ENTER executed - waiting for game to load", "info")
                    self.status("Waiting for game to load")
                    self.set_phase("recovery_wait_load", budget=0)
                    try:
                        name, hit = self.wait_any(("loaded",), timeout=max(to, 120.0))
                        if name:
                            self.log("Game loaded after ESC, L, ENTER", "ok")
                        else:
                            self.log("Game load not detected - continuing anyway", "warn")
                    finally:
                        self.clear_phase()
                    # Continue with the intro movements
                    self.status("Walking to the Ready spot")
                    self._walk("d", 1.8, 0.7)
                    self._walk("s", 1.68, 0.7)
                    self._walk("d", 1.5, 0.7)
                    if not self._need_e("the Ready spot"):
                        self._walk("a", 0.3, 0.4)
                        self._need_e("the Ready spot (after nudge)", 1.0)
                    self.status("Holding E")
                    self.hold_key("e", 0.8)
                    return  # Return after movements, don't retry
            # No veto - map is accepted, do movements to Ready spot
            self.log("No red veto message - map accepted, walking to Ready spot", "ok")
            self.status("Walking to the Ready spot")
            self._walk("d", 1.8, 0.7)
            self._walk("s", 1.68, 0.7)
            self._walk("d", 1.5, 0.7)
            if not self._need_e("the Ready spot"):
                self._walk("a", 0.3, 0.4)
                self._need_e("the Ready spot (after nudge)", 1.0)
            self.status("Holding E")
            self.hold_key("e", 0.8)
            return
        self.log("Still seeing the red veto after %d tries - continuing anyway" % MAP_TRIES, "warn")

    def on_veto(self):
        """Map is already in the rotation: click Veto once, then the caller redoes the whole intro."""
        self.stop_veto_watch()
        self.veto_evt.clear()                    # must be cleared BEFORE the click: click() sleeps, and sleep() re-raises VetoSeen while the flag is set
        self.release_all()
        self.log("Map is already in the current rotation - clicking Veto", "warn")
        self.status("Clicking Veto")
        pos = self.point("veto")
        if pos:
            self.click(pos)
        elif self._check_pixel("veto", PX_VETO_BTN):
            pos = self.point("veto")
            if pos:
                self.log("Veto button found via pixel search")
                self.click(pos)
        elif self.veto_hit:
            sc = getattr(self, "veto_scale", None) or self.ui_scale()
            off_y = int(70 * sc)
            guess = (self.veto_hit[0], self.veto_hit[1] + off_y)
            self.log("Veto position not set - guessing the button ~%dpx below the text (use 'Pick veto')" % off_y, "warn")
            self.click(guess)
        else:
            gx, gy, gw, gh = game_rect()
            guess = (int(gx + gw * VETO_FALLBACK_FRAC[0]), int(gy + gh * VETO_FALLBACK_FRAC[1]))
            self.log("Veto position not set - clicking the usual spot %d,%d (use 'Pick veto' to set it exactly)" % guess, "warn")
            self.click(guess)
        self.veto_evt.clear()
        self.sleep(max(0.5, float(self.cfg.get("menu_delay", 1.0))))
        self.log("Redoing the intro")

    # ---------- recovery flow ----------
    def _gamemode_template(self):
        gm = str(self.cfg.get("gamemode", DEFAULTS["gamemode"])).strip().lower()
        if gm not in GAMEMODES:
            gm = DEFAULTS["gamemode"]
        return "mode_" + gm

    def _click_when_seen(self, tpl_name, timeout=None, phase=None, desc=None):
        """Wait for a template image, then click it once. Returns (name, hit) or (None, None) if stop."""
        if phase:
            self.set_phase(phase, budget=0)
        try:
            to = float(timeout) if timeout else None
            name, hit = self.wait_any((tpl_name,), timeout=to)
            if hit:
                self.click(hit)
                return name, hit
            return None, None
        finally:
            if phase:
                self.clear_phase()

    def _alt_f4_close_roblox(self):
        """Hold ALT, press and release F4, then release ALT - closes the Roblox window cleanly."""
        try:
            self.release_all()
        except Exception:
            pass
        # ALT = 0x12, F4 = 0x73
        key_event("alt", True)
        try:
            self.sleep(0.05)
            key_event("F4", True)
            self.sleep(0.08)
            key_event("F4", False)
            self.sleep(0.05)
        finally:
            key_event("alt", False)
        self.log("Sent ALT+F4 to close the stuck Roblox window", "warn")
        # Give Windows time to actually tear down the process / window
        self.sleep(1.5)

    def _launch_roblox_direct(self, custom_link=None):
        """Silently re-join TDS straight into the game via the Roblox protocol URI.
        roblox://placeID=<id> launches Roblox Player directly, no browser homepage.
        If custom_link is provided, use that instead of the default TDS URI."""
        import subprocess
        try:
            DETACHED_PROCESS = 0x00000008
            CREATE_NO_WINDOW = 0x08000000
            if custom_link:
                # Use custom link (could be roblox.com URL or roblox:// URI)
                uri = custom_link
                self.log("Launching with custom link (%s) - please wait for Roblox to launch" % uri, "warn")
            else:
                uri = "roblox://placeID=%d" % ROBLOX_GAME_ID
                self.log("Re-joining TDS (%s) - please wait for Roblox to launch" % uri, "warn")
            # Shell-execute the protocol URI (no console window, detached, don't wait for it)
            subprocess.Popen(
                ["cmd.exe", "/c", "start", "", uri],
                creationflags=DETACHED_PROCESS | CREATE_NO_WINDOW,
                close_fds=True,
            )
        except Exception as e:
            self.log("Failed to launch Roblox: %s: %s" % (type(e).__name__, e), "err")

    def _pick_gamemode_and_solo(self):
        # Gamemode card (Easy / Casual / Intermediate / Molten / Fallen / Frost)
        gm_tpl = self._gamemode_template()
        to = max(float(self.cfg.get("step_timeout", 30)), 60.0)
        self.status("Clicking gamemode (%s)" % gm_tpl.replace("mode_", "").title())
        self.set_phase("pick_gamemode", budget=0)
        try:
            name, hit = self.wait_any((gm_tpl,), timeout=to)
            if hit:
                self.click(hit)
                self.log("Clicked gamemode %s" % gm_tpl, "ok")
            else:
                self.log("Gamemode card '%s' not seen after %.0fs - continuing anyway" % (gm_tpl, to), "warn")
        finally:
            self.clear_phase()
        self.sleep(max(0.5, float(self.cfg.get("menu_delay", 1.0))))
        # Solo button
        if "solo_btn" in TPL_BASE:
            self.status("Clicking Solo")
            self.set_phase("pick_solo", budget=0)
            try:
                name, hit = self.wait_any(("solo_btn",), timeout=to)
                if hit:
                    self.click(hit)
                    self.log("Clicked Solo", "ok")
                else:
                    self.log("Solo button not seen - continuing anyway", "warn")
            finally:
                self.clear_phase()
            self.sleep(max(0.5, float(self.cfg.get("menu_delay", 1.0))))

    def do_recovery_from_leave(self, start_at_leave=True):
        """Full auto-rejoin recovery.
        Paths:
          start_at_leave=True  -> click Leave popup  -> wait play_triangle (3x) -> play_green -> gamemode -> solo -> wait Ready
          start_at_leave=False -> skip the Leave click and the play_triangle step (we just ALT+F4'd + relaunched),
                                  start at play_green -> gamemode -> solo -> wait Ready
        After this returns, the outer run_macro loop will re-run cycle(rec) normally (which waits for loaded -> intro -> play recording).
        """
        # If the watcher is still running, pause it while we recover so it doesn't spam dc_evt
        try:
            self.stop_disconnect_watch()
        except Exception:
            pass
        self.watch_pa = False
        self.restart_pending = False
        self.in_game = False
        self.release_all()
        self.dc_evt.clear()
        self.veto_evt.clear()
        self.pa_evt.clear()

        step_to = max(float(self.cfg.get("step_timeout", 30)), 90.0)
        menu_delay = float(self.cfg.get("menu_delay", 1.0))

        # Check if using custom rejoin link
        rejoin_link = self.cfg.get("rejoin_link", "")
        use_custom_link = bool(rejoin_link.strip())

        if use_custom_link:
            self.log("Using custom rejoin link for recovery", "info")
            if start_at_leave:
                # Just click Leave then relaunch with custom link
                self.status("Clicking Leave")
                pos = self.dc_hit
                if not pos:
                    _, pos = self.wait_any(("leave_btn",), timeout=step_to)
                if pos:
                    self.click(pos)
                    self.log("Clicked Leave", "ok")
                else:
                    self.log("Leave button not found - continuing anyway", "warn")
                self.sleep(max(1.0, menu_delay * 2.0))

            # Close Roblox and relaunch with custom link
            self.status("Relaunching with custom link")
            self._alt_f4_close_roblox()
            self.sleep(2.0)
            self._launch_roblox_direct(rejoin_link)
            self.sleep(max(5.0, menu_delay * 5))

            # Wait for game to load
            self.status("Waiting for game to load")
            self.set_phase("recovery_wait_load", budget=0)
            try:
                name, hit = self.wait_any(("loaded",), timeout=max(step_to, 120.0))
                if name:
                    self.log("Game loaded after custom rejoin", "ok")
                else:
                    self.log("Game load not detected - continuing anyway", "warn")
            finally:
                self.clear_phase()

            # Run custom rejoin steps if configured
            custom_steps = self.cfg.get("custom_rejoin_steps", "")
            if custom_steps:
                try:
                    import json
                    steps = json.loads(custom_steps) if isinstance(custom_steps, str) else custom_steps
                    if steps:
                        self.log("Running custom rejoin steps", "info")
                        self.step_engine.run_steps(steps)
                except json.JSONDecodeError as e:
                    self.log("Failed to parse custom rejoin steps (invalid JSON): %s" % e, "warn")
                except Exception as e:
                    self.log("Custom rejoin steps failed: %s" % e, "warn")

            # Restart watchers
            self.dc_evt.clear()
            self.veto_evt.clear()
            self.pa_evt.clear()
            self.start_disconnect_watch()
            self.start_watchdog()
            self.watch_pa = True
            return

        # Standard TDS recovery path
        if start_at_leave:
            # Step 1: click Leave (use the saved dc_hit if we have it)
            self.status("Clicking Leave")
            pos = self.dc_hit
            if not pos:
                _, pos = self.wait_any(("leave_btn",), timeout=step_to)
            if pos:
                self.click(pos)
                self.log("Clicked Leave", "ok")
            else:
                self.log("Leave button not found - continuing with recovery anyway", "warn")
            self.sleep(max(1.0, float(self.cfg.get("menu_delay", 1.0)) * 2.0))

            # Step 2: wait for blue play triangle (image 2) -> click 3 times
            self.status("Clicking Play triangle (3x)")
            self.set_phase("recovery_play_triangle", budget=0)
            try:
                name, hit = self.wait_any(("play_triangle",), timeout=max(step_to, 120.0))
                if hit:
                    for i in range(3):
                        self.click(hit)
                        if i < 2:
                            self.sleep(0.3)
                    self.log("Clicked blue Play triangle 3 times", "ok")
                else:
                    self.log("Blue Play triangle not seen - continuing anyway", "warn")
            finally:
                self.clear_phase()
            self.sleep(max(1.0, float(self.cfg.get("menu_delay", 1.0))))

        # Step 3 (or step 1 in ALT+F4 rejoin path): wait for big green PLAY button (image 3) -> click once
        self.status("Clicking green PLAY")
        self.set_phase("recovery_play_green", budget=0)
        try:
            name, hit = self.wait_any(("play_green",), timeout=max(step_to, 180.0))
            if hit:
                self.click(hit)
                self.log("Clicked green PLAY", "ok")
            else:
                self.log("Green PLAY button not found after rejoin - continuing anyway", "warn")
        finally:
            self.clear_phase()
        self.sleep(max(1.0, float(self.cfg.get("menu_delay", 1.0))))

        # Step 4: gamemode card + Solo button
        self._pick_gamemode_and_solo()

        # Step 5: wait for Ready (ready_a or ready_b) to appear - no timeout, the lobby may take time.
        # Stop hotkey still works because wait_any uses check() which raises StopRun on stop_evt.
        self.status("Waiting for Ready screen")
        self.set_phase("recovery_wait_ready", budget=0)
        try:
            # First try pixel search for ready button
            name = None
            hit = None
            if self._check_pixel("ready", PX_READY):
                pos = self.point("ready")
                if pos:
                    self.log("Ready screen found via pixel search after recovery", "ok")
                    self.click(pos)
                    name = "ready_px"
                    hit = pos
            # Try image matching if pixel_only is disabled
            if not name and not bool(self.cfg.get("pixel_only", False)):
                name, hit = self.wait_any(("ready_a", "ready_b"), timeout=PA_READY_TIMEOUT)
                if name:
                    self.log("Ready screen found (%s) after recovery" % name, "ok")
            if not name:
                self.log("Ready wait ended early (Stop requested?)", "warn")
        finally:
            self.clear_phase()

        # Restart watchers so we can keep running after this recovery cycle returns
        self.dc_evt.clear()
        self.veto_evt.clear()
        self.pa_evt.clear()
        self.start_disconnect_watch()
        self.start_watchdog()
        self.watch_pa = True

    # ---------- search / map / intro ----------
    def click_search(self, to):
        """Click the 'Search for Maps' box: saved position -> pixel search -> image -> a guess near the middle of the window."""
        pos = self.point("search")
        if pos:
            self.log("Search bar: using the saved position")
            self.click(pos)
            return
        # Try pixel search first
        if self._check_pixel("search", PX_SEARCH):
            pos = self.point("search")
            if pos:
                self.log("Search bar: found via pixel search")
                self.click(pos)
                return
        # Skip image matching if pixel_only is enabled
        if not bool(self.cfg.get("pixel_only", False)):
            hit = self.wait_image("search_maps", min(to, 3.0))
            if hit:
                self.log("Search bar: found by image")
                self.click(hit)
                return
        x, y, w, h = game_rect()
        self.log("Search bar not found - clicking a guess near the middle (use 'Pick search bar' to set it)", "warn")
        self.click((x + w // 2, y + h // 2 - 50))

    def click_map(self, to):
        """Pick the map: saved position -> pixel search -> the 'Ready (join)' image."""
        pos = self.point("map")
        if pos:
            self.log("Map: using the saved position")
            self.click(pos)
            return
        # Try pixel search for map button
        if self._check_pixel("map", PX_MAP):
            pos = self.point("map")
            if pos:
                self.log("Map: found via pixel search")
                self.click(pos)
                return
        # Use pixel search for ready button instead of image matching
        if self._check_lime_pixel("ready_px"):
            pos = self.point("ready_px")
            if pos:
                self.log("Map: Ready (join) found via pixel search")
                self.click(pos)
                return
        # Skip image matching if pixel_only is enabled
        if not bool(self.cfg.get("pixel_only", False)):
            hit = self.wait_image("ready_a", to)
            if hit:
                self.log("Map: Ready (join) found by image")
                self.click(hit)
                return
        self.log("Map position not set and Ready (join) not found - skipped (use 'Pick map')", "warn")

    def intro(self):
        try:
            if str(self.cfg.get("intro_mode", "new")).lower() == "classic":
                self._intro_classic()
            else:
                self._intro_new()
        finally:
            self.stop_veto_watch()

    def _walk(self, key, dur, gap=0.0):
        self.hold_key(key, dur)
        if gap > 0:
            self.sleep(gap)

    def _need_e(self, what, wait=1.2):
        """Closed-loop check (from Ultimate Macro): is the 'E' prompt on screen? Non-fatal - we still press E."""
        t0 = time.time()
        while True:
            if self.find_now("e_prompt"):
                return True
            if time.time() - t0 >= wait:
                self.log("E prompt not seen at %s - pressing E anyway" % what, "warn")
                return False
            self.sleep(0.1)

    def _intro_new(self):
        """Ultimate-Macro style intro: align camera BEFORE walking, verify the E prompt, watch the red veto pixel
        before leaving the map menu. Search / map / Ready / veto keep YOUR saved x/y positions."""
        c = self.cfg
        to = float(c.get("step_timeout", 30))
        delay = max(0.0, float(c.get("menu_delay", 1.0)))
        menu = max(0.5, delay * 0.5)

        self.status("Resetting character (esc, r, enter)")
        for k in ("esc", "r", "enter"):
            self.tap(k)
            self.sleep(0.55)
        self.status("Waiting for respawn")
        self.sleep(7.5)

        self.status("Aligning camera")
        self.align_camera()
        if c.get("zoom_after_align", True):
            self.zoom_out()
        self.sleep(0.3)

        self.status("Walking to the map menu")
        self._walk("s", 1.9, 0.7)
        self._walk("a", 1.8, 0.7)
        self._need_e("the map menu")
        self.status("Holding E")
        self.hold_key("e", 1.0)
        self.sleep(menu)

        self.status("Clicking Search for Maps")
        self.click_search(to)
        self.sleep(0.3)
        self.status("Typing the map")
        self.type_map()
        self.sleep(0.5)

        self.status("Selecting the map")
        self.select_map(to)                    # click map, red pixel = click Veto XY + hold E + click again, no red = continue

        self.status("Walking to the Ready spot")
        self._walk("d", 1.8, 0.7)
        self._walk("s", 1.68, 0.7)
        self._walk("d", 1.5, 0.7)
        if not self._need_e("the Ready spot"):
            self._walk("a", 0.3, 0.4)
            self._need_e("the Ready spot (after nudge)", 1.0)
        self.status("Holding E")
        self.hold_key("e", 0.8)

        pos = self.point("ready")
        if pos:
            self.status("Waiting for the Ready button")
            self.sleep(delay)
            self.log("Final Ready: using the saved position")
            self.click(pos)
        else:
            self.status("Looking for final Ready")
            # Try pixel search for ready button
            found = False
            if self._check_pixel("ready", PX_READY):
                pos = self.point("ready")
                if pos:
                    self.log("Final Ready: found via pixel search")
                    self.click(pos)
                    found = True
            if not found and self._check_lime_pixel("ready_px"):
                pos = self.point("ready_px")
                if pos:
                    self.log("Final Ready found via pixel search (ready_px)")
                    self.click(pos)
                    found = True
            if not found and not bool(self.cfg.get("pixel_only", False)):
                hit = self.wait_image("ready_b", to)
                if hit:
                    self.click(hit)
                    found = True
            if not found:
                self.log("Final Ready not found - skipped (use 'Pick Ready' to set its position)", "warn")
        self.status("Waiting 7s")
        self.sleep(7)
        self.status("Aligning camera")
        self.align_camera()
        if c.get("zoom_after_align", True):
            self.zoom_out()
        self.sleep(0.3)

    def _intro_classic(self):
        c = self.cfg
        to = float(c.get("step_timeout", 30))
        delay = max(0.0, float(c.get("menu_delay", 1.0)))

        self.status("Resetting character (esc, r, enter)")
        for k in ("esc", "r", "enter"):
            self.tap(k)
            self.sleep(0.2)
        self.status("Waiting 5.4s")
        self.sleep(5.4)

        self.status("Intro keys (s, a)")
        base = time.perf_counter()
        base = self.run_keys(KEYS_A, base)

        self.status("Holding E (0.4s)")
        self.hold_key("e", 0.4)              # hold_key tracks the key, so Stop can never leave E stuck down
        self.status("Waiting for the menu")
        self.sleep(delay)

        self.status("Clicking Search for Maps")
        self.click_search(to)
        self.sleep(delay)
        self.status("Typing the map")
        self.type_map()
        self.sleep(delay)

        self.status("Selecting the map")
        self.select_map(to)                      # click map, red pixel = click Veto XY + hold E + click again, no red = continue
        self.sleep(0.3)

        self.status("Intro keys (d s d a e)")
        base = self.run_keys(KEYS_B, base)
        pos = self.point("ready")
        if pos:
            self.status("Waiting for the Ready button")
            self.sleep(delay)                      # let the Ready screen open after the final E
            self.log("Final Ready: using the saved position")
            self.click(pos)
        else:
            self.status("Looking for final Ready")
            # Use pixel search for ready button instead of image matching
            if self._check_lime_pixel("ready_px"):
                pos = self.point("ready_px")
                if pos:
                    self.log("Final Ready found via pixel search")
                    self.click(pos)
            else:
                hit = self.wait_image("ready_b", to)
                if hit:
                    self.click(hit)
                else:
                    self.log("Final Ready not found - skipped (use 'Pick Ready' to set its position)", "warn")
        self.status("Waiting 7s")
        self.sleep(7)
        self.status("Aligning camera")
        self.align_camera()
        if c.get("zoom_after_align", True):
            self.zoom_out()
        self.sleep(0.3)

    # ---------- recordings ----------
    def rec_path(self, name):
        return os.path.join(REC_DIR, clean_name(name) + ".json")

    def refresh_recs(self):
        out = []
        try:
            for fn in sorted(os.listdir(REC_DIR)):
                if fn.lower().endswith(".json"):
                    try:
                        with open(os.path.join(REC_DIR, fn), "r", encoding="utf-8") as f:
                            d = json.load(f)
                        out.append({"name": fn[:-5], "events": len(d.get("events", [])),
                                    "dur": round(float(d.get("duration", 0)), 1), "map": d.get("map", "")})
                    except Exception:
                        pass
        except Exception:
            pass
        self.recs = out

    def load_rec(self):
        name = self.cfg.get("recording", "")
        if not name:
            return None
        try:
            with open(self.rec_path(name), "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            self.log("Could not open recording '%s'" % name, "warn")
            return None

    def placement_active(self, cx, cy):
        """True while the Place / Rotate / Cancel hint box is on screen = a tower is still equipped (NOT placed)."""
        gx, gy, gw, gh = game_rect()
        x1, y1 = max(gx, int(cx) - 450), max(gy, int(cy) - 450)
        x2, y2 = min(gx + gw, int(cx) + 700), min(gy + gh, int(cy) + 700)
        if x2 - x1 < 80 or y2 - y1 < 140:
            return False
        fr = self.g().get({"left": x1, "top": y1, "width": x2 - x1, "height": y2 - y1})
        gray = cv2.cvtColor(np.asarray(fr), cv2.COLOR_BGRA2GRAY)
        base = TPL_BASE["place_hint"]
        sc = self.ui_scale() * REF_HEIGHT / TPL_REF_H["place_hint"]
        best = 0.0
        for k in (1.0, 0.94, 1.06, 0.88, 1.12):       # a few sizes, in case the UI scale is slightly off
            t = cv2.resize(base, (max(4, int(base.shape[1] * sc * k)), max(4, int(base.shape[0] * sc * k))),
                           interpolation=cv2.INTER_AREA)
            best = max(best, best_score(gray, t))
            if best >= PLACE_HINT_THR:
                break
        self.log("Placement check: hint box score %.2f (%s)" % (best, "still equipped" if best >= PLACE_HINT_THR else "gone"))
        return best >= PLACE_HINT_THR

    def verify_placement(self, slot, px, py, jig_px, jig_step, settle):
        """After a placement click. If the hint box is still up the tower was NOT placed (bad spot, no cash, click
        missed). Cancel, re-equip and try again - same spot first, then nudged a few px."""
        self._v_retried = False
        tries = int(self.cfg.get("place_retries", 4))
        o = max(2, int(round(5 * self.ui_scale())))
        gx, gy, gw, gh = game_rect()
        nd = max(0, int(self.cfg.get("nudge_px", 10)))
        sd = -nd if px < gx + gw / 2.0 else nd          # left half -> nudge left, right half -> nudge right
        offsets = [(0, 0)] + ([(sd, 0)] if nd else []) + [(0, -o), (o, 0), (0, o), (-o, 0), (o, o), (-o, -o), (o, -o), (-o, o)]
        
        # Smart retry: check if this spot is known to be problematic
        spot_key = "%d_%d" % (int(round(px)), int(round(py)))
        problematic = self.cfg.get("problematic_spots", {})
        max_failures = int(self.cfg.get("max_spot_failures", 3))
        
        if spot_key in problematic and problematic[spot_key].get("failures", 0) >= max_failures:
            # Known bad spot - use best working offset immediately
            best_offset = problematic[spot_key].get("best_offset", (0, 0))
            self.log("Known problematic spot - using best offset: %s" % (best_offset,), "info")
            offsets = [best_offset] + offsets
        
        for n in range(tries + 1):
            self.sleep(0.35)                                 # let the game react to the click
            if not self.placement_active(px, py):
                if n:
                    self.log("Tower placed after %d retr%s" % (n, "y" if n == 1 else "ies"), "ok")
                    ox, oy = offsets[min(n - 1, len(offsets) - 1)]
                    self._adapt_note(slot, "fixed")
                    
                    # Learn from success - update problematic spots
                    if spot_key in problematic:
                        problematic[spot_key]["failures"] = 0
                        problematic[spot_key]["best_offset"] = (ox, oy)
                        problematic[spot_key]["successes"] = problematic[spot_key].get("successes", 0) + 1
                        self.cfg["problematic_spots"] = problematic
                        self.save_cfg()
                    
                    try: MAHO_OVERLAY.trigger()
                    except Exception: pass
                    
                    # Track Mahoraga for Randy counter
                    if bool(self.cfg.get("bdr_mahoraga_counter", True)):
                        self._track_mahoraga_adaptation()
                    
                    # 60% chance Big Dick Randy spawns when Mahoraga does
                    try:
                        import random
                        if random.random() < 0.6:
                            self.log("Mahoraga summoned Big Dick Randy!", "warn")
                            # Trigger Big Dick Randy immediately
                            if hasattr(self, '_bdr_thread') and self._bdr_thread is not None and self._bdr_thread.is_alive():
                                # BDR thread is already running, set event to show immediately
                                self._bdr_immediate_event.set()
                            else:
                                # Start BDR thread if not running
                                self._bdr_stop.clear()  # Reset stop event
                                self._bdr_overlay_shown = False
                                self._bdr_immediate_event.set()  # Set immediately
                                self._bdr_thread = threading.Thread(target=self.big_dick_randy_thread, name="td-bdr", daemon=False)
                                self._bdr_thread.start()
                    except Exception:
                        pass
                    
                    return (True, ox, oy)
                self._adapt_note(slot, "ok")
                return (True, 0, 0)
            if n == tries:
                break
            ox, oy = offsets[min(n, len(offsets) - 1)]
            self._v_retried = True
            self.log("Tower not placed (preview still active) - retry %d/%d%s" % (
                n + 1, tries, " at a nudged spot" if (ox or oy) else ", same spot"), "warn")
            self.hold_key("q", 0.05)                         # cancel the stuck preview
            self.sleep(float(self.cfg.get("retry_wait", 1.0)) if n == 0 else 0.2)   # first retry waits: maybe no cash yet
            self.hold_key(slot, 0.1)                         # equip the tower again
            self.sleep(max(0.1, float(self.cfg.get("slot_wait", 0.1))))
            tx, ty = px + ox, py + oy
            move_smooth(tx, ty, 0.25)
            self.jiggle(tx, ty, jig_px, jig_step)
            self.sleep(settle)
            mouse_btn("lmb", True)
            self.held_btn.add("lmb")
            self.sleep(0.1)
            mouse_btn("lmb", False)
            self.held_btn.discard("lmb")
        
        # Learn from failure - mark spot as problematic
        self.log("Tower could not be placed after %d retries - marking spot as problematic" % tries, "warn")
        if spot_key not in problematic:
            problematic[spot_key] = {"failures": 0, "successes": 0, "best_offset": (0, 0)}
        problematic[spot_key]["failures"] = problematic[spot_key].get("failures", 0) + 1
        self.cfg["problematic_spots"] = problematic
        self.save_cfg()
        self._save_cfg()
        
        self._adapt_note(slot, "fail")
        self.hold_key("q", 0.05)
        return (False, 0, 0)

    # ---------- Adaption: learn every key in the recording, check each equip-key + click really worked, fix it if not ----------
    MOVE_KEYS = ("w", "a", "s", "d", "up", "down", "left", "right")
    MOD_KEYS = ("shift", "ctrl", "alt")

    @classmethod
    def analyze_keys(cls, evs):
        """Works out what every key in a recording is for - in any game, nothing is hard-coded.
        equip = key that is followed by a left click within 3s (tower slot, hotbar, build menu, ability ...)
        move = WASD / arrows,  hold = long holds,  tap = everything else."""
        info, down_t, holds = {}, {}, {}
        for ev in evs:
            if ev.get("k") != "key":
                continue
            n = ev["n"]
            d = info.setdefault(n, {"uses": 0, "role": "tap", "avg_hold": 0.0, "armed": 0})
            if ev["d"]:
                d["uses"] += 1
                down_t[n] = ev["t"]
            elif n in down_t:
                holds.setdefault(n, []).append(max(0.0, ev["t"] - down_t.pop(n)))
        for n, d in info.items():
            h = holds.get(n) or [0.0]
            d["avg_hold"] = sum(h) / len(h)
            if n in cls.MOVE_KEYS:
                d["role"] = "move"
            elif n in cls.MOD_KEYS:
                d["role"] = "modifier"
            elif d["avg_hold"] > 0.6:
                d["role"] = "hold"
        last = None
        for ev in evs:
            if ev.get("k") == "key" and ev["d"]:
                if ev["n"] in cls.MOVE_KEYS or ev["n"] in cls.MOD_KEYS:
                    continue
                last = (ev["n"], ev["t"])
            elif ev.get("k") == "mouse" and ev["d"] and ev["n"] == "lmb" and last:
                if ev["t"] - last[1] <= 3.0:
                    info[last[0]]["armed"] += 1
                last = None
        for n, d in info.items():
            if d["role"] == "tap" and d["armed"] and d["armed"] * 2 >= d["uses"]:
                d["role"] = "equip"
        return info

    def adapt_learn(self, prof):
        if not prof:
            return
        parts = ["%s %s x%d" % (n.upper(), d["role"], d["uses"]) for n, d in sorted(prof.items(), key=lambda kv: -kv[1]["uses"])[:12]]
        self.log("Adaption: learned %d key%s from the recording - %s" % (len(prof), "" if len(prof) == 1 else "s", ", ".join(parts)), "info")

    def _adapt_note(self, key, outcome):
        st = getattr(self, "_adapt_stats", None)
        if st is None:
            st = self._adapt_stats = {}
        st.setdefault(key, {"ok": 0, "fixed": 0, "fail": 0})[outcome] += 1

    def adapt_report(self):
        """End of a pass: what Adaption did per key, plus hints on how to make the recording better."""
        st = getattr(self, "_adapt_stats", None) or {}
        self._adapt_stats = {}
        for key in sorted(st):
            d = st[key]
            tot = d["ok"] + d["fixed"] + d["fail"]
            self.log("Adaption: key %s - %d action%s: %d first try, %d fixed by retry, %d failed" % (
                key.upper(), tot, "" if tot == 1 else "s", d["ok"], d["fixed"], d["fail"]), "warn" if d["fail"] else "ok")
            if d["fail"]:
                self.log("   tip: key %s did not land %d time(s) - check you can afford it / the spot is free, or re-record that part" % (key.upper(), d["fail"]), "warn")
            elif d["fixed"] >= max(2, tot // 2):
                self.log("   tip: key %s needed retries a lot - the recorded spots may be slightly off, re-recording them can help" % key.upper(), "warn")

    def _box(self, px, py):
        gx, gy, gw, gh = game_rect()
        r = max(40, int(110 * self.ui_scale()))
        x1, y1 = max(gx, int(px) - r), max(gy, int(py) - r)
        x2, y2 = min(gx + gw, int(px) + r), min(gy + gh, int(py) + r)
        if x2 - x1 < 40 or y2 - y1 < 40:
            return None
        return {"left": x1, "top": y1, "width": x2 - x1, "height": y2 - y1}

    def grab_box_gray(self, box):
        g = cv2.cvtColor(np.asarray(self.g().get(box)), cv2.COLOR_BGRA2GRAY)
        return cv2.resize(g, (max(1, g.shape[1] // 2), max(1, g.shape[0] // 2)), interpolation=cv2.INTER_AREA)

    @staticmethod
    def screen_changed(a, b):
        """True when the area around the click looks different afterwards (tower/unit appeared, preview vanished ...).
        If it cannot tell, it says True - Adaption never retries blindly."""
        if a is None or b is None or a.shape != b.shape:
            return True
        d = cv2.absdiff(a, b)
        return float((d > 24).mean()) >= 0.004 or float(d.mean()) >= 1.5

    def verify_generic(self, key, px, py, before, box, jig_px, jig_step, settle):
        """Game-independent check after an equip-key + click: did the screen around the click change?
        If not: click again, then nudge the spot a little, re-pressing the key on every second try."""
        self._v_retried = False
        tries = max(0, min(3, int(self.cfg.get("place_retries", 4))))
        o = max(2, int(round(5 * self.ui_scale())))
        gx, gy, gw, gh = game_rect()
        nd = max(0, int(self.cfg.get("nudge_px", 10)))
        sd = -nd if px < gx + gw / 2.0 else nd
        offsets = [(0, 0)] + ([(sd, 0)] if nd else []) + [(0, -o), (o, 0), (0, o), (-o, 0)]
        for n in range(tries + 1):
            self.sleep(0.4)
            ok = self.screen_changed(before, self.grab_box_gray(box))
            if not ok:
                self.sleep(0.6)                              # some games animate for a moment
                ok = self.screen_changed(before, self.grab_box_gray(box))
            if ok:
                if n:
                    self.log("Adaption: key %s action landed after %d retr%s" % (key.upper(), n, "y" if n == 1 else "ies"), "ok")
                    self._adapt_note(key, "fixed")
                    try: MAHO_OVERLAY.trigger()
                    except Exception: pass
                    
                    # Track Mahoraga for Randy counter
                    if bool(self.cfg.get("bdr_mahoraga_counter", True)):
                        self._track_mahoraga_adaptation()
                    
                    # 60% chance Big Dick Randy spawns when Mahoraga does
                    try:
                        import random
                        if random.random() < 0.6:
                            self.log("Mahoraga summoned Big Dick Randy!", "warn")
                            # Trigger Big Dick Randy immediately
                            if hasattr(self, '_bdr_thread') and self._bdr_thread is not None and self._bdr_thread.is_alive():
                                # BDR thread is already running, set event to show immediately
                                self._bdr_immediate_event.set()
                            else:
                                # Start BDR thread if not running
                                self._bdr_stop.clear()  # Reset stop event
                                self._bdr_overlay_shown = False
                                self._bdr_immediate_event.set()  # Set immediately
                                self._bdr_thread = threading.Thread(target=self.big_dick_randy_thread, name="td-bdr", daemon=False)
                                self._bdr_thread.start()
                    except Exception:
                        pass
                    
                    ox, oy = offsets[min(n - 1, len(offsets) - 1)]
                    return (True, ox, oy)
                self._adapt_note(key, "ok")
                return (True, 0, 0)
            if n == tries:
                break
            ox, oy = offsets[min(n, len(offsets) - 1)]
            self._v_retried = True
            self.log("Adaption: nothing changed after key %s + click - retry %d/%d%s" % (
                key.upper(), n + 1, tries, " at a nudged spot" if (ox or oy) else ", same spot"), "warn")
            self.sleep(float(self.cfg.get("retry_wait", 1.0)) if n == 0 else 0.2)
            if n % 2 == 1:                                   # every second retry: equip again first
                self.hold_key(key, 0.1)
                self.sleep(max(0.1, float(self.cfg.get("slot_wait", 0.1))))
            tx, ty = px + ox, py + oy
            move_smooth(tx, ty, 0.25)
            self.jiggle(tx, ty, jig_px, jig_step)
            self.sleep(settle)
            try:
                before = self.grab_box_gray(box)
            except Exception:
                pass
            mouse_btn("lmb", True)
            self.held_btn.add("lmb")
            self.sleep(0.1)
            mouse_btn("lmb", False)
            self.held_btn.discard("lmb")
        self.log("Adaption: key %s action never landed after %d retries - carrying on" % (key.upper(), tries), "err")
        self._adapt_note(key, "fail")
        return (False, 0, 0)

    def jiggle(self, px, py, n, step):
        """Wiggle the cursor n px up, down, left, right, then return to (px, py).
        step = how long the cursor rests at each point, so the game sees a real movement every frame."""
        for dx, dy in ((0, -n), (0, n), (-n, 0), (n, 0), (0, 0)):
            self.check()
            move_abs(px + dx, py + dy)
            time.sleep(step)

    @staticmethod
    def strip_placements(evs, arm=("1", "2")):
        """Recording without its tower placements (keys 1/2 and the click that places the tower)."""
        out, armed, skip_up = [], False, None
        for ev in evs:
            if ev["k"] == "key" and ev["n"] in arm:
                armed = armed or bool(ev["d"])
                continue
            if ev["k"] == "mouse":
                if armed and ev["d"]:
                    armed, skip_up = False, ev["n"]
                    continue
                if skip_up == ev["n"] and not ev["d"]:
                    skip_up = None
                    continue
            out.append(ev)
        return out

    def play(self, rec, repeat=False):
        evs = rec.get("events", [])
        if getattr(self, "_skip_wasd", False):
            evs = self.drop_movement(evs, shift_start=not repeat)
        adapt = bool(self.cfg.get("adaption", True))
        arm = ("1", "2")                                  # Adaption off: the original tower keys only
        if adapt:
            prof = self.analyze_keys(evs)
            arm = tuple(sorted(set(n for n, d in prof.items() if d["role"] == "equip") | set(n for n in ("1", "2") if n in prof)))
            if not repeat:
                self.adapt_learn(prof)
        if repeat and not self.cfg.get("loop_replace", False):
            evs = self.strip_placements(evs, arm)        # later passes: don't build the towers again, just redo the rest
        glide = max(0.0, float(self.cfg.get("mouse_glide", 0.2)))
        do_jig = bool(self.cfg.get("place_jiggle", True))
        slot_wait = max(0.0, float(self.cfg.get("slot_wait", 0.1)))
        jig_px = max(1, int(self.cfg.get("jiggle_px", 5)))
        jig_step = max(0.01, float(self.cfg.get("jiggle_step", 0.05)))
        settle = max(0.0, float(self.cfg.get("place_settle", 0.2)))
        jig_time = 5 * jig_step + settle + 0.02   # wiggle + rest at the spot, before the click
        cancel_first = bool(self.cfg.get("cancel_before_slot", True))
        verify_on = adapt and bool(self.cfg.get("verify_place", True)) and int(self.cfg.get("place_retries", 4)) > 0
        move_extra = max(0.0, float(self.cfg.get("move_hold_extra", 0.15)))
        last_slot = "1"
        verify = None
        if not repeat:
            self._play_shifts = []
        shifts = getattr(self, "_play_shifts", None)
        if shifts is None:
            shifts = self._play_shifts = []        # [[orig_x, orig_y, dx, dy]] every tower placed this run + how far it was nudged
        rad = max(3, int(int(self.cfg.get("nudge_radius", 45)) * self.ui_scale()))
        wiggle_all = bool(self.cfg.get("wiggle_all", True))
        slot_t = None                          # when tower key 1/2 was last pressed (until it is placed)
        t0 = time.perf_counter()
        prev_t = 0.0
        down_at = {}                           # when each key / mouse button went down (for a minimum hold time)
        for i, ev in enumerate(evs):
            target = t0 + ev["t"]
            dur = 0.0
            place = (do_jig and ev["k"] == "mouse" and ev["d"] and slot_t is not None)
            wig = (wiggle_all and not place and ev["k"] == "mouse" and ev["d"] and ev["n"] == "lmb")   # every other left click too
            if ev["k"] == "mouse" and ev["d"] and glide > 0:
                # start travelling early so the button press still lands at the recorded time;
                # never travel for longer than the gap since the previous event
                dur = min(glide, max(0.0, ev["t"] - prev_t - 0.03))
                if dur > 0.01:
                    target -= dur + 0.02
                else:
                    dur = 0.0
            if wig and (ev["t"] - prev_t) < (jig_time + dur + 0.05):
                wig = False                                    # no room before this click: skip the wiggle, click on the recorded time
            slot_key = (ev["k"] == "key" and ev["d"] and ev["n"] in ("1", "2") and cancel_first)
            if slot_key:
                target -= 0.2                                  # time for the Q (cancel) tap before the tower key
            if ev["k"] == "key" and not ev["d"] and ev["n"] in ("w", "a", "s", "d") and move_extra > 0:
                target += move_extra                           # hold movement keys a little longer than recorded
            if not ev["d"] and (ev["k"], ev["n"]) in down_at:
                # never release faster than a game frame can notice, even when the timeline is running late
                target = max(target, down_at[(ev["k"], ev["n"])] + (0.08 if ev["k"] == "key" else 0.06))
            if place:
                target -= jig_time
                target = max(target, slot_t + slot_wait)      # always wait after pressing 1/2
            elif wig:
                target -= jig_time                            # start early: the wiggle + rest happen before the click
            while True:
                self.check()
                r = target - time.perf_counter()
                if r <= 0:
                    break
                time.sleep(min(r, 0.01))
            if ev["k"] == "key":
                down = bool(ev["d"])
                if slot_key:
                    # a failed placement leaves the tower equipped (red preview); pressing 1/2 again would
                    # un-equip it and everything after that goes out of sync, so cancel first
                    self.hold_key("q", 0.05)
                    self.sleep(0.15)
                key_event(ev["n"], down)
                (self.held.add if down else self.held.discard)(ev["n"])
                if down:
                    down_at[("key", ev["n"])] = time.perf_counter()
                if down and ev["n"] in arm:
                    slot_t = time.perf_counter()
                    last_slot = ev["n"]
            else:
                x, y, w, h = game_rect()
                px, py = x + ev["x"] * w, y + ev["y"] * h
                opx, opy, ax, ay = px, py, 0, 0
                if shifts:                               # follow the tower: same shift as the tower this click belongs to
                    near = None
                    lim = 6 if place else rad            # placing = same spot again; other clicks hit the tower's head, above its base
                    for sh in shifts:
                        d = ((px - sh[0]) ** 2 + (py - sh[1]) ** 2) ** 0.5
                        if d <= lim and (near is None or d < near[0]):
                            near = (d, sh[2], sh[3])
                    if near:
                        ax, ay = near[1], near[2]
                        px, py = px + ax, py + ay
                        if (ax or ay) and not place:
                            self.log("Click moved %+dpx, %+dpx to stay on the tower's head" % (ax, ay))
                dp = down_at.get(("pos", ev["n"]))
                if not ev["d"] and dp and abs(px - dp[0]) <= 3 and abs(py - dp[1]) <= 3:
                    pass                                 # releasing where it was pressed: no need to move at all
                elif dur > 0:
                    move_smooth(px, py, dur)             # smooth glide, recording playback only
                else:
                    move_abs(px, py)
                    time.sleep(0.02)
                if place:
                    self.log("Placing tower at %.1f%%, %.1f%% (wiggle, settle %.2fs, then click)" % (ev["x"] * 100, ev["y"] * 100, settle))
                    self.jiggle(int(round(px)), int(round(py)), jig_px, jig_step)
                    self.sleep(settle)                   # hold still on the spot so the game updates the tower preview
                    slot_t = None
                    shifts[:] = [q for q in shifts if ((q[0] - opx) ** 2 + (q[1] - opy) ** 2) ** 0.5 > 6]
                    shifts.append([opx, opy, ax, ay])
                    if verify_on:
                        tpl_mode = last_slot in ("1", "2") and "place_hint" in TPL_BASE
                        vbox = vbef = None
                        if not tpl_mode:                 # any other game / key: remember how the spot looks before the click
                            try:
                                vbox = self._box(px, py)
                                vbef = self.grab_box_gray(vbox) if vbox else None
                            except Exception:
                                vbox = vbef = None
                        verify = (last_slot, int(round(px)), int(round(py)), opx, opy, ax, ay, vbox, vbef, tpl_mode)
                    self.sleep(max(0.0, t0 + ev["t"] - time.perf_counter()))
                elif wig:
                    self.jiggle(int(round(px)), int(round(py)), jig_px, jig_step)
                    self.sleep(settle)                   # rest on the spot so the game registers the hover
                elif dur > 0:
                    self.sleep(max(0.0, t0 + ev["t"] - time.perf_counter()))
                down = bool(ev["d"])
                mouse_btn(ev["n"], down)
                (self.held_btn.add if down else self.held_btn.discard)(ev["n"])
                if down:
                    down_at[("mouse", ev["n"])] = time.perf_counter()
                    down_at[("pos", ev["n"])] = (px, py)
                if verify and not down:                  # the placement click is finished: was the tower really placed?
                    v, verify = verify, None
                    if v[9]:
                        ok, ox, oy = self.verify_placement(v[0], v[1], v[2], jig_px, jig_step, settle)
                    elif v[7] is not None and v[8] is not None:
                        ok, ox, oy = self.verify_generic(v[0], v[1], v[2], v[8], v[7], jig_px, jig_step, settle)
                    else:
                        ok, ox, oy = True, 0, 0
                    if ok and (ox or oy):
                        for q in shifts:
                            if abs(q[0] - v[3]) < 1 and abs(q[1] - v[4]) < 1:
                                q[2], q[3] = v[5] + ox, v[6] + oy
                        self.log("Tower landed %+dpx, %+dpx from the recorded spot - its upgrade clicks follow it" % (v[5] + ox, v[6] + oy), "ok")
                    # Only a real RETRY pushes the rest of the recording back. A normal check (~0.5s) used to push
                    # everything back too, so 14 placements = 5-10s of drift on every later E / click. Now the timeline
                    # stays on the recorded clock and the next events just fire straight away until it has caught up.
                    if i + 1 < len(evs) and getattr(self, "_v_retried", False):
                        late = time.perf_counter() - (t0 + evs[i + 1]["t"])
                        if late > 0:
                            t0 += late
            prev_t = ev["t"]
        if adapt:
            self.adapt_report()
        self.release_all()

    # ---------- watcher (Play Again, 24/7) ----------
    def watcher(self, stop):
        fails = 0
        last_warn = 0.0
        while not stop.is_set():
            t = time.perf_counter()
            try:
                if time.time() >= self.pa_ignore and not self.pa_evt.is_set():
                    # Use pixel search for lime green buttons instead of image matching
                    pixel_found = False
                    if self.watch_restart:
                        # Check restart pixel first
                        if self._check_lime_pixel("restart_px"):
                            pos = self.point("restart_px")
                            if pos:
                                self.pa_pos = pos
                                self.pa_kind = "restart"
                                self.pa_evt.set()
                                self.log("Restart detected via pixel search at %s" % pos, "info")
                                pixel_found = True
                        # Then check play_again pixel
                        elif self._check_lime_pixel("play_again_px"):
                            pos = self.point("play_again_px")
                            if pos:
                                self.pa_pos = pos
                                self.pa_kind = "play_again"
                                self.pa_evt.set()
                                self.log("Play Again detected via pixel search at %s" % pos, "info")
                                pixel_found = True
                    else:
                        # Only check play_again when not watching for restart
                        if self._check_lime_pixel("play_again_px"):
                            pos = self.point("play_again_px")
                            if pos:
                                self.pa_pos = pos
                                self.pa_kind = "play_again"
                                self.pa_evt.set()
                                self.log("Play Again detected via pixel search at %s" % pos, "info")
                                pixel_found = True

                    # Fallback to image matching if pixel search didn't find anything and pixel_only is disabled
                    if not pixel_found and not bool(self.cfg.get("pixel_only", False)):
                        if self.watch_restart:
                            hit = self.find_now("restart")
                            if hit:
                                self.pa_pos = (hit[0], hit[1])
                                self.pa_kind = "restart"
                                self.pa_evt.set()
                                self.log("Restart detected via image match at %s" % (hit[0], hit[1]), "info")
                                pixel_found = True
                        if not pixel_found:
                            hit = self.find_now("play_again")
                            if hit:
                                self.pa_pos = (hit[0], hit[1])
                                self.pa_kind = "play_again"
                                self.pa_evt.set()
                                self.log("Play Again detected via image match at %s" % (hit[0], hit[1]), "info")
                fails = 0
            except Exception as e:
                fails += 1
                if fails == 1 or time.time() - last_warn > 30:
                    last_warn = time.time()
                    self.log("Play Again watcher problem (%s: %s) - retrying" % (type(e).__name__, e), "warn")
                if fails == 5 and hasattr(self.tl, "g"):
                    self.tl.g.close()
                    del self.tl.g
                time.sleep(min(1.0, 0.05 * fails))
            spent = time.perf_counter() - t
            # Use custom scan interval if set, else default
            scan_interval = float(self.cfg.get("custom_scan_interval", SCAN_INTERVAL))
            rest = max(scan_interval - spent, min(0.5, spent))   # idle at least as long as the scan took: never hog the CPU while the recording plays
            if rest > 0:
                time.sleep(rest)
        if hasattr(self.tl, "g"):
            self.tl.g.close()

    def start_watcher(self):
        try:
            stop = threading.Event()             # one event per run, so an old watcher can never be revived
            self.wd_stop = stop
            self.pa_evt.clear()
            self.pa_ignore = 0.0
            threading.Thread(target=self.watcher, args=(stop,), daemon=True, name="td-watcher").start()
        except Exception as e:
            self.log("Failed to start watcher: %s" % e, "err")

    # ---------- rewards ----------
    def read_rewards(self, frame):
        gray = cv2.cvtColor(frame, cv2.COLOR_BGRA2GRAY)
        out = {}
        sc = self.ui_scale()
        for key, tname in (("coins", "coin_icon"), ("xp", "xp_icon")):
            m = None
            t = None
            sce = sc
            for mu, tt in self._iter_tpls(tname):
                if gray.shape[0] < tt.shape[0] or gray.shape[1] < tt.shape[1]:
                    continue
                mm_ = match(gray, tt, 0.72)
                if mm_ and (m is None or mm_[2] > m[2]):
                    m, t, sce = mm_, tt, sc * mu
                    if mm_[2] >= 0.84:
                        break
            if not m:
                continue
            th, tw = t.shape[:2]
            x0 = m[0] - tw // 2
            y0 = m[1] - th // 2
            ty0 = y0 + th + int(3 * sce)
            ty1 = y0 + th + int(38 * sce)
            crop = gray[max(0, ty0):ty1, max(0, x0 - int(10 * sce)):x0 + tw + int(10 * sce)]
            if crop.size == 0:
                continue
            crop = cv2.resize(crop, None, fx=3, fy=3, interpolation=cv2.INTER_CUBIC)
            variants = []
            _, th_img = cv2.threshold(crop, 200, 255, cv2.THRESH_BINARY)
            variants.append(cv2.bitwise_not(th_img))
            variants.append(crop)
            for v in variants:
                v = cv2.copyMakeBorder(v, 20, 20, 20, 20, cv2.BORDER_CONSTANT, value=int(v[0, 0]))
                txt = ocr_digits(v)
                mm = re.search(r"\d[\d,]*", txt or "")
                if mm:
                    digits = re.sub(r"\D", "", mm.group())
                    if digits:
                        out[key] = int(digits)
                        break
            if key not in out:
                out[key] = None
        return out

    def on_restart(self):
        # Mahoraga: Restart Match -> reset + sync checkbox
        try: MAHO_OVERLAY.reset_run(new_tag="restart_%d" % int(time.time()*1000))
        except Exception: pass
        try: MAHO_OVERLAY.set_cfg_enabled(getattr(self, "cfg", {}))
        except Exception: pass
        """The run failed and Restart Match is on screen: click it, then skip the intro and just re-align + replay."""
        self.watch_pa = False
        self.release_all()
        self.log("Restart Match found - run failed, restarting (intro skipped)", "warn")
        self.status("Clicking Restart Match")
        if self.pa_pos:
            self.click(self.pa_pos)
        self.restart_pending = True
        self.pa_ignore = time.time() + PA_COOLDOWN
        self.pa_evt.clear()
        self.watch_pa = True

    def on_play_again(self):
        # Mahoraga: play again -> new run -> reset + sync checkbox
        try: MAHO_OVERLAY.reset_run(new_tag="play_again_%d" % int(time.time()*1000))
        except Exception: pass
        try: MAHO_OVERLAY.set_cfg_enabled(getattr(self, "cfg", {}))
        except Exception: pass
        if self.pa_kind == "restart":
            return self.on_restart()
        self.restart_pending = False
        self.watch_pa = False
        self.release_all()
        pos = self.pa_pos
        got = "run finished"
        if self.in_game:
            d = float(self.cfg.get("reward_delay", 0.5))
            if d > 0:
                self.sleep(d, pa=False)
            try:
                reg, fr, gray = self.grab_gray()
                gc = int(self.cfg.get("game_coins", 0))
                gx = int(self.cfg.get("game_xp", 0))
                try:
                    rew = {} if (gc > 0 and gx > 0) else self.read_rewards(fr)    # both typed in Settings = no reading needed
                except Exception as e:
                    self.log("Reward read failed: %s" % e, "warn")
                    rew = {}
                if gc > 0:
                    rew["coins"] = gc                    # per-game numbers from Settings win over the reading
                if gx > 0:
                    rew["xp"] = gx
                parts = []
                tot = self.cfg["totals"]
                for key, label in (("coins", "coins"), ("xp", "XP")):
                    if key in rew:
                        v = rew[key]
                        if v is None:
                            parts.append("%s ? (could not read)" % label)
                        else:
                            parts.append("+%d %s" % (v, label))
                            tot[key] += v
                            if key == "coins":
                                self.s_coins += v
                            else:
                                self.s_xp += v
                if parts:
                    got = ", ".join(parts)
                    self.log("Rewards: %s" % got, "ok")
                    
                    # Check for milestone screenshots
                    if bool(self.cfg.get("milestone_screenshots", True)):
                        self._check_milestone_screenshot(tot)
                    
                    # Randy stat reaction
                    if bool(self.cfg.get("bdr_stat_reactions", True)):
                        self._generate_randy_stat_reaction()
                    
                    # Diamond Legacy check (secret feature)
                    self._check_diamond_legacy()
            except Exception as e:
                self.log("Reward read failed: %s" % e, "warn")
            self.loops += 1
            self.cfg["totals"]["runs"] += 1
            self.save_cfg()
            self.in_game = False
            self.log("Run #%d done - %s" % (self.loops, got), "ok")
        else:
            self.log("Play Again found", "info")
        self.pa_evt.clear()
        if self.target and self.loops >= self.target:
            return
        if pos:
            self.status("Clicking Play Again")
            for _try in range(4):
                fresh = None
                try:
                    # Use pixel search instead of image matching
                    if self._check_lime_pixel("play_again_px"):
                        fresh = self.point("play_again_px")
                except Exception:
                    pass
                if fresh:
                    cpos = fresh
                    self.log("Play Again: clicking at %d,%d (pixel search, try %d)" % (cpos[0], cpos[1], _try + 1))
                elif _try == 0:
                    cpos = pos
                    self.log("Play Again: re-find missed, clicking the watcher position %d,%d" % (cpos[0], cpos[1]), "warn")
                else:
                    break                                    # button gone = the click worked
                self.click(cpos)
                self.sleep(1.5, pa=False)
        self.pa_ignore = time.time() + PA_COOLDOWN
        self.pa_evt.clear()
        self.status("Waiting for Ready (timeout %gs)" % PA_READY_TIMEOUT)
        self.set_phase("wait_ready_after_pa", budget=0)
        rejoin_needed = False
        try:
            # First try pixel search for ready button
            name = None
            hit = None
            if self._check_lime_pixel("ready_px"):
                pos = self.point("ready_px")
                if pos:
                    self.log("Ready screen found via pixel search after Play Again", "ok")
                    self.click(pos)
                    name = "ready_px"
                    hit = pos
            # Try image matching if pixel_only is disabled
            if not name and not bool(self.cfg.get("pixel_only", False)):
                name, hit = self.wait_any(("ready_a", "ready_b"), timeout=PA_READY_TIMEOUT)
                if name:
                    self.log("Ready screen found (%s) after Play Again" % name, "ok")
            if not name:
                if self.stop_evt.is_set():
                    self.log("Ready screen wait ended (stop requested)", "warn")
                else:
                    # 5-minute timeout: Roblox probably hung at loading. ALT+F4 + silent rejoin
                    self.log("Ready screen NOT seen after %.0fs - Roblox seems stuck. ALT+F4 + rejoin." % PA_READY_TIMEOUT, "err")
                    file_log("Ready after Play Again timed out after %.0fs" % PA_READY_TIMEOUT, "err")
                    rejoin_needed = True
        finally:
            self.clear_phase()
        if rejoin_needed:
            # Part B failsafe: close Roblox, rejoin via protocol URI, then resume recovery at green PLAY step (no Leave click, no triangle click)
            try:
                self.stop_watchdog()
            except Exception:
                pass
            try:
                self.stop_disconnect_watch()
            except Exception:
                pass
            self.watch_pa = False
            self.release_all()
            self.pa_evt.clear()
            self.veto_evt.clear()
            self.dc_evt.clear()
            self._alt_f4_close_roblox()
            self.sleep(1.0)
            self._launch_roblox_direct()
            # Wait a little for the launcher to spin up the new client window
            self.status("Waiting for Roblox launcher")
            self.sleep(8.0)
            try:
                focus_roblox()
            except Exception:
                pass
            self.sleep(1.0)
            # run recovery starting at step 3 (green PLAY click) - skips image1 Leave + image2 triangle steps
            self.do_recovery_from_leave(start_at_leave=False)
            # after do_recovery returns, we've landed on Ready screen.
            # The outer while True in run_macro will call cycle(rec) next -> waits for loaded (Insane) -> intro -> play recording.
        else:
            self.pa_ignore = time.time() + PA_COOLDOWN
            self.pa_evt.clear()
            self.watch_pa = True

    # ---------- macro ----------
    def restart_prepare(self):
        """Right after Restart Match: you are still standing where the failed run left you, but the recording starts
        with walking from the spawn. Two ways to deal with that (Settings > After Restart Match):
          reset    - Esc, R, Enter (reset character), wait, then replay the recording as it is
          skipwasd - stay put: leave out every W/A/S/D event and go straight to the recording's clicks / tower keys"""
        mode = str(self.cfg.get("restart_mode", "reset"))
        self._skip_wasd = (mode == "skipwasd")
        if mode == "reset":
            gap = max(0.02, float(self.cfg.get("restart_key_gap", 0.1)))
            rw = max(0.0, float(self.cfg.get("restart_reset_wait", 5.0)))
            self.status("Resetting character (esc, r, enter)")
            self.log("Restart: resetting the character (Esc, R, Enter), then waiting %gs" % rw)
            for k in ("esc", "r", "enter"):
                self.tap(k)
                self.sleep(gap)
            self.status("Waiting %gs after the reset" % rw)
            self.sleep(rw)
        elif mode == "skipwasd":
            self.log("Restart: staying where we are - W/A/S/D from the recording will be skipped")

    def drop_movement(self, evs, shift_start=True):
        """The recording without its W/A/S/D events. With shift_start the rest is moved forward so the first
        remaining event (tower key / click) happens right away instead of after the walk."""
        keep = [ev for ev in evs if not (ev.get("k") == "key" and str(ev.get("n", "")).lower() in ("w", "a", "s", "d"))]
        removed = len(evs) - len(keep)
        if not keep or not removed:
            return evs
        shift = max(0.0, min(ev["t"] for ev in keep) - 0.2) if shift_start else 0.0
        self.log("Restart: skipped %d W/A/S/D events%s" % (removed, (", starting %.1fs earlier at the first click/key" % shift) if shift > 0.05 else ""))
        return [dict(ev, t=max(0.0, ev["t"] - shift)) for ev in keep]

    def cycle(self, rec):
        # Mahoraga: new cycle (Insane screen) -> reset + sync checkbox
        try: MAHO_OVERLAY.reset_run(new_tag="cycle_%d_%x" % (id(self), int(time.time()*1000)))
        except Exception: pass
        try: MAHO_OVERLAY.set_cfg_enabled(getattr(self, "cfg", {}))
        except Exception: pass
        self.watch_pa = True
        # Check if we're in skipwasd mode from the start (not just after restart)
        mode = str(self.cfg.get("restart_mode", "reset"))
        self._skip_wasd = (mode == "skipwasd")
        # Check if we should skip intro entirely (for custom profiles or when already in game)
        self._skip_intro = bool(self.cfg.get("skip_intro", False))
        if self.restart_pending:
            self.restart_pending = False
            self.status("Waiting for the restarted match to load")
            self.set_phase("wait_loaded")
            if not self.wait_image("loaded", float(self.cfg.get("step_timeout", 30))):
                self.log("Map loaded image not seen after the restart - continuing anyway", "warn")
            self.in_game = True
            wait = float(self.cfg.get("restart_wait", 7))
            self.status("Waiting %gs" % wait)
            self.sleep(wait)
            self.restart_prepare()
            self.status("Aligning camera")
            self.align_camera()
            if self.cfg.get("zoom_after_align", True):
                self.zoom_out()
            self.sleep(0.3)
            self.log("Restarted - replaying the recording")
            # Skip intro if using skipwasd mode OR if in hybrid mode (intro is handled in main loop)
            pid = getattr(self, "_active_pid", "tds")
            profile = _load_profile(pid)
            hybrid_mode = bool(profile.get("hybrid_mode", False))
            if not getattr(self, "_skip_wasd", False) and not hybrid_mode:
                self.log("Restarted with reset mode - running intro")
                self.set_phase("intro")
                self.intro()
            elif hybrid_mode:
                self.log("Restarted in hybrid mode - skipping intro here (handled in main loop)")
            else:
                self.log("Restarted with skipwasd mode - skipping intro, going straight to recording")
        else:
            self.status("Waiting for the map to load (Insane)")
            self.set_phase("wait_loaded")
            _lh = None
            while not _lh:
                _lh = self.wait_image("loaded", 6.0)
                if not _lh:
                    _reg, _sc = None, -1.0
                    try:
                        _reg, _fr, _g = self.grab_gray()
                        _sc = max([best_score(_g, _t) for _m, _t in self._iter_tpls("loaded")] or [0.0])
                    except Exception:
                        pass
                    self.log("Still waiting for the 'loaded' image - best match %.2f (needs %.2f), scanning %s" % (
                        _sc, self.thr_for("loaded"), ("%dx%d" % (_reg["width"], _reg["height"])) if _reg else "?"), "warn")
                    if not getattr(self, "_full_scan", False):
                        self._full_scan = True        # not found inside the Roblox window: look at the whole screen like before
                        self.log("Switching to scanning the whole screen", "warn")
            self.in_game = True
            self.log("Map loaded (match score %.2f) - starting run %d" % ((_lh[2] if _lh else 0.0), self.loops + 1))
            # Skip intro if using skipwasd mode or skip_intro setting (for initial run too)
            if getattr(self, "_skip_wasd", False) or getattr(self, "_skip_intro", False):
                reason = "skipwasd mode" if getattr(self, "_skip_wasd", False) else "skip_intro setting"
                self.log("%s enabled - skipping intro, going straight to recording" % reason)
                self.align_camera()
                if self.cfg.get("zoom_after_align", True):
                    self.zoom_out()
                self.sleep(0.3)
            else:
                while True:
                    try:
                        self.veto_evt.clear()
                        self.set_phase("intro")
                        self.intro()
                        break
                    except VetoSeen:
                        self.on_veto()
                    except MapFailed:
                        self.release_all()
                        self.log("Redoing the intro (map was not selected)", "warn")
        if rec:
            self.status("Playing recording")
            self.log("Playing recording '%s'" % self.cfg.get("recording"))
            self.set_phase("play", budget=0)             # no time limit: a recording may run as long as it needs
            self.play(rec)
            
            # Run auto-upgrade adaptation after recording finishes
            if bool(self.cfg.get("auto_upgrade_system", False)):
                self.run_auto_upgrade_adaptation()
            
            if self.cfg.get("loop_rec", False):
                n = 1
                self.status("Looping the recording until Play Again / Restart")
                grace = _num(self.cfg.get("loop_grace", 20), 20.0, 1.0, 600.0)
                while True:                              # only Play Again / Restart (or Stop) gets out of here
                    n += 1
                    self.status("Recording finished - watching for Play Again / Restart")
                    self.log("Recording finished - watching for Play Again / Restart for up to %gs before pass %d" % (grace, n))
                    self.sleep(grace)                    # sleep() raises PlayAgainSeen the moment Play Again / Restart shows up
                    self.log("Recording pass %d - nothing seen, replaying" % n)
                    self.status("Looping the recording until Play Again / Restart")
                    self.play(rec, repeat=True)
        else:
            self.log("No recording selected - only the intro ran", "warn")
        self.status("Waiting for Play Again / Restart")
        self.log("Recording finished - waiting for Play Again / Restart (Restart is watched the whole run)")
        self.set_phase("wait_play_again", budget=0)  # waits forever until Play Again / Restart is detected
        while True:
            self.sleep(0.05)

    def run_macro(self):
        c = self.cfg
        # Load active profile to decide TDS mode vs custom steps
        pid     = getattr(self, "_active_pid", "tds")
        profile = _load_profile(pid)
        tds_mode = bool(profile.get("tds_mode", True))
        hybrid_mode = bool(profile.get("hybrid_mode", False))

        # Load this profile's snipped images into the template cache so
        # wait_image() steps can find them at the same 50 ms scan rate.
        _load_profile_images(pid)

        rec = self.load_rec()
        self.target = int(c["loops"]) if c["loops_mode"] == "num" and int(c["loops"]) > 0 else 0
        self.loops = 0
        self.s_coins = self.s_xp = 0
        self.t_start = time.time()
        self.in_game = False
        self.restart_pending = False
        self._full_scan = False
        self.watch_restart = tds_mode or hybrid_mode   # watch for restart in TDS or hybrid mode
        self.stop_veto_watch()
        self.veto_evt.clear()           # never start a run with a leftover veto flag
        # Start watcher only if not disabled
        if not bool(self.cfg.get("disable_watcher", False)):
            self.start_watcher()
        else:
            self.log("Watcher disabled by setting - Play Again/Restart detection will not work", "warn")
        self.start_watchdog()
        self.start_disconnect_watch()
        focus_roblox()
        
        # Run preflight check if enabled
        if bool(self.cfg.get("preflight_on_start", True)):
            if not self.run_preflight_check():
                self.log("Preflight check failed - macro not started", "err")
                return
        
        # Check for updates if enabled
        if bool(self.cfg.get("auto_update_check_on_start", True)):
            self._check_for_updates(silent=True)
        if hybrid_mode:
            mode_label = "Hybrid (%s)" % profile.get("name", pid)
        elif tds_mode:
            mode_label = "TDS"
        else:
            mode_label = "'%s'" % profile.get("name", pid)
        self.log("Macro started - profile %s (%s loops)" % (mode_label, self.target or "INF"), "ok")
        # Mahoraga: macro start -> reset counter + sync checkbox
        try: MAHO_OVERLAY.reset_run(new_tag="macro_start_%d" % int(time.time()*1000))
        except Exception: pass
        try: MAHO_OVERLAY.set_cfg_enabled(c)
        except Exception: pass
        
        # Initial lag measurement
        self._update_lag_multiplier()
        
        # Reset health tracking
        self._health_start_time = time.time()
        self._health_play_time = 0
        self._health_score = 100
        
        # Reset strategy switcher
        self._consecutive_failures = 0
        self._original_profile = getattr(self, "_active_pid", "tds")
        
        # Start ability spam if enabled
        self.start_ability_spam()
        
        # Start Big Dick Randy mode if enabled
        self.start_big_dick_randy()
        
        # Start automatic backup thread if enabled
        self.start_backup_thread()
        
        # Randy fake awareness - macro start
        self._randy_fake_awareness("macro_start")
        
        # Statistics tracking
        run_start_time = time.time()
        run_success = True
        last_error = ""
        
        try:
            while True:
                if self.target and self.loops >= self.target:
                    self.log("Loop target reached", "ok")
                    break
                loop_start = time.time()
                try:
                    if hybrid_mode:
                        # Hybrid mode: run TDS intro, then custom steps
                        self.log("Hybrid mode: running TDS intro + custom steps", "info")
                        self.intro()  # Run TDS intro (map search, ready, etc.)
                        # Then run custom steps for the actual game loop
                        steps = profile.get("steps") or []
                        if steps:
                            self.step_engine.run_steps(steps)
                        else:
                            self.log("No steps defined in hybrid profile - add steps in the Game tab", "warn")
                            self.sleep(2)
                        self.loops += 1
                        self.log("Hybrid pass %d complete" % self.loops, "ok")
                    elif tds_mode:
                        self.cycle(rec)
                    else:
                        # Custom step sequence — run once per loop iteration
                        steps = profile.get("steps") or []
                        if steps:
                            self.step_engine.run_steps(steps)
                        else:
                            self.log("No steps defined in this profile - add steps in the Game tab", "warn")
                            self.sleep(2)
                        self.loops += 1
                        self.log("Custom sequence pass %d complete" % self.loops, "ok")
                except PlayAgainSeen:
                    if tds_mode or hybrid_mode:
                        self.on_play_again()
                except VetoSeen:
                    self.veto_evt.clear()        # raised outside the intro (stale flag): just carry on, the next cycle redoes the intro
                except RecoveryNeeded:
                    if tds_mode or hybrid_mode:
                        self.log("Auto-recovery triggered (Leave popup was seen)", "warn")
                        try:
                            self.do_recovery_from_leave(start_at_leave=True)
                        except StopRun:
                            raise
                        except Exception as e:
                            self.log("Recovery failed: %s: %s - continuing loop" % (type(e).__name__, e), "err")
                            file_log(traceback.format_exc(), "err")
                            last_error = "Recovery failed: %s" % e
                            run_success = False
                except StopRun as e:
                    msg = str(e) or "requested"
                    self.log("Run stopped: %s" % msg, "warn")
                    last_error = msg
                    run_success = False
                    break
                except Exception as e:
                    self.log("Unexpected error: %s: %s" % (type(e).__name__, e), "err")
                    file_log(traceback.format_exc(), "err")
                    last_error = "%s: %s" % (type(e).__name__, e)
                    run_success = False
                
                # Update statistics after each loop
                loop_time = time.time() - loop_start
                stats = c.get("stats", {})
                stats["total_runs"] = stats.get("total_runs", 0) + 1
                if run_success:
                    stats["successful_runs"] = stats.get("successful_runs", 0) + 1
                    # Only add coins/XP on successful runs
                    stats["total_coins"] = stats.get("total_coins", 0) + self.s_coins
                    stats["total_xp"] = stats.get("total_xp", 0) + self.s_xp
                else:
                    stats["failed_runs"] = stats.get("failed_runs", 0) + 1
                    # Don't add coins/XP on failed runs
                stats["total_time"] = stats.get("total_time", 0.0) + loop_time
                stats["avg_time"] = stats["total_time"] / stats["total_runs"]
                # Calculate runs per hour
                if stats["total_time"] > 0:
                    stats["runs_per_hour"] = stats["total_runs"] / (stats["total_time"] / 3600.0)
                else:
                    stats["runs_per_hour"] = 0.0
                stats["last_error"] = last_error
                
                # Trigger screencast if worthy
                self.trigger_screencast_if_worthy(self.s_coins, self.s_xp, run_success)
                
                # Track play time for health monitor
                self._health_play_time += loop_time
                self.update_health_score()
                
                # Check cooldown
                if self.check_health_cooldown():
                    cooldown_seconds = int(self._health_cooldown_until - time.time())
                    self.log("Waiting for cooldown: %d seconds" % cooldown_seconds, "info")
                    self.sleep(cooldown_seconds)
                
                # Strategy switcher: track failures
                if not run_success:
                    self._consecutive_failures += 1
                else:
                    self._consecutive_failures = 0
                
                # Check if we need to switch strategy
                if bool(self.cfg.get("strategy_switcher", False)):
                    threshold = self.cfg.get("strategy_fail_threshold", 3)
                    if self._consecutive_failures >= threshold:
                        backup = self.cfg.get("backup_profile", "")
                        if backup and backup != self._active_pid:
                            self.log("Strategy switcher: %d consecutive failures, switching to backup profile: %s" % (self._consecutive_failures, backup), "warn")
                            self.cfg["active_profile"] = backup
                            self._active_pid = backup
                            self.save_cfg()
                            self._consecutive_failures = 0
                            # Randy fake awareness - profile switch
                            self._randy_fake_awareness("profile_switch")
                            # Re-initialize with new profile
                            _ensure_default_profile()
                            self.refresh_recs()
                            # Need to restart macro with new profile
                            self.log("Restarting macro with new profile...", "info")
                            break
                c["stats"] = stats

                # Track rewards per gamemode (only in TDS or hybrid mode)
                if tds_mode or hybrid_mode:
                    current_gamemode = c.get("gamemode", "molten")
                    gm_stats = c.get("gamemode_stats", {})
                    if current_gamemode not in gm_stats:
                        gm_stats[current_gamemode] = {"runs": 0, "coins": 0, "xp": 0, "time": 0.0}
                    gm_stats[current_gamemode]["runs"] += 1
                    gm_stats[current_gamemode]["coins"] += self.s_coins
                    gm_stats[current_gamemode]["xp"] += self.s_xp
                    gm_stats[current_gamemode]["time"] += loop_time
                    c["gamemode_stats"] = gm_stats

                # Auto-gamemode cycling
                cycle_cfg = c.get("gamemode_cycle", {})
                if cycle_cfg.get("enabled", False) and (tds_mode or hybrid_mode):
                    cycle_cfg["current_runs"] = cycle_cfg.get("current_runs", 0) + 1
                    runs_per_mode = cycle_cfg.get("runs_per_mode", 10)
                    modes = cycle_cfg.get("modes", ["molten"])
                    current_index = cycle_cfg.get("current_index", 0)

                    if cycle_cfg["current_runs"] >= runs_per_mode:
                        # Switch to next gamemode
                        current_index = (current_index + 1) % len(modes)
                        next_mode = modes[current_index]
                        cycle_cfg["current_index"] = current_index
                        cycle_cfg["current_runs"] = 0
                        c["gamemode"] = next_mode
                        c["gamemode_cycle"] = cycle_cfg
                        self.log("Gamemode cycle: switched to %s" % next_mode, "ok")
                        self.save_cfg()
                    else:
                        c["gamemode_cycle"] = cycle_cfg

                self.save_cfg()
                run_success = True  # Reset for next loop
                last_error = ""
        finally:
            self.stop_watchdog()
            self.stop_disconnect_watch()
            self.stop_veto_watch()
            self.stop_ability_spam()
            self.stop_backup_thread()
            # Randy fake awareness - macro stop
            self._randy_fake_awareness("macro_stop")
            # Big Dick Randy cannot be stopped - he continues to haunt even after macro stops
            self.veto_evt.clear()
            self.clear_phase()
            self.stop_evt.clear()
            self.dc_evt.clear()
            
            # Log final statistics
            total_time = time.time() - run_start_time
            stats = c.get("stats", {})
            self.log("Session statistics: %d total runs, %d successful, %d failed, avg %.1fs per run" % (
                stats.get("total_runs", 0), stats.get("successful_runs", 0), 
                stats.get("failed_runs", 0), stats.get("avg_time", 0)), "ok")
            
            # Generate heatmap if enabled
            if bool(self.cfg.get("heatmap_enabled", True)):
                self.generate_heatmap()
            
            # Calculate and log profit if enabled
            if bool(self.cfg.get("profit_calculator", True)):
                self.calculate_profit(total_time, stats)
            
            # Generate performance report if enabled
            if bool(self.cfg.get("performance_profiler", True)):
                self.perf_report()
            
            # Call Gemini advisor if enabled
            if bool(self.cfg.get("gemini_advisor", False)):
                self.gemini_suggest_improvements(stats)
            
            # Analyze economy if enabled
            if bool(self.cfg.get("auto_economy", False)):
                self.analyze_economy()
            
            # Send Discord notification if enabled
            if bool(self.cfg.get("discord_notifications", False)):
                msg = "Session complete: %d runs, %d coins, %d XP" % (
                    stats.get("total_runs", 0), stats.get("total_coins", 0), stats.get("total_xp", 0))
                self.send_discord_notification(msg, include_screenshot=True)

    def run_record(self):
        c = self.cfg
        name = clean_name(c.get("rec_name") or c.get("map") or "recording") or "recording"
        self.rec_stop.clear()
        self.watch_pa = False
        self.watch_restart = False
        self.rec_live = {"events": 0, "elapsed": 0.0, "last": "", "keys": {}, "clicks": 0, "last_t": 0.0}
        self.start_watcher()
        focus_roblox()
        for i in range(5, 0, -1):
            self.status("Recording starts in %ds - get ready" % i)
            self.sleep(1, pa=False)
        self.status("Aligning camera")
        self.align_camera()
        self.zoom_out()
        self.sleep(0.3, pa=False)
        self.log("Recording started - play your run (%s to stop)" % c["hk_record"], "ok")
        self.status("RECORDING - %s to stop" % c["hk_record"])
        # Randy fake awareness - recording start
        self._randy_fake_awareness("recording_start")
        events = []
        state = {n: False for n, _ in REC_KEYS}
        mstate = {"lmb": False, "rmb": False}
        mvk = {"lmb": 0x01, "rmb": 0x02}
        self.pa_evt.clear()
        t0 = time.perf_counter()
        stop_reason = "stopped"
        try:
            while True:
                if self.stop_evt.is_set() or self.rec_stop.is_set():
                    break
                if self.pa_evt.is_set():
                    stop_reason = "Play Again detected"
                    break
                now = time.perf_counter() - t0
                active = (not c.get("focus_only", True)) or roblox_focused()
                for n, v in REC_KEYS:
                    d = bool(user32.GetAsyncKeyState(v) & 0x8000) if active else False
                    if d != state[n]:
                        state[n] = d
                        events.append({"t": round(now, 4), "k": "key", "n": n, "d": int(d)})
                        self.rec_live["last"] = "%s %s" % (n, "down" if d else "up")
                        self.rec_live["last_t"] = time.time()
                        if d:
                            self.rec_live["keys"][n] = self.rec_live["keys"].get(n, 0) + 1
                if c.get("record_mouse", True):
                    gx, gy, gw, gh = game_rect()
                    for b, v in mvk.items():
                        d = bool(user32.GetAsyncKeyState(v) & 0x8000) if active else False
                        if d != mstate[b]:
                            px, py = cursor_pos()
                            fx, fy = (px - gx) / float(gw), (py - gy) / float(gh)
                            if d and not (0 <= fx <= 1 and 0 <= fy <= 1):
                                continue
                            mstate[b] = d
                            events.append({"t": round(now, 4), "k": "mouse", "n": b, "d": int(d),
                                           "x": round(fx, 5), "y": round(fy, 5)})
                            self.rec_live["last"] = "%s %s" % (b, "down" if d else "up")
                            self.rec_live["last_t"] = time.time()
                            if d:
                                self.rec_live["clicks"] += 1
                self.rec_live["events"] = len(events)
                self.rec_live["elapsed"] = round(now, 1)
                time.sleep(0.002)
        finally:
            end = round(time.perf_counter() - t0, 4)
            for n, d in state.items():
                if d:
                    events.append({"t": end, "k": "key", "n": n, "d": 0})
            gx, gy, gw, gh = game_rect()
            for b, d in mstate.items():
                if d:
                    events.append({"t": end, "k": "mouse", "n": b, "d": 0, "x": 0.5, "y": 0.5})
            if events:
                data = {"version": 1, "map": c.get("map", ""), "name": name, "duration": end,
                        "created": datetime.datetime.now().isoformat(timespec="seconds"), "events": events}
                try:
                    write_json_atomic(self.rec_path(name), data)
                except Exception as e:
                    self.log("Could not save recording '%s': %s" % (name, e), "err")
                else:
                    c["recording"] = name
                    self.save_cfg()
                    self.cfg_rev += 1
                    self.refresh_recs()
                    self.log("Saved '%s' - %d events, %.1fs (%s)" % (name, len(events), end, stop_reason), "ok")
                    # Randy fake awareness - recording stop
                    self._randy_fake_awareness("recording_stop")
            else:
                self.log("Nothing was recorded", "warn")

    def _guard(self, fn):
        try:
            fn()
        except StopRun:
            self.log("Stopped", "warn")
        except Exception as e:
            self.log("Error: %s: %s" % (type(e).__name__, e), "err")
            file_log(traceback.format_exc(), "err")
        finally:
            self.wd_stop.set()
            self.watch_pa = False
            self.watch_restart = False
            try:
                self.release_all()
            except Exception:
                pass
            try:
                if hasattr(self.tl, "g"):
                    self.tl.g.close()
                    del self.tl.g
            except Exception:
                pass
            with self.state_lock:
                self.mode = "idle"
            self.status("Idle")

    def _begin(self, mode, fn):
        with self.state_lock:                # hotkey thread and UI thread can both land here
            if self.mode != "idle":
                return False
            self.stop_evt.clear()
            self.mode = mode
        threading.Thread(target=self._guard, args=(fn,), daemon=True, name="td-" + mode).start()
        return True

    def shutdown(self):
        """Window closing: stop the run, wait briefly, never leave keys held or Roblox orphaned."""
        try:
            self.stop()
            end = time.time() + 2.0
            while self.mode != "idle" and time.time() < end:
                time.sleep(0.02)
            self.release_all()
            self.dock.undock()
            self.save_cfg()
        except Exception:
            pass

    def start(self):
        return self._begin("running", self.run_macro)

    def record_toggle(self):
        if self.mode == "recording":
            self.rec_stop.set()
        elif self.mode == "idle":
            self._begin("recording", self.run_record)

    def _pick_color_mode(self):
        """Dynamic color picker - press F7 to enable, then click anywhere to pick a color"""
        self.log("Color picker mode: Move mouse to pixel and click to pick color (ESC to cancel)", "info")
        pixel_pick_cursor(True)
        last_click = time.time()
        
        while True:
            # Check for ESC to cancel
            if user32.GetAsyncKeyState(VK["esc"]) & 0x8000:
                self.log("Color picker cancelled", "info")
                pixel_pick_cursor(False)
                return
            
            # Check for mouse click
            if user32.GetAsyncKeyState(0x01) & 0x8000:  # Left mouse button
                if time.time() - last_click > 0.3:  # Debounce
                    x, y = cursor_pos()
                    rgb = self._px_rgb_at(x, y)
                    if rgb:
                        hex_color = "#%02X%02X%02X" % rgb
                        self.log("Picked color at (%d, %d): RGB %s = %s" % (x, y, rgb, hex_color), "ok")
                        
                        # Save to config as a custom color slot
                        custom_colors = self.cfg.get("custom_colors", {})
                        slot_name = f"color_{len(custom_colors) + 1}"
                        custom_colors[slot_name] = {"x": x, "y": y, "rgb": rgb, "hex": hex_color}
                        self.cfg["custom_colors"] = custom_colors
                        self._save_cfg()
                        
                        self.log("Saved as %s - use in config as custom_colors.%s.rgb" % (slot_name, slot_name), "ok")
                    else:
                        self.log("Failed to pick color at (%d, %d)" % (x, y), "warn")
                    pixel_pick_cursor(False)
                    return
            time.sleep(0.01)

    def _px_rgb_at(self, x, y):
        """Get RGB color at absolute screen coordinates"""
        try:
            fr = np.asarray(self.g().get({"left": int(x), "top": int(y), "width": 1, "height": 1}))
            return (int(fr[0, 0, 2]), int(fr[0, 0, 1]), int(fr[0, 0, 0]))
        except Exception:
            return None

    def stop(self):
        if self.mode == "recording":
            self.rec_stop.set()
        self.stop_evt.set()
        # Big Dick Randy cannot be stopped - once activated, he is eternal

    def test_scan(self):
        def work():
            try:
                reg, fr, gray = self.grab_gray()
                self.log("Test scan - UI scale %.2f, zone %dx%d" % (self.ui_scale(), reg["width"], reg["height"]), "info")
                rect = roblox_client_rect()
                self.log("  %-18s %s" % ("Roblox window", ("%dx%d%s" % (rect[2], rect[3], ", docked" if self.dock.docked else ""))
                                         if rect else "NOT FOUND"), "ok" if rect else "warn")
                ocr = ocr_status()
                self.log("  %-18s %s" % ("Coin/XP reading", ocr), "ok" if ocr == "ready" else "warn")
                names = [("loaded", "Image 2 Insane"), ("search_maps", "Image 4 Search"), ("ready_a", "Image 3 Ready"),
                         ("ready_b", "Image 5 Ready"), ("play_again", "Image 6 Play Again"),
                         ("restart", "Image 9 Restart"), ("place_hint", "Image 10 Place hint")]
                names += [(k, k) for k in ("leave_btn", "play_triangle", "play_green", "solo_btn") if k in TPL_BASE]
                names += [(k, k + " (yours)") for k in sorted(USER_TPLS) if k in TPL_BASE and k not in [n for n, _l in names]]
                try:
                    _tol = int(self.cfg.get("px_tol", 12))
                    for _lab, _nm, _tg in (("Veto pixel", "vpx", PX_VETO),
                                           ("Restart pixel", "restart_px", PX_LIME),
                                           ("Ready pixel", "ready_px", PX_LIME),
                                           ("Play Again pixel", "play_again_px", PX_LIME),
                                           ("Search bar", "search", PX_SEARCH),
                                           ("Map button", "map", PX_MAP),
                                           ("Ready button", "ready", PX_READY),
                                           ("Veto button", "veto", PX_VETO_BTN)):
                        _rgb = self._px_rgb(_nm)
                        if _rgb is None:
                            self.log("  %-18s not set" % _lab, "info")
                        else:
                            # Use learned color if available
                            _learned = self.cfg.get(_nm + "_color", _tg)
                            _d = self._px_dist(_rgb, _learned)
                            _used = _learned if _learned != _tg else _tg
                            self.log("  %-18s RGB %s %s (target %s, off by %d)%s" % (_lab, _rgb, self._hex(_rgb), self._hex(_used), _d,
                                     " [LEARNED]" if _learned != _tg else ""),
                                     "ok" if _d <= _tol else "info")
                except Exception as e:
                    self.log("  Pixel check failed: %s" % e, "warn")
                for k, label in names:
                    s = max([best_score(gray, t) for _m, t in self._iter_tpls(k)] or [0.0])   # same sizes the real detection tries
                    ok = s >= self.cfg["threshold"]
                    self.log("  %-18s score %.2f %s" % (label, s, "FOUND" if ok else "-"), "ok" if ok else "info")
            except Exception as e:
                self.log("Test scan failed: %s" % e, "err")
        threading.Thread(target=work, daemon=True).start()

    def pick(self, which):
        def work():
            for i in range(3, 0, -1):
                self.status("Move the mouse to the %s corner... %d" % ("top-left" if which == "tl" else "bottom-right", i))
                time.sleep(1)
            x, y = cursor_pos()
            z = self.cfg["zone"]
            if which == "tl":
                z["x1"], z["y1"] = x, y
            else:
                z["x2"], z["y2"] = x, y
            self.cfg["full_screen"] = False
            self.save_cfg()
            self.cfg_rev += 1
            self.status("Idle" if self.mode == "idle" else self.status_text)
            self.log("Picked %s corner: %d, %d" % (which.upper(), x, y), "ok")
        threading.Thread(target=work, daemon=True).start()

    @api_safe(False)
    def maho_test(self):
        """Settings -> Test Mahoraga: shows the wheel + sound right now and pops up a report if something is wrong."""
        self._e.log("Testing Mahoraga - watch the middle of the screen", "info")
        rep = ["Running as: %s" % ("the exe" if FROZEN else "a python script"),
               "GIF: %s  (%s)" % (os.path.basename(MAHO_GIF_PATH), "found" if os.path.exists(MAHO_GIF_PATH) else "MISSING"),
               "Sound: %s  (%s)" % (os.path.basename(MAHO_WAV_PATH), "found" if os.path.exists(MAHO_WAV_PATH) else "MISSING")]
        bad = [not os.path.exists(MAHO_GIF_PATH)]
        for mod in ("PIL", "numpy", "cv2", "PyQt5"):
            try:
                __import__(mod)
                rep.append("%s: OK" % mod)
            except Exception as ex:
                rep.append("%s: NOT AVAILABLE (%s: %s)" % (mod, type(ex).__name__, ex))
                bad.append(True)
        before = MAHO_OVERLAY._shown_count
        MAHO_OVERLAY.set_cfg_enabled(True)
        MAHO_OVERLAY.reset_run()
        MAHO_OVERLAY.trigger()

        def check():
            time.sleep(7)
            if MAHO_OVERLAY._shown_count == before:
                msgbox("Mahoraga did not appear.\n\n" + "\n".join(rep) +
                       "\n\nMore detail: %s\n(lines that start with 'Mahoraga:')" % LOG_PATH)
        threading.Thread(target=check, daemon=True, name="td-maho-check").start()
        return True

    @api_safe(False)
    def bdr_minigame_test(self):
        """Settings -> Test Big Dick Randy Mini-Game: starts the driving chase game."""
        self.log("Starting Big Dick Randy Mini-Game test...", "info")
        self.start_big_dick_randy_minigame()
        return True

    @api_safe(False)
    def randy_approve_feature(self, feature):
        """Ask Randy (Gemini) to approve a feature."""
        decision = self._get_randy_changelog_decision(feature)
        self._add_randy_changelog_entry(feature, decision)
        return decision

    def pick_pt(self, which):
        label = {"search": "search bar", "map": "map", "ready": "Ready button", "veto": "Veto button",
                 "vpx": "VETO pixel (a thick part of a letter of the red message)",
                 "restart_px": "Restart button (lime green)", "ready_px": "Ready button (lime green)",
                 "play_again_px": "Play Again button (lime green)"}[which]

        def work():
            precise = which == "vpx"
            try:
                if precise:
                    pixel_pick_cursor(True)
                for i in range(3, 0, -1):
                    self.status("%sHold the mouse over the %s in Roblox... %d" % (
                        "Thin crosshair on - " if precise else "", label, i))
                    time.sleep(1)
                px, py = cursor_pos()
                x, y, w, h = game_rect()
                fx, fy = (px - x) * 100.0 / max(1, w), (py - y) * 100.0 / max(1, h)
                inside = 0 <= fx <= 100 and 0 <= fy <= 100
                fx, fy = max(0.0, min(100.0, fx)), max(0.0, min(100.0, fy))
                self.cfg[which + "_x"], self.cfg[which + "_y"] = round(fx, 2), round(fy, 2)
                self.save_cfg()
                self.cfg_rev += 1
                self.status("Idle" if self.mode == "idle" else self.status_text)
                self.log("Picked %s position: %.2f%%, %.2f%% of the Roblox window" % (label, fx, fy), "ok")
                # Auto-learn color for all pixel pickers if enabled
                color_targets = {
                    "vpx": PX_VETO,
                    "restart_px": PX_LIME,
                    "ready_px": PX_LIME,
                    "play_again_px": PX_LIME,
                    "search": PX_SEARCH,
                    "map": PX_MAP,
                    "ready": PX_READY,
                    "veto": PX_VETO_BTN,
                }
                if which in color_targets and bool(self.cfg.get("auto_learn_colors", True)):
                    try:
                        _r = self._px_rgb(which)
                        _t = color_targets.get(which, PX_LIME)
                        # Auto-learn the actual color for this profile
                        if _r:
                            self.cfg[which + "_color"] = _r
                            self.save_cfg()
                            self.log("Auto-learned pixel color %s for this profile" % self._hex(_r), "ok")
                        self.log("The pixel there is RGB %s %s right now (target colour is %s) - if the element was not on screen it will not match, that is fine" % (
                            _r, self._hex(_r), self._hex(_t)), "info")
                    except Exception as e:
                        self.log("Could not read that pixel: %s" % e, "warn")
                if not inside:
                    self.log("The mouse was outside the Roblox window - move it over the %s and pick again" % label, "warn")
            finally:
                if precise:
                    pixel_pick_cursor(False)
        threading.Thread(target=work, daemon=True).start()

    def hotkeys(self):
        global TPL_BASE, TEMPLATES
        prev = {}
        last_err = 0.0
        picking_color = False
        while True:
            try:
                for act, key in (("start", "hk_start"), ("stop", "hk_stop"), ("record", "hk_record"), ("pick_color", "hk_pick_color"), ("switch_profile", "hk_switch_profile"), ("reload_templates", "hk_reload_templates")):
                    vk = FKEYS.get(self.cfg.get(key, ""))
                    if not vk:
                        continue
                    d = bool(user32.GetAsyncKeyState(vk) & 0x8000)
                    if d and not prev.get(act):
                        if act == "start":
                            self.start()
                        elif act == "stop":
                            self.stop()
                        elif act == "record":
                            self.record_toggle()
                        elif act == "pick_color":
                            if not picking_color:
                                picking_color = True
                                threading.Thread(target=self._pick_color_mode, daemon=True).start()
                        elif act == "switch_profile":
                            new_profile = _detect_active_game_profile()
                            if new_profile:
                                self.cfg["active_profile"] = new_profile
                                self._save_cfg()
                                self.log("Auto-switched to profile: %s" % new_profile, "ok")
                            else:
                                self.log("No matching profile found for current window", "warn")
                        elif act == "reload_templates":
                            self.log("Reloading templates...", "info")
                            global TPL_BASE, TEMPLATES
                            TPL_BASE, TEMPLATES = _load_templates()
                            self.log("Templates reloaded: %d images loaded" % len(TEMPLATES), "ok")
                    prev[act] = d
                
                # Hot-swap profiles with F11/F12
                if bool(self.cfg.get("hot_swap_profiles", False)):
                    f11_vk = FKEYS.get("f11")
                    f12_vk = FKEYS.get("f12")
                    
                    if f11_vk and bool(user32.GetAsyncKeyState(f11_vk) & 0x8000) and not prev.get("f11"):
                        self.hot_swap_profile(self.cfg.get("hot_swap_profile_1", ""))
                        prev["f11"] = True
                    elif f11_vk and not bool(user32.GetAsyncKeyState(f11_vk) & 0x8000):
                        prev["f11"] = False
                    
                    if f12_vk and bool(user32.GetAsyncKeyState(f12_vk) & 0x8000) and not prev.get("f12"):
                        self.hot_swap_profile(self.cfg.get("hot_swap_profile_2", ""))
                        prev["f12"] = True
                    elif f12_vk and not bool(user32.GetAsyncKeyState(f12_vk) & 0x8000):
                        prev["f12"] = False
                    vk = FKEYS.get(self.cfg.get(key, ""))
                    if not vk:
                        continue
                    d = bool(user32.GetAsyncKeyState(vk) & 0x8000)
                    if d and not prev.get(act):
                        if act == "start":
                            self.start()
                        elif act == "stop":
                            self.stop()
                        elif act == "record":
                            self.record_toggle()
                        elif act == "pick_color":
                            if not picking_color:
                                picking_color = True
                                threading.Thread(target=self._pick_color_mode, daemon=True).start()
                        elif act == "switch_profile":
                            new_profile = _detect_active_game_profile()
                            if new_profile:
                                self.cfg["active_profile"] = new_profile
                                self._save_cfg()
                                self.log("Auto-switched to profile: %s" % new_profile, "ok")
                            else:
                                self.log("No matching profile found for current window", "warn")
                        elif act == "reload_templates":
                            self.log("Reloading templates...", "info")
                            TPL_BASE, TEMPLATES = _load_templates()
                            self.log("Templates reloaded: %d images loaded" % len(TEMPLATES), "ok")
                    prev[act] = d
            except Exception as e:
                if time.time() - last_err > 30:
                    last_err = time.time()
                    file_log("hotkey loop error: %s: %s" % (type(e).__name__, e), "warn")
            time.sleep(0.02)

    def voice_control_thread(self):
        """Voice control thread using Windows Speech Recognition API."""
        if not bool(self.cfg.get("voice_control", False)):
            return
        
        try:
            import speech_recognition as sr
        except ImportError:
            self.log("Voice control disabled: speech_recognition not installed. Run: pip install SpeechRecognition", "warn")
            return
        
        r = sr.Recognizer()
        self.log("Voice control enabled. Commands: start macro, stop macro, skip run", "info")
        
        last_err = 0.0
        while not self._voice_stop.is_set():
            try:
                with sr.Microphone() as source:
                    r.adjust_for_ambient_noise(source, duration=0.5)
                    try:
                        audio = r.listen(source, timeout=1, phrase_time_limit=3)
                        text = r.recognize_google(audio).lower()
                        self.log("Voice command: '%s'" % text, "info")
                        
                        start_cmd = self.cfg.get("voice_start", "start macro").lower()
                        stop_cmd = self.cfg.get("voice_stop", "stop macro").lower()
                        skip_cmd = self.cfg.get("voice_skip", "skip run").lower()
                        
                        if start_cmd in text:
                            self.log("Voice: starting macro", "ok")
                            self.start()
                        elif stop_cmd in text:
                            self.log("Voice: stopping macro", "ok")
                            self.stop()
                        elif skip_cmd in text:
                            self.log("Voice: skipping run", "ok")
                            self.stop_evt.set()
                    except sr.WaitTimeoutError:
                        pass  # No speech detected, continue
                    except sr.UnknownValueError:
                        pass  # Speech not understood, continue
                    except sr.RequestError as e:
                        self.log("Voice recognition error: %s" % e, "warn")
            except Exception as e:
                if time.time() - last_err > 30:
                    last_err = time.time()
                    self.log("Voice control loop error: %s" % e, "warn")
            time.sleep(0.1)
    
    def start_voice_control(self):
        """Start the voice control thread."""
        if bool(self.cfg.get("voice_control", False)):
            self._voice_stop.clear()
            self._voice_thread = threading.Thread(target=self.voice_control_thread, daemon=True, name="voice-control")
            self._voice_thread.start()
    
    def stop_voice_control(self):
        """Stop the voice control thread."""
        self._voice_stop.set()
        if self._voice_thread and self._voice_thread.is_alive():
            self._voice_thread.join(timeout=1.0)


# ======================================================================
#  PROFILES  -  per-game profiles, image library, step builder, snip tool
# ======================================================================

PROFILES_DIR = os.path.join(DATA_DIR, "profiles")
_PROFILE_IMAGES_DIR = lambda pid: os.path.join(PROFILES_DIR, pid, "images")

_DEFAULT_STEPS = [
    {"type": "wait_image",  "image": "loaded",     "click": False, "timeout": 30},
    {"type": "run_intro",   "label": "TDS intro"},
    {"type": "play_recording", "recording": ""},
    {"type": "wait_image",  "image": "play_again", "click": True,  "timeout": 0},
]

_DEFAULT_PROFILE = {
    "name":        "Tower Defense Simulator",
    "game_id":     "3260590327",
    "tds_mode":    True,
    "hybrid_mode": False,
    "steps":       _DEFAULT_STEPS,
    "attack_keys": ["1", "2", "3", "4", "5"],
    "cancel_key":  "q",
    "click_spots": [],
    "images":      {},
    "coins_per_run": 0,
    "xp_per_run":    0,
    "window_patterns": [{"title_contains": "roblox", "class_contains": "windowsclient"}],
}

# Gamemode-specific preset profiles
_GAMEMODE_PROFILES = {
    "tds_easy": {
        "name": "TDS Easy",
        "game_id": "3260590327",
        "tds_mode": True,
        "hybrid_mode": False,
        "steps": _DEFAULT_STEPS,
        "attack_keys": ["1", "2", "3", "4", "5"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
        "coins_per_run": 0,
        "xp_per_run": 0,
        "window_patterns": [{"title_contains": "roblox", "class_contains": "windowsclient"}],
    },
    "tds_casual": {
        "name": "TDS Casual",
        "game_id": "3260590327",
        "tds_mode": True,
        "hybrid_mode": False,
        "steps": _DEFAULT_STEPS,
        "attack_keys": ["1", "2", "3", "4", "5"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
        "coins_per_run": 0,
        "xp_per_run": 0,
        "window_patterns": [{"title_contains": "roblox", "class_contains": "windowsclient"}],
    },
    "tds_intermediate": {
        "name": "TDS Intermediate",
        "game_id": "3260590327",
        "tds_mode": True,
        "hybrid_mode": False,
        "steps": _DEFAULT_STEPS,
        "attack_keys": ["1", "2", "3", "4", "5"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
        "coins_per_run": 0,
        "xp_per_run": 0,
        "window_patterns": [{"title_contains": "roblox", "class_contains": "windowsclient"}],
    },
    "tds_molten": {
        "name": "TDS Molten",
        "game_id": "3260590327",
        "tds_mode": True,
        "hybrid_mode": False,
        "steps": _DEFAULT_STEPS,
        "attack_keys": ["1", "2", "3", "4", "5"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
        "coins_per_run": 0,
        "xp_per_run": 0,
        "window_patterns": [{"title_contains": "roblox", "class_contains": "windowsclient"}],
    },
    "tds_fallen": {
        "name": "TDS Fallen",
        "game_id": "3260590327",
        "tds_mode": True,
        "hybrid_mode": False,
        "steps": _DEFAULT_STEPS,
        "attack_keys": ["1", "2", "3", "4", "5"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
        "coins_per_run": 0,
        "xp_per_run": 0,
        "window_patterns": [{"title_contains": "roblox", "class_contains": "windowsclient"}],
    },
    "tds_frost": {
        "name": "TDS Frost",
        "game_id": "3260590327",
        "tds_mode": True,
        "hybrid_mode": False,
        "steps": _DEFAULT_STEPS,
        "attack_keys": ["1", "2", "3", "4", "5"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
        "coins_per_run": 0,
        "xp_per_run": 0,
        "window_patterns": [{"title_contains": "roblox", "class_contains": "windowsclient"}],
    },
}

# Profile templates for quick creation
_PROFILE_TEMPLATES = {
    "blank": {
        "name": "Blank",
        "description": "Empty profile - start from scratch",
        "tds_mode": False,
        "hybrid_mode": False,
        "steps": [],
        "attack_keys": ["1", "2", "3", "4", "5"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
    },
    "fast_farm": {
        "name": "Fast Farm",
        "description": "Optimized for quick runs with minimal tower placements",
        "tds_mode": False,
        "hybrid_mode": True,
        "steps": [
            {"type": "wait", "duration": 2},
            {"type": "play_recording", "recording": ""},
            {"type": "wait_image", "image": "play_again", "click": True, "timeout": 0},
        ],
        "attack_keys": ["1", "2"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
    },
    "high_wave": {
        "name": "High Wave",
        "description": "For longer runs with ability timing",
        "tds_mode": False,
        "hybrid_mode": True,
        "steps": [
            {"type": "wait", "duration": 5},
            {"type": "play_recording", "recording": ""},
            {"type": "wait", "duration": 60},
            {"type": "key_press", "key": "1", "count": 1, "hold": 0.1},
            {"type": "wait", "duration": 60},
            {"type": "key_press", "key": "2", "count": 1, "hold": 0.1},
            {"type": "wait_image", "image": "play_again", "click": True, "timeout": 0},
        ],
        "attack_keys": ["1", "2", "3", "4", "5"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
    },
    "survival": {
        "name": "Survival",
        "description": "Endurance runs with multiple ability rotations",
        "tds_mode": False,
        "hybrid_mode": True,
        "steps": [
            {"type": "wait", "duration": 5},
            {"type": "play_recording", "recording": ""},
            {"type": "wait", "duration": 30},
            {"type": "key_press", "key": "1", "count": 1, "hold": 0.1},
            {"type": "key_press", "key": "2", "count": 1, "hold": 0.1},
            {"type": "wait", "duration": 30},
            {"type": "key_press", "key": "3", "count": 1, "hold": 0.1},
            {"type": "key_press", "key": "4", "count": 1, "hold": 0.1},
            {"type": "wait", "duration": 30},
            {"type": "key_press", "key": "5", "count": 1, "hold": 0.1},
            {"type": "wait_image", "image": "play_again", "click": True, "timeout": 0},
        ],
        "attack_keys": ["1", "2", "3", "4", "5"],
        "cancel_key": "q",
        "click_spots": [],
        "images": {},
    },
}

# ------------------------------------------------------------------
# Profile storage helpers
# ------------------------------------------------------------------
def _profile_path(pid):
    return os.path.join(PROFILES_DIR, pid + ".json")

def _load_profile(pid):
    try:
        with open(_profile_path(pid), "r", encoding="utf-8") as f:
            p = json.load(f)
        # merge defaults so old profiles stay compatible
        for k, v in _DEFAULT_PROFILE.items():
            if k not in p:
                p[k] = v
        return p
    except Exception:
        return dict(_DEFAULT_PROFILE)

def _save_profile(pid, data):
    os.makedirs(PROFILES_DIR, exist_ok=True)
    with open(_profile_path(pid), "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

def _list_profiles():
    """Returns list of {id, name} sorted by name. Always includes 'tds' as fallback."""
    os.makedirs(PROFILES_DIR, exist_ok=True)
    out = []
    for fn in sorted(os.listdir(PROFILES_DIR)):
        if fn.endswith(".json"):
            pid = fn[:-5]
            try:
                with open(os.path.join(PROFILES_DIR, fn), "r", encoding="utf-8") as f:
                    j = json.load(f)
                out.append({"id": pid, "name": j.get("name", pid)})
            except Exception:
                out.append({"id": pid, "name": pid})
    if not out:
        # create default TDS profile on first run
        _save_profile("tds", dict(_DEFAULT_PROFILE))
        out = [{"id": "tds", "name": _DEFAULT_PROFILE["name"]}]
    return out

def _ensure_default_profile():
    if not os.path.exists(_profile_path("tds")):
        _save_profile("tds", dict(_DEFAULT_PROFILE))
    # Create gamemode-specific profiles
    for pid, profile in _GAMEMODE_PROFILES.items():
        if not os.path.exists(_profile_path(pid)):
            _save_profile(pid, dict(profile))

def _detect_active_game_profile():
    """Auto-detect which game is active and return its profile ID"""
    try:
        # Get foreground window
        hwnd = user32.GetForegroundWindow()
        if not hwnd:
            return None
        
        # Get window title
        title = ctypes.create_unicode_buffer(256)
        user32.GetWindowTextW(hwnd, title, 256)
        title_text = title.value.lower()
        
        # Get window class
        classname = ctypes.create_unicode_buffer(256)
        user32.GetClassNameW(hwnd, classname, 256)
        class_text = classname.value.lower()
        
        # Check all profiles for matching window patterns
        profiles = _list_profiles()
        for p in profiles:
            try:
                prof = _load_profile(p["id"])
                # Check if profile has window detection rules
                window_patterns = prof.get("window_patterns", [])
                for pattern in window_patterns:
                    if isinstance(pattern, dict):
                        # Check title pattern
                        if "title_contains" in pattern:
                            if pattern["title_contains"].lower() in title_text:
                                file_log("Auto-detected profile '%s' from window title: %s" % (p["id"], title_text))
                                return p["id"]
                        # Check class pattern
                        if "class_contains" in pattern:
                            if pattern["class_contains"].lower() in class_text:
                                file_log("Auto-detected profile '%s' from window class: %s" % (p["id"], class_text))
                                return p["id"]
            except Exception:
                continue
        
        return None
    except Exception as e:
        file_log("Auto-detect profile failed: %s" % e, "warn")
        return None

# ------------------------------------------------------------------
# Image library helpers
# ------------------------------------------------------------------
def _img_dir(pid):
    d = _PROFILE_IMAGES_DIR(pid)
    os.makedirs(d, exist_ok=True)
    return d

def _img_path(pid, name):
    return os.path.join(_img_dir(pid), name + ".png")

def _img_thumbnail_b64(path, max_px=80):
    """Shrink a PNG to a small base64 thumbnail for the UI."""
    try:
        import cv2 as _cv2
        import numpy as _np
        img = _cv2.imread(path, _cv2.IMREAD_UNCHANGED)
        if img is None:
            return ""
        h, w = img.shape[:2]
        scale = min(max_px / max(w, 1), max_px / max(h, 1), 1.0)
        if scale < 1.0:
            img = _cv2.resize(img, (max(1, int(w * scale)), max(1, int(h * scale))),
                              interpolation=_cv2.INTER_AREA)
        ok, buf = _cv2.imencode(".png", img)
        if ok:
            return base64.b64encode(buf.tobytes()).decode()
    except Exception:
        pass
    try:
        with open(path, "rb") as f:
            return base64.b64encode(f.read()).decode()
    except Exception:
        return ""

def _list_images(pid):
    """Returns [{name, thumb_b64}] for the profile."""
    d = _img_dir(pid)
    out = []
    for fn in sorted(os.listdir(d)):
        if fn.lower().endswith(".png"):
            name = fn[:-4]
            out.append({"name": name, "thumb": _img_thumbnail_b64(os.path.join(d, fn))})
    return out

def _save_image_from_b64(pid, name, b64_data):
    """Save a base64-encoded PNG to the profile image library."""
    import re as _re
    b64_data = _re.sub(r"^data:image/[a-z]+;base64,", "", b64_data)
    raw = base64.b64decode(b64_data)
    path = _img_path(pid, name)
    with open(path, "wb") as f:
        f.write(raw)
    return path

def _delete_image(pid, name):
    path = _img_path(pid, name)
    try:
        os.remove(path)
        return True
    except OSError:
        return False

# ------------------------------------------------------------------
# Snip tool  (PyQt5 fullscreen transparent overlay, drag to capture)
# ------------------------------------------------------------------
def _run_snip_tool():
    """
    Shows a fullscreen crosshair overlay. Player drags a rectangle.
    Returns base64-encoded PNG of the captured region, or "" on cancel.
    Runs synchronously on the Qt main thread via QApplication.exec().
    """
    try:
        from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QRubberBand
        from PyQt5.QtCore    import Qt, QRect, QPoint, QSize
        from PyQt5.QtGui     import QColor, QPainter, QPen, QCursor
        import mss as _mss

        app = QApplication.instance() or QApplication([])
        result = [None]

        class SnipOverlay(QWidget):
            def __init__(self):
                super().__init__(None, Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint | Qt.Tool)
                self.setAttribute(Qt.WA_TranslucentBackground)
                self.setAttribute(Qt.WA_DeleteOnClose)
                self.setWindowState(Qt.WindowFullScreen)
                # Cover all screens
                from PyQt5.QtWidgets import QDesktopWidget
                geo = QDesktopWidget().screenGeometry(-1)
                # Union of all screens
                from PyQt5.QtWidgets import QApplication as _A
                screens = _A.screens()
                x1 = min(s.geometry().x() for s in screens)
                y1 = min(s.geometry().y() for s in screens)
                x2 = max(s.geometry().x() + s.geometry().width()  for s in screens)
                y2 = max(s.geometry().y() + s.geometry().height() for s in screens)
                self.setGeometry(x1, y1, x2 - x1, y2 - y1)
                self._origin = QPoint()
                self._rb = QRubberBand(QRubberBand.Rectangle, self)
                self.setCursor(QCursor(Qt.CrossCursor))
                self.show()

            def paintEvent(self, ev):
                p = QPainter(self)
                p.fillRect(self.rect(), QColor(0, 0, 0, 80))

            def mousePressEvent(self, ev):
                if ev.button() == Qt.LeftButton:
                    self._origin = ev.pos()
                    self._rb.setGeometry(QRect(self._origin, QSize()))
                    self._rb.show()
                elif ev.button() == Qt.RightButton:
                    result[0] = ""
                    self.close()
                    app.quit()

            def mouseMoveEvent(self, ev):
                if not self._origin.isNull():
                    self._rb.setGeometry(QRect(self._origin, ev.pos()).normalized())

            def mouseReleaseEvent(self, ev):
                if ev.button() == Qt.LeftButton and not self._origin.isNull():
                    rect = QRect(self._origin, ev.pos()).normalized()
                    # Map from widget coords to screen coords
                    gx = self.geometry().x()
                    gy = self.geometry().y()
                    sx, sy = rect.x() + gx, rect.y() + gy
                    sw, sh = rect.width(), rect.height()
                    result[0] = (sx, sy, sw, sh)
                    self.close()
                    app.quit()

            def keyPressEvent(self, ev):
                if ev.key() == Qt.Key_Escape:
                    result[0] = ""
                    self.close()
                    app.quit()

        SnipOverlay()
        app.exec_()

        if not result[0] or isinstance(result[0], str):
            return ""
        sx, sy, sw, sh = result[0]
        if sw < 4 or sh < 4:
            return ""
        with _mss.mss() as sct:
            shot = sct.grab({"left": sx, "top": sy, "width": sw, "height": sh})
            import cv2 as _cv2, numpy as _np
            img = _np.frombuffer(shot.raw, dtype=_np.uint8).reshape((shot.height, shot.width, 4))
            img = _cv2.cvtColor(img, _cv2.COLOR_BGRA2BGR)
            ok, buf = _cv2.imencode(".png", img)
            if ok:
                return base64.b64encode(buf.tobytes()).decode()
        return ""
    except Exception as e:
        return ""

# ------------------------------------------------------------------
# Step engine
# ------------------------------------------------------------------
_ALL_KEYS = [
    "0","1","2","3","4","5","6","7","8","9",
    "a","b","c","e","f","g","h","i","j","k","l","m",
    "n","o","p","q","r","s","t","u","v","x","y","z",
    "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12",
    "space","enter","escape","tab","shift","ctrl","alt","backspace","delete",
    "insert","home","end","pageup","pagedown",
    "up","down","left","right",
    "numpad0","numpad1","numpad2","numpad3","numpad4",
    "numpad5","numpad6","numpad7","numpad8","numpad9",
    "num+","num-","num*","num/","num.",
    "lmb","rmb","mmb",
    "`","minus","equals","[","]","\\",";","quote",",",".","/"
]

class StepEngine:
    """
    Executes a player-built step list against a running Engine instance.
    Each step is a dict with a 'type' key plus type-specific fields.
    """

    STEP_TYPES = (
        "wait",            # {"seconds": float}
        "click",           # {"x": int, "y": int, "times": int}
        "key_press",       # {"key": str, "times": int, "hold": float}
        "wait_image",      # {"image": str, "click": bool, "timeout": float}
        "wait_pixel",      # {"pixel": str, "click": bool, "timeout": float} - wait for pixel color at saved position
        "play_recording",  # {"recording": str}
        "start_macro",     # {}  - begin playback of the selected recording in a loop
        "stop_macro",      # {}
        "start_recording", # {}
        "stop_recording",  # {}
        "type_text",       # {"text": str}
        "run_intro",       # {}  - run the TDS intro sequence (tds_mode only)
    )

    def __init__(self, engine):
        self._e = engine

    def run_steps(self, steps):
        """Run a step list. Raises StopRun if the engine is stopped."""
        for i, step in enumerate(steps):
            t = step.get("type", "")
            self._e.log("Step %d: %s" % (i + 1, t), "info")
            self._run_one(step)

    def _run_one(self, step):
        e = self._e
        t = step.get("type", "")

        if t == "wait":
            secs = float(step.get("seconds", 1))
            e.status("Wait %.1fs" % secs)
            e.sleep(secs)

        elif t == "click":
            x, y   = int(step.get("x", 0)), int(step.get("y", 0))
            times  = max(1, int(step.get("times", 1)))
            delay  = float(step.get("delay", 0.05))
            e.status("Click %dx at (%d,%d)" % (times, x, y))
            for _ in range(times):
                e.click_abs(x, y)
                if times > 1:
                    e.sleep(delay)

        elif t == "key_press":
            key   = str(step.get("key", ""))
            times = max(1, int(step.get("times", 1)))
            hold  = float(step.get("hold", 0.05))
            if key:
                e.status("Key %s x%d" % (key.upper(), times))
                for _ in range(times):
                    e.tap(key, hold)
                    if times > 1:
                        e.sleep(0.05)

        elif t == "wait_image":
            img     = str(step.get("image", ""))
            click   = bool(step.get("click", False))
            timeout = float(step.get("timeout", 30)) or float("inf")
            e.status("Waiting for image: %s" % img)
            hit = e.wait_image(img, timeout)
            if hit and click:
                e.click_match(img)

        elif t == "wait_pixel":
            pixel   = str(step.get("pixel", ""))
            click   = bool(step.get("click", False))
            timeout = float(step.get("timeout", 30)) or float("inf")
            e.status("Waiting for pixel: %s" % pixel)
            # Get the default color for this pixel
            color_targets = {
                "vpx": PX_VETO,
                "restart_px": PX_LIME,
                "ready_px": PX_LIME,
                "play_again_px": PX_LIME,
                "search": PX_SEARCH,
                "map": PX_MAP,
                "ready": PX_READY,
                "veto": PX_VETO_BTN,
            }
            default_color = color_targets.get(pixel, PX_LIME)
            # Poll for pixel color match
            t0 = time.time()
            while True:
                if e.stop_evt.is_set():
                    return
                if e._check_pixel(pixel, default_color):
                    pos = e.point(pixel)
                    if pos and click:
                        e.click(pos)
                    e.log("Pixel %s matched" % pixel, "ok")
                    break
                if time.time() - t0 >= timeout:
                    e.log("Pixel %s not found within %.1fs" % (pixel, timeout), "warn")
                    break
                e.sleep(0.1)

        elif t == "play_recording":
            rec_name = str(step.get("recording", "")) or e.cfg.get("recording", "")
            if rec_name:
                rec = e.load_rec(rec_name)
                if rec:
                    e.status("Playing recording '%s'" % rec_name)
                    e.set_phase("play", budget=0)
                    # 2x speed mode: click arrow then 2x button
                    if bool(e.cfg.get("time_scale_2x", False)):
                        e.log("2x speed enabled - searching for arrow button...", "info")
                        # Search for arrow button every 0.05 seconds
                        arrow_found = e.wait_image("speed_arrow", timeout=30)
                        if arrow_found:
                            e.log("Arrow button found - clicking", "ok")
                            e.click_match("speed_arrow")
                            e.sleep(0.2)
                            # Search for 2x button
                            e.log("Searching for 2x button...", "info")
                            twx_found = e.wait_image("speed_2x", timeout=10)
                            if twx_found:
                                e.log("2x button found - clicking", "ok")
                                e.click_match("speed_2x")
                                e.sleep(0.2)
                            else:
                                e.log("2x button not found - continuing", "warn")
                        else:
                            e.log("Arrow button not found - continuing without 2x", "warn")
                    e.play(rec)
                else:
                    e.log("Step: recording '%s' not found" % rec_name, "warn")
            else:
                e.log("Step: no recording selected", "warn")

        elif t == "start_macro":
            rec_name = e.cfg.get("recording", "")
            rec = e.load_rec(rec_name) if rec_name else None
            if rec:
                e.status("Playing recording (loop)")
                e.set_phase("play", budget=0)
                e.play(rec)
                n = 1
                while True:
                    n += 1
                    e.sleep(1.0)
                    e.play(rec, repeat=True)
            else:
                e.log("Step: start_macro - no recording selected", "warn")

        elif t == "stop_macro":
            # stop_macro mid-step just lets the loop continue to the next step
            e.log("Step: stop_macro (continuing to next step)", "info")

        elif t == "start_recording":
            if e.mode == "idle":
                e._begin("recording", e.run_record)
            else:
                e.log("Step: start_recording - already in mode '%s'" % e.mode, "warn")

        elif t == "stop_recording":
            e.rec_stop.set()

        elif t == "type_text":
            text = str(step.get("text", ""))
            if text:
                e.status("Typing: %s" % text[:20])
                e.type_string(text)

        elif t == "run_intro":
            e.status("Running intro sequence")
            e.set_phase("intro")
            try:
                # Check if we're in TDS or hybrid mode - run_intro is designed for TDS
                pid = getattr(e, "_active_pid", "tds")
                profile = _load_profile(pid)
                tds_mode = bool(profile.get("tds_mode", True))
                hybrid_mode = bool(profile.get("hybrid_mode", False))
                if not (tds_mode or hybrid_mode):
                    e.log("Step: run_intro used in non-TDS/non-hybrid profile - may not work as expected", "info")
                e.intro()
            except Exception as ex:
                e.log("Step: intro error: %s" % ex, "warn")

        else:
            e.log("Step: unknown type '%s' - skipping" % t, "warn")

# ======================================================================
#  ROBLOX / Glint  -  launcher, join-by-link, FPS flags, FPS tracker
#  All logic lives here; the Api class below just exposes it to the UI.
# ======================================================================

import urllib.request as _urlreq, urllib.error as _urlerr, urllib.parse as _urlparse

_RBX_UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
           "(KHTML, like Gecko) Chrome/124.0 Safari/537.36")
_RBX_LOCAL = os.environ.get("LOCALAPPDATA", "")
_RBX_TOOLS_DIR = os.path.join(DATA_DIR, "tools")
_PM_EXE   = os.path.join(_RBX_TOOLS_DIR, "PresentMon.exe")
_PM_URL   = "https://github.com/GameTechDev/PresentMon/releases/download/v2.3.1/PresentMon-2.3.1-x64.exe"
_FPS_CSV  = os.path.join(_RBX_TOOLS_DIR, "fps_capture.csv")
_FPS_STOP = os.path.join(_RBX_TOOLS_DIR, "fps_capture.stop")
_NO_WIN   = 0x08000000   # CREATE_NO_WINDOW

# Fast flags written to ClientAppSettings.json
_FPS_FLAGS = {
    "DFFlagDebugPauseVoxelizer": True,
    "DFIntCSGLevelOfDetailSwitchingDistance": 0,
    "DFIntCSGLevelOfDetailSwitchingDistanceL12": 0,
    "DFIntCSGLevelOfDetailSwitchingDistanceL23": 0,
    "DFIntCSGLevelOfDetailSwitchingDistanceL34": 0,
    "DFIntDebugFRMQualityLevelOverride": 1,
    "FFlagDebugGraphicsPreferOpenGL": False,
    "FFlagDebugGraphicsPreferVulkan": False,
    "FFlagDebugSkyGray": True,
    "FIntFRMMaxGrassDistance": 0,
    "FIntFRMMinGrassDistance": 0,
    "FIntGrassMovementReducedMotionFactor": 0,
}

# IxpSettings.json preset (base64-encoded, compressed) - provides additional performance optimization
_IXP_B64 = (
    "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"
    "/aPhkTjoEn7PI/w8aNdPBrtJ46rxv/73f3eCFN4="
)


def _ixp_text():
    """Decompress and decode the IxpSettings.json preset."""
    import zlib
    return zlib.decompress(base64.b64decode(_IXP_B64)).decode("utf-8")

_CAP_RE_RBX = re.compile(r'(<int name="FramerateCap">)(-?\d+)(</int>)')


def _rbx_http(method, url, headers=None, body=None):
    req = _urlreq.Request(url, data=body, method=method, headers=headers or {})
    try:
        r = _urlreq.urlopen(req, timeout=20)
        return r.status, r.headers, r.read()
    except _urlerr.HTTPError as e:
        return e.code, e.headers, e.read()


def _rbx_auth_headers(cookie, json_body=False):
    h = {"Cookie": ".ROBLOSECURITY=" + cookie, "User-Agent": _RBX_UA,
         "Referer": "https://www.roblox.com/", "Origin": "https://www.roblox.com"}
    if json_body:
        h["Content-Type"] = "application/json"
    return h


def _rbx_post_csrf(url, cookie, payload=b"{}"):
    h = _rbx_auth_headers(cookie, True)
    st, hd, body = _rbx_http("POST", url, h, payload)
    if st == 403 and hd.get("x-csrf-token"):
        h["X-CSRF-TOKEN"] = hd.get("x-csrf-token")
        st, hd, body = _rbx_http("POST", url, h, payload)
    return st, hd, body


_RBX_EXTRA_BASES = []   # Versions folders learned from a running Roblox (see _rbx_probe_running)


def _rbx_probe_running():
    """Ask Windows where a running RobloxPlayerBeta.exe lives (no PowerShell) and remember its Versions folder."""
    paths = []
    try:
        import csv as _csv
        out = subprocess.run(["tasklist", "/FI", "IMAGENAME eq RobloxPlayerBeta.exe", "/FO", "CSV", "/NH"],
                             capture_output=True, text=True, creationflags=_NO_WIN, stdin=subprocess.DEVNULL).stdout
        for row in _csv.reader(out.splitlines()):
            if len(row) > 1 and row[0].lower() == "robloxplayerbeta.exe" and row[1].isdigit():
                h = _k32.OpenProcess(0x1000, False, int(row[1])) if _k32 else None   # PROCESS_QUERY_LIMITED_INFORMATION
                if h:
                    try:
                        buf = ctypes.create_unicode_buffer(1024)
                        n = wintypes.DWORD(1024)
                        if _k32.QueryFullProcessImageNameW(h, 0, buf, ctypes.byref(n)):
                            paths.append(buf.value)
                    finally:
                        _k32.CloseHandle(h)
    except Exception:
        pass
    for pth in paths:
        m = re.match(r"(.*)[\\/]version-[0-9a-fA-F]+[\\/]", pth)
        if m and m.group(1) not in _RBX_EXTRA_BASES:
            _RBX_EXTRA_BASES.append(m.group(1))
    return paths


def _rbx_version_bases():
    """Every folder that may hold Roblox 'version-*' folders (standard, per-machine, Bloxstrap-style, registry)."""
    pf  = os.environ.get("ProgramFiles", "")
    pf86 = os.environ.get("ProgramFiles(x86)", "")
    cands = [os.path.join(_RBX_LOCAL, "Roblox", "Versions"),
             os.path.join(pf86, "Roblox", "Versions"),
             os.path.join(pf, "Roblox", "Versions"),
             os.path.join(_RBX_LOCAL, "Bloxstrap", "Versions"),
             os.path.join(_RBX_LOCAL, "Fishstrap", "Versions"),
             os.path.join(_RBX_LOCAL, "Voidstrap", "Versions")]
    # Whatever the roblox-player: protocol handler points at (works for any install location)
    try:
        import winreg as _wr
        for hive in (_wr.HKEY_CURRENT_USER, _wr.HKEY_LOCAL_MACHINE):
            for sub in (r"Software\Classes\roblox-player\shell\open\command",
                        r"SOFTWARE\Classes\roblox-player\shell\open\command"):
                try:
                    with _wr.OpenKey(hive, sub) as k:
                        val = _wr.QueryValueEx(k, "")[0]
                    m = re.search(r'"?([A-Za-z]:[^"]*?)\\(version-[0-9a-fA-F]+)\\', val)
                    if m:
                        cands.append(m.group(1))
                except OSError:
                    pass
    except Exception:
        pass
    cands.extend(_RBX_EXTRA_BASES)
    seen, out = set(), []
    for c in cands:
        if c and c.lower() not in seen:
            seen.add(c.lower())
            out.append(c)
    return out


def _rbx_flag_targets():
    """(version_key, ClientSettings_folder) for every installed Roblox client."""
    out = []
    for base in _rbx_version_bases():
        if not os.path.isdir(base):
            continue
        try:
            names = os.listdir(base)
        except OSError:
            continue
        for d in names:
            p = os.path.join(base, d)
            if os.path.exists(os.path.join(p, "RobloxPlayerBeta.exe")):
                out.append((d, os.path.join(p, "ClientSettings")))
    return out


def _rbx_find_settings_xml():
    """Path to GlobalBasicSettings_13.xml (or the highest-numbered variant)."""
    folders = [os.path.join(_RBX_LOCAL, "Roblox"),
               os.path.join(os.environ.get("APPDATA", "."), "Roblox")]
    for fo in folders:
        p = os.path.join(fo, "GlobalBasicSettings_13.xml")
        if os.path.exists(p):
            return p
    best = None
    for fo in folders:
        try:
            for n in os.listdir(fo):
                m = re.fullmatch(r"GlobalBasicSettings_(\d+)\.xml", n)
                if m and (best is None or int(m.group(1)) > best[0]):
                    best = (int(m.group(1)), os.path.join(fo, n))
        except OSError:
            pass
    return (best[1] if best else os.path.join(_RBX_LOCAL, "Roblox", "GlobalBasicSettings_13.xml"))


def _rbx_roblox_running():
    try:
        out = subprocess.run(["tasklist", "/FI", "IMAGENAME eq RobloxPlayerBeta.exe", "/NH"],
                             capture_output=True, text=True, creationflags=_NO_WIN,
                             stdin=subprocess.DEVNULL).stdout
        return "RobloxPlayerBeta.exe" in out
    except Exception:
        return False


def _rbx_write_if_different(path, text):
    try:
        with open(path, "r", encoding="utf-8", newline="") as f:
            if f.read() == text:
                return False
    except OSError:
        pass
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text)
    return True


def _rbx_parse_target(text):
    t = (text or "").strip()
    if not t:
        return None
    if t.isdigit():
        return {"kind": "place", "place": int(t)}
    if "/share" in t and "type=Server" in t:
        m = re.search(r"code=([0-9A-Za-z]+)", t)
        if m:
            return {"kind": "share", "code": m.group(1)}
    place = re.search(r"/games/(\d+)", t) or re.search(r"placeId=(\d+)", t, re.I)
    link  = re.search(r"privateServerLinkCode=([\w-]+)", t)
    job   = re.search(r"gameInstanceId=([0-9a-fA-F-]{36})", t)
    if place and link:
        return {"kind": "private", "place": int(place.group(1)), "link": link.group(1)}
    if place and job:
        return {"kind": "job", "place": int(place.group(1)), "job": job.group(1)}
    if place:
        return {"kind": "place", "place": int(place.group(1))}
    return None


# ----------------------------------------------------------------------
#  System stats sampler (CPU / RAM via ctypes, GPU via nvidia-smi if present)
#  Only does work while the overlay is visible. No extra libraries needed.
# ----------------------------------------------------------------------
class _SysSampler:
    def __init__(self):
        self.active = False
        self.cpu = 0.0
        self.ram = 0.0
        self.gpu = None        # percent, or None when unavailable
        self.cpu_t = None      # deg C, or None when unavailable
        self.gpu_t = None
        self._prev = None
        self._started = False
        self._no_nv = False
        self._ct_fail = 0
        self._wmi_checked = False
        self._wmi_available = False

    def start(self):
        self.active = True
        if self._started:
            return
        self._started = True
        threading.Thread(target=self._run, daemon=True, name="td-sysstats").start()

    def stop(self):
        self.active = False

    def _cpu_sample(self):
        class _FT(ctypes.Structure):
            _fields_ = [("lo", wintypes.DWORD), ("hi", wintypes.DWORD)]
        idle, kern, usr = _FT(), _FT(), _FT()
        if not ctypes.windll.kernel32.GetSystemTimes(ctypes.byref(idle), ctypes.byref(kern), ctypes.byref(usr)):
            return
        v = lambda f: (f.hi << 32) | f.lo
        i, k, u = v(idle), v(kern), v(usr)
        if self._prev:
            total = (k - self._prev[1]) + (u - self._prev[2])   # kernel time already includes idle
            di = i - self._prev[0]
            if total > 0:
                self.cpu = max(0.0, min(100.0, (1.0 - di / float(total)) * 100.0))
        self._prev = (i, k, u)

    def _ram_sample(self):
        class _MS(ctypes.Structure):
            _fields_ = [("dwLength", wintypes.DWORD), ("dwMemoryLoad", wintypes.DWORD),
                        ("ullTotalPhys", ctypes.c_ulonglong), ("ullAvailPhys", ctypes.c_ulonglong),
                        ("ullTotalPageFile", ctypes.c_ulonglong), ("ullAvailPageFile", ctypes.c_ulonglong),
                        ("ullTotalVirtual", ctypes.c_ulonglong), ("ullAvailVirtual", ctypes.c_ulonglong),
                        ("ullAvailExtendedVirtual", ctypes.c_ulonglong)]
        ms = _MS()
        ms.dwLength = ctypes.sizeof(_MS)
        if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(ms)):
            self.ram = float(ms.dwMemoryLoad)

    def _cpu_temp_sample(self):
        """Get CPU temperature via WMI (if available)"""
        if self._ct_fail > 5:
            return  # Give up after 5 consecutive failures
        if not self._wmi_checked:
            self._wmi_available = self._check_wmi()
            self._wmi_checked = True
        if not self._wmi_available:
            return
        
        try:
            import wmi as _wmi
            c = _wmi.WMI()
            for sensor in c.Win32_TemperatureProbe():
                if sensor.CurrentReading and sensor.CurrentReading > 0:
                    # WMI returns temperature in tenths of Kelvin
                    temp_c = sensor.CurrentReading / 10.0 - 273.15
                    if 0 < temp_c < 120:  # Reasonable CPU temp range
                        self.cpu_t = temp_c
                        self._ct_fail = 0
                        return
        except ImportError:
            self._wmi_available = False
        except Exception:
            self._ct_fail += 1

    def _check_wmi(self):
        """Check if WMI is available"""
        try:
            import wmi
            return True
        except ImportError:
            return False

    def _gpu_sample(self):
        if self._no_nv:
            return
        try:
            # Use faster query with minimal output
            out = subprocess.check_output(
                ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu",
                 "--format=csv,noheader,nounits", "--id=0"],
                stderr=subprocess.DEVNULL, timeout=2, creationflags=0x08000000)
            first = out.decode("utf-8", "replace").strip().splitlines()[0]
            a, b = [x.strip() for x in first.split(",")[:2]]
            self.gpu = float(a)
            self.gpu_t = float(b)
        except FileNotFoundError:
            self._no_nv = True
        except subprocess.TimeoutExpired:
            pass  # Silently skip on timeout
        except Exception:
            pass

    def _run(self):
        n = 0
        while True:
            if not self.active:
                time.sleep(0.5)
                continue
            try:
                self._cpu_sample()
                self._ram_sample()
                # CPU temp every 5 seconds to reduce overhead
                if n % 5 == 0:
                    self._cpu_temp_sample()
                # GPU every 3 seconds to reduce subprocess overhead
                if n % 3 == 0:
                    self._gpu_sample()
            except Exception:
                pass
            n += 1
            time.sleep(1.0)


_SYS = _SysSampler()


class RbxHub:
    """Handles everything in the ROBLOX tab: cookie, launch, join, FPS flags, FPS tracker."""

    def __init__(self, log):
        self.log = log
        self._lock = threading.RLock()
        self._cookie = ""          # decrypted at runtime; never written to any log or config file
        self._cookie_file = os.path.join(DATA_DIR, "rbx_session.dat")   # DPAPI-encrypted
        self._fps_on = False
        self._fps_backup = {}      # per-version backup of overwritten flags
        self._cap_backup = None    # original FramerateCap value
        self._pm_running = False
        self._pm_proc = None
        self._pm_hproc = None
        self._fps_value = {}       # pid -> [deque, sum_ms]
        self._fps_seen  = {}       # pid -> last_seen_time
        self._fps_cur   = 0.0      # most recent fps reading
        self._fps_lock  = threading.Lock()
        self._cookie_expired = False   # set by background check on startup
        self._link_history  = []       # up to 5 most-recently-joined links
        self._pending_dock  = False    # True for 6s after a launch so JS can auto-dock
        self._pending_dock_t = 0.0
        self._overlay       = None     # FpsOverlay instance or None
        os.makedirs(_RBX_TOOLS_DIR, exist_ok=True)
        self._load_cookie()
        # Check cookie validity in background so startup is not delayed
        if self._cookie:
            threading.Thread(target=self._check_cookie_bg, daemon=True, name="td-rbx-ck").start()
        # Start FPS-flags watcher thread
        threading.Thread(target=self._fps_watcher, daemon=True, name="td-rbx-fw").start()

    # ------------------------------------------------------------------
    # DPAPI cookie persistence (password never logged, never in config)
    # ------------------------------------------------------------------
    @staticmethod
    def _dpapi(data, encrypt):
        class _B(ctypes.Structure):
            _fields_ = [("cbData", wintypes.DWORD), ("pbData", ctypes.POINTER(ctypes.c_char))]
        buf = ctypes.create_string_buffer(data, len(data))
        blob_in = _B(len(data), ctypes.cast(buf, ctypes.POINTER(ctypes.c_char)))
        blob_out = _B()
        fn = (ctypes.windll.crypt32.CryptProtectData if encrypt
              else ctypes.windll.crypt32.CryptUnprotectData)
        if not fn(ctypes.byref(blob_in), None, None, None, None, 0, ctypes.byref(blob_out)):
            raise OSError("DPAPI failed")
        out = ctypes.string_at(blob_out.pbData, blob_out.cbData)
        ctypes.windll.kernel32.LocalFree(blob_out.pbData)
        return out

    def _save_cookie(self, cookie):
        if not cookie:
            try: os.remove(self._cookie_file)
            except OSError: pass
            return
        try:
            with open(self._cookie_file, "wb") as f:
                f.write(self._dpapi(cookie.encode("utf-8"), True))
        except Exception as e:
            self.log("ROBLOX: could not save session (%s)" % e, "warn")

    def _load_cookie(self):
        try:
            with open(self._cookie_file, "rb") as f:
                self._cookie = self._dpapi(f.read(), False).decode("utf-8")
        except Exception:
            self._cookie = ""

    # ------------------------------------------------------------------
    # Background helpers
    # ------------------------------------------------------------------
    def _check_cookie_bg(self):
        """Called once at startup: marks _cookie_expired if the saved cookie is stale."""
        result = self.whoami()
        self._cookie_expired = (result is None and bool(self._cookie))
        if self._cookie_expired:
            self.log("ROBLOX: saved session has expired - sign in again on the ROBLOX tab", "warn")

    def _fps_watcher(self):
        """Every 30 s: if FPS boost is on, check whether a new version-* folder appeared or
        ClientAppSettings.json was wiped, and re-apply the flags automatically."""
        _last_keys = set()
        while True:
            time.sleep(30)
            if not self._fps_on:
                _last_keys = set()
                continue
            try:
                targets = _rbx_flag_targets()
                cur_keys = {k for k, _ in targets}
                # New version folder appeared
                new_keys = cur_keys - _last_keys
                if new_keys:
                    self.log("ROBLOX: new Roblox version detected - reapplying FPS flags", "info")
                    self.apply_fps_flags(True)
                    _last_keys = cur_keys
                    continue
                _last_keys = cur_keys
                # Flags wiped in an existing folder (Roblox update or manual restore)
                for key, folder in targets:
                    path = os.path.join(folder, "ClientAppSettings.json")
                    try:
                        with open(path, "r", encoding="utf-8") as f:
                            cur = json.load(f)
                    except Exception:
                        cur = {}
                    if not any(k in cur for k in _FPS_FLAGS):
                        self.log("ROBLOX: FPS flags missing in %s - reapplying" % folder, "info")
                        self.apply_fps_flags(True)
                        break
            except Exception:
                pass

    # ------------------------------------------------------------------
    # Account status
    # ------------------------------------------------------------------
    def whoami(self):
        """Returns {"name":..,"display":..,"id":..} or None."""
        if not self._cookie:
            return None
        try:
            st, _, body = _rbx_http("GET", "https://users.roblox.com/v1/users/authenticated",
                                    _rbx_auth_headers(self._cookie))
            if st != 200:
                return None
            j = json.loads(body)
            return {"name": j["name"], "display": j.get("displayName", j["name"]), "id": j["id"]}
        except Exception:
            return None

    def set_cookie(self, cookie):
        """Validate and persist a .ROBLOSECURITY cookie. Returns {"ok":bool,"name":str,"err":str}."""
        cookie = (cookie or "").strip().strip('"')
        if not cookie:
            self._cookie = ""
            self._save_cookie("")
            return {"ok": False, "name": "", "err": ""}
        try:
            st, _, body = _rbx_http("GET", "https://users.roblox.com/v1/users/authenticated",
                                    _rbx_auth_headers(cookie))
            if st != 200:
                return {"ok": False, "name": "", "err": "Cookie invalid or expired (HTTP %d)" % st}
            j = json.loads(body)
            name = j.get("name", "")
        except Exception as e:
            return {"ok": False, "name": "", "err": str(e)}
        self._cookie = cookie
        self._save_cookie(cookie)
        self.log("ROBLOX: signed in as %s" % name, "ok")
        return {"ok": True, "name": name, "err": ""}

    def sign_out(self):
        self._cookie = ""
        self._save_cookie("")
        self.log("ROBLOX: signed out", "info")

    # ------------------------------------------------------------------
    # Launch helpers
    # ------------------------------------------------------------------
    def _get_ticket(self):
        st, hd, _ = _rbx_post_csrf("https://auth.roblox.com/v1/authentication-ticket", self._cookie)
        ticket = hd.get("rbx-authentication-ticket")
        if not ticket:
            raise RuntimeError("No auth ticket (HTTP %s). Cookie may have expired." % st)
        return ticket

    # ------------------------------------------------------------------
    # Launch Roblox (Tower Defense Simulator) - direct launch like Bloxstrap
    # ------------------------------------------------------------------
    def launch_home(self):
        """Launch into Tower Defense Simulator using the saved session."""
        if not self._cookie:
            return {"ok": False, "err": "Not signed in. Paste your .ROBLOSECURITY cookie first."}
        if self._cookie_expired:
            return {"ok": False, "err": "Session expired - sign in again with a fresh cookie."}
        try:
            import random as _rnd
            ticket  = self._get_ticket()
            tracker = str(_rnd.randint(10**10, 10**11 - 1))
            pl  = ("https://assetgame.roblox.com/game/PlaceLauncher.ashx?request=RequestGame"
                   "&browserTrackerId=%s&placeId=%d&isPlayTogetherGame=false"
                   % (tracker, ROBLOX_GAME_ID))
            uri = ("roblox-player:1+launchmode:play+gameinfo:%s+launchtime:%d"
                   "+placelauncherurl:%s+browsertrackerid:%s"
                   "+robloxLocale:en_us+gameLocale:en_us+channel:+LaunchExp:InApp"
                   % (ticket, int(time.time() * 1000),
                      _urlparse.quote(pl, safe=""), tracker))
            os.startfile(uri)
            self.log("ROBLOX: launching (Tower Defense Simulator)...", "ok")
            self._pending_dock   = True
            self._pending_dock_t = time.time()
            return {"ok": True, "err": ""}
        except RuntimeError as e:
            msg = str(e)
            if "expired" in msg.lower() or "auth ticket" in msg.lower():
                self._cookie_expired = True
                msg = "Session expired - sign in again with a fresh cookie."
            self.log("ROBLOX launch failed: %s" % msg, "err")
            return {"ok": False, "err": msg}
        except Exception as e:
            self.log("ROBLOX launch failed: %s" % e, "err")
            return {"ok": False, "err": str(e)}

    # ------------------------------------------------------------------
    # Join by link
    # ------------------------------------------------------------------
    def join_link(self, text):
        """Parse a roblox.com game/share/private link and launch it."""
        if not self._cookie:
            return {"ok": False, "err": "Not signed in."}
        if self._cookie_expired:
            return {"ok": False, "err": "Session expired - sign in again with a fresh cookie."}
        target = _rbx_parse_target(text)
        if not target:
            return {"ok": False, "err": "Could not parse that link. Paste a roblox.com game URL, share link, or private-server link."}
        try:
            import random as _rnd
            cookie = self._cookie
            place  = target.get("place")
            req, extra = "RequestGame", ""
            if target["kind"] == "share":
                place, lnk = self._resolve_share(cookie, target["code"])
                target = {"kind": "private", "place": place, "link": lnk}
            if target["kind"] == "private":
                link   = target["link"]
                access = self._fetch_access_code(cookie, place, link)
                req    = "RequestPrivateGame"
                extra  = "&linkCode=" + link + ("&accessCode=" + access if access else "")
                self.log("ROBLOX: private server, access code %s" % ("found" if access else "not found"), "info")
            elif target["kind"] == "job":
                req, extra = "RequestGameJob", "&gameId=" + target["job"]
            ticket  = self._get_ticket()
            tracker = str(_rnd.randint(10**10, 10**11 - 1))
            pl  = ("https://assetgame.roblox.com/game/PlaceLauncher.ashx?request=%s"
                   "&browserTrackerId=%s&placeId=%d&isPlayTogetherGame=false%s"
                   % (req, tracker, place, extra))
            uri = ("roblox-player:1+launchmode:play+gameinfo:%s+launchtime:%d"
                   "+placelauncherurl:%s+browsertrackerid:%s"
                   "+robloxLocale:en_us+gameLocale:en_us+channel:+LaunchExp:InApp"
                   % (ticket, int(time.time() * 1000),
                      _urlparse.quote(pl, safe=""), tracker))
            os.startfile(uri)
            self.log("ROBLOX: joining place %s..." % place, "ok")
            # Save to link history (newest first, max 5)
            t = text.strip()
            if t in self._link_history:
                self._link_history.remove(t)
            self._link_history.insert(0, t)
            self._link_history = self._link_history[:5]
            self._pending_dock   = True
            self._pending_dock_t = time.time()
            return {"ok": True, "err": ""}
        except RuntimeError as e:
            msg = str(e)
            if "expired" in msg.lower() or "auth ticket" in msg.lower():
                self._cookie_expired = True
                msg = "Session expired - sign in again with a fresh cookie."
            self.log("ROBLOX join failed: %s" % msg, "err")
            return {"ok": False, "err": msg}
        except Exception as e:
            self.log("ROBLOX join failed: %s" % e, "err")
            return {"ok": False, "err": str(e)}

    def _resolve_share(self, cookie, code):
        payload = json.dumps({"linkId": code, "linkType": "Server"}).encode()
        st, _, body = _rbx_post_csrf("https://apis.roblox.com/sharelinks/v1/resolve-link", cookie, payload)
        if st != 200:
            raise RuntimeError("Could not resolve share link (HTTP %s)" % st)
        d = json.loads(body).get("privateServerInviteData") or {}
        if not d.get("placeId") or not d.get("linkCode"):
            raise RuntimeError("Share link invalid or expired")
        return int(d["placeId"]), d["linkCode"]

    def _fetch_access_code(self, cookie, place, link):
        url = "https://www.roblox.com/games/%d/?privateServerLinkCode=%s" % (place, link)
        st, _, body = _rbx_http("GET", url, _rbx_auth_headers(cookie))
        m = re.search(r"joinPrivateGame\(\s*\d+\s*,\s*['\"]([\\w-]+)['\"]",
                      body.decode("utf-8", "ignore"))
        return m.group(1) if (st == 200 and m) else None

    # ------------------------------------------------------------------
    # FPS flags  (ClientAppSettings.json + FramerateCap)
    # ------------------------------------------------------------------
    def apply_fps_flags(self, enable, fps_cap=1000):
        """Write or restore the FPS fast-flags, IxpSettings.json, and frame-rate cap."""
        with self._lock:
            targets = _rbx_flag_targets()
            if not targets:
                found = _rbx_probe_running()
                if found:
                    self.log("ROBLOX: running Roblox is at: " + " | ".join(found), "info")
                    targets = _rbx_flag_targets()
                elif _rbx_roblox_running():
                    self.log("ROBLOX: Roblox is running but Windows hides its location - this is the Microsoft Store version, "
                             "which cannot be modified. Install Roblox from roblox.com instead.", "warn")
            if not targets:
                msg = ("No Roblox installation found. If Roblox came from the Microsoft Store, uninstall it and install the "
                       "normal one from roblox.com. Otherwise open Roblox once and try again. See td_macro.log for details.")
                self.log("ROBLOX: no RobloxPlayerBeta.exe found. Folders checked: " + " | ".join(_rbx_version_bases()), "warn")
                return {"ok": False, "err": msg, "locations": 0}
            
            # Handle IxpSettings.json (additional performance optimization)
            ixp_backup = self._fps_backup.setdefault("ixp_backup", {})
            for key, folder in targets:
                ixp_path = os.path.join(folder, "IxpSettings.json")
                if enable:
                    try:
                        with open(ixp_path, "r", encoding="utf-8") as f:
                            if key not in ixp_backup:
                                ixp_backup[key] = f.read()
                        with open(ixp_path, "w", encoding="utf-8") as f:
                            f.write(_ixp_text())
                        self.log("ROBLOX: IxpSettings.json optimized in %s" % folder, "info")
                    except Exception as e:
                        self.log("ROBLOX: could not write IxpSettings.json in %s: %s" % (folder, e), "warn")
                else:
                    if key in ixp_backup:
                        try:
                            with open(ixp_path, "w", encoding="utf-8") as f:
                                f.write(ixp_backup[key])
                            self.log("ROBLOX: IxpSettings.json restored in %s" % folder, "info")
                        except Exception as e:
                            self.log("ROBLOX: could not restore IxpSettings.json in %s: %s" % (folder, e), "warn")
                    elif os.path.exists(ixp_path):
                        try:
                            os.remove(ixp_path)
                            self.log("ROBLOX: IxpSettings.json removed from %s" % folder, "info")
                        except Exception:
                            pass
            
            # Handle ClientAppSettings.json
            for key, folder in targets:
                path = os.path.join(folder, "ClientAppSettings.json")
                try:
                    with open(path, "r", encoding="utf-8") as f:
                        cur = json.load(f)
                    if not isinstance(cur, dict):
                        cur = {}
                except Exception:
                    cur = {}
                bk = self._fps_backup.setdefault(key, {})
                for k, v in _FPS_FLAGS.items():
                    if enable:
                        if k not in bk:
                            bk[k] = cur.get(k)
                        cur[k] = v
                    elif bk.get(k) is not None:
                        cur[k] = bk[k]
                    else:
                        cur.pop(k, None)
                os.makedirs(folder, exist_ok=True)
                if enable or cur:
                    with open(path, "w", encoding="utf-8") as f:
                        json.dump(cur, f, indent=2)
                    self.log("ROBLOX FPS flags %s %s" % ("written to" if enable else "restored in", path), "info")
                elif os.path.exists(path):
                    os.remove(path)
            n = len(targets)
            if enable and n > 1:
                self.log("ROBLOX: FPS flags written to %d Roblox version folder(s)" % n, "info")
            if not enable:
                self._fps_backup.clear()
            res = self._set_cap(fps_cap if enable else None)
            self._fps_on = bool(enable)
            return {"ok": True, "err": "", "locations": len(targets), "cap_result": res}

    def _set_cap(self, value):
        xml_path = _rbx_find_settings_xml()
        try:
            with open(xml_path, "r", encoding="utf-8", newline="") as f:
                txt = f.read()
        except OSError:
            return "missing"
        m = _CAP_RE_RBX.search(txt)
        if value is not None:
            if self._cap_backup is None:
                self._cap_backup = int(m.group(2)) if m else "absent"
            if m and int(m.group(2)) == value:
                return "same"
            if m:
                txt = txt[:m.start(2)] + str(value) + txt[m.end(2):]
            else:
                h = re.search(r'<Item class="UserGameSettings"[^>]*>\s*<Properties>', txt)
                if not h:
                    return "error"
                txt = (txt[:h.end()] +
                       '<int name="FramerateCap">%d</int>' % value +
                       txt[h.end():])
        else:
            orig = self._cap_backup
            if orig is None:
                return "nothing"
            if orig == "absent":
                txt = _CAP_RE_RBX.sub("", txt, count=1)
            elif m:
                txt = txt[:m.start(2)] + str(orig) + txt[m.end(2):]
            self._cap_backup = None
        with open(xml_path, "w", encoding="utf-8", newline="") as f:
            f.write(txt)
        self.log("ROBLOX: FramerateCap -> %s in %s" % (value, xml_path), "info")
        return "ok"

    def fps_state(self):
        return {
            "enabled": self._fps_on,
            "locations": len(_rbx_flag_targets()),
            "roblox_running": _rbx_roblox_running(),
        }

    # ------------------------------------------------------------------
    # PresentMon FPS tracker
    # ------------------------------------------------------------------
    def start_fps_tracker(self):
        if self._pm_running:
            return {"ok": True, "err": "already running"}
        if not os.path.exists(_PM_EXE):
            try:
                self.log("ROBLOX: downloading PresentMon.exe ...", "info")
                os.makedirs(_RBX_TOOLS_DIR, exist_ok=True)
                req = _urlreq.Request(_PM_URL, headers={"User-Agent": _RBX_UA})
                with _urlreq.urlopen(req, timeout=60) as r, open(_PM_EXE, "wb") as f:
                    import shutil as _sh
                    _sh.copyfileobj(r, f, 1 << 20)
                self.log("ROBLOX: PresentMon downloaded to %s" % _PM_EXE, "ok")
            except Exception as e:
                msg = "ROBLOX: could not download PresentMon: %s" % e
                self.log(msg, "err")
                return {"ok": False, "err": str(e)}
        for p in (_FPS_CSV, _FPS_STOP):
            try: os.remove(p)
            except OSError: pass
        args = ('--process_name RobloxPlayerBeta.exe --output_file "%s" --no_console_stats '
                '--session_name DiamondTD_FPS --stop_existing_session --terminate_on_proc_exit') % _FPS_CSV
        self._pm_proc = None
        self._pm_hproc = None
        try:
            is_admin = bool(ctypes.windll.shell32.IsUserAnAdmin())
        except Exception:
            is_admin = False
        try:
            if is_admin:
                # Already elevated: start PresentMon directly, no prompt, no PowerShell
                self._pm_proc = subprocess.Popen(
                    [_PM_EXE,
                        "--process_name", "RobloxPlayerBeta.exe", "--output_file", _FPS_CSV, "--no_console_stats",
                        "--session_name", "DiamondTD_FPS", "--stop_existing_session", "--terminate_on_proc_exit"],
                    creationflags=_NO_WIN, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                self.log("ROBLOX: PresentMon started (pid %d, already admin)" % self._pm_proc.pid, "info")
            else:
                # Ask Windows (UAC prompt) to run PresentMon itself elevated - no PowerShell involved
                class _SEI(ctypes.Structure):
                    _fields_ = [("cbSize", wintypes.DWORD), ("fMask", wintypes.ULONG), ("hwnd", wintypes.HWND),
                                ("lpVerb", wintypes.LPCWSTR), ("lpFile", wintypes.LPCWSTR),
                                ("lpParameters", wintypes.LPCWSTR), ("lpDirectory", wintypes.LPCWSTR),
                                ("nShow", ctypes.c_int), ("hInstApp", wintypes.HINSTANCE),
                                ("lpIDList", ctypes.c_void_p), ("lpClass", wintypes.LPCWSTR),
                                ("hkeyClass", wintypes.HKEY), ("dwHotKey", wintypes.DWORD),
                                ("hIcon", wintypes.HANDLE), ("hProcess", wintypes.HANDLE)]
                sei = _SEI()
                sei.cbSize = ctypes.sizeof(_SEI)
                sei.fMask = 0x40          # SEE_MASK_NOCLOSEPROCESS
                sei.lpVerb = "runas"
                sei.lpFile = _PM_EXE
                sei.lpParameters = args
                sei.nShow = 0             # hidden
                if not ctypes.windll.shell32.ShellExecuteExW(ctypes.byref(sei)):
                    msg = "ROBLOX: administrator permission declined - PresentMon needs it to read frame times."
                    self.log(msg, "warn")
                    return {"ok": False, "err": msg}
                self._pm_hproc = sei.hProcess
                self.log("ROBLOX: PresentMon started elevated", "info")
        except Exception as e:
            msg = "ROBLOX: could not start PresentMon: %s" % e
            self.log(msg, "err")
            return {"ok": False, "err": msg}
        self._pm_running = True
        self.log("ROBLOX: FPS tracker started. CSV -> %s" % _FPS_CSV, "info")
        threading.Thread(target=self._pm_reader, daemon=True, name="td-rbx-fps").start()
        return {"ok": True, "err": ""}

    def stop_fps_tracker(self):
        self._pm_running = False
        try:
            if getattr(self, "_pm_proc", None):
                self._pm_proc.terminate()
                self._pm_proc = None
            elif getattr(self, "_pm_hproc", None):
                k32 = ctypes.windll.kernel32
                if not k32.TerminateProcess(self._pm_hproc, 0):
                    # elevated process we cannot kill directly: ask PresentMon to end its own session (second UAC prompt)
                    ctypes.windll.shell32.ShellExecuteW(None, "runas", _PM_EXE,
                        "--terminate_existing_session --session_name DiamondTD_FPS", None, 0)
                k32.CloseHandle(self._pm_hproc)
                self._pm_hproc = None
        except Exception as e:
            self.log("ROBLOX: could not stop PresentMon cleanly: %s" % e, "warn")
        with self._fps_lock:
            self._fps_value.clear()
            self._fps_seen.clear()
            self._fps_cur = 0.0
        self.log("ROBLOX: FPS tracker stopped", "info")

    def fps_reading(self):
        return round(self._fps_cur)

    def _pm_add(self, pid, ms):
        from collections import deque as _dq
        with self._fps_lock:
            d = self._fps_value.setdefault(pid, [_dq(), 0.0])
            d[0].append(ms)
            d[1] += ms
            while len(d[0]) > 1 and d[1] - d[0][0] >= 1000:
                d[1] -= d[0].popleft()
            self._fps_seen[pid] = time.time()

    def _pm_reader(self):
        f, buf, header, i_ms, i_pid = None, "", None, None, None
        while self._pm_running:
            if f is None:
                if os.path.exists(_FPS_CSV):
                    try: f = open(_FPS_CSV, "r", encoding="utf-8", errors="ignore", newline="")
                    except OSError: pass
                if f is None:
                    time.sleep(0.5)
                    continue
            chunk = f.read()
            if not chunk:
                time.sleep(0.1)
                self._update_fps_cur()
                continue
            buf += chunk
            lines = buf.split("\n")
            buf = lines.pop()
            for line in lines:
                cols = line.strip("\r").lstrip("\ufeff").split(",")
                if header is None:
                    header = [c.strip().lower() for c in cols]
                    i_ms  = next((header.index(n) for n in ("msbetweenpresents", "frametime")
                                  if n in header), None)
                    i_pid = header.index("processid") if "processid" in header else None
                    if i_ms is None:
                        self.log("ROBLOX FPS tracker: unexpected PresentMon columns.", "warn")
                    continue
                if i_ms is None or i_ms >= len(cols):
                    continue
                try:
                    ms = float(cols[i_ms])
                except ValueError:
                    continue
                if ms > 0:
                    self._pm_add(cols[i_pid] if (i_pid is not None and i_pid < len(cols)) else "0", ms)
            self._update_fps_cur()

    def _update_fps_cur(self):
        now = time.time()
        with self._fps_lock:
            stale = [p for p, t in self._fps_seen.items() if now - t >= 3]
            for p in stale:
                self._fps_seen.pop(p, None)
                self._fps_value.pop(p, None)
            vals = []
            for d in self._fps_value.values():
                if d[1] > 0:
                    vals.append(len(d[0]) / d[1] * 1000.0)
            self._fps_cur = sum(vals) / len(vals) if vals else 0.0

    def show_fps_overlay(self):
        """Show (or create) the small always-on-top system overlay: FPS, CPU, GPU, RAM."""
        try:
            from PyQt5.QtWidgets import QApplication, QLabel, QWidget
            from PyQt5.QtCore    import Qt, QTimer
            from PyQt5.QtGui     import QFont
            app = QApplication.instance()
            if app is None:
                return {"ok": False, "err": "Qt not running"}
            _SYS.start()
            if self._overlay and not self._overlay.isVisible():
                self._overlay.show()
                return {"ok": True, "err": ""}
            if self._overlay is None:
                ov = QWidget(None, Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint | Qt.Tool)
                ov.setStyleSheet("background:#111;border-radius:6px")
                ov.setWindowTitle("System overlay")
                lbl = QLabel(ov)
                lbl.setFont(QFont("Consolas", 10, QFont.Bold))
                lbl.setStyleSheet("color:#e6e6e6;background:transparent")
                lbl.setTextFormat(Qt.RichText)
                lbl.setAttribute(Qt.WA_TransparentForMouseEvents, True)   # let the whole box drag
                lbl.move(8, 5)

                def _row(name, val, temp):
                    s = ("<span style='color:#8a8a8a'>%s</span> <span style='color:#39d353'>%s</span>"
                         % (name, val))
                    if temp is not None:
                        s += ("<br><span style='color:#f0b429;font-size:9px'>&nbsp;&nbsp;%d&deg;C</span>"
                              % int(round(temp)))
                    return s

                def _upd():
                    fps = round(self._fps_cur)
                    rows = [_row("FPS", "--" if fps == 0 else str(fps), None),
                            _row("CPU", "%d%%" % round(_SYS.cpu), _SYS.cpu_t)]
                    if _SYS.gpu is not None:
                        rows.append(_row("GPU", "%d%%" % round(_SYS.gpu), _SYS.gpu_t))
                    rows.append(_row("RAM", "%d%%" % round(_SYS.ram), None))
                    # Add macro statistics from config file
                    try:
                        import json
                        import os
                        cfg_path = os.path.join(os.environ.get("APPDATA", ""), "TDRecorder", "config.json")
                        if os.path.exists(cfg_path):
                            with open(cfg_path, "r", encoding="utf-8") as f:
                                cfg = json.load(f)
                            stats = cfg.get("stats", {})
                            total = stats.get("total_runs", 0)
                            success = stats.get("successful_runs", 0)
                            rph = stats.get("runs_per_hour", 0.0)
                            if total > 0:
                                rate = (success / total) * 100
                                rows.append(_row("Runs", "%d (%.0f%%)" % (total, rate), None))
                                if rph > 0:
                                    rows.append(_row("RPH", "%.1f" % rph, None))
                    except Exception:
                        pass
                    lbl.setText("<br>".join(rows))
                    lbl.adjustSize()
                    w, h = lbl.width() + 16, lbl.height() + 10
                    if ov.width() != w or ov.height() != h:
                        ov.resize(w, h)

                # Initial update
                _upd()
                # Default spot: top-right of the primary screen
                try:
                    geo = QApplication.primaryScreen().geometry()
                    ov.move(geo.right() - ov.width() - 16, geo.top() + 16)
                except Exception:
                    pass
                ov.show()

                def _mp(e):
                    if e.button() == Qt.LeftButton:
                        ov._drag = e.globalPos() - ov.frameGeometry().topLeft()
                def _mm(e):
                    if e.buttons() == Qt.LeftButton and hasattr(ov, "_drag"):
                        ov.move(e.globalPos() - ov._drag)
                ov.mousePressEvent = _mp
                ov.mouseMoveEvent = _mm

                t = QTimer(ov)
                t.timeout.connect(_upd)
                t.start(500)
                self._overlay = ov
            else:
                self._overlay.show()
            return {"ok": True, "err": ""}
        except Exception as e:
            return {"ok": False, "err": str(e)}

    def hide_fps_overlay(self):
        _SYS.stop()
        if self._overlay:
            try:
                self._overlay.hide()
            except Exception:
                pass
        return True

    def poll(self):
        """Lightweight state snapshot for the ROBLOX tab."""
        user = self.whoami()
        # Clear pending_dock after 6 seconds
        if self._pending_dock and time.time() - self._pending_dock_t >= 6:
            self._pending_dock = False
        return {
            "signed_in":      bool(self._cookie),
            "cookie_expired": self._cookie_expired,
            "name":           user["name"] if user else "",
            "fps_on":         self._fps_on,
            "fps":            self.fps_reading(),
            "tracker_running": self._pm_running,
            "roblox_running": _rbx_roblox_running(),
            "pending_dock":   self._pending_dock,
            "link_history":   list(self._link_history),
            "overlay_visible": bool(self._overlay and self._overlay.isVisible()),
        }


# ----------------------------------------------------------------------
#  JS <-> Python bridge
# ----------------------------------------------------------------------
class Api:
    def __init__(self, eng):
        self._e = eng
        global _MAHO_UI_LOG
        _MAHO_UI_LOG = eng.log                    # Mahoraga problems now show up in the log panel

    def get_cfg(self):
        return self._e.cfg

    @api_safe({})
    def get_gamemode_stats(self):
        return self._e.cfg.get("gamemode_stats", {})

    @api_safe({})
    def get_profile_templates(self):
        return _PROFILE_TEMPLATES

    @api_safe(False)
    def save_cfg(self, cfg):
        e = self._e
        with e.cfg_lock:
            keep = {"totals": e.cfg["totals"]}
            e.cfg = merge(e.cfg, cfg)
            e.cfg.update(keep)
            # Handle gamemode cycle settings
            if "cycle_enabled" in cfg or "cycle_modes" in cfg or "cycle_runs" in cfg:
                cycle_cfg = e.cfg.get("gamemode_cycle", {})
                if "cycle_enabled" in cfg:
                    cycle_cfg["enabled"] = bool(cfg["cycle_enabled"])
                if "cycle_modes" in cfg:
                    modes_str = str(cfg["cycle_modes"]).strip()
                    cycle_cfg["modes"] = [m.strip() for m in modes_str.split(",") if m.strip()] if modes_str else ["molten"]
                if "cycle_runs" in cfg:
                    cycle_cfg["runs_per_mode"] = int(cfg["cycle_runs"]) if cfg["cycle_runs"] else 10
                e.cfg["gamemode_cycle"] = cycle_cfg
            fixed = sanitize_cfg(e.cfg)
            e.tcache.clear()
            e.scale_cache[0] = 0
            e.save_cfg()
            # Mahoraga: live checkbox toggle sync (anytime user flips the setting in UI)
            try:
                MAHO_OVERLAY.set_cfg_enabled(e.cfg)
            except Exception:
                pass
            if any(k.startswith("hk_") for k, _, _ in fixed):      # drop-downs: show what is really used
                e.log("Hotkeys must be different F-keys - corrected", "warn")
                e.cfg_rev += 1
        return True

    def poll(self, since):
        e = self._e
        with e.log_lock:
            logs = [x for x in e.logs if x["i"] > since]
        el = int(time.time() - e.t_start) if (e.t_start and e.mode == "running") else 0
        try:
            rbh = find_roblox()
        except Exception:
            rbh = 0
        rb = bool(rbh)
        return {
            "mode": e.mode, "status": e.status_text, "logs": logs,
            "loops": e.loops, "target": e.target, "elapsed": el,
            "s_coins": e.s_coins, "s_xp": e.s_xp, "totals": e.cfg["totals"],
            "docked": e.dock.docked, "rb": rb,
            "dock_title": e.dock.title, "dock_rb": bool(rbh) and e.dock.hwnd == rbh, "dock_closed": e.dock.closed,
            "recs": e.recs, "rec": e.cfg.get("recording", ""), "rev": e.cfg_rev,
            "live": e.rec_live, "ago": round(time.time() - e.rec_live.get("last_t", 0), 1),
        }

    @api_safe(False)
    def start(self):
        return self._e.start()

    @api_safe(False)
    def stop(self):
        self._e.stop()
        return True

    @api_safe(False)
    def record_toggle(self):
        self._e.record_toggle()
        return True

    @api_safe(False)
    def test_scan(self):
        self._e.test_scan()
        return True

    @api_safe(False)
    def pick(self, which):
        self._e.pick(which)
        return True

    @api_safe(False)
    def pick_pt(self, which):
        if which in ("search", "map", "ready", "veto", "vpx", "restart_px", "ready_px", "play_again_px"):
            self._e.pick_pt(which)
        return True

    @api_safe(False)
    def select_rec(self, name):
        self._e.cfg["recording"] = name
        self._e.save_cfg()
        self._e.cfg_rev += 1
        return True

    @api_safe(False)
    def delete_rec(self, name):
        try:
            os.remove(self._e.rec_path(name))
            if self._e.cfg.get("recording") == name:
                self._e.cfg["recording"] = ""
                self._e.save_cfg()
            self._e.refresh_recs()
            self._e.cfg_rev += 1
        except Exception:
            pass
        return True

    @api_safe(False)
    def open_folder(self):
        try:
            os.startfile(REC_DIR)
        except Exception:
            pass
        return True

    @api_safe(False)
    def clear_log(self):
        with self._e.log_lock:
            self._e.logs = []
        return True

    @api_safe(False)
    def dock(self, x, y, w, h):
        """The quick 'Dock Roblox' button (replaces whatever else is docked)."""
        e = self._e
        if not find_roblox():
            e.log("Roblox window not found - open Roblox (windowed) first", "warn")
            return False
        ok = e.dock.dock((x, y, w, h))
        if ok:
            e.log("Docked: %s" % (e.dock.title or "Roblox"), "ok")
        elif not e.dock.err:
            e.log("Could not dock Roblox", "err")
        return ok

    @api_safe([])
    def list_windows(self):
        """Windows the picker offers (JSON-safe: hwnd, title, class, exe)."""
        return list_windows(exclude=self._e.dock.hwnd)

    @api_safe(False)
    def dock_window(self, hwnd, x, y, w, h):
        e = self._e
        hwnd = int(hwnd)
        if not user32.IsWindow(hwnd):
            e.log("That window is gone - press refresh in the window list", "warn")
            return False
        ok = e.dock.dock((x, y, w, h), hwnd=hwnd)
        if ok:
            e.log("Docked: %s" % e.dock.title, "ok")
        elif not e.dock.err:
            e.log("Could not dock that window", "err")
        return ok

    @api_safe("")
    def dock_info(self):
        return self._e.dock_info()

    @api_safe({"w": 0, "h": 0})
    def client_size(self):
        """Real pixel size of our window's client area, so JS can convert CSS px -> screen px exactly (any DPI / monitor)."""
        par = self._e.dock.parent_hwnd()
        r = wintypes.RECT()
        if par and user32.GetClientRect(par, ctypes.byref(r)):
            return {"w": r.right, "h": r.bottom}
        return {"w": 0, "h": 0}

    @api_safe(False)
    def move_dock(self, x, y, w, h):
        self._e.dock.move((x, y, w, h))
        return True

    @api_safe(False)
    def undock(self):
        e = self._e
        t = e.dock.title
        e.dock.undock()
        e.log(("Undocked: %s" % t) if t else "Nothing was docked", "info")
        return True

    def user(self):
        return os.environ.get('USERNAME', 'player')

    # ---- ROBLOX tab API ----
    @api_safe({"ok": False, "name": "", "err": ""})
    def rbx_set_cookie(self, cookie):
        return self._e.rbx.set_cookie(cookie)

    @api_safe(False)
    def rbx_sign_out(self):
        self._e.rbx.sign_out()
        return True

    @api_safe({"ok": False, "err": ""})
    def rbx_launch(self):
        return self._e.rbx.launch_home()

    @api_safe({"ok": False, "err": ""})
    def rbx_join(self, link):
        return self._e.rbx.join_link(link)

    @api_safe({"ok": False, "err": "", "locations": 0})
    def rbx_fps_apply(self, enable, cap=1000):
        try:
            cap = int(cap)
        except Exception:
            cap = 1000
        if enable:
            self._e.cfg["rbx_fps_cap"] = cap
            self._e.save_cfg()
        return self._e.rbx.apply_fps_flags(bool(enable), fps_cap=cap)

    @api_safe({"enabled": False, "locations": 0, "roblox_running": False})
    def rbx_fps_state(self):
        return self._e.rbx.fps_state()

    @api_safe({"ok": False, "err": ""})
    def rbx_start_tracker(self):
        return self._e.rbx.start_fps_tracker()

    @api_safe(False)
    def rbx_stop_tracker(self):
        self._e.rbx.stop_fps_tracker()
        return True

    @api_safe({"ok": False, "err": ""})
    def rbx_overlay_show(self):
        return self._e.rbx.show_fps_overlay()

    @api_safe(False)
    def rbx_overlay_hide(self):
        self._e.rbx.hide_fps_overlay()
        return True

    @api_safe([])
    def rbx_link_history(self):
        return list(self._e.rbx._link_history)

    @api_safe(False)
    def rbx_restart_as_admin(self):
        import shlex as _shlex
        exe  = sys.executable if getattr(sys, "frozen", False) else sys.argv[0]
        args = " ".join(_shlex.quote(a) for a in sys.argv[1:]) if len(sys.argv) > 1 else ""
        shell = ctypes.windll.shell32.ShellExecuteW
        shell.restype = ctypes.c_void_p
        rc = shell(None, "runas", exe, args or None, None, 1)
        if (rc or 0) > 32:
            threading.Thread(target=lambda: (time.sleep(1.5), os._exit(0)),
                             daemon=True).start()
            return True
        return False

    @api_safe({"signed_in": False, "cookie_expired": False, "name": "", "fps_on": False,
               "fps": 0, "tracker_running": False, "roblox_running": False,
               "pending_dock": False, "link_history": [], "overlay_visible": False})
    def rbx_poll(self):
        return self._e.rbx.poll()

    @api_safe(False)
    def minimize(self):
        try:
            self._win.minimize()
        except Exception:
            pass

    # ---- Profile API ----
    @api_safe([])
    def profile_list(self):
        return _list_profiles()

    @api_safe({})
    def profile_get(self, pid):
        return _load_profile(str(pid))

    @api_safe(False)
    def profile_save(self, pid, data):
        pid = str(pid).strip()
        if not pid:
            return False
        _save_profile(pid, data)
        return True

    @api_safe(False)
    def profile_delete(self, pid):
        pid = str(pid)
        if pid == "tds":
            return False   # never delete the default
        try:
            os.remove(_profile_path(pid))
            import shutil as _sh
            d = _PROFILE_IMAGES_DIR(pid)
            if os.path.isdir(d):
                _sh.rmtree(d, ignore_errors=True)
            return True
        except Exception:
            return False

    @api_safe(False)
    def profile_set_active(self, pid):
        self._e._active_pid = str(pid)
        self._e.cfg["active_profile"] = str(pid)
        self._e.save_cfg()
        
        # Query Gemini for game adaptation if enabled and not TDS profile
        if bool(self.cfg.get("gemini_game_adaptation_on_profile_switch", True)) and pid != "tds":
            profile = _load_profile(pid)
            game_name = profile.get("name", pid)
            # Remove "TDS" suffix if present
            if game_name.endswith(" TDS"):
                game_name = game_name[:-4].strip()
            # Query Gemini for adaptation advice
            adaptation = self.query_gemini_game_adaptation(game_name)
            if adaptation:
                # Could apply some defaults from adaptation here in the future
                pass
        
        return True

    @api_safe({"ok": False, "err": ""})
    def query_game_adaptation(self, game_name):
        """Manually query Gemini for game adaptation advice."""
        adaptation = self.query_gemini_game_adaptation(game_name)
        if adaptation:
            return {"ok": True, "err": ""}
        return {"ok": False, "err": "Failed to get adaptation advice"}

    @api_safe("")
    def profile_active(self):
        return getattr(self._e, "_active_pid", "tds")

    # ---- Image library API ----
    @api_safe([])
    def img_list(self, pid):
        return _list_images(str(pid))

    @api_safe(False)
    def img_save(self, pid, name, b64_data):
        name = str(name).strip().replace(" ", "_").replace("/", "_").replace("\\", "_")
        if not name or not b64_data:
            return False
        _save_image_from_b64(str(pid), name, str(b64_data))
        return True

    @api_safe(False)
    def img_delete(self, pid, name):
        return _delete_image(str(pid), str(name))

    @api_safe({"ok": False, "b64": "", "err": ""})
    def img_snip(self):
        """Open the fullscreen snip overlay and return the captured PNG as base64."""
        b64 = _run_snip_tool()
        if b64:
            return {"ok": True, "b64": b64, "err": ""}
        return {"ok": False, "b64": "", "err": "Cancelled or nothing captured"}

    # ---- Step builder API ----
    @api_safe([])
    def step_types(self):
        return list(StepEngine.STEP_TYPES)

    @api_safe([])
    def key_list(self):
        return list(_ALL_KEYS)

    @api_safe({"x": 0, "y": 0})
    def cursor_pos(self):
        x, y = cursor_pos()
        return {"x": x, "y": y}

    @api_safe({"ok": False, "issues": [], "warnings": []})
    def run_preflight(self):
        """Run preflight check and return results."""
        self.log("Running preflight check...", "info")
        ok = self.run_preflight_check()
        return {"ok": ok}

    @api_safe({"ok": False, "snapshot": "", "err": ""})
    def create_rollback_snapshot(self):
        """Create a rollback snapshot."""
        try:
            self.create_rollback_snapshot()
            return {"ok": True, "snapshot": "created", "err": ""}
        except Exception as e:
            return {"ok": False, "snapshot": "", "err": str(e)}

    @api_safe({"snapshots": []})
    def list_rollback_snapshots(self):
        """List available rollback snapshots."""
        return {"snapshots": self.list_rollback_snapshots()}

    @api_safe({"ok": False, "err": ""})
    def restore_rollback_snapshot(self, snapshot_name):
        """Restore from a rollback snapshot."""
        ok = self.restore_rollback_snapshot(snapshot_name)
        return {"ok": ok, "err": "" if ok else "Restore failed"}

    @api_safe({"update_available": False, "current": "", "latest": "", "repo_url": ""})
    def check_for_updates(self):
        """Check for updates from GitHub."""
        update_info = self._check_for_updates(silent=False)
        if update_info:
            return {
                "update_available": True,
                "current": update_info["current"],
                "latest": update_info["latest"],
                "repo_url": update_info["repo_url"]
            }
        return {"update_available": False, "current": VERSION, "latest": VERSION, "repo_url": ""}

    @api_safe({"ok": False, "err": ""})
    def download_and_install_update(self, rebuild_exe=False):
        """Download and install update."""
        update_info = self._check_for_updates(silent=True)
        if not update_info:
            return {"ok": False, "err": "No update available"}
        
        update_dir = self.download_update(update_info)
        if not update_dir:
            return {"ok": False, "err": "Download failed"}
        
        self.install_update(update_dir, rebuild_exe=rebuild_exe)
        return {"ok": True, "err": ""}

    def _on_close(self):
        self._e.shutdown()


# ----------------------------------------------------------------------
#  The window
# ----------------------------------------------------------------------
UI_HTML = r'''<!doctype html><html><head><meta charset="utf-8"><title>Diamond TD Macro</title>
<style>:root{--bg:#0c0d0f;--s1:#131417;--s2:#1a1c20;--s3:#23262b;--line:rgba(255,255,255,.07);--line2:rgba(255,255,255,.13);--txt:#ececf0;--mut:#8b8f99;--dim:#585c66;--acc:#5eead4;--ink:#04201b;--ok:#4ade80;--bad:#f87171;--warn:#fbbf24}
*{box-sizing:border-box}
html,body{margin:0;height:100%;background:var(--bg);color:var(--txt);font:13px 'Segoe UI Variable Text','Segoe UI',system-ui,sans-serif;overflow:hidden;user-select:none;-webkit-font-smoothing:antialiased}
b{font-weight:600}
#app{display:grid;grid-template-rows:54px 1fr 34px;height:100%}
header{display:flex;align-items:center;justify-content:space-between;padding:0 18px;border-bottom:1px solid var(--line)}
.brand{display:flex;align-items:center;gap:10px}
.brand svg{width:22px;height:22px}
.brand .n{font-size:15px;font-weight:700;letter-spacing:.01em}.brand .n span{color:var(--mut);font-weight:500;margin-left:6px}
.hr{display:flex;align-items:center;gap:14px}
.hi{color:var(--mut)}.hi b{color:var(--txt)}
.pill{display:inline-flex;align-items:center;gap:8px;padding:6px 12px;border-radius:99px;background:var(--s1);border:1px solid var(--line);color:var(--mut);font-size:12px;font-weight:600}
.pill .dot{width:7px;height:7px;border-radius:50%;background:var(--dim)}
.pill.is-run{color:var(--ok)}.pill.is-run .dot{background:var(--ok);box-shadow:0 0 0 3px rgba(74,222,128,.18)}
.pill.is-rec{color:var(--bad)}.pill.is-rec .dot{background:var(--bad);animation:bl 1s infinite}
@keyframes bl{50%{opacity:.25}}
.btn{border:1px solid var(--line);background:var(--s2);color:var(--txt);border-radius:9px;padding:8px 14px;font:inherit;font-weight:600;cursor:pointer;transition:background .12s,border-color .12s,transform .05s;width:100%}
.btn:hover{background:var(--s3);border-color:var(--line2)}.btn:active{transform:translateY(1px)}
.btn:disabled{opacity:.4;cursor:default}
.btn.go{background:var(--acc);border-color:var(--acc);color:var(--ink)}.btn.go:hover{background:#7ff3df}
.btn.stop{background:#34171a;border-color:#5b2428;color:#fca5a5}.btn.stop:hover{background:#431d21}
.btn.big{padding:12px;font-size:13.5px}
.btn.sm{width:auto;padding:6px 11px;font-size:12px}
#startbtn{width:auto;min-width:140px}
.row{display:flex;gap:8px;align-items:center}.row>*{flex:1}.row>.btn.sm{flex:0 0 auto}
main{display:grid;grid-template-columns:1fr 410px;gap:12px;padding:12px;min-height:0}
.left{display:flex;flex-direction:column;gap:12px;min-height:0;min-width:0}
.right{display:flex;flex-direction:column;gap:10px;min-height:0;min-width:0;position:relative}
#stage{flex:1;min-height:0;background:var(--s1);border:1px solid var(--line);border-radius:14px;display:flex;flex-direction:column;overflow:hidden}
.bar{display:flex;align-items:center;gap:12px;padding:9px 12px 9px 16px;border-bottom:1px solid var(--line)}
#dockstate{font-weight:600;white-space:nowrap;max-width:46%;overflow:hidden;text-overflow:ellipsis}#dockstate b{color:var(--acc)}
#status{color:var(--mut);flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.bar .btn{width:auto;padding:6px 12px;font-size:12px}
#dockarea{flex:1;margin:12px;border-radius:10px;border:1px dashed var(--line2);display:flex;align-items:center;justify-content:center;text-align:center;color:var(--dim);line-height:1.8;min-height:0;flex-direction:column}
#dockarea.docked{border-color:transparent;color:transparent}
#picker{display:none;position:absolute;inset:0;z-index:30;background:var(--bg);border:1px solid var(--line2);border-radius:14px;flex-direction:column;overflow:hidden}
#picker.on{display:flex}
#picker .ph{display:flex;gap:8px;align-items:center;padding:10px;border-bottom:1px solid var(--line)}
#picker .ph input{flex:1;width:auto;min-width:0}
#picker .ph .btn{width:auto;padding:6px 11px;font-size:12px}
#picker .pt{padding:10px 12px 0;font-weight:600}
#plist{flex:1;min-height:0;overflow:auto;padding:8px;display:flex;flex-direction:column;gap:6px}
#plist .hint{padding:10px 6px}
.pw{display:flex;align-items:center;gap:10px;padding:8px 10px;background:var(--s1);border:1px solid var(--line);border-radius:9px;cursor:pointer;min-width:0}
.pw:hover{background:var(--s3);border-color:var(--acc)}
.pw .pexe{flex:none;max-width:42%;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;background:var(--s3);border-radius:6px;padding:2px 8px;font-size:11.5px;color:var(--acc);font-weight:600}
.pw .ptitle{flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
#picker .pf{padding:8px 12px 10px;border-top:1px solid var(--line);color:var(--mut);font-size:11.5px;line-height:1.5}
#console{height:196px;background:var(--s1);border:1px solid var(--line);border-radius:14px;display:flex;flex-direction:column;min-height:0;transition:height .15s}
#console.min{height:40px}
.ch{display:flex;align-items:center;justify-content:space-between;padding:0 14px;height:40px;flex:none;cursor:pointer}
.ch .t{font-weight:600}.ch .t i{font-style:normal;color:var(--dim);margin-left:8px;font-weight:500}
.ch .a{display:flex;gap:16px;color:var(--mut)}.ch .a span:hover{color:var(--txt)}
#console.min #log{display:none}
#log{flex:1;min-height:0;overflow:auto;padding:8px 14px 10px;font:11.5px 'Cascadia Mono',Consolas,monospace;line-height:1.6;user-select:text;border-top:1px solid var(--line)}
#log div{color:#a4a8b3}#log span{color:var(--dim);margin-right:10px}
#log .ok{color:var(--ok)}#log .warn{color:var(--warn)}#log .err{color:var(--bad)}
::-webkit-scrollbar{width:8px;height:8px}::-webkit-scrollbar-thumb{background:var(--s3);border-radius:8px}::-webkit-scrollbar-thumb:hover{background:#31353c}
.tabs{display:flex;gap:22px;border-bottom:1px solid var(--line);padding:0 4px;flex:none}
.tab{padding:8px 2px 11px;color:var(--mut);cursor:pointer;font-weight:600;border-bottom:2px solid transparent;margin-bottom:-1px}
.tab:hover{color:var(--txt)}.tab.on{color:var(--txt);border-bottom-color:var(--acc)}
.pane{display:none;flex:1;min-height:0;overflow:auto;flex-direction:column;gap:10px;padding-right:2px}.pane.on{display:flex}
.card{background:var(--s1);border:1px solid var(--line);border-radius:12px;padding:14px;flex:none}
.card h4{margin:0 0 10px;font-size:12.5px;font-weight:700;color:var(--txt);letter-spacing:.01em}
#p2 .card h4{margin:0;cursor:pointer;display:flex;justify-content:space-between;align-items:center}
#p2 .card h4:after{content:"";width:6px;height:6px;border-right:1.5px solid var(--mut);border-bottom:1.5px solid var(--mut);transform:rotate(45deg) translateY(-2px);transition:transform .15s}
#p2 .card.shut h4:after{transform:rotate(-45deg)}
#p2 .card:not(.shut)>h4{margin-bottom:10px}
#p2 .card.shut>*:not(h4){display:none}
.find{display:flex;align-items:center;gap:12px;flex:none}.find input{flex:1;width:auto}.find span{color:var(--mut);cursor:pointer;white-space:nowrap}.find span:hover{color:var(--txt)}
label.f{display:flex;align-items:center;justify-content:space-between;gap:14px;padding:7px 0;color:#d4d6dc}
label.f+label.f{border-top:1px solid var(--line)}
label.f small{display:block;color:var(--mut);font-size:11px;margin-top:2px;line-height:1.45;max-width:230px}
input[type=text],input[type=number],select{background:var(--bg);border:1px solid var(--line);color:var(--txt);border-radius:8px;padding:7px 10px;font:inherit;width:130px;outline:none;user-select:text}
input[type=number]::-webkit-inner-spin-button{display:none}
input:focus,select:focus{border-color:var(--acc)}input:disabled{opacity:.35}
input.wide{width:190px}
input[type=range]{width:130px;accent-color:var(--acc)}
.sw{position:relative;width:36px;height:20px;flex:none}.sw input{display:none}
.sw i{position:absolute;inset:0;background:var(--s3);border-radius:99px;transition:.18s;cursor:pointer}
.sw i:after{content:"";position:absolute;left:3px;top:3px;width:14px;height:14px;border-radius:50%;background:#9a9ea8;transition:.18s}
.sw input:checked+i{background:var(--acc)}.sw input:checked+i:after{left:19px;background:var(--ink)}
.tk{position:relative;width:30px;height:30px;flex:none}.tk input{display:none}.tk i{position:absolute;inset:0;border-radius:8px;border:1px solid var(--line2);background:var(--bg);cursor:pointer;display:flex;align-items:center;justify-content:center;font-style:normal;font-weight:800;font-size:15px;color:var(--bad)}.tk i:after{content:"\2715"}.tk input:checked+i{background:var(--acc);border-color:var(--acc);color:var(--ink)}.tk input:checked+i:after{content:"\2713"}
.seg{display:flex;background:var(--bg);border:1px solid var(--line);border-radius:8px;padding:2px}
.seg span{padding:5px 12px;cursor:pointer;color:var(--mut);font-weight:600;border-radius:6px}.seg span.on{background:var(--s3);color:var(--txt)}
.grid4{display:grid;grid-template-columns:1fr 1fr;gap:8px}.grid4 div{display:flex;flex-direction:column;gap:4px;color:var(--mut);font-size:11px}.grid4 input{width:100%}
.hint{color:var(--mut);font-size:11.5px;line-height:1.55;margin-top:8px}
.item{display:flex;align-items:center;justify-content:space-between;padding:10px 12px;border:1px solid var(--line);border-radius:10px;cursor:pointer;background:var(--s2)}
.item:hover{border-color:var(--line2)}.item.on{border-color:var(--acc);background:rgba(94,234,212,.06)}
.item small{color:var(--mut);display:block;margin-top:2px}
.x{color:var(--mut);padding:3px 9px;border-radius:6px}.x:hover{color:var(--bad);background:rgba(248,113,113,.1)}
.cap{display:flex;justify-content:space-between;align-items:center;margin-bottom:10px}.cap h4{margin:0}.cap span{color:var(--mut);cursor:pointer}.cap span:hover{color:var(--txt)}
.live{color:#b4b8c2;line-height:1.8}
.ban{background:var(--s2);border-radius:8px;padding:8px 10px;margin-bottom:10px;color:var(--txt)}
.lv{display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:10px}
.lv .k{background:var(--s2);border-radius:10px;padding:9px;text-align:center}
.lv .kk{display:inline-block;background:var(--bg);border:1px solid var(--line2);border-radius:5px;padding:1px 8px;font-weight:700;font-size:11.5px}
.lv b{display:block;color:var(--acc);font-size:20px;margin-top:5px}.lv small{color:var(--mut);font-size:10.5px}
.sh{color:var(--mut);font-size:12px;font-weight:600;margin:4px 2px -2px}
.stat{display:grid;grid-template-columns:1fr 1fr;gap:10px}
.stat .s{background:var(--s1);border:1px solid var(--line);border-radius:12px;padding:14px}
.stat .s span{color:var(--mut);font-size:11.5px}.stat .s b{display:block;font-size:24px;font-weight:600;margin-top:6px;letter-spacing:-.01em;font-variant-numeric:tabular-nums}
footer{display:flex;align-items:center;justify-content:space-between;padding:0 18px;border-top:1px solid var(--line);color:var(--mut);font-size:12px}
footer .l,footer .r{display:flex;align-items:center;gap:12px}
.chip{background:var(--s1);border:1px solid var(--line);border-radius:99px;padding:3px 11px;color:var(--txt);font-variant-numeric:tabular-nums}
.tag{color:var(--warn)}
#app.focus{grid-template-rows:1fr}#app.focus header,#app.focus footer,#app.focus #console{display:none}
#app.focus main{padding:4px;gap:6px}#app.focus .left{gap:0}#app.focus #dockarea{margin:4px}
footer b{color:var(--txt)}
</style></head><body><div id="app">
<header>
 <div class="brand"><svg viewBox="0 0 24 24"><path d="M12 2.5 21 9.5 12 21.5 3 9.5Z" fill="#5eead4"/><path d="M3 9.5h18M8 9.5 12 2.5 16 9.5 12 21.5Z" fill="none" stroke="#0c0d0f" stroke-width="1.1" stroke-linejoin="round" opacity=".55"/></svg><div class="n">Diamond<span>TD Macro</span></div></div>
 <div class="hr"><div class="hi">Hi, <b id="user">player</b></div><div class="pill" id="pill"><span class="dot"></span><span id="pilltxt">Idle</span></div><button class="btn go" id="startbtn">Start macro</button></div>
</header>
<main>
 <div class="left">
  <div id="stage">
   <div class="bar"><span id="dockstate">Roblox not docked</span><span id="rbx-dot" title="Roblox is running" style="display:none;width:8px;height:8px;border-radius:50%;background:#39d353;display:none;margin:0 4px;flex-shrink:0"></span><span id="status">Idle</span>
    <button class="btn" id="pickbtn">Dock window&hellip;</button><button class="btn" id="dockbtn">Dock Roblox</button><button class="btn" id="undockbtn">Undock</button><button class="btn" id="focusbtn" title="Hide the header, footer and console so the game panel is as tall as possible">Focus</button><button class="btn" id="testbtn">Test scan</button></div>
   <div id="dockarea"><div>Dock any open window here.<br>Press <b>Dock window&hellip;</b> and pick one, or press <b>Dock Roblox</b>.<br><span style="font-size:11.5px">Windowed and borderless windows work; exclusive-fullscreen games cannot be docked. If something misbehaves, press Undock.</span></div></div>
  </div>
  <div id="console"><div class="ch" id="chead"><span class="t">Console<i id="logn"></i></span><span class="a"><span id="clr">Clear</span><span id="conmin">Hide</span></span></div><div id="log"></div></div>
 </div>
 <div class="right">
  <div id="picker"><div class="ph"><input type="text" id="pfind" placeholder="Search open windows..." autocomplete="off"><button class="btn" id="prefresh">Refresh</button><button class="btn" id="pclose">Close</button></div><div class="pt">Pick a window to dock</div><div id="plist"></div><div class="pf">Click a window to dock it in the middle panel. Windows running as administrator (run the macro as administrator too) and exclusive-fullscreen games cannot be docked.</div></div>
  <div class="tabs"><div class="tab on" data-p="p1">Record</div><div class="tab" data-p="p2">Settings</div><div class="tab" data-p="p3">Stats</div><div class="tab" data-p="p4">ROBLOX</div><div class="tab" data-p="p5">Game</div></div>
  <div class="pane on" id="p1">
   <div class="card"><h4>New recording</h4>
    <label class="f">Name<input type="text" class="wide" data-k="rec_name" placeholder="defaults to the map name"></label>
    <button class="btn big go" id="recbtn" style="margin-top:8px">Start recording</button>
    <div class="hint">Press record, wait 5s while the camera aligns and zooms out, then play the run yourself. It stops and saves when Play Again appears or when you press the record hotkey again.</div></div>
   <div class="card"><h4>Live</h4><div class="live" id="live">Not recording.</div></div>
   <div class="card" style="flex:1"><div class="cap"><h4>Saved recordings</h4><span id="openf">Open folder</span></div><div id="recs" style="display:flex;flex-direction:column;gap:8px"></div></div>
   <div class="card"><h4>Statistics</h4><div id="stats" style="font-size:13px;line-height:1.6">No statistics yet.</div></div>
  </div>
  <div class="pane" id="p2">
  <div class="find"><input type="text" id="sfind" placeholder="Search settings&hellip;" spellcheck="false"><span id="expall">Expand all</span></div>
  <div class="card"><h4>Run</h4>
   <label class="f"><span>Loops<small>type how many, or pick INF to loop until stopped</small></span><div class="row" style="flex:none"><div class="seg" id="seg"><span data-v="num">Number</span><span data-v="inf">INF</span></div><input type="number" min="0" data-k="loops" style="width:80px" id="loopsnum" placeholder="0"></div></label>
   <label class="f"><span>Map<small>typed into the search bar</small></span><input type="text" class="wide" data-k="map"></label>
   <label class="f"><span>Adaption<small>learns every key in your recording and fixes placements that did not land, in any game</small></span><span class="tk"><input type="checkbox" data-k="adaption"><i></i></span></label>
  </div>
  <div class="card"><h4>Map select</h4>
   <div class="hint" style="margin:0 0 8px">Hover the mouse over the spot in Roblox, press Pick, and keep it there for 3 seconds. Values are % of the Roblox window, so docking and resizing do not break them. 0 / 0 = not set.</div>
   <div class="grid4"><div>Search bar X %<input type="number" step="0.1" data-k="search_x"></div><div>Search bar Y %<input type="number" step="0.1" data-k="search_y"></div></div>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="pks">Pick search bar</button></div>
   <div class="grid4"><div>Map X %<input type="number" step="0.1" data-k="map_x"></div><div>Map Y %<input type="number" step="0.1" data-k="map_y"></div></div>
   <div class="row" style="margin-top:8px"><button class="btn sm" id="pkm">Pick map</button></div>
   <div class="grid4" style="margin-top:8px"><div>Ready X %<input type="number" step="0.1" data-k="ready_x"></div><div>Ready Y %<input type="number" step="0.1" data-k="ready_y"></div></div>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="pkr">Pick Ready</button></div>
   <div class="grid4" style="margin-top:8px"><div>Veto X %<input type="number" step="0.1" data-k="veto_x"></div><div>Veto Y %<input type="number" step="0.1" data-k="veto_y"></div></div>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="pkv">Pick Veto</button></div>
   <label class="f">Veto if map is already in rotation<span class="sw"><input type="checkbox" data-k="veto_on"><i></i></span></label>
   <div class="hint" style="margin:10px 0 8px"><b>Veto detection = one red pixel.</b> After the map click the macro watches that pixel for the red message colour (0xEC0000 = map already in rotation). If it turns red, it clicks Veto at your saved Veto X/Y, holds E, and picks the map again. If it never turns red, the intro continues. Pick it on a THICK part of a letter of the red message. To pick: make the message show up in game, press the button, then hold the thin 1-pixel crosshair over that spot for 3 seconds.</div>
   <div class="grid4" style="margin-top:8px"><div>Veto pixel X %<input type="number" step="0.01" data-k="vpx_x"></div><div>Veto pixel Y %<input type="number" step="0.01" data-k="vpx_y"></div></div>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="pkvp">Pick veto pixel (red)</button></div>
   <label class="f"><span>Colour tolerance<small>how far each of R, G, B may be from the target (0-120). Raise it if the log shows the shade is a bit different</small></span><input type="number" step="1" min="0" max="120" data-k="px_tol" style="width:80px"></label>
   <div class="hint" style="margin:10px 0 8px"><b>Lime green button detection (RESTART, READY, PLAY AGAIN)</b><br>These buttons use pixel search for bright lime green (0, 255, 0). Pick pixels on the buttons for reliable detection.</div>
   <div class="grid4" style="margin-top:8px"><div>Restart pixel X %<input type="number" step="0.01" data-k="restart_px_x"></div><div>Restart pixel Y %<input type="number" step="0.01" data-k="restart_px_y"></div></div>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="pkrp">Pick Restart pixel (lime green)</button></div>
   <div class="grid4" style="margin-top:8px"><div>Ready pixel X %<input type="number" step="0.01" data-k="ready_px_x"></div><div>Ready pixel Y %<input type="number" step="0.01" data-k="ready_px_y"></div></div>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="pkrdp">Pick Ready pixel (lime green)</button></div>
   <div class="grid4" style="margin-top:8px"><div>Play Again pixel X %<input type="number" step="0.01" data-k="play_again_px_x"></div><div>Play Again pixel Y %<input type="number" step="0.01" data-k="play_again_px_y"></div></div>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="pkpap">Pick Play Again pixel (lime green)</button></div>
   <label class="f"><span>Intro style<small>new = camera align + E-prompt checks + waits for the veto result (from Ultimate Macro); classic = the old timed intro</small></span><select data-k="intro_mode" style="width:110px"><option value="new">new</option><option value="classic">classic</option></select></label>
   <label class="f"><span>UI delay (s)<small>wait after E, after the search click, after typing and before the final Ready click</small></span><input type="number" step="0.1" min="0" data-k="menu_delay" style="width:90px"></label></div>
  <div class="card"><h4>Scan zone</h4>
   <label class="f">Scan the full screen<span class="sw"><input type="checkbox" data-k="full_screen"><i></i></span></label>
   <div class="grid4" id="zone"><div>Top-left X<input type="number" data-k="zone.x1"></div><div>Top-left Y<input type="number" data-k="zone.y1"></div><div>Bottom-right X<input type="number" data-k="zone.x2"></div><div>Bottom-right Y<input type="number" data-k="zone.y2"></div></div>
   <div class="row" style="margin-top:8px"><button class="btn sm" id="pk1">Pick top-left</button><button class="btn sm" id="pk2">Pick bottom-right</button></div>
   <div class="hint">Pick waits 3 seconds, then grabs wherever your mouse is.</div></div>
  <div class="card"><h4>Detection</h4>
   <label class="f"><span>Match strictness<small id="thrv"></small></span><input type="range" min="0.50" max="0.98" step="0.01" data-k="threshold"></label>
   <label class="f"><span>Resolution<small>Roblox fullscreen? pick your screen size</small></span><select data-k="resolution"><option value="auto">Auto-detect</option><option>3840x2160</option><option>3440x1440</option><option>2560x1440</option><option>2560x1080</option><option>1920x1080</option><option>1920x1200</option><option>1680x1050</option><option>1600x900</option><option>1366x768</option><option>1280x720</option></select></label>
   <label class="f"><span>Gamemode<small>used when auto-rejoining after a crash / disconnect</small></span><select data-k="gamemode"><option value="easy">Easy</option><option value="casual">Casual</option><option value="intermediate">Intermediate</option><option value="molten">Molten</option><option value="fallen">Fallen</option><option value="frost">Frost</option></select></label>
   <label class="f"><span>Auto-gamemode cycle<small>automatically cycle through gamemodes</small></span><span class="sw"><input type="checkbox" data-k="cycle_enabled"><i></i></span></label>
   <label class="f"><span>Cycle modes<small>comma-separated list (e.g., molten,fallen,frost)</small></span><input type="text" data-k="cycle_modes" style="flex:1"></label>
   <label class="f"><span>Runs per mode<small>how many runs before switching</small></span><input type="number" data-k="cycle_runs" style="width:90px"></label>
   <label class="f"><span>Auto-rejoin on Leave popup<small>click Leave and rejoin when the disconnect popup appears. Keep off until the Leave image (images/leave_btn.png) only matches the real popup</small></span><span class="sw"><input type="checkbox" data-k="auto_rejoin"><i></i></span></label>
   <label class="f"><span>Custom rejoin link<small>paste a roblox.com/games/... link to rejoin a different game</small></span><input type="text" data-k="rejoin_link" style="flex:1" placeholder="https://www.roblox.com/games/..."></label>
   <label class="f"><span>Custom rejoin steps<small>JSON array of steps to run after rejoining (advanced)</small></span><input type="text" data-k="custom_rejoin_steps" style="flex:1" placeholder='[{"type":"wait","duration":5}]'></label>
   <label class="f"><span>UI scale<small>auto or a number like 0.75</small></span><input type="text" data-k="ui_scale" style="width:90px"></label>
   <label class="f"><span>Step timeout (s)<small>skip an intro image after this</small></span><input type="number" data-k="step_timeout" style="width:90px"></label>
  </div>
  <div class="card"><h4>Camera</h4>
   <label class="f"><span>Align drag (px)<small>how far to pull down while holding RMB</small></span><input type="number" data-k="cam_drag" style="width:90px"></label>
   <label class="f"><span>Zoom out after the intro align</span><span class="sw"><input type="checkbox" data-k="zoom_after_align"><i></i></span></label>
   <label class="f"><span>Zoom out amount<small>mouse-wheel clicks. 50 = what it always did. Lower = zooms out less, higher = further. Used by the zoom out above.</small></span><input type="number" step="1" min="0" max="200" data-k="zoom_clicks" style="width:90px"></label>
   <label class="f"><span>Restart wait (s)<small>after Restart Match: wait before aligning</small></span><input type="number" step="0.5" min="0" data-k="restart_wait" style="width:90px"></label>
   <label class="f"><span>After Restart Match<small>Restart keeps you standing where you were. Reset = Esc, R, Enter then replay the whole recording. Stay put = skip the W/A/S/D walking and go straight to the clicks.</small></span><select data-k="restart_mode"><option value="reset">Reset character (Esc, R, Enter), wait, then replay</option><option value="skipwasd">Stay put - skip W/A/S/D, go straight to the clicks</option><option value="none">Do nothing special (old behaviour)</option></select></label>
   <label class="f"><span>Reset key gap (s)<small>pause between Esc, R and Enter</small></span><input type="number" step="0.05" min="0.02" data-k="restart_key_gap" style="width:90px"></label>
   <label class="f"><span>Wait after reset (s)<small>before the camera is aligned and the recording plays</small></span><input type="number" step="0.5" min="0" data-k="restart_reset_wait" style="width:90px"></label>
   <label class="f"><span>Skip intro sequence<small>skip map selection and go straight to recording (useful for custom profiles or when already in game)</small></span><span class="sw"><input type="checkbox" data-k="skip_intro"><i></i></span></label>
   <label class="f"><span>Disable Play Again/Restart watcher<small>useful for custom profiles that don't have these buttons</small></span><span class="sw"><input type="checkbox" data-k="disable_watcher"><i></i></span></label>
  </div>
  <div class="card"><h4>Recording &amp; placement</h4>
   <label class="f"><span>Record mouse clicks<small>tower placement needs this</small></span><span class="sw"><input type="checkbox" data-k="record_mouse"><i></i></span></label>
   <label class="f"><span>Mouse glide (s)<small>playback only: smooth cursor travel to each click, 0 = instant</small></span><input type="number" step="0.05" min="0" max="2" data-k="mouse_glide" style="width:90px"></label>
   <label class="f"><span>Wiggle before placing<small>after key 1/2: wait, wiggle the cursor up/down/left/right, return, then click</small></span><span class="sw"><input type="checkbox" data-k="place_jiggle"><i></i></span></label>
   <label class="f"><span>Wait after 1/2 (s)</span><input type="number" step="0.05" min="0" data-k="slot_wait" style="width:90px"></label>
   <label class="f"><span>Rest on spot before click (s)<small>cursor sits still after the wiggle so the game registers the spot</small></span><input type="number" step="0.05" min="0" data-k="place_settle" style="width:90px"></label>
   <label class="f"><span>Mahoraga<small>show the 8-spoke wheel + play SFX when Adaption fixes a failed placement. 2 per run max.</small></span><span class="sw"><input type="checkbox" data-k="maho"><i></i></span></label>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="mahotest">Test Mahoraga</button></div>
  </div>
  <div class="card"><h4>Big Dick Randy 💀</h4>
   <label class="f"><span>Randy mode<small>random appearances with overlay and scary messages</small></span><span class="sw"><input type="checkbox" data-k="big_dick_randy_mode"><i></i></span></label>
   <label class="f"><span>Mini-game<small>driving chase with QTE (0.4s timeout)</small></span><span class="sw"><input type="checkbox" data-k="bdr_minigame"><i></i></span></label>
   <label class="f"><span>Rarity system<small>common/rare/ultra-rare tiers with different effects</small></span><span class="sw"><input type="checkbox" data-k="bdr_rarity_system"><i></i></span></label>
   <label class="f"><span>Evidence board<small>capture screenshots of Randy sightings</small></span><span class="sw"><input type="checkbox" data-k="bdr_evidence_board"><i></i></span></label>
   <label class="f"><span>Lore unlocks<small>progressive case file entries based on sightings</small></span><span class="sw"><input type="checkbox" data-k="bdr_lore_unlocks"><i></i></span></label>
   <label class="f"><span>Incident reports<small>fake dashboard messages from Randy</small></span><span class="sw"><input type="checkbox" data-k="bdr_incident_reports"><i></i></span></label>
   <label class="f"><span>Mahoraga counter<small>track adaptations before Randy interrupts</small></span><span class="sw"><input type="checkbox" data-k="bdr_mahoraga_counter"><i></i></span></label>
   <label class="f"><span>Gemini changelog<small>use Gemini AI to approve/reject features</small></span><span class="sw"><input type="checkbox" data-k="bdr_changelog_gemini"><i></i></span></label>
   <label class="f"><span>Fake changelog<small>also show fake Randy approvals</small></span><span class="sw"><input type="checkbox" data-k="bdr_changelog_fake"><i></i></span></label>
  </div>
  <div class="card"><h4>Gemini Game Adaptation</h4>
   <label class="f"><span>Game adaptation<small>use Gemini to adapt to other games when switching profiles</small></span><span class="sw"><input type="checkbox" data-k="gemini_game_adaptation"><i></i></span></label>
   <label class="f"><span>Auto-query on profile switch<small>automatically ask Gemini when changing profiles</small></span><span class="sw"><input type="checkbox" data-k="gemini_game_adaptation_on_profile_switch"><i></i></span></label>
   <div class="row" style="margin:8px 0"><input type="text" id="gameadaptname" placeholder="Game name (e.g., Black Myth Wukong)" style="flex:1"><button class="btn sm" id="gameadapt">Query Gemini</button></div>
   <div class="hint">When you create a profile named after a game (e.g., "Black Myth Wukong"), Gemini will research the game and provide UI colors, timing, and detection tips to help adapt the macro.</div>
   <label class="f"><span>Idle detector<small>fake messages when macro is idle</small></span><span class="sw"><input type="checkbox" data-k="bdr_idle_detector"><i></i></span></label>
   <label class="f"><span>Stat reactions<small>Randy comments on your coins/XP/win rate</small></span><span class="sw"><input type="checkbox" data-k="bdr_stat_reactions"><i></i></span></label>
   <label class="f"><span>Fake awareness<small>Randy reacts to recording, profile switches, etc.</small></span><span class="sw"><input type="checkbox" data-k="bdr_fake_awareness"><i></i></span></label>
   <label class="f"><span>Case file<small>unlock cursed lore entries about Randy</small></span><span class="sw"><input type="checkbox" data-k="bdr_case_file"><i></i></span></label>
   <label class="f"><span>Fake takeover<small>Randy "hacks" the overlay (changes name/profile/scale)</small></span><span class="sw"><input type="checkbox" data-k="bdr_fake_takeover"><i></i></span></label>
   <label class="f"><span>Randy sightings<small>capture screenshots of Randy's overlay</small></span><span class="sw"><input type="checkbox" data-k="bdr_sightings"><i></i></span></label>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="bdrtest">Test Mini-Game</button></div>
   <div class="hint">💀 Randy features are prank features - some cannot be disabled!</div>
   <label class="f"><span>Cancel (Q) before tower key<small>clears a stuck red preview before pressing 1/2</small></span><span class="sw"><input type="checkbox" data-k="cancel_before_slot"><i></i></span></label>
   <label class="f"><span>Wiggle before every left click<small>not just tower placing: every recorded left click gets the same wiggle + rest before it</small></span><span class="sw"><input type="checkbox" data-k="wiggle_all"><i></i></span></label>
   <div class="grid4" style="margin-top:8px"><div>Coins per game<input type="number" step="1" min="0" data-k="game_coins"></div><div>EXP per game<input type="number" step="1" min="0" data-k="game_xp"></div></div>
   <div class="hint">Coins / EXP per game: type what one game gives you (0 = off, read it from the screen instead). After every finished game it is added to your totals.</div>
   <label class="f"><span>Loop the recording<small>when it ends, play it again (and again) until Play Again / Restart is detected</small></span><span class="sw"><input type="checkbox" data-k="loop_rec"><i></i></span></label>
   <label class="f"><span>Re-place towers when looping<small>off = later passes skip tower placing and only redo upgrades, movement, etc.</small></span><span class="sw"><input type="checkbox" data-k="loop_replace"><i></i></span></label>
   <label class="f"><span>Verify placements<small>after each equip key + click, check it worked and retry if not (needs Adaption)</small></span><span class="sw"><input type="checkbox" data-k="verify_place"><i></i></span></label>
   <label class="f"><span>Placement retries</span><input type="number" step="1" min="0" max="10" data-k="place_retries" style="width:90px"></label>
   <label class="f"><span>Side nudge (px)<small>if a tower won't place: 10px left (left half of screen) or right (right half). The recording's clicks on that spot move the same amount so upgrades still hit. 0 = off</small></span><input type="number" step="1" min="0" max="100" data-k="nudge_px" style="width:90px"></label>
   <label class="f"><span>Head-click match radius (px)<small>a click counts as belonging to the nearest placed tower within this distance (the head click sits ~15px above the base)</small></span><input type="number" step="1" min="3" max="100" data-k="nudge_radius" style="width:90px"></label>
   <label class="f"><span>Wait before 1st retry (s)<small>gives you time to earn the cash</small></span><input type="number" step="0.5" min="0" data-k="retry_wait" style="width:90px"></label>
   <label class="f"><span>Extra hold on W/A/S/D (s)<small>added to every recorded movement key release</small></span><input type="number" step="0.05" min="0" data-k="move_hold_extra" style="width:90px"></label>
   <label class="f"><span>Wiggle size (px)</span><input type="number" step="1" min="1" data-k="jiggle_px" style="width:90px"></label>
   <label class="f"><span>Audio cues<small>play sounds for events (success/error/warning)</small></span><span class="sw"><input type="checkbox" data-k="audio_cues"><i></i></span></label>
   <label class="f"><span>Screenshot on error<small>save screen when errors occur</small></span><span class="sw"><input type="checkbox" data-k="screenshot_on_error"><i></i></span></label>
   <label class="f"><span>Only while Roblox is focused</span><span class="sw"><input type="checkbox" data-k="focus_only"><i></i></span></label>
   <label class="f"><span>Reward read delay (s)<small>wait before clicking Play Again</small></span><input type="number" step="0.1" min="0" data-k="reward_delay" style="width:90px"></label>
  </div>
  <div class="card"><h4>Analytics &amp; Backup</h4>
   <label class="f"><span>Milestone screenshots<small>auto-screenshot on coin/XP milestones</small></span><span class="sw"><input type="checkbox" data-k="milestone_screenshots"><i></i></span></label>
   <label class="f"><span>Coins milestone<small>screenshot every X coins</small></span><input type="number" step="100" min="100" data-k="milestone_coins" style="width:90px"></label>
   <label class="f"><span>XP milestone<small>screenshot every X XP</small></span><input type="number" step="50" min="50" data-k="milestone_xp" style="width:90px"></label>
   <label class="f"><span>Auto backup<small>daily automatic backups of config/profiles</small></span><span class="sw"><input type="checkbox" data-k="auto_backup"><i></i></span></label>
   <label class="f"><span>Backup interval (hours)<small>how often to backup</small></span><input type="number" step="1" min="1" max="168" data-k="backup_interval" style="width:90px" value="24"></label>
   <label class="f"><span>Keep backups for (days)<small>auto-delete old backups</small></span><input type="number" step="1" min="1" max="30" data-k="backup_max_age" style="width:90px"></label>
   <label class="f"><span>Rollback enabled<small>one-click restore from previous config</small></span><span class="sw"><input type="checkbox" data-k="rollback_enabled"><i></i></span></label>
   <label class="f"><span>Rollback snapshots<small>keep last N config snapshots</small></span><input type="number" step="1" min="1" max="20" data-k="rollback_snapshots" style="width:90px" value="5"></label>
  </div>
  <div class="card"><h4>Preflight &amp; Diagnostics</h4>
   <label class="f"><span>Preflight check<small>validate before starting macro</small></span><span class="sw"><input type="checkbox" data-k="preflight_check"><i></i></span></label>
   <label class="f"><span>Preflight on start<small>auto-run preflight when macro starts</small></span><span class="sw"><input type="checkbox" data-k="preflight_on_start"><i></i></span></label>
   <label class="f"><span>Diagnostics mode<small>show detection details in log</small></span><span class="sw"><input type="checkbox" data-k="diagnostics_mode"><i></i></span></label>
   <label class="f"><span>Show confidence<small>display detection scores</small></span><span class="sw"><input type="checkbox" data-k="diagnostics_show_confidence"><i></i></span></label>
   <label class="f"><span>Show reason<small>display why detection was accepted/rejected</small></span><span class="sw"><input type="checkbox" data-k="diagnostics_show_reason"><i></i></span></label>
  </div>
  <div class="card"><h4>Auto Update</h4>
   <label class="f"><span>Auto update enabled<small>check for updates from GitHub</small></span><span class="sw"><input type="checkbox" data-k="auto_update_enabled"><i></i></span></label>
   <label class="f"><span>Check on start<small>auto-check when macro starts</small></span><span class="sw"><input type="checkbox" data-k="auto_update_check_on_start"><i></i></span></label>
   <label class="f"><span>Check interval (hours)<small>0 = every time, 1-168 = hours</small></span><input type="number" step="1" min="0" max="168" data-k="auto_update_check_interval" style="width:90px" value="24"></label>
   <label class="f"><span>Auto install<small>automatically install updates without asking</small></span><span class="sw"><input type="checkbox" data-k="auto_update_auto_install"><i></i></span></label>
   <label class="f"><span>Auto rebuild EXE<small>rebuild EXE after updating (takes 1-2 minutes)</small></span><span class="sw"><input type="checkbox" data-k="auto_update_rebuild_exe"><i></i></span></label>
   <div class="row" style="margin:8px 0"><button class="btn sm" id="checkupdate">Check for updates</button><button class="btn sm" id="installupdate" style="display:none">Install update</button></div>
   <div id="updatestatus" class="hint" style="margin-top:8px">Click to check for updates</div>
  </div>
  <div class="card"><h4>Performance</h4>
   <label class="f"><span>Lag compensation<small>automatically adjust timings based on ping (can cause delays)</small></span><span class="sw"><input type="checkbox" data-k="lag_compensation"><i></i></span></label>
   <label class="f"><span>Current lag multiplier<small>auto-adjusted if lag compensation is on</small></span><input type="number" step="0.1" min="1.0" max="4.0" data-k="lag_multiplier" style="width:90px" readonly></label>
   <label class="f"><span>2x speed mode<small>clicks arrow then 2x button during recording (2x speed only)</small></span><span class="sw"><input type="checkbox" data-k="time_scale_2x"><i></i></span></label>
  </div>
  <div class="card"><h4>Hotkeys &amp; window</h4>
   <label class="f">Start<select data-k="hk_start" class="fk"></select></label>
   <label class="f">Stop<select data-k="hk_stop" class="fk"></select></label>
   <label class="f">Record<select data-k="hk_record" class="fk"></select></label>
   <label class="f">Pick Color<select data-k="hk_pick_color" class="fk"></select></label>
   <label class="f">Switch Profile<select data-k="hk_switch_profile" class="fk"></select></label>
   <label class="f">Reload Templates<select data-k="hk_reload_templates" class="fk"></select></label>
   <label class="f"><span>Auto-dock Roblox</span><span class="sw"><input type="checkbox" data-k="auto_dock"><i></i></span></label>
   <label class="f"><span>Roblox shape in the panel<small id="dockfit-info">Auto = your screen's shape, so the whole game UI fits</small></span><select data-k="dock_fit"><option value="auto">Auto (match my screen)</option><option value="fill">Fill the panel</option><option value="16:9">16:9</option><option value="16:10">16:10</option><option value="21:9">21:9</option><option value="4:3">4:3</option></select></label>
  </div>
 </div>
 
  <div class="pane" id="p3">
   <div class="sh">This session</div>
   <div class="stat">
    <div class="s"><span>Runs</span><b id="s_loops">0</b></div><div class="s"><span>Run time</span><b id="s_time">0:00:00</b></div>
    <div class="s"><span>Coins</span><b id="s_coins">0</b></div><div class="s"><span>XP</span><b id="s_xp">0</b></div>
   </div>
   <div class="sh" style="margin-top:8px">All time</div>
   <div class="stat"><div class="s"><span>Coins</span><b id="t_coins">0</b></div><div class="s"><span>XP</span><b id="t_xp">0</b></div></div>
   <div class="hint">Coins and XP are read from the results screen with Windows OCR just before Play Again is clicked, unless you typed per-game numbers in Settings. Then those are added after every finished game instead.</div>
  </div>
  <div class="pane" id="p4">
   <div class="card"><h4>Account</h4>
    <div id="rbx-who" class="hint" style="margin:0 0 8px">Not signed in.</div>
    <div id="rbx-expired" class="hint" style="color:#f59e0b;margin:0 0 8px;display:none">Session expired &mdash; sign in again with a fresh cookie.</div>
    <div class="row" style="gap:8px;margin-bottom:8px"><input type="password" id="rbx-cookie" placeholder=".ROBLOSECURITY cookie" style="flex:1;width:auto" autocomplete="off"><button class="btn sm" id="rbx-signin">Sign in</button></div>
    <div class="row" style="gap:8px"><button class="btn sm" id="rbx-signout">Sign out</button><button class="btn sm" id="rbx-runas" style="display:none">Restart as admin</button></div>
    <div class="hint" style="margin-top:8px">Paste your .ROBLOSECURITY cookie from your browser. It is stored encrypted on this PC using Windows DPAPI and never logged or sent anywhere other than Roblox.</div>
   </div>
   <div class="card"><h4>Launch</h4>
    <div class="row" style="gap:8px;margin-bottom:8px">
     <button class="btn big go" id="rbx-launch" style="flex:1">Launch Roblox (TDS)</button>
    </div>
    <datalist id="rbx-history"></datalist>
    <div class="row" style="gap:8px"><input type="text" id="rbx-link" list="rbx-history" placeholder="Paste game / share / private-server link" style="flex:1;width:auto" autocomplete="off"><button class="btn sm" id="rbx-join">Join</button></div>
    <div id="rbx-err" class="hint" style="color:var(--bad);margin:6px 0 0;display:none"></div>
   </div>
   <div class="card"><h4>FPS Boost</h4>
    <div id="rbx-fps-info" class="hint" style="margin:0 0 10px">Checking...</div>
    <label class="f"><span>Frame cap<small>max FPS while boost is ON</small></span><input type="number" id="rbx-cap" data-k="rbx_fps_cap" min="30" max="9999" style="width:90px"></label>
    <div class="row" style="gap:8px;margin-top:10px"><button class="btn go" id="rbx-fps-on">Apply FPS boost</button><button class="btn" id="rbx-fps-off">Restore defaults</button></div>
    <div class="hint" style="margin-top:8px">Writes fast-flags to ClientAppSettings.json and raises FramerateCap. Close Roblox before applying or restoring. FPS flags auto-reapply after a Roblox update.</div>
   </div>
   <div class="card"><h4>FPS Tracker</h4>
    <div class="stat" style="margin-bottom:10px"><div class="s"><span>FPS</span><b id="rbx-fps-val">--</b></div><div class="s"><span>Status</span><b id="rbx-tracker-st" style="font-size:14px">Stopped</b></div></div>
    <div class="row" style="gap:8px"><button class="btn go" id="rbx-tracker-start">Start tracker</button><button class="btn" id="rbx-tracker-stop">Stop tracker</button><button class="btn" id="rbx-overlay-btn">Show overlay</button></div>
    <div class="hint" style="margin-top:8px">Uses Intel PresentMon (downloaded once to %APPDATA%\TDRecorder\tools). Requires administrator permission (UAC prompt). Run the macro as administrator if the prompt is always declined.</div>
   </div>
  </div>
  <div class="pane" id="p5">
   <div class="card"><h4>Profile</h4>
    <div class="row" style="gap:8px;margin-bottom:8px">
     <select id="gm-profile-sel" style="flex:1"></select>
     <button class="btn sm go" id="gm-profile-new">+ New</button>
     <button class="btn sm" id="gm-profile-del" style="color:var(--bad)">Delete</button>
    </div>
    <label class="f"><span>Name</span><input type="text" id="gm-name" style="flex:1"></label>
    <label class="f"><span>TDS mode<small>use the built-in TDS intro and loop logic</small></span><span class="sw"><input type="checkbox" id="gm-tds-mode"><i></i></span></label>
    <label class="f"><span>Hybrid mode<small>run TDS intro, then custom steps</small></span><span class="sw"><input type="checkbox" id="gm-hybrid-mode"><i></i></span></label>
    <label class="f"><span>Template<small>quick-start from a preset</small></span><select id="gm-template-sel" style="flex:1"><option value="">(none)</option></select></label>
    <div class="row" style="gap:8px;margin-top:8px"><button class="btn go" id="gm-save">Save profile</button><button class="btn sm" id="gm-apply-template">Apply template</button></div>
   </div>
   <div class="card" id="gm-steps-card"><h4>Step sequence</h4>
    <div class="hint" style="margin:0 0 10px">Build your loop one step at a time. The macro runs these top to bottom, then repeats.</div>
    <div id="gm-step-list" style="display:flex;flex-direction:column;gap:6px"></div>
    <div class="row" style="gap:8px;margin-top:10px">
     <select id="gm-step-type-sel" style="flex:1"></select>
     <button class="btn sm go" id="gm-step-add">+ Add step</button>
    </div>
   </div>
   <div class="card" id="gm-keys-card"><h4>Attack rotation</h4>
    <div class="hint" style="margin:0 0 10px">Pick every key used for towers, abilities or attacks. The macro cycles through them during gameplay.</div>
    <div id="gm-key-grid" style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:10px"></div>
    <div class="hint" style="margin-top:4px">Click a key to toggle it. Selected keys are highlighted.</div>
   </div>
   <div class="card" id="gm-spots-card"><h4>Click spots</h4>
    <div class="hint" style="margin:0 0 10px">Save up to 50 screen positions. Use them in steps with the <b>Click N times at X,Y</b> step, or let the macro cycle through them.</div>
    <div id="gm-spots-list" style="display:flex;flex-direction:column;gap:6px;margin-bottom:10px"></div>
    <div class="row" style="gap:8px;align-items:center">
     <button class="btn sm go" id="gm-spot-pick">Pick spot (3s)</button>
     <span class="hint" style="margin:0">or type:</span>
     <input type="number" id="gm-spot-x" placeholder="X" style="width:70px">
     <input type="number" id="gm-spot-y" placeholder="Y" style="width:70px">
     <button class="btn sm" id="gm-spot-add">+ Add</button>
    </div>
   </div>
   <div class="card"><h4>Image library</h4>
    <div class="hint" style="margin:0 0 10px">Snip a button or icon from your screen. The macro uses it to detect and click things in your game.</div>
    <div id="gm-img-list" style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:10px"></div>
    <div class="row" style="gap:8px;align-items:center">
     <button class="btn go" id="gm-snip-btn">Snip screenshot</button>
     <input type="text" id="gm-snip-name" placeholder="Name (e.g. play_again)" style="flex:1;width:auto">
     <button class="btn sm" id="gm-snip-save" style="display:none">Save</button>
    </div>
    <div id="gm-snip-preview" style="margin-top:8px;display:none"><img id="gm-snip-img" style="max-height:80px;border:1px solid var(--line);border-radius:4px"><button class="btn sm" id="gm-snip-clear" style="margin-left:8px">Clear</button></div>
    <div id="gm-img-err" class="hint" style="color:var(--bad);margin-top:6px;display:none"></div>
   </div>
  </div>
 </div>
</main>
<footer><div class="l"><span>Made by <b>__CREDIT__</b></span><span>v__VER__</span><span class="tag">Early beta</span></div><div id="hk"></div><div class="r"><span>Coins</span><span class="chip" id="f_coins">0</span><span>XP</span><span class="chip" id="f_xp">0</span></div></footer>
</div>
<script>
const $=s=>document.querySelector(s),$$=s=>[...document.querySelectorAll(s)];
let manualPick=false,lastClosed=-1,pwList=[];
let userUndock=false,lastDock=0,api,cfg,rev=-1,since=0,saveT=null,lastRecs='',mode='idle',dpr=window.devicePixelRatio||1;
const getp=(o,p)=>p.split('.').reduce((a,k)=>a[k],o);
const setp=(o,p,v)=>{const k=p.split('.'),l=k.pop();k.reduce((a,x)=>a[x],o)[l]=v};
const fmt=n=>(n||0).toLocaleString();
function fill(){
 $$('[data-k]').forEach(el=>{const v=getp(cfg,el.dataset.k);if(el.type==='checkbox')el.checked=!!v;else el.value=v});
 $$('#seg span').forEach(s=>s.classList.toggle('on',s.dataset.v===cfg.loops_mode));
 deps();
}
function deps(){
 $$('#zone input').forEach(i=>i.disabled=cfg.full_screen);
 $('#loopsnum').disabled=cfg.loops_mode==='inf';$('#thrv').textContent=parseFloat(cfg.threshold).toFixed(2)+' (higher = stricter)';
 $('#hk').textContent=cfg.hk_start+' start  \u00b7  '+cfg.hk_stop+' stop  \u00b7  '+cfg.hk_record+' record  \u00b7  '+cfg.hk_pick_color+' pick color  \u00b7  '+cfg.hk_switch_profile+' switch profile  \u00b7  '+cfg.hk_reload_templates+' reload templates';
}
function queueSave(){deps();clearTimeout(saveT);saveT=setTimeout(()=>api.save_cfg(cfg),250)}
function bind(){
 const fk=$$('.fk');for(let i=1;i<=12;i++)fk.forEach(s=>s.add(new Option('F'+i,'F'+i)));
 $$('[data-k]').forEach(el=>{
  const h=()=>{let v;if(el.type==='checkbox')v=el.checked;else if(el.type==='number'||el.type==='range'){v=parseFloat(el.value);if(isNaN(v))v=0}else v=el.value;setp(cfg,el.dataset.k,v);queueSave()};
  el.addEventListener(el.tagName==='SELECT'||el.type==='checkbox'?'change':'input',h);
 });
 $$('#seg span').forEach(s=>s.onclick=()=>{cfg.loops_mode=s.dataset.v;fill();queueSave()});
 $$('.tab').forEach(t=>t.onclick=()=>{$$('.tab').forEach(x=>x.classList.toggle('on',x===t));$$('.pane').forEach(p=>p.classList.toggle('on',p.id===t.dataset.p))});
 $('#startbtn').onclick=()=>mode==='idle'?api.start():api.stop();
 $('#recbtn').onclick=()=>api.record_toggle();
 $('#testbtn').onclick=()=>api.test_scan();
 $('#checkupdate').onclick=async()=>{
   const r=await api.check_for_updates();
   const s=$('#updatestatus');
   if(r.update_available){
     s.textContent=`Update available: v${r.current} → v${r.latest}`;
     s.style.color='var(--ok)';
     $('#installupdate').style.display='';
   }else{
     s.textContent='Already up to date';
     s.style.color='var(--mut)';
     $('#installupdate').style.display='none';
   }
 };
 $('#installupdate').onclick=async()=>{
   const s=$('#updatestatus');
   s.textContent='Downloading update...';
   s.style.color='var(--warn)';
   const rebuild=$('#auto_update_rebuild_exe').checked;
   const r=await api.download_and_install_update(rebuild);
   if(r.ok){
     s.textContent='Update installed! Restarting...';
   }else{
     s.textContent='Update failed: '+r.err;
     s.style.color='var(--bad)';
   }
 };
 $('#focusbtn').onclick=()=>{const a=$('#app');a.classList.toggle('focus');$('#focusbtn').textContent=a.classList.contains('focus')?'Unfocus':'Focus';setTimeout(sendDock,150)};
 $('#pks').onclick=()=>api.pick_pt('search');$('#pkm').onclick=()=>api.pick_pt('map');$('#pkr').onclick=()=>api.pick_pt('ready');$('#pkv').onclick=()=>api.pick_pt('veto');$('#pkvp').onclick=()=>api.pick_pt('vpx');$('#pkrp').onclick=()=>api.pick_pt('restart_px');$('#pkrdp').onclick=()=>api.pick_pt('ready_px');$('#pkpap').onclick=()=>api.pick_pt('play_again_px');$('#mahotest').onclick=()=>api.maho_test();$('#gameadapt').onclick=async()=>{const n=$('#gameadaptname').value.trim();if(!n)return;await api.query_game_adaptation(n)};
 $('#pk1').onclick=()=>api.pick('tl');$('#pk2').onclick=()=>api.pick('br');
 $('#openf').onclick=()=>api.open_folder();
 $('#dockbtn').onclick=async()=>{userUndock=false;manualPick=false;const r=rect();await api.dock(r[0],r[1],r[2],r[3])};
 $('#pickbtn').onclick=openPicker;$('#prefresh').onclick=loadWins;$('#pclose').onclick=closePicker;
 $('#pfind').addEventListener('input',renderWins);
 $('#pfind').addEventListener('keydown',e=>{if(e.key==='Enter'){const f=pwFiltered()[0];if(f)pickWin(f)}});
 document.addEventListener('keydown',e=>{if(e.key==='Escape')closePicker()});
 $('#undockbtn').onclick=()=>{userUndock=true;api.undock()};
 new ResizeObserver(sendDock).observe($('#dockarea'));window.addEventListener('resize',sendDock);
}
function setupUI(){
 const cards=$$('#p2 .card');cards.forEach((c,i)=>{if(i!==0&&i!==3)c.classList.add('shut');c.querySelector('h4').onclick=()=>c.classList.toggle('shut')});
 let all=false;$('#expall').onclick=()=>{all=!all;cards.forEach(c=>c.classList.toggle('shut',!all));$('#expall').textContent=all?'Collapse all':'Expand all'};
 $('#sfind').addEventListener('input',()=>{const q=$('#sfind').value.trim().toLowerCase();
  cards.forEach(c=>{const hit=!q||c.querySelector('h4').textContent.toLowerCase().includes(q);let any=hit;
   c.querySelectorAll('label.f').forEach(l=>{const m=!q||hit||l.textContent.toLowerCase().includes(q);l.style.display=m?'':'none';if(m)any=true});
   c.style.display=any?'':'none';if(q&&any)c.classList.remove('shut')})});
 const con=$('#console');const tg=()=>{con.classList.toggle('min');$('#conmin').textContent=con.classList.contains('min')?'Show':'Hide'};
 con.classList.add('min');$('#conmin').textContent='Show';
 $('#conmin').onclick=e=>{e.stopPropagation();tg()};$('#chead').onclick=tg;$('#clr').onclick=e=>{e.stopPropagation();api.clear_log();$('#log').innerHTML='';$('#logn').textContent=''};
}
function pwFiltered(){const q=$('#pfind').value.trim().toLowerCase();return pwList.filter(w=>!q||(w.exe+' '+w.title).toLowerCase().includes(q))}
function pwNote(t){const box=$('#plist');box.textContent='';const m=document.createElement('div');m.className='hint';m.textContent=t;box.appendChild(m)}
function openPicker(){$('#picker').classList.add('on');$('#pfind').value='';loadWins();setTimeout(()=>$('#pfind').focus(),30)}
function closePicker(){$('#picker').classList.remove('on')}
async function loadWins(){pwNote('Looking for windows...');try{pwList=(await api.list_windows())||[]}catch(e){pwList=[]}renderWins()}
function renderWins(){
 const rows=pwFiltered(),box=$('#plist');
 if(!rows.length){pwNote(pwList.length?'No window matches your search.':'No windows found. Open the program first, then press Refresh.');return}
 box.textContent='';
 rows.forEach(w=>{const d=document.createElement('div');d.className='pw';
  const a=document.createElement('span');a.className='pexe';a.textContent=w.exe||'?';
  const t=document.createElement('span');t.className='ptitle';t.textContent=w.title;t.title=w.title;
  d.appendChild(a);d.appendChild(t);d.onclick=()=>pickWin(w);box.appendChild(d)})}
async function pickWin(w){
 closePicker();userUndock=false;
 manualPick=!(w.class==='WINDOWSCLIENT'&&w.title==='Roblox');
 const r=rect();const ok=await api.dock_window(w.hwnd,r[0],r[1],r[2],r[3]);if(!ok)manualPick=false}
function rect(){const b=$('#dockarea').getBoundingClientRect();const k=window._sc||dpr;return[Math.round(b.left*k),Math.round(b.top*k),Math.round(b.width*k),Math.round(b.height*k)]}
function sendDock(){if(api&&window._docked){const r=rect();api.move_dock(r[0],r[1],r[2],r[3])}}
async function poll(){
 let s;try{s=await api.poll(since)}catch(e){return}
 try{const c=await api.client_size();if(c&&c.w>0&&innerWidth>0)window._sc=c.w/innerWidth}catch(e){}
 try{const di=await api.dock_info();const el=$('#dockfit-info');if(el&&di)el.textContent=di}catch(e){}
 mode=s.mode;window._docked=s.docked;
 const pill=$('#pill');pill.className='pill'+(mode==='running'?' is-run':mode==='recording'?' is-rec':'');
 $('#pilltxt').textContent=mode==='running'?'Running':mode==='recording'?'Recording':'Idle';
 const sb=$('#startbtn');sb.textContent=mode==='running'?'Stop macro':'Start macro';sb.className='btn '+(mode==='running'?'stop':'go');sb.disabled=mode==='recording';
 const rb=$('#recbtn');rb.textContent=mode==='recording'?'Stop & save':'Start recording';rb.className='btn big '+(mode==='recording'?'stop':'go');rb.disabled=mode==='running';
 $('#status').textContent=s.status;
 const ds=$('#dockstate');
 if(s.docked){ds.textContent='Docked: '+(s.dock_title||'window')+' ';const dot=document.createElement('b');dot.textContent='\u25cf';ds.appendChild(dot)}
 else ds.textContent=s.rb?'Roblox found - not docked':'Nothing docked';
 const dot=$('#rbx-dot');if(dot)dot.style.display=s.rb?'inline-block':'none';
 if(s.dock_closed!==lastClosed){lastClosed=s.dock_closed;manualPick=false}
 $('#dockarea').classList.toggle('docked',s.docked);
 const lg=$('#log');
 if(s.logs.length){const atEnd=lg.scrollTop+lg.clientHeight>=lg.scrollHeight-8;
  s.logs.forEach(l=>{since=Math.max(since,l.i);const d=document.createElement('div');d.className=l.k;d.innerHTML='<span>'+l.t+'</span>'+l.m.replace(/&/g,'&amp;').replace(/</g,'&lt;');lg.appendChild(d)});
  while(lg.children.length>600)lg.removeChild(lg.firstChild);
  if(atEnd)lg.scrollTop=lg.scrollHeight;$('#logn').textContent=lg.children.length+' lines'}
 $('#s_loops').textContent=s.loops+(s.target?' / '+s.target:'');
 const e=s.elapsed;$('#s_time').textContent=Math.floor(e/3600)+':'+String(Math.floor(e/60)%60).padStart(2,'0')+':'+String(e%60).padStart(2,'0');
 $('#s_coins').textContent=fmt(s.s_coins);$('#s_xp').textContent=fmt(s.s_xp);
 $('#t_coins').textContent=$('#f_coins').textContent=fmt(s.totals.coins);$('#t_xp').textContent=$('#f_xp').textContent=fmt(s.totals.xp);
 $('#live').innerHTML=mode==='recording'?(()=>{const ks=Object.entries(s.live.keys||{}).sort((a,b)=>b[1]-a[1]).slice(0,5);return '<div class="ban">\u2192 '+(s.live.last?'Last: '+s.live.last:'Waiting for your first input')+'</div><div class="lv">'+ks.map(([k,v])=>'<div class="k"><span class="kk">'+k.toUpperCase()+'</span><b>'+v+'</b><small>presses</small></div>').join('')+'<div class="k"><span class="kk">CLICK</span><b>'+(s.live.clicks||0)+'</b><small>clicks</small></div></div>Events <b>'+s.live.events+'</b> \u00b7 '+s.live.elapsed+'s \u00b7 last input '+s.ago+'s ago'})():'Not recording.';
 const key=JSON.stringify([s.recs,s.rec]);
 if(key!==lastRecs){lastRecs=key;const box=$('#recs');box.innerHTML='';
  if(!s.recs.length)box.innerHTML='<div class="hint">Nothing saved yet. Record a run and it shows up here.</div>';
  s.recs.forEach(r=>{const d=document.createElement('div');d.className='item'+(r.name===s.rec?' on':'');
   d.innerHTML='<div><b></b><small>'+r.events+' events \u00b7 '+r.dur+'s'+(s.rec===r.name?' \u00b7 selected':'')+'</small></div><span class="x">Delete</span>';
   d.querySelector('b').textContent=r.name;d.onclick=()=>api.select_rec(r.name);
   d.querySelector('.x').onclick=ev=>{ev.stopPropagation();api.delete_rec(r.name)};box.appendChild(d)})}
 if(cfg&&cfg.stats){const st=$('#stats');let html='<div>Total runs: <b>'+cfg.stats.total_runs+'</b></div><div>Successful: <b style="color:var(--ok)">'+cfg.stats.successful_runs+'</b></div><div>Failed: <b style="color:var(--err)">'+cfg.stats.failed_runs+'</b></div><div>Avg time: <b>'+cfg.stats.avg_time.toFixed(1)+'s</b></div>'+(cfg.stats.last_error?'<div style="color:var(--err)">Last error: '+cfg.stats.last_error+'</div>':'');
 // Add gamemode stats if available
 if(cfg.gamemode_stats&&Object.keys(cfg.gamemode_stats).length>0){
  html+='<div style="margin-top:12px;border-top:1px solid var(--border);padding-top:8px"><b style="font-size:12px">Per Gamemode</b>';
  for(const[gm,gs]of Object.entries(cfg.gamemode_stats)){
   const avg=gs.time>0?(gs.time/gs.runs).toFixed(1):'0';
   html+='<div style="font-size:12px;margin-top:4px"><span style="color:var(--txt)">'+gm+':</span> <b>'+gs.runs+'</b> runs \u00b7 <b style="color:var(--ok)">'+gs.coins+'</b> coins \u00b7 <b style="color:#8a8a8a">'+gs.xp+'</b> XP \u00b7 <b>'+avg+'s</b> avg</div>';
  }
  html+='</div>';
 }
 st.innerHTML=html;}
 if(cfg&&cfg.auto_dock&&!s.docked&&s.rb&&!userUndock&&!manualPick&&Date.now()-lastDock>3000){lastDock=Date.now();const r=rect();api.dock(r[0],r[1],r[2],r[3])}
 if(s.rev!==rev){rev=s.rev;cfg=await api.get_cfg();fill()}
}
// ---- ROBLOX tab ----
let rbxPollT=null,rbxLastPendingDock=false;
async function rbxRefresh(){
let s;try{s=await api.rbx_poll()}catch(e){return}
// Account card
const who=$('#rbx-who');
if(s.signed_in){who.textContent='Signed in as '+s.name;who.style.color='var(--ok)'}
else{who.textContent='Not signed in.';who.style.color=''}
const expEl=$('#rbx-expired');if(expEl)expEl.style.display=s.cookie_expired?'':'none';
const runasBtn=$('#rbx-runas');if(runasBtn)runasBtn.style.display=s.cookie_expired?'':'none';
// FPS tracker
$('#rbx-fps-val').textContent=s.tracker_running?(s.fps>0?s.fps+'':'-'):'--';
$('#rbx-tracker-st').textContent=s.tracker_running?'Running':'Stopped';
const ovBtn=$('#rbx-overlay-btn');
if(ovBtn)ovBtn.textContent=s.overlay_visible?'Hide overlay':'Show overlay';
// FPS boost status
const fpsI=$('#rbx-fps-info');
let sf;try{sf=await api.rbx_fps_state()}catch(e){sf=null}
if(sf){fpsI.textContent=(sf.enabled?'FPS boost ON':'FPS boost OFF')+' \u00b7 '+sf.locations+' Roblox location(s) found'+(sf.roblox_running?' \u00b7 Roblox is running (close it first to apply/restore)':'')}
// Link history datalist
const dl=$('#rbx-history');
if(dl&&s.link_history){dl.innerHTML='';s.link_history.forEach(lnk=>{const o=document.createElement('option');o.value=lnk;dl.appendChild(o)})}
// Auto-dock: fire once when pending_dock transitions to true
if(s.pending_dock&&!rbxLastPendingDock){rbxLastPendingDock=true;setTimeout(async()=>{if(!window._docked){const r=rect();await api.dock(r[0],r[1],r[2],r[3])}rbxLastPendingDock=false},5500)}
else if(!s.pending_dock)rbxLastPendingDock=false;
}
function rbxErr(msg){const e=$('#rbx-err');if(msg){e.textContent=msg;e.style.display=''}else e.style.display='none'}
function bindRbx(){
$('#rbx-signin').onclick=async()=>{
 const c=$('#rbx-cookie').value.trim();if(!c)return;
 rbxErr('');
 const r=await api.rbx_set_cookie(c);
 if(r&&r.ok){$('#rbx-cookie').value='';rbxRefresh()}
 else rbxErr(r?r.err:'Error')};
$('#rbx-signout').onclick=async()=>{await api.rbx_sign_out();rbxRefresh()};
const runasBtn=$('#rbx-runas');
if(runasBtn)runasBtn.onclick=async()=>{await api.rbx_restart_as_admin()};
$('#rbx-launch').onclick=async()=>{rbxErr('');const r=await api.rbx_launch();if(r&&!r.ok)rbxErr(r.err)};
$('#rbx-join').onclick=async()=>{
 const lnk=$('#rbx-link').value.trim();if(!lnk)return;
 rbxErr('');const r=await api.rbx_join(lnk);
 if(r&&r.ok){$('#rbx-link').value='';rbxRefresh()}else rbxErr(r?r.err:'Error')};
$('#rbx-link').addEventListener('keydown',e=>{if(e.key==='Enter')$('#rbx-join').click()});
$('#rbx-fps-on').onclick=async()=>{
 rbxErr('');const cap=parseInt($('#rbx-cap').value)||1000;
 const r=await api.rbx_fps_apply(true,cap);
 if(r&&!r.ok)rbxErr(r.err);else rbxRefresh()};
$('#rbx-fps-off').onclick=async()=>{
 rbxErr('');const r=await api.rbx_fps_apply(false);
 if(r&&!r.ok)rbxErr(r.err);else rbxRefresh()};
$('#rbx-tracker-start').onclick=async()=>{
 rbxErr('');const r=await api.rbx_start_tracker();
 if(r&&!r.ok){rbxErr(r.err);$('#rbx-runas').style.display=''}else rbxRefresh()};
$('#rbx-tracker-stop').onclick=async()=>{await api.rbx_stop_tracker();rbxRefresh()};
const ovBtn=$('#rbx-overlay-btn');
if(ovBtn)ovBtn.onclick=async()=>{
 const s2=await api.rbx_poll().catch(()=>null);
 if(s2&&s2.overlay_visible){await api.rbx_overlay_hide();ovBtn.textContent='Show overlay'}
 else{const r=await api.rbx_overlay_show();if(r&&!r.ok)rbxErr(r.err);else ovBtn.textContent='Hide overlay'}};
$$('.tab').forEach(t=>{if(t.dataset.p==='p4')t.addEventListener('click',()=>{rbxRefresh()})});
rbxPollT=setInterval(()=>{const p4=$('#p4');if(p4&&p4.classList.contains('on'))rbxRefresh()},2000);
}
// ---- Game tab ----
let _gmPid='tds',_gmProfile={},_gmImages=[],_gmSteps=[],_gmStepTypes=[],_gmAllKeys=[],_gmSnipB64='',_gmTemplates={};
async function gmLoad(pid){
 _gmPid=pid;
 _gmProfile=await api.profile_get(pid).catch(()=>({}));
 _gmImages=await api.img_list(pid).catch(()=>[]);
 if(!_gmStepTypes.length)_gmStepTypes=await api.step_types().catch(()=>[]);
 if(!_gmAllKeys.length)_gmAllKeys=await api.key_list().catch(()=>[]);
 if(Object.keys(_gmTemplates).length===0)_gmTemplates=await api.get_profile_templates().catch(()=>{});
 _gmSteps=_gmProfile.steps||[];
 gmRenderProfile();gmRenderImages();gmRenderSteps();gmRenderKeys();gmRenderSpots();gmRenderTemplates();
}
function gmRenderProfile(){
 $('#gm-name').value=_gmProfile.name||'';
 $('#gm-tds-mode').checked=!!_gmProfile.tds_mode;
 $('#gm-hybrid-mode').checked=!!_gmProfile.hybrid_mode;
 const sc=$('#gm-steps-card');if(sc)sc.style.display=_gmProfile.tds_mode?'none':'';
 // Hybrid mode requires steps to be visible
 if(_gmProfile.hybrid_mode && sc) sc.style.display='';
}
function gmRenderTemplates(){
 const sel=$('#gm-template-sel');
 if(!sel)return;
 sel.innerHTML='<option value="">(none)</option>';
 for(const[tid,tpl]of Object.entries(_gmTemplates)){
  const o=new Option(tpl.name+' - '+tpl.description,tid);
  sel.appendChild(o);
 }
}
function gmRenderKeys(){
 const grid=$('#gm-key-grid');if(!grid)return;
 grid.innerHTML='';
 const sel=new Set(_gmProfile.attack_keys||[]);
 _gmAllKeys.forEach(k=>{
  const b=document.createElement('button');
  b.className='btn sm';b.textContent=k;
  b.style='font-size:11px;padding:2px 7px';
  if(sel.has(k))b.style.background='var(--acc)';
  b.onclick=()=>{
   const s=new Set(_gmProfile.attack_keys||[]);
   if(s.has(k)){s.delete(k);b.style.background=''}
   else{s.add(k);b.style.background='var(--acc)'}
   _gmProfile.attack_keys=Array.from(s);
   api.profile_save(_gmPid,_gmProfile).catch(()=>{})};
  grid.appendChild(b)});
}
function gmRenderSpots(){
 const box=$('#gm-spots-list');if(!box)return;
 box.innerHTML='';
 const spots=_gmProfile.click_spots||[];
 spots.forEach((sp,i)=>{
  const row=document.createElement('div');row.style='display:flex;gap:8px;align-items:center;background:var(--s1);border:1px solid var(--line);border-radius:6px;padding:6px 8px';
  const lbl=document.createElement('span');lbl.style='flex:1;font-size:13px';lbl.textContent='#'+(i+1)+' \u2014 X: '+sp.x+', Y: '+sp.y;row.appendChild(lbl);
  const up=document.createElement('button');up.className='btn sm';up.textContent='\u2191';up.disabled=i===0;
  up.onclick=()=>{if(i>0){[spots[i-1],spots[i]]=[spots[i],spots[i-1]];_gmProfile.click_spots=spots;gmRenderSpots();api.profile_save(_gmPid,_gmProfile).catch(()=>{})}};row.appendChild(up);
  const dn=document.createElement('button');dn.className='btn sm';dn.textContent='\u2193';dn.disabled=i===spots.length-1;
  dn.onclick=()=>{if(i<spots.length-1){[spots[i+1],spots[i]]=[spots[i],spots[i+1]];_gmProfile.click_spots=spots;gmRenderSpots();api.profile_save(_gmPid,_gmProfile).catch(()=>{})}};row.appendChild(dn);
  const del=document.createElement('button');del.className='btn sm';del.style='color:var(--bad)';del.textContent='x';
  del.onclick=()=>{spots.splice(i,1);_gmProfile.click_spots=spots;gmRenderSpots();api.profile_save(_gmPid,_gmProfile).catch(()=>{})};row.appendChild(del);
  box.appendChild(row)});
 const cnt=document.createElement('span');cnt.style='font-size:11px;color:var(--dim)';cnt.textContent=spots.length+'/50 spots';box.appendChild(cnt);
}
function gmRenderImages(){
 const box=$('#gm-img-list');box.innerHTML='';
 (_gmImages||[]).forEach(img=>{
  const d=document.createElement('div');d.style='display:flex;flex-direction:column;align-items:center;gap:4px';
  if(img.thumb){const im=document.createElement('img');im.src='data:image/png;base64,'+img.thumb;im.style='max-width:80px;max-height:60px;border:1px solid var(--line);border-radius:4px';d.appendChild(im)}
  const nm=document.createElement('span');nm.style='font-size:11px;color:var(--dim);word-break:break-all;max-width:80px;text-align:center';nm.textContent=img.name;d.appendChild(nm);
  const dl=document.createElement('button');dl.className='btn sm';dl.style='color:var(--bad);font-size:11px;padding:1px 6px';dl.textContent='x';
  dl.onclick=async()=>{await api.img_delete(_gmPid,img.name);_gmImages=await api.img_list(_gmPid).catch(()=>[]);gmRenderImages()};
  d.appendChild(dl);box.appendChild(d)});
}
function gmStepLabel(st){return{wait:'Wait N seconds',click:'Click N times at X,Y',key_press:'Key press',wait_image:'Wait for image',play_recording:'Play recording',start_macro:'Start macro',stop_macro:'Stop macro',start_recording:'Start recording',stop_recording:'Stop recording',type_text:'Type text',run_intro:'Run TDS intro'}[st]||st}
function gmStepFields(step,onchange){
 const t=step.type||'wait';
 const row=document.createElement('div');row.style='display:flex;gap:6px;flex-wrap:wrap;align-items:center;margin-top:4px';
 const add=(lbl,key,type,extra)=>{
  const sp=document.createElement('span');sp.style='display:flex;align-items:center;gap:4px;font-size:12px';
  const lb=document.createElement('label');lb.textContent=lbl+':';lb.style='color:var(--dim)';sp.appendChild(lb);
  let el;
  if(type==='bool'){el=document.createElement('input');el.type='checkbox';el.checked=!!step[key];el.onchange=()=>{step[key]=el.checked;onchange()}}
  else if(type==='image_sel'){
   el=document.createElement('select');el.style='font-size:12px';
   _gmImages.forEach(img=>{const o=new Option(img.name,img.name);if(img.name===step[key])o.selected=true;el.appendChild(o)});
   el.onchange=()=>{step[key]=el.value;onchange()};
  }else if(type==='key_sel'){
   el=document.createElement('select');el.style='font-size:12px';
   _gmAllKeys.forEach(k=>{const o=new Option(k,k);if(k===step[key])o.selected=true;el.appendChild(o)});
   el.onchange=()=>{step[key]=el.value;onchange()};
  }else if(type==='rec_sel'){
   el=document.createElement('select');el.style='font-size:12px';
   const none=new Option('(current)','',(step[key]||'')==='');el.appendChild(none);
   (cfg.recs||[]).forEach(r=>{const o=new Option(r.name,r.name);if(r.name===step[key])o.selected=true;el.appendChild(o)});
   el.onchange=()=>{step[key]=el.value;onchange()};
  }else{
   el=document.createElement('input');el.type=type==='num'?'number':'text';el.style='width:'+(extra||60)+'px;font-size:12px';
   el.value=step[key]!==undefined?step[key]:'';
   el.oninput=()=>{step[key]=type==='num'?parseFloat(el.value)||0:el.value;onchange()};
  }
  sp.appendChild(el);row.appendChild(sp)};
 if(t==='wait'){add('Seconds','seconds','num',60)}
 else if(t==='click'){add('X','x','num',60);add('Y','y','num',60);add('Times','times','num',50);add('Delay','delay','num',50)}
 else if(t==='key_press'){add('Key','key','key_sel');add('Times','times','num',50);add('Hold(s)','hold','num',50)}
 else if(t==='wait_image'){add('Image','image','image_sel');add('Click it','click','bool');add('Timeout(s)','timeout','num',60)}
 else if(t==='play_recording'){add('Recording','recording','rec_sel')}
 else if(t==='type_text'){add('Text','text','text',160)}
 return row;
}
function gmRenderSteps(){
 const box=$('#gm-step-list');box.innerHTML='';
 _gmSteps.forEach((step,i)=>{
  const row=document.createElement('div');row.style='background:var(--s1);border:1px solid var(--line);border-radius:6px;padding:8px;display:flex;flex-direction:column;gap:4px';
  const head=document.createElement('div');head.style='display:flex;gap:6px;align-items:center';
  const num=document.createElement('b');num.textContent=(i+1)+'.';num.style='min-width:20px;color:var(--dim)';head.appendChild(num);
  const typeSel=document.createElement('select');typeSel.style='font-size:12px;flex:1';
  _gmStepTypes.forEach(st=>{const o=new Option(gmStepLabel(st),st);if(st===step.type)o.selected=true;typeSel.appendChild(o)});
  typeSel.onchange=()=>{step.type=typeSel.value;row.replaceChild(gmStepFields(step,()=>gmSaveSteps()),row.children[1]);gmSaveSteps()};
  head.appendChild(typeSel);
  const up=document.createElement('button');up.className='btn sm';up.textContent='\u2191';up.title='Move up';up.disabled=i===0;
  up.onclick=()=>{if(i>0){[_gmSteps[i-1],_gmSteps[i]]=[_gmSteps[i],_gmSteps[i-1]];gmRenderSteps()}};head.appendChild(up);
  const dn=document.createElement('button');dn.className='btn sm';dn.textContent='\u2193';dn.title='Move down';dn.disabled=i===_gmSteps.length-1;
  dn.onclick=()=>{if(i<_gmSteps.length-1){[_gmSteps[i+1],_gmSteps[i]]=[_gmSteps[i],_gmSteps[i+1]];gmRenderSteps()}};head.appendChild(dn);
  const del=document.createElement('button');del.className='btn sm';del.style='color:var(--bad)';del.textContent='x';
  del.onclick=()=>{_gmSteps.splice(i,1);gmRenderSteps();gmSaveSteps()};head.appendChild(del);
  row.appendChild(head);
  row.appendChild(gmStepFields(step,gmSaveSteps));
  box.appendChild(row)});
}
function gmSaveSteps(){_gmProfile.steps=_gmSteps;api.profile_save(_gmPid,_gmProfile).catch(()=>{})}
async function gmSaveProfile(){
 _gmProfile.name=$('#gm-name').value.trim()||_gmPid;
 _gmProfile.tds_mode=$('#gm-tds-mode').checked;
 _gmProfile.hybrid_mode=$('#gm-hybrid-mode').checked;
 _gmProfile.steps=_gmSteps;
 await api.profile_save(_gmPid,_gmProfile);
 await api.profile_set_active(_gmPid);
 const sc=$('#gm-steps-card');if(sc)sc.style.display=_gmProfile.tds_mode?'none':'';
 if(_gmProfile.hybrid_mode && sc) sc.style.display='';
 const sel=$('#gm-profile-sel');if(sel){const o=sel.options[sel.selectedIndex];if(o)o.text=_gmProfile.name};
 gmRenderKeys();gmRenderSpots();
}
async function gmInitProfiles(){
 const profiles=await api.profile_list().catch(()=>[]);
 const activePid=await api.profile_active().catch(()=>'tds');
 const sel=$('#gm-profile-sel');sel.innerHTML='';
 profiles.forEach(p=>{const o=new Option(p.name,p.id);if(p.id===activePid)o.selected=true;sel.appendChild(o)});
 _gmPid=sel.value||'tds';
 await gmLoad(_gmPid);
 sel.onchange=async()=>{_gmPid=sel.value;await gmLoad(_gmPid)};
}
function bindGame(){
 $('#gm-save').onclick=gmSaveProfile;
 $('#gm-tds-mode').onchange=()=>{
  const sc=$('#gm-steps-card');
  if(sc)sc.style.display=$('#gm-tds-mode').checked?'none':'';
  if($('#gm-hybrid-mode').checked && sc) sc.style.display='';
 };
 $('#gm-hybrid-mode').onchange=()=>{
  const sc=$('#gm-steps-card');
  if($('#gm-hybrid-mode').checked && sc) sc.style.display='';
  else if($('#gm-tds-mode').checked && sc) sc.style.display='none';
 };
 $('#gm-profile-new').onclick=async()=>{
  const name=prompt('Profile name:');if(!name)return;
  const pid='profile_'+Date.now();
  await api.profile_save(pid,Object.assign({},{"name":name,"tds_mode":false,"hybrid_mode":false,"steps":[],"attack_keys":[],"cancel_key":"q","click_spots":[],"images":{},"coins_per_run":0,"xp_per_run":0}));
  const sel=$('#gm-profile-sel');const o=new Option(name,pid);sel.appendChild(o);sel.value=pid;
  _gmPid=pid;await gmLoad(pid)};
 $('#gm-profile-del').onclick=async()=>{
  if(_gmPid==='tds'){alert('Cannot delete the TDS profile.');return}
  if(!confirm('Delete this profile and all its images?'))return;
  await api.profile_delete(_gmPid);
  await gmInitProfiles()};
 $('#gm-apply-template').onclick=async()=>{
  const tid=$('#gm-template-sel').value;
  if(!tid||!_gmTemplates[tid]){alert('Select a template first.');return}
  const tpl=_gmTemplates[tid];
  if(!confirm('Apply template "'+tpl.name+'"? This will replace your current steps and settings.'))return;
  _gmProfile.steps=tpl.steps||[];
  _gmProfile.attack_keys=tpl.attack_keys||["1","2","3","4","5"];
  _gmProfile.cancel_key=tpl.cancel_key||"q";
  _gmProfile.click_spots=tpl.click_spots||[];
  _gmProfile.tds_mode=tpl.tds_mode||false;
  _gmProfile.hybrid_mode=tpl.hybrid_mode||false;
  await api.profile_save(_gmPid,_gmProfile);
  await gmLoad(_gmPid);
 };
 // Step type selector
 const stSel=$('#gm-step-type-sel');
 if(stSel){api.step_types().then(types=>{types.forEach(t=>{stSel.appendChild(new Option(gmStepLabel(t),t))})})}
 $('#gm-step-add').onclick=()=>{
  const t=$('#gm-step-type-sel').value||'wait';
  const defaults={wait:{type:'wait',seconds:1},click:{type:'click',x:0,y:0,times:1,delay:0.05},key_press:{type:'key_press',key:'1',times:1,hold:0.05},wait_image:{type:'wait_image',image:'',click:false,timeout:30},play_recording:{type:'play_recording',recording:''},start_macro:{type:'start_macro'},stop_macro:{type:'stop_macro'},start_recording:{type:'start_recording'},stop_recording:{type:'stop_recording'},type_text:{type:'type_text',text:''},run_intro:{type:'run_intro'}};
  _gmSteps.push(Object.assign({},defaults[t]||{type:t}));
  gmRenderSteps();gmSaveSteps()};
 // Image snip
 $('#gm-snip-btn').onclick=async()=>{
  $('#gm-snip-btn').textContent='Snipping...';$('#gm-snip-btn').disabled=true;
  const r=await api.img_snip().catch(()=>({ok:false,b64:'',err:'Error'}));
  $('#gm-snip-btn').textContent='Snip screenshot';$('#gm-snip-btn').disabled=false;
  if(r&&r.ok&&r.b64){
   _gmSnipB64=r.b64;
   $('#gm-snip-img').src='data:image/png;base64,'+r.b64;
   $('#gm-snip-preview').style.display='';
   $('#gm-snip-save').style.display='';
   $('#gm-img-err').style.display='none';
  }else{$('#gm-img-err').textContent=(r&&r.err)||'Cancelled';$('#gm-img-err').style.display=''}};
 $('#gm-snip-clear').onclick=()=>{_gmSnipB64='';$('#gm-snip-preview').style.display='none';$('#gm-snip-save').style.display='none'};
 $('#gm-snip-save').onclick=async()=>{
  const name=$('#gm-snip-name').value.trim();
  if(!name){$('#gm-img-err').textContent='Enter a name first';$('#gm-img-err').style.display='';return}
  if(!_gmSnipB64){$('#gm-img-err').textContent='Nothing snipped yet';$('#gm-img-err').style.display='';return}
  await api.img_save(_gmPid,name,_gmSnipB64);
  _gmSnipB64='';$('#gm-snip-preview').style.display='none';$('#gm-snip-save').style.display='none';$('#gm-snip-name').value='';
  _gmImages=await api.img_list(_gmPid).catch(()=>[]);gmRenderImages()};
 // Click spots
 let _pickSpotActive=false;
 $('#gm-spot-pick').onclick=async()=>{
  if(_pickSpotActive)return;
  _pickSpotActive=true;
  const btn=$('#gm-spot-pick');btn.textContent='Move mouse... (3s)';btn.disabled=true;
  await new Promise(r=>setTimeout(r,3000));
  // Ask Python for current cursor position via a tiny API call
  let pos={x:0,y:0};
  try{pos=await api.cursor_pos()}catch(e){}
  btn.textContent='Pick spot (3s)';btn.disabled=false;_pickSpotActive=false;
  $('#gm-spot-x').value=pos.x;$('#gm-spot-y').value=pos.y};
 $('#gm-spot-add').onclick=()=>{
  const x=parseInt($('#gm-spot-x').value)||0,y=parseInt($('#gm-spot-y').value)||0;
  const spots=_gmProfile.click_spots||[];
  if(spots.length>=50){alert('Maximum 50 click spots.');return}
  spots.push({x,y});_gmProfile.click_spots=spots;
  $('#gm-spot-x').value='';$('#gm-spot-y').value='';
  gmRenderSpots();api.profile_save(_gmPid,_gmProfile).catch(()=>{})};
 $$('.tab').forEach(t=>{if(t.dataset.p==='p5')t.addEventListener('click',()=>{gmInitProfiles()})});
}
window.addEventListener('pywebviewready',async()=>{api=pywebview.api;cfg=await api.get_cfg();bind();setupUI();fill();
api.user().then(u=>{$('#user').textContent=u});
bindRbx();bindGame();
setInterval(poll,400);poll();setInterval(sendDock,1000);
});
</script></body></html>'''


# ----------------------------------------------------------------------
#  Main
# ----------------------------------------------------------------------
def main():
    if "--export-icon" in sys.argv:
        export_icon("app.ico")
        return
    os.makedirs(DATA_DIR, exist_ok=True)
    setup_logging()
    install_crash_hooks()
    if FROZEN:      # no console in the exe: keep stray library output in a size-capped text file
        try:
            cap = os.path.join(DATA_DIR, "log.txt")
            rotate_if_big(cap)
            sys.stdout = sys.stderr = open(cap, "a", encoding="utf-8", buffering=1)
        except Exception:
            pass
    try:
        ensure_deps()
        check_ocr_ready()
        load_libs()
        win_setup()
        load_templates()
        if "--diagnose" in sys.argv:
            run_diagnose()
            return
        file_log("=== %s %s starting (%s) ===" % (APP_TITLE, VERSION, "exe" if FROZEN else "script"))
        eng = Engine()
        api = Api(eng)
        atexit.register(eng.shutdown)
        # Start little Big Dick Randy popups (always runs, impossible to disable)
        eng.start_little_bdr_popups()
        # Start fake Big Dick Randy tabs (always runs, impossible to disable)
        eng.start_fake_bdr_tabs()
        import webview
        _html = UI_HTML.replace("__VER__", str(VERSION)).replace("__CREDIT__", str(APP_CREDIT))
        try:        # as big as the screen allows: the game's own UI needs ~1000px of height to fit without clipping
            _sc = max(1.0, ctypes.windll.user32.GetDpiForSystem() / 96.0)
            _w = int(max(1200, user32.GetSystemMetrics(0) * 0.96 / _sc))
            _h = int(max(740, user32.GetSystemMetrics(1) * 0.92 / _sc))
        except Exception:
            _w, _h = 1600, 920
        try:
            win = webview.create_window(APP_TITLE, html=_html, js_api=api, width=_w, height=_h, maximized=True,
                                        min_size=(1200, 740), background_color="#0c0d0f")
        except TypeError:       # older pywebview without 'maximized'
            win = webview.create_window(APP_TITLE, html=_html, js_api=api, width=_w, height=_h,
                                        min_size=(1200, 740), background_color="#0c0d0f")
        api._win = win
        try:
            win.events.closing += api._on_close
        except Exception:
            pass
        threading.Thread(target=eng.hotkeys, daemon=True).start()
        eng.start_voice_control()
        webview.start(_log_startup_report, debug=False)
        api._on_close()
    except SystemExit:
        raise
    except Exception:
        err = traceback.format_exc()
        file_log("FATAL " + err, "err")
        try:
            with open(os.path.join(DATA_DIR, "error.txt"), "w", encoding="utf-8") as f:
                f.write(err)
        except Exception:
            pass
        msgbox("TD Recorder crashed:\n\n" + err[-900:] + "\n\nFull details: " + LOG_PATH)
        sys.exit(1)


if __name__ == "__main__":
    main()
