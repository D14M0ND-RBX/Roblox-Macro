# Diamond-Macro  `v1.66 · Beta`

A Windows macro recorder/player for Roblox tower defense.
<!-- GitHub auto-push enabled --> Record a run **once**, then let it replay forever. It handles the lobby intro, the replay, the Play Again click and the next game on its own, and it logs the coins and XP you earn.

## What's New in v1.50

### 🥚 Randy Easter Eggs
- **Hidden Randy icons** - Tiny Randy appears randomly on screen
- **Random positioning** - Appears anywhere on screen every 5-15 minutes
- **Stays briefly** - Shows for 5-10 seconds then disappears
- **No interaction** - Just visual, doesn't interfere with macro
- **Log message** - "Randy easter egg appeared - did you see it?"
- **Settings:** randy_easter_eggs
- **Thread:** randy_easter_eggs_thread (daemon)

### 🔌 Plugin System (Future)
- **Modular architecture** - Enable plugin system for extensibility
- **Custom plugins** - Load plugins from custom directories
- **Settings:** plugin_system_enabled, plugins, plugin_directories
- **Status:** Settings added, implementation pending massive UI overhaul

### 📊 Recording Comparison (Future)
- **Compare recordings** - Diff two recordings side-by-side
- **Visual diff** - Show timing and click differences
- **Settings:** recording_comparison_enabled, recording_comparison_mode
- **Status:** Settings added, implementation pending UI overhaul

### 🎯 Quick Actions Bar (Future)
- **Toolbar** - Common actions in window header
- **Settings:** quick_actions_bar
- **Status:** Setting added, implementation pending UI redesign

### 📈 Per-Recording Stats (Future)
- **Per-recording tracking** - Success rate per recording
- **Data structure ready** - recording_stats in config
- **Status:** Data structure ready, UI pending

### 🧠 Smart Retry Logic
- **Learns from failures** - Tracks failures per placement spot
- **Failure database** - Stores failure count and last strategy used
- **Adaptive strategies:**
  - 1st failure: Log it
  - 2nd failure: Try longer settle time (1.5x)
  - 3rd+ failures: Try aggressive nudge (10px in appropriate direction)
- **Persistent tracking** - Saved to config
- **Settings:** smart_retry, failure_database (data)
- **Integrated into** verify_placement logic

### 🏷️ Recording Tags
- **Tag recordings** - Organize recordings by map, gamemode, or custom tags
- **Filter by tags** - Quickly find recordings for specific maps
- **API support** - Full API for managing tags (get, set, list all, filter)
- **Per-recording tags** - Each recording can have multiple tags
- **All tags view** - See all unique tags across recordings
- **Find by tag** - Get all recordings with a specific tag
- **Settings:** recording_tags_enabled, recording_tags (data structure)
- **API methods:** get_recording_tags, set_recording_tags, get_all_tags, get_recordings_by_tag

### 🔊 Randy Voice Lines (TTS)
- **Randy speaks** - Uses Windows TTS to speak when Randy appears
- **Random lines** - Various creepy/funny voice lines
- **Configurable chance** - 50% chance to speak by default
- **Requires pyttsx3** - Uses Python text-to-speech library
- **Settings:** randy_voice_lines, randy_voice_chance
- **Added to requirements:** pyttsx3>=2.90

### 💬 Randy Advice Generator
- **Terrible advice** - Randy gives obviously bad advice
- **Hilarious lines** - "Just click faster bro", "Put the tower in the enemy spawn"
- **Manual trigger** - "Get Randy Advice" button in Settings
- **20 different lines** - Randomly selected each time
- **Settings:** randy_advice_generator
- **API method:** get_randy_advice

### ⚡ Advanced Features
- **Quick actions bar** - Toolbar with common actions (toggleable)
- **Smart retry** - Learn from past failures (toggleable)
- **Randy easter eggs** - Hidden Randy icons in UI (toggleable)
- **Per-recording stats** - Track success rate per recording (data structure ready)
- **Settings:** quick_actions_bar, smart_retry, randy_easter_eggs, recording_stats, failure_database

### 🧠 Gemini Game Adaptation
- **AI-powered game research** - When you create a profile named after a game, Gemini researches it
- **UI color detection** - Gemini provides button colors, health bar colors, important UI element colors
- **Timing advice** - Suggested delays, animation durations, transition times
- **Detection tips** - Game-specific advice for detecting UI elements
- **JSON format** - Returns structured data that can be used to auto-configure settings
- **Auto-query on switch** - Automatically asks Gemini when you switch profiles (optional)
- **Saves to file** - Advice saved to `%APPDATA%\Diamond-Macro\game_adaptation_[gamename].json`
- **Works with any game** - Not just Tower Defense Simulator - can adapt to Black Myth Wukong, Elden Ring, etc.
- **Settings:** gemini_game_adaptation, gemini_game_adaptation_on_profile_switch
- **Requires:** Gemini API key (same as advisor feature)

### 🔄 Auto Update System
- **Check for updates from GitHub** - Automatically checks your repo for new versions
- **Version comparison** - Compares local version with GitHub README
- **Auto-rebuild EXE** - Option to automatically rebuild EXE after updating source (takes 1-2 minutes)
- **Auto-restart** - Macro restarts after update installation
- **Config backup** - Automatically backs up config before updating
- **Downloads core files** - Updates Diamond-Macro.bat, README.md, UPDATE.LOG, requirements.txt
- **Configurable interval** - Set how often to check (0 = every time, 1-168 hours)
- **Auto-install option** - Can automatically install without asking (optional)
- **Safe rollback** - If update fails, keeps working version
- **UI section** - New "Auto Update" card in Settings
- **Settings:** auto_update_enabled, auto_update_check_on_start, auto_update_check_interval, auto_update_auto_install, auto_update_rebuild_exe, github_repo_url

### 🔍 Preflight System
- **Validate before starting** - Checks everything before macro begins
- **Required images check** - Ensures all 9 Tower Defense Simulator images exist
- **Profile structure validation** - Verifies active profile is valid and not corrupted
- **Recording verification** - Confirms selected recording exists (for custom mode)
- **Roblox window check** - Ensures Roblox is accessible
- **Resolution warning** - Warns if resolution is below recommended (1920x1080)
- **Auto-run on start** - Option to automatically run preflight when macro starts
- **Blocks bad starts** - Won't start macro if critical issues found
- **Detailed reporting** - Lists all issues and warnings in log
- **UI toggle** - "Preflight check" and "Preflight on start" in settings

### 🐛 Detection Diagnostics Mode
- **Debugging aid** - Shows why detections succeed or fail
- **Confidence scores** - Displays match scores for each detection
- **Accept/reject reasons** - Explains why a detection was accepted or rejected
- **Rate-limited output** - Max 1 diagnostic message per second to avoid log spam
- **Template name tracking** - Shows which template was being matched
- **Helps troubleshooting** - Easy to understand why macro clicked (or didn't click)
- **UI toggle** - "Diagnostics mode" checkbox in new Preflight & Diagnostics section
- **Additional toggles** - "Show confidence" and "Show reason" for granular control

### ↩️ One-Click Rollback
- **Config snapshots** - Automatically saves config snapshots
- **Keep last N snapshots** - Configurable (default: 5, max: 20)
- **Timestamped snapshots** - `config_snapshot_YYYYMMDD_HHMMSS.json`
- **Auto-cleanup** - Removes old snapshots beyond limit
- **Restore via API** - Can restore from any snapshot
- **Backup before restore** - Creates backup before restoring (safety net)
- **List snapshots** - View all available snapshots
- **Safe recovery** - If update breaks something, one click to go back
- **UI toggle** - "Rollback enabled" and "Rollback snapshots" in settings

### 👁️ Randy Fake Awareness
- **Reacts to macro events** - Randy comments when you start/stop recording
- **Profile switch reactions** - Randy notices when you change profiles
- **Macro start/stop** - Randy watches you begin and end sessions
- **30% reaction chance** - Randy speaks when events happen
- **Surveillance theme** - "Randy sees you recording. He'll remember this."
- **UI toggle** - "Fake awareness" checkbox in Randy settings

### 📁 Randy's Case File
- **Cursed lore entries** - 10 progressively horrifying case file entries
- **Progress-based unlocks** - Each Randy sighting adds progress (0-100)
- **Horror escalation** - Entries get worse as you progress
- **Final entry reveals** - "CASE CLOSED. Subject has been integrated."
- **Permanent tracking** - Progress saved in config
- **UI toggle** - "Case file" checkbox in Randy settings

### 🖥️ Randy Fake Takeover ("Hacks Your PC")
- **Overlay name change** - Window title changes to "BIG DICK RANDY'S MACRO"
- **Profile hijack** - Profile changes to "randy_profile"
- **Resolution override** - Randy claims 1920x1080 is his preferred resolution
- **Scale matching** - "Scale override: MATCHING MACRO (Randy sees everything)"
- **Theatrical restoration** - After 3 seconds, Randy "generously" restores your settings
- **10% trigger chance** - Only on ultra-rare Randy appearances
- **Purely cosmetic** - Doesn't actually change files, just logs it
- **UI toggle** - "Fake takeover" checkbox in Randy settings

### 📸 Randy Sightings
- **Capture Randy appearances** - Screenshots of Randy's overlay saved
- **Timestamped files** - `randy_sighting_YYYYMMDD_HHMMSS.png`
- **Auto-cleanup** - Keeps only last 10 sightings
- **Save location** - `%APPDATA%\Diamond-Macro\randy_sightings\`
- **Counter display** - "Total: X" in log
- **UI toggle** - "Randy sightings" checkbox in Randy settings

### 💎 Diamond Legacy (Secret Feature)
- **Hidden progression system** - Unlocks automatically at certain milestones
- **Tier-based rewards** - 5 tiers of increasing prestige
- **Mysterious messages** - The Diamond whispers to you
- **No settings needed** - Works silently in the background
- **Permanent tracking** - Your legacy is remembered forever
- *Keep playing to discover more...*

### 💾 Auto Backup System
- **Daily automatic backups** - Backs up config and profiles every 24 hours
- **Background thread** - Runs independently without blocking macro operation
- **Configurable interval** - Set backup frequency (1-168 hours)
- **Auto-cleanup** - Keeps backups for 7 days by default (configurable)
- **Zip format** - Compresses backups to save space
- **Includes all data** - Config, profiles, and custom images
- **Backup location** - Saved to `%APPDATA%\Diamond-Macro\backups\`
- **Proper shutdown** - Thread stops cleanly when macro closes

### 💀 Randy Stat Reactions - Enhanced
- **After-run comments** - Randy reacts to your stats after each game completes
- **Special milestones** - 69 coins, 420 XP, 50 runs, 100 runs
- **Wealth observations** - Comments on coin hoarding and XP accumulation
- **Surveillance theme** - Randy monitors your progress
- **30% comment chance** - Randy speaks when conditions are met
- **UI toggle** - New "Stat reactions" checkbox in Randy settings
- **Separate from fake tabs** - Works independently from other Randy features

## What's New in v1.45

### 💀 Randy System Overhaul
- **Rarity system** - Common (70%), Rare (25%), Ultra-Rare (5%) tiers with different effects
- **Common** - Normal popup size, normal duration
- **Rare** - 1.5x size, 1.5x duration, gold glow effect
- **Ultra-Rare** - 2x size, 2x duration, red glow effect, unique sound
- **Evidence board** - Captures screenshots of Randy sightings (max 20 stored)
- **Lore unlocks** - Progressive case file entries based on sightings (10 entries total)
- **Incident reports** - Fake dashboard messages like "SUBJECT HAS ENTERED THE SETTINGS MENU"
- **Mahoraga counter** - Tracks adaptations before Randy interrupts the streak
- **Gemini changelog** - Uses Gemini 2.5 Flash to approve/reject features (real AI decisions!)
- **Fake changelog** - Also shows fake Randy approvals alongside real ones
- **Idle detector** - Fake creepy messages when macro is idle
- **New UI section** - "Big Dick Randy 💀" card in Settings with all new toggles
- **All settings configurable** - Toggle each feature on/off independently

## What's New in v1.44

### ⚡ 2x Speed Mode
- **New setting: 2x speed mode** - Clicks arrow button then 2x button during recording
- **Automatic detection** - Searches for arrow button every 0.05 seconds
- **Only during recording** - Does not affect intro or other phases
- **Setting location** - Performance section in Settings panel
- **Requires template images** - Users need to add `speed_arrow.png` and `speed_2x.png` to images folder
- **Smart fallback** - If buttons not found, continues without 2x (logs warning)
- **Setting:** `time_scale_2x` - Toggle to enable/disable

## What's New in v1.43

### ⚙️ Lag Compensation Setting Added to UI
- **Added to Settings panel** - Lag compensation now visible in Performance section
- **Checkbox to enable/disable** - Easy toggle in settings
- **Multiplier display** - Shows current lag multiplier (read-only)
- **Fixed accessibility** - Setting was in code but not in UI before
- **Defaults to False** - Off by default to avoid unintended delays

## What's New in v1.42

### 🔒 Roblox Unfocusable When Docked
- **WS_EX_NOACTIVATE added** - Roblox window won't steal focus when docked
- **Prevents AVG/popups interference** - Roblox won't grab focus from macro during AFK
- **Macro remains focusable** - Can still click away from macro window
- **Only when docked** - Applies only when Roblox is docked to macro panel
- **No setting needed** - Built-in behavior for docked windows

### 🐛 Lag Compensation Fix
- **Fixed default value bug** - Code was defaulting to True instead of False
- **Now defaults to False** - Lag compensation is off by default
- **Setting:** `lag_compensation` - Now properly respects False default
- **Multiplier behavior** - Only applies if setting is explicitly True

## What's New in v1.41

### 🔒 Always on Top Window
- **Macro window stays on top** - Prevents AVG or other popups from stealing focus while AFK
- **Still clickable** - You can still unfocus by clicking other windows (mouse + click)
- **AFK protection** - Random notifications won't break the macro when you're away
- **Setting:** Built-in behavior (no setting needed)

## What's New in v1.40

### 💀 Fake Big Dick Randy Achievement Tabs
- **Fake achievement popups** - Randy sends fake achievement notifications
- **Random timing** - Appears every 900-5400 seconds (15-90 minutes)
- **Max 5 tabs** - Limits to 5 fake tabs at once
- **Stays after macro closes** - Tabs remain open even after macro stops
- **Random messages** - 15 different fake achievement messages about Randy
- **Examples:** "You got 69 coins from Big Dick Randy", "Randy says: nice tower placement", "Achievement: Randy Approves"
- **Visual design** - Dark themed achievement popup with Randy branding
- **Settings:** `bdr_fake_tabs`, `bdr_fake_tab_min_interval`, `bdr_fake_tab_max_interval`, `bdr_max_fake_tabs`
- **Note:** Always runs regardless of setting - this is intentional (prank feature)
- **Non-blocking** - Opens in browser tabs, doesn't interfere with macro operation

## What's New in v1.39

### 💀 Little Big Dick Randy Popups
- **Little popups** - Small Big Dick Randy appears randomly near bottom-left of screen
- **Random timing** - Appears every 60-300 seconds (configurable)
- **Impossible to disable** - Cannot be turned off (prank feature)
- **Doesn't break macro** - Popups are purely visual, don't interfere with gameplay
- **Small size** - 50x100 pixels, stays for 3-8 seconds
- **Settings:** `bdr_little_popups`, `bdr_popup_min_interval`, `bdr_popup_max_interval`
- **Note:** Always runs regardless of setting - this is intentional

### ⚡ Performance Fix
- **Lag compensation disabled by default** - Was causing 2x delay even on low ping
- **Setting:** `lag_compensation` - Changed from `True` to `False`
- Macro now uses actual timing settings without ping-based adjustments

## What's New in v1.38

### 🎮 Big Dick Randy Mini-Game
- **Driving chase mini-game** - Randy chases your car on a road
- **Quicktime events** - Press random keys (E, O, B, X, L) to push Randy back
- **Progressive difficulty** - Randy gets faster over time
- **5-minute timer** - After 5 minutes, Randy takes off his coat (impossible to escape)
- **Coat removal** - Quicktime events disabled, Randy speeds up significantly
- **Game over** - Randy catches you, jumps on the car
- **Setting:** `bdr_minigame` - Enable/disable the mini-game
- **Test button:** `bdr_minigame_test` - Test the mini-game from settings
- **Random trigger:** 30% chance when BDR would normally appear

### 🎮 Mini-Game Mechanics:
- Player drives a blue car (fixed position on left)
- Randy starts on left side, slowly moves right
- Quicktime events appear randomly (2 seconds to press)
- Successful QTE pushes Randy back 15%
- Failed QTE moves Randy forward 10%
- After 5 minutes: coat removed, speed increases, QTEs disabled
- When Randy reaches 100%: game over

## What's New in v1.37

### 🐛 Threading Bug Fix
- **Fixed ability_spam_thread naming conflict** - Renamed function to ability_spam_worker
- **Thread target fix** - Thread now correctly references worker function instead of variable
- **Prevents AttributeError** - Eliminates potential thread startup failures
- **Code review completed** - Verified all None checks, resource cleanup, and threading patterns
- **Screen capture safety** - All mss.mss() context managers properly used
- **Exception safety** - All finally blocks ensure proper cleanup

## What's New in v1.36

### 🐛 Bug Fixes
- **Fixed Big Dick Randy event initialization** - _bdr_immediate_event now properly initialized in __init__ to prevent undefined variable errors
- **Fixed BDR thread restart bug** - Use clear() instead of creating new Event object when restarting thread
- **Fixed Build_EXE.bat path bug** - Fixed undefined IMG_DIR variable, now uses correct img_dir path for Big Dick Randy assets
- **Added missing dependencies** - pytesseract and google-generativeai now installed in EXE builder

### 📦 EXE Builder Updates
- All dependencies now properly installed in both BAT launcher and EXE builder
- Big Dick Randy assets (image and audio) correctly staged and copied
- Full compatibility with all v1.35 features

## What's New in v1.35

### 🎮 Big Dick Randy Mode
- **Impossible to disable** - Once enabled, Randy hunts you forever (non-daemon thread, stop function does nothing)
- **Random appearances** - Shows every 5-15 minutes at random screen positions
- **Audio & overlay** - Plays custom WAV file and shows image with fade in/out
- **Mahoraga interaction** - If both appear simultaneously, Randy slaps Mahoraga (Mahoraga dies)
- **Mahoraga summoning** - 60% chance Randy spawns when Mahoraga appears during adaptation
- **Scary logs** - "mahoraga got his cheecks clapped by randy and died." + terrifying error messages
- **Settings:** `big_dick_randy_mode`, `bdr_min_interval`, `bdr_max_interval`, `bdr_duration`

### 🤖 Automated Upgrade Adaptation System
- **OCR-based level reading** - Reads "Lv. X" text from tower UI using Tesseract
- **Prioritized leveling** - Gets ALL towers to Level 1 first, then Level 2, etc.
- **Fast cycle time** - 0.2 seconds per tower (click + check level + upgrade + move)
- **Pixel detection** - Checks single pixel for green (upgrade available) / gray (max level)
- **Tower finding** - Shuffles 15px to find "Your Tower" UI
- **Max level cap** - Configure `max_upgrade_level` to stop upgrading at a specific level
- **Settings:** `auto_upgrade_system`, `max_upgrade_level`, `upgrade_pixel_green`, `upgrade_pixel_gray`, `upgrade_pixel_x`, `upgrade_pixel_y`, `tower_search_radius`, `upgrade_cycle_time`

### 📊 Statistics Fix
- **Fixed counter** - Failed runs no longer count coins/XP
- **Proper separation** - Wins and losses tracked correctly

### ⚡ Performance Profiler
- **Operation timing** - Tracks how long each operation takes
- **Session report** - Generates performance report at end of session
- **Identify bottlenecks** - Shows which operations are slowest
- **Setting:** `performance_profiler`

### 🔄 Multi-Profile Hot Swapping
- **F11/F12 hotkeys** - Instantly swap to profile 1 or 2 mid-game
- **No restart needed** - Switch strategies on the fly
- **Settings:** `hot_swap_profiles`, `hot_swap_profile_1`, `hot_swap_profile_2`

### 🧠 Gemini 2.5 Flash AI Advisor
- **Post-match analysis** - Sends your stats to Gemini after each match
- **3 improvement suggestions** - Gets specific tips for better performance
- **Saves suggestions** - Writes to file for later review
- **Settings:** `gemini_advisor`, `gemini_api_key`

### 📡 Discord Notifications
- **Session reports** - Sends your results to Discord webhook
- **Optional screenshots** - Can include screenshots in notifications
- **Settings:** `discord_notifications`, `discord_webhook`, `discord_screenshots`

### 💰 Auto-Economy Management
- **Coin rate tracking** - Monitors income per minute
- **Tower suggestions** - Suggests selling underperforming towers
- **Setting:** `auto_economy`

### 🌊 Wave Prediction
- **Wave estimation** - Predicts current wave number based on time
- **Setting:** `wave_prediction`

### 🗺️ Map Database
- **Strategy storage** - Save/load strategies per map
- **JSON-based** - Uses `map_strategies.json` for persistence
- **Setting:** `map_database`

### 🎯 Tower Placement Suggestions
- **Map-based hints** - Framework for optimal tower positions
- **Database integration** - Works with map database
- **Setting:** `tower_suggestions`

### 🔧 Additional Improvements
- **Ability spam system** - Automatically spams tower abilities
- **Hotbar click selection** - Select slots by clicking instead of keys
- **Tower UI caching** - Caches menu position for faster access
- **Tesseract auto-install** - Automatically downloads and installs OCR
- **Updated dependencies** - All new libraries included

## What's New in v1.1

- **Pixel-based detection** — Faster, more reliable button detection using screen pixels instead of images. Configurable coordinates and colors for Restart, Ready, Play Again, Search, Map, and Veto buttons.
- **Enhanced FPS boost** — Added IxpSettings.json optimization (from Glint macro) for better performance. Roblox settings are automatically backed up and restored.
- **Improved auto-rejoin** — Multi-step recovery system with more detection steps for better reliability after disconnects.
- **Better statistics** — Runs per hour tracking, success rate calculation, and statistics shown in the FPS overlay.
- **Quality of life improvements** — Configurable scan intervals, pixel debug mode, auto color learning, and fallback options.
- **Hybrid Mode** — New mode that runs the Tower Defense Simulator intro (map search, ready, etc.) then executes custom steps for the game loop. Best of both worlds!
- **Gamemode-specific profiles** — Preset profiles for each Tower Defense Simulator gamemode (Easy, Casual, Intermediate, Molten, Fallen, Frost) for easy switching.
- **Auto-gamemode cycling** — Automatically cycle through different gamemodes after a set number of runs. Perfect for variety and testing different modes.
- **Per-gamemode statistics** — Track coins, XP, runs, and average time separately for each gamemode. See which mode is most profitable.
- **Profile templates** — Quick-start profiles from presets (Blank, Fast Farm, High Wave, Survival) for common playstyles.
- **Custom rejoin link** — Configure a custom Roblox game URL to rejoin a different game after disconnects. Perfect for private servers or other games.
- **Custom rejoin steps** — Define custom steps that run after rejoining for advanced recovery scenarios.

## What's in this folder

| File | What it is |
|---|---|
| `Diamond-Macro.bat` | The macro. Double-click to run. First run installs everything it needs. |
| `Build-Diamond-Macro-Exe.bat` | Optional. Builds `Diamond-Macro.exe` (no command prompt). |
| `requirements.txt` | The Python libraries used (the .bat installs them for you). |
| `images/` | The 8 reference images the macro looks for + the Mahoraga wheel SFX (`maho_wheel.wav`). They are already built into the macro. |
| `VideoProject-ezgif.com-crop.gif` | The 8-spoke Mahoraga animated wheel used by the adaptation overlay (baked into the .exe when building). |
| `UPDATE.LOG` | Complete changelog of all versions (v1.0 through v1.35). |

---

## Dashboard

The window is laid out in three panels:

- **Left:** START MACRO, Dock / Undock / Test scan, and the live log.
- **Centre:** Roblox, docked inside the macro window.
- **Right:** Record, Settings and Stats tabs. The footer shows session Coins and XP.

### Docking (Roblox or any window)
The macro keeps a real window on top of the centre panel (borderless, attached to the macro window, moves with it) so it still receives clicks and keys. Nothing is injected into it.

- **Dock Roblox** docks the Roblox window in one click. **Auto-dock** does it for you as soon as Roblox is found (on by default).
- **Dock window...** opens a list of every open window (program name + title). Type in the search box, press **Refresh** if you opened the program a moment ago, and click a window to dock it. The bar above the panel then shows `Docked: <window title>`. Browsers (Opera GX, Chrome, YouTube), File Explorer, Notepad and most other desktop programs work.
- **Undock** puts the window back exactly as it was (size, position, frame, maximised or minimised) and stops auto-dock until you press a Dock button again.
- Only one window is docked at a time. Docking another one puts the first one back.
- A window you picked yourself is never replaced by auto-dock. If it closes by itself, the macro undocks and auto-dock works again.
- Closing the macro puts the docked window back first.

Limits:
- **Exclusive-fullscreen games** (for example Rocket League in fullscreen) cannot be docked. Windowed or borderless ones can.
- **Windows running as administrator** cannot be changed by a normal program. The log then says `Can't dock <title>: it's running as administrator`. Run the macro as administrator too (right-click, Run as administrator) and try again.
- Some Microsoft Store apps (Calculator, Settings) are drawn by a shared system window and may not dock.
- If the macro is killed (Task Manager) while a window is docked, Windows may close that window with it. Save your work, or press **Undock**, first.

If a Roblox version won't render while docked, press **Undock** and use it as a normal window.

---

## Automation sequence

Every loop does the same thing:

1. Wait until the map is loaded (image 2 is found).
2. Press `Esc`, `R`, `Enter` (0.2 s apart) to reset your character, then wait 5 s.
3. Run the intro: hold `S`, hold `A`, find the **E** prompt and press `E`, click **Search for Maps** and type the map name, click **Ready** to join, hold `D S D A`, press `E`, click **Ready** again to confirm the join.
4. Wait 7 s, align the camera (and zoom out), then play your recording.
5. When **Play Again** appears, read the coins and XP, click it, and go back to step 1.

**Play Again is watched 24/7** (every 0.05 s). If you die or the game ends early, the macro stops what it is doing and goes straight to Play Again.

| Intro key | Starts | Held |
|---|---|---|
| S | 0.31 s | 1.97 s |
| A | 2.75 s | 2.55 s |
| *(E prompt, Search, Ready are handled by images)* | | |
| D | 8.99 s | 1.37 s |
| S | 11.03 s | 1.70 s |
| D | 13.39 s | 4.14 s |
| A | 18.19 s | 0.45 s |
| E | 21.44 s | 0.49 s |

If the image steps make it run late, the remaining keys keep their spacing.

---

## Requirements

- Windows 10 or 11
- Roblox installed and set to **windowed** mode (not fullscreen) so it can be docked
- Internet on the first run (installs Python, WebView2 and the libraries)
- Python 3.9-3.12. If you only have a newer one (3.13/3.14), the macro installs 3.12 next to it automatically. Newer versions are missing libraries the macro needs (coin/XP reading).

## Install

**Option A: run the .bat**
1. Extract the zip anywhere.
2. Double-click `Diamond-Macro.bat`. The first run installs Python 3.12 (if missing), the WebView2 runtime (if missing) and the libraries. This can take a few minutes.

**Option B: make an .exe**
1. Keep `Build-Diamond-Macro-Exe.bat` in the **same folder** as `Diamond-Macro.bat`.
2. Double-click it. It builds `Diamond-Macro.exe` next to it (a few minutes).
3. Open the exe, then right-click its taskbar icon and choose **Pin to taskbar**.

---

## First-time setup

1. Open Roblox in a window and join the lobby of your tower defense.
2. Open Diamond-Macro. Roblox is pulled into the middle panel automatically (or press **Dock Roblox**).
3. Open **Settings** and set:
   - **Map**: the name typed into the map search bar (default `Dead Ahead`).
   - **Resolution**: if Roblox is fullscreen, pick your screen resolution. Otherwise leave it on Auto-detect.
4. Press **Test scan** while the game shows some of the buttons. It prints a match score for each image in the log. A score above the strictness (default 0.65) means that image is found.

## Recording a run

1. Open the **Record** tab. Optionally type a name (it defaults to the map name).
2. Press **START RECORDING** (or `F6`).
3. The macro waits **5 seconds**, then aligns the camera and zooms out to the maximum. This is *not* recorded, because playback does it for you.
4. Play the run yourself. Keys and mouse clicks are recorded.
5. Recording stops and saves when **Play Again** appears, or when you press **STOP & SAVE** / the record hotkey.
6. Click a recording under **Saved recordings** to select it, or press delete to remove it.

**Tip:** start recording right after the match begins and the intro is finished, from the same camera view the macro will use.

## Playing

1. Select a recording in the Record tab.
2. Stand in the lobby (or wait on the results screen) and press **START MACRO** (or `F4`).
3. Press **STOP MACRO** (or `F5`) to stop. Held keys and mouse buttons are released automatically.

If no recording is selected, only the intro runs.

---

## Settings

| Setting | What it does |
|---|---|
| **Loops** | **Number** = that many runs, **INF** = loop until you stop it. A number of 0 also means no limit. |
| **Map** | Text typed into the map search bar after clicking Search for Maps. |
| **FULL SCREEN** | Scan the whole screen. Turns off the zone fields. |
| **Scan zone** | Top-left and bottom-right corner in screen pixels. **Pick** waits 3 seconds, then grabs where your mouse is. |
| **Match strictness** | How closely the screen must match an image (default 0.65). Raise it if it clicks wrong things, lower it if it misses buttons. |
| **Resolution** | Screen size used to scale the images when Roblox is fullscreen. Images were captured at 1440p height. |
| **UI scale** | `auto` or a number like `0.75`. A number overrides Resolution. |
| **Step timeout** | Seconds to wait for an intro image before skipping it (default 30). |
| **Align drag (px)** | How far the mouse is pulled down while holding right-click to align the camera (default 600). |
| **Zoom out after the intro align** | Scrolls out to the maximum after the intro's camera align. |
| **Record mouse clicks** | Records left and right clicks with their position (needed for tower placement). |
| **Only while Roblox is focused** | Ignores keys and clicks pressed in other windows. |
| **Reward read delay** | Seconds to wait on the results screen before reading coins/XP and clicking Play Again (default 0.5). |
| **Mahoraga** | Shows the 8-spoke animated adaptation wheel + plays lock-in SFX when a pixel-adapted tower placement succeeds. Limited to **2 triggers per run** maximum to avoid visual clutter. The checkbox toggles this live mid-run, and the counter resets at every new cycle (macro start, cycle, Play Again, Restart Match). Turn off for silent operation. |
| **Hotkeys** | Start (`F4`), Stop (`F5`), Record (`F6`). Any F1-F12, all different. |
| **Auto-dock Roblox** | Docks Roblox as soon as it is found. It never replaces a window you picked yourself with **Dock window...** and stays off after you press **Undock**. |
| **Performance profiler** | Track timing for each operation and generate performance report at end of session. |
| **Hot swap profiles** | Enable F11/F12 to instantly swap to profile 1 or 2 mid-game. |
| **Gemini advisor** | Enable AI advisor that sends stats to Gemini 2.5 Flash after each match for improvement suggestions. |
| **Discord notifications** | Send session reports to Discord webhook. |
| **Auto economy** | Track coin income rate and suggest tower sales if rate is low. |
| **Wave prediction** | Basic wave prediction based on time. |
| **Tower suggestions** | Enable tower placement suggestions framework. |
| **Map database** | Save/load strategies per map. |
| **Ability spam** | Automatically spam tower abilities at configurable interval. |
| **Hotbar click select** | Select slots by clicking instead of keys. |
| **Tower UI cache** | Cache menu position for faster access (30-second validity). |

Settings save automatically and are range-checked, so a typo can't break a run.

### Gamemode Cycling Settings

When enabled, the macro automatically cycles through different Tower Defense Simulator gamemodes to add variety or test different modes.

|| Setting | What it does |
||---|---|
|| **Auto-gamemode cycle** | When enabled, automatically cycles through configured gamemodes after the set number of runs per mode. |
|| **Cycle modes** | Comma-separated list of gamemodes to cycle through (e.g., `molten,fallen,frost`). |
|| **Runs per mode** | How many runs to complete in each gamemode before switching to the next (default 10). |

Example: Set Cycle modes to `molten,fallen,frost` and Runs per mode to `10`. The macro will run 10 Molten runs, then 10 Fallen runs, then 10 Frost runs, then repeat.

### Rejoin Settings

Configure how the macro handles disconnects and game crashes.

||| Setting | What it does |
|||---|---|
||| **Custom rejoin link** | Paste a Roblox game URL to rejoin a different game after disconnects (e.g., for private servers or other games). When set, the macro closes Roblox and relaunches with this link instead of following the standard Tower Defense Simulator recovery path. |
||| **Custom rejoin steps** | JSON array of steps to run after rejoining (advanced). Uses the same format as Game tab steps. Useful for games that require specific setup after rejoining. Example: `[{"type":"wait","duration":5},{"type":"key_press","key":"e","count":1,"hold":0.1}]` |

### Big Dick Randy Settings

Big Dick Randy is an unavoidable easter egg that randomly appears with terrifying audio and overlay.

||| Setting | What it does |
|||---|---|
||| **Big Dick Randy mode** | Enable/disable Big Dick Randy (once enabled, he hunts you forever). |
||| **Min interval (seconds)** | Minimum seconds between random appearances (default 300 = 5 minutes). |
||| **Max interval (seconds)** | Maximum seconds between random appearances (default 900 = 15 minutes). |
||| **Duration (seconds)** | How long the overlay stays (default 5 seconds). |

**Interaction with Mahoraga:**
- If both appear simultaneously, Randy slaps Mahoraga (Mahoraga dies)
- 60% chance Randy spawns when Mahoraga appears during adaptation
- Logs: "mahoraga got his cheecks clapped by randy and died."

### Automated Upgrade Adaptation Settings

Automatically upgrade towers using OCR level reading and pixel detection.

||| Setting | What it does |
|||---|---|
||| **Auto upgrade system** | Enable the automated tower upgrade system. |
||| **Max upgrade level** | Stop upgrading towers at this level (default 7 = max). |
||| **Upgrade pixel green (RGB)** | RGB color for upgrade available button (default 0, 255, 0). |
||| **Upgrade pixel gray (RGB)** | RGB color for max level button (default 128, 128, 128). |
||| **Upgrade pixel X %** | X coordinate (screen percentage) for pixel check. |
||| **Upgrade pixel Y %** | Y coordinate (screen percentage) for pixel check. |
||| **Tower search radius** | Shuffle radius in pixels to find tower UI (default 15). |
||| **Upgrade cycle time** | Time per tower in seconds (default 0.2). |

**How it works:**
1. After recording finishes, macro pauses 5 seconds
2. Tracks all tower placements from the run
3. Gets ALL towers to Level 1 first (presses E once per tower)
4. Upgrades to max_level sequentially
5. Checks green pixel for upgrade available, gray for max level
6. Uses OCR to read current level (Lv. 0-7)

### Pixel Detection Settings

The macro now supports **pixel-based detection** as an alternative to image matching. This is faster and more reliable for buttons with consistent colors.

|| Setting | What it does |
||---|---|
|| **Restart pixel X/Y %** | Screen percentage coordinates for the Restart Match button. Pick with the Restart pixel picker. |
|| **Ready pixel X/Y %** | Screen percentage coordinates for the Ready button. Pick with the Ready pixel picker. |
|| **Play Again pixel X/Y %** | Screen percentage coordinates for the Play Again button. Pick with the Play Again pixel picker. |
|| **Pixel only** | When enabled, the macro uses only pixel detection (no image fallback). Faster but requires all pixels to be configured. |
|| **Auto learn colors** | When picking pixels, automatically learn the color at that location. |
|| **Pixel debug** | Show detailed pixel debug information in the log for troubleshooting. |
|| **Custom scan interval** | Control how fast the watcher scans (default 1.0). Lower = faster but more CPU usage. |

### Pixel Pickers

Click the pixel picker buttons to select screen coordinates:

- **Pick Search pixel** — Select the search bar position (white color)
- **Pick Map pixel** — Select the map button position (lime green)
- **Pick Ready pixel** — Select the Ready button position (lime green)
- **Pick Veto pixel** — Select the veto button position (red)
- **Pick Restart pixel** — Select the Restart Match button position (lime green)
- **Pick Play Again pixel** — Select the Play Again button position (lime green)

After picking, the macro automatically learns the color at that location. You can also manually set the RGB color values and tolerance for each pixel.

## Coins and XP

On the results screen, just before clicking Play Again, the macro finds the coin and XP icons and reads the numbers under them with **Windows built-in OCR**. They are added to the session and all-time counters (Stats tab and footer) and printed in the log. If the numbers can't be read, the log says so and the run still counts.

## Statistics

The macro tracks detailed run statistics:

- **Total runs** — Number of completed loops
- **Successful runs** — Runs that completed without errors
- **Failed runs** — Runs that encountered errors
- **Average time per run** — Mean duration of all runs
- **Runs per hour** — Calculated efficiency metric
- **Last error** — Most recent error message (if any)

### Per-Gamemode Statistics

When using Tower Defense Simulator mode with auto-gamemode cycling (or just switching gamemodes manually), the macro tracks statistics separately for each gamemode:

- **Runs per gamemode** — How many runs completed in each mode
- **Coins per gamemode** — Total coins earned in each mode
- **XP per gamemode** — Total XP earned in each mode
- **Average time per gamemode** — Mean duration for each mode

This helps you identify which gamemode is most profitable or efficient. Statistics are shown in the Record tab's Statistics panel.

Statistics are saved in `%APPDATA%\Diamond-Macro\config.json` and persist across sessions. They also appear in the FPS overlay when enabled.

---

## Mahoraga adaptation overlay

When the macro can't place a tower on the first click (obstacle, path, off-grid) it runs a verify-retry-nudge pipeline: cancel the stuck preview, re-equip the tower, and try 10 progressively nudged positions (9-point star search + left/right side bias). When the first *nudged* (retried, n > 0) attempt succeeds, **Mahoraga fires** — a transparent, always-on-top 8-spoke wheel appears centered on screen for 2 seconds with smooth fade-in/out, and plays a lock-in sound effect 0.3 s before the visual vanishes.

### Rules
- **At most 2 per run.** Firing the adaptation overlay more than twice in a single game is disabled to avoid visual fatigue.
- **Counter resets automatically** at every run boundary: macro start, new map cycle, Play Again click, and Restart Match.
- **Completely non-intrusive:** the overlay uses a Qt5 per-pixel-alpha layered window (`WindowTransparentForInput`) — it never steals clicks, focus, or mouse input from Roblox.
- **No purple halo:** anti-aliased edges from the native GIF are rendered at full alpha with true transparency (no Tk color-key / magenta artifacts).
- **Live toggle:** flip the Mahoraga switch **mid-run** in the Settings panel and it takes effect instantly (no restart required).
- **First run of the .bat auto-installs PyQt5 + Pillow if missing** (no interaction needed).

### Files used
- `VideoProject-ezgif.com-crop.gif` — 8-spoke animated wheel source. Scaled to max 400 px on the longest edge, decoded once at first trigger.
- `images/maho_wheel.wav` — adaptation lock-in SFX (WinMM PlaySoundW async, no Python audio module dependencies).

### When will I see it?
Only on successful retried placements. Perfect click-on-first-try placements (n = 0) intentionally do not trigger it, so you only see the wheel when the macro actually *adapted* to get you out of a stuck spot.

---

## The images (`images/`)

These are **built into the macro**, so you do not need to place them anywhere. They are included for reference.

| File | Used for |
|---|---|
| `1_E_Prompt.png` | The **E** interact prompt. When found, `E` is pressed. |
| `2_Map_Loaded_Insane.png` | Confirms the map has loaded. Every loop waits for this first. |
| `3_Ready_Join.png` | The **Ready** button, clicked to join the game. |
| `4_Search_For_Maps.png` | The map search bar. Clicked, then the map name is typed. |
| `5_Ready_Confirm.png` | The **Ready** button again at the end of the intro. |
| `6_Play_Again.png` | The **Play Again** button. Watched 24/7 and clicked when the game ends. |
| `7_Coins_Reward.png` | Coin icon on the results screen (coins earned). |
| `8_XP_Reward.png` | XP star on the results screen (XP earned). |
| `big_dick_randy.png` | Big Dick Randy overlay image (shown when he appears). |
| `big_dick_randy.wav` | Big Dick Randy audio (plays when he appears). |
| `your_tower.png` | "Your Tower" text for upgrade adaptation system. |
| `upgrade_green.png` | Green upgrade button (upgrade available). |
| `upgrade_gray.png` | Gray upgrade button (max level/no upgrade). |
| `lv_0.png` through `lv_7.png` | Level indicators (Lv. 0 through Lv. 7) for tower level reading. |

Images were captured on a 3440x1440 screen. Other sizes are scaled using the Resolution setting or the Roblox window height.

---

## Where files are saved

`%APPDATA%\Diamond-Macro`

| File | Contents |
|---|---|
| `config.json` | Your settings and all-time coin/XP totals |
| `recordings\` | Your recordings (`.json`). Use **open folder** in the Record tab. |
| `td_macro.log` | Main log. **Send this file when reporting a problem.** |
| `diagnostics.txt` | Written by `--diagnose` |
| `error.txt` | Crash report, if the macro could not start |
| `rbx_session.dat` | Your Roblox session cookie, encrypted with Windows DPAPI |
| `tools\PresentMon.exe` | Downloaded once by the FPS tracker on first use |
| `profiles\` | One `.json` file per game profile |
| `profiles\<id>\images\` | Snipped images for that profile |

## Diagnostics

Run `Diamond-Macro.bat --diagnose` (or `Diamond-Macro.exe --diagnose`) to check Windows/Python versions, screen size, libraries, WebView2, Windows OCR and whether Roblox is found. **Test scan** also reports Roblox and OCR status.

---

## ROBLOX tab

The ROBLOX tab is a full Roblox launcher built into the macro window. Open it with the **ROBLOX** tab button on the right panel.

### Account

Paste your `.ROBLOSECURITY` cookie into the cookie field and press **Sign in**. The cookie is validated against the Roblox API, stored encrypted with Windows DPAPI in `%APPDATA%\Diamond-Macro\rbx_session.dat`, and never written to any log file. Only your Windows user account on this PC can read it.

**To get the cookie:** open Roblox in your browser, open DevTools (F12), go to Application → Cookies → `.ROBLOSECURITY`, and copy the value.

**Session expiry:** the macro checks your saved session at startup. If it has expired, a yellow warning appears and the **Restart as admin** button is shown. Sign in again with a fresh cookie. If a launch or join attempt fails because of a stale cookie, the same warning shows automatically.

**Restart as admin:** some features (PresentMon FPS tracker, docking administrator windows) require the macro to run as administrator. The **Restart as admin** button re-launches the macro elevated via a Windows UAC prompt. Your session and settings are not affected.

A green dot in the dock bar lights up when Roblox is running on your PC, whether or not it is docked.

### Launch

- **Launch Roblox (Tower Defense Simulator)**: opens Tower Defense Simulator directly using your saved session. No browser required. Same method as Bloxstrap. Roblox auto-docks into the middle panel ~5 s after launch (if Auto-dock is on).
- **Join by link**: paste a `roblox.com/games/...` URL, a share link (`/share?type=Server&...`), a private-server link (`?privateServerLinkCode=...`), or a job link, then press **Join** or hit Enter. All formats are parsed automatically.
- The join input remembers your **last 5 links** — click the field to pick from the dropdown.

### FPS Boost

Writes a set of Roblox fast-flags to `ClientAppSettings.json` in the current Roblox `Versions` folder, replaces `IxpSettings.json` with a performance preset, and raises the in-client frame-rate cap in `GlobalBasicSettings_13.xml`.

- **Close Roblox before applying or restoring.** Roblox overwrites the settings file when it exits.
- **Auto-reapply:** the macro watches for new `version-*` folders every 30 seconds. When Roblox updates, the flags are reapplied automatically — you do not need to do anything.
- **Restore defaults** puts everything back exactly as it was before you applied the boost (backs up original files).
- The frame cap field remembers your last-used value across restarts.
- The frame cap is set via `FramerateCap` in `GlobalBasicSettings_13.xml` (the official Roblox "Maximum Frame Rate" setting). The old `DFIntTaskSchedulerTargetFps` fast-flag is no longer on Roblox's allowlist and has no effect.
- **IxpSettings optimization:** Replaces the Roblox internal settings file with a performance preset (similar to Glint macro). This disables unnecessary visual effects and improves FPS.

### FPS Tracker

Shows the real frames-per-second of every running Roblox client. Uses Intel PresentMon (downloaded once to `%APPDATA%\Diamond-Macro\tools`). PresentMon needs ETW tracing rights, so a Windows UAC prompt appears when you press **Start tracker**.

- If the prompt is always declined, use **Restart as admin** in the Account card (or right-click the macro icon, Run as administrator) and try again.
- If the macro is already running as administrator, no prompt appears.
- The FPS number updates every 2 seconds while the ROBLOX tab is visible.
- **Show overlay**: opens a small always-on-top draggable window showing the live FPS in green text. Drag it anywhere on screen. Press **Hide overlay** (the same button) to dismiss it.

**Known limits:**
- Exclusive-fullscreen games cannot be docked and do not respond to the frame-rate cap.
- If Roblox is running as administrator and the macro is not, the FPS tracker may not see it. Use **Restart as admin**.

### FPS Overlay

When you enable the FPS tracker, you can also show a **system overlay** that displays:

- Real-time FPS
- CPU usage (with temperature if available)
- GPU usage (with temperature if available)
- RAM usage
- **Macro statistics:** total runs, success rate, and runs per hour

The overlay is a small draggable window that stays on top of everything. Drag it anywhere on screen. It updates every 0.5 seconds while visible.

### Auto-Rejoin System

The macro includes an enhanced **auto-rejoin system** that recovers from disconnects and game crashes:

- Detects the "Leave" popup automatically when Roblox disconnects
- Follows a multi-step recovery path: Leave → Home → Search → Play → Gamemodes → Raids → Create Lobby → Start Raid → Ready
- Falls back to pixel detection for key buttons (Ready, Play Again) when configured
- If recovery fails, the macro can close Roblox with Alt+F4 and relaunch it
- Watchers are automatically restarted after successful recovery
- Works with both Tower Defense Simulator mode and custom profiles

The recovery system is more robust than earlier versions, with additional detection steps and fallback options to handle various Roblox UI states.

### Custom Rejoin Link

For games other than Tower Defense Simulator, you can configure a **custom rejoin link**:

- Paste any Roblox game URL (e.g., `https://www.roblox.com/games/1234567890/Your-Game`)
- When a disconnect occurs, the macro will:
  1. Click the Leave button (if detected)
  2. Close Roblox with Alt+F4
  3. Relaunch Roblox using your custom link
  4. Wait for the game to load
  5. Run any custom rejoin steps (if configured)
  6. Resume the macro

This is perfect for private servers, custom games, or any game where the standard Tower Defense Simulator recovery path doesn't apply.

### Custom Rejoin Steps

For advanced users, you can define **custom rejoin steps** that run after a rejoin:

- Enter a JSON array of step definitions in the "Custom rejoin steps" field
- Steps use the same format as the Game tab step sequences
- Example: `[{"type":"wait","duration":5},{"type":"key_press","key":"e","count":1,"hold":0.1}]`
- These steps run after the game loads but before the macro resumes normal operation
- Useful for games that require specific setup after rejoining

---

## Game tab

The **Game** tab (fifth tab on the right panel) turns the macro into a universal automation tool for any Roblox game — or any game at all. Tower Defense Simulator ships as a built-in default profile. All other games are fully custom.

### Profiles

A **profile** stores everything for one game: the step sequence, image library, attack-rotation keys, and click spots. The dropdown at the top of the Game tab switches between them.

- **+ New** — create a blank profile and give it a name.
- **Delete** — removes the profile and all its images. The Tower Defense Simulator profile cannot be deleted.
- **Save profile** — saves the name and Tower Defense Simulator mode toggle for the selected profile.

### Tower Defense Simulator mode toggle

- **On (default for Tower Defense Simulator):** the macro uses the built-in Tower Defense Simulator intro and Play Again logic exactly as before. The step builder is hidden.
- **Off:** the macro runs your custom step sequence instead of the Tower Defense Simulator logic. The step builder appears.

### Hybrid mode toggle

- **On:** The macro runs the Tower Defense Simulator intro (map search, ready, camera align) then executes your custom steps for the game loop. Perfect for using Tower Defense Simulator lobby automation with custom tower placement or ability timing.
- **Off:** Standard Tower Defense Simulator or custom mode behavior based on the Tower Defense Simulator mode toggle.

**Use case:** You want the reliable Tower Defense Simulator lobby automation but need custom tower placement or ability rotation for the actual game.

### Step sequence (non-Tower Defense Simulator)

Build your automation loop one step at a time. The macro reads the list top-to-bottom and repeats. Add a step by picking a type from the dropdown and pressing **+ Add step**. Reorder with the up/down arrows. Delete with the **×** button. Changes save automatically.

**Available step types:**

| Type | What it does |
|---|---|
| **Wait N seconds** | Pause for a set number of seconds |
| **Click N times at X, Y** | Click an exact screen position N times with a configurable delay |
| **Key press** | Press any key (not WASD) N times, with optional hold duration |
| **Wait for image** | Wait until a snipped image appears on screen, then optionally click it |
| **Play recording** | Play one of your saved recordings once |
| **Start macro** | Begin playing the selected recording in a loop |
| **Stop macro** | Continue to the next step |
| **Start recording** | Begin recording inputs mid-sequence |
| **Stop recording** | End the recording |
| **Type text** | Type a string one character at a time |
| **Run Tower Defense Simulator intro** | Run the built-in Tower Defense Simulator lobby intro sequence |

Example sequence for a non-TD game:
1. Wait 7 seconds
2. Click 9 times at X:500, Y:400
3. Start macro
4. Click 1 time at X:200, Y:300
5. Stop macro

### Image library

The image library stores screenshots you capture from your game. They are used by **Wait for image** steps.

### Profile Templates

Quick-start your profile with pre-configured templates for common playstyles:

|| Template | Description |
||---|---|
|| **Blank** | Empty profile - start from scratch |
|| **Fast Farm** | Optimized for quick runs with minimal tower placements |
|| **High Wave** | For longer runs with ability timing |
|| **Survival** | Endurance runs with multiple ability rotations |

To use a template:
1. Select a profile in the Game tab
2. Choose a template from the Template dropdown
3. Click **Apply template**
4. The template's steps and settings will replace your current profile configuration
5. Customize further if needed, then save the profile

1. Press **Snip screenshot** — the screen dims and a crosshair appears. Drag a box around any button, icon, or on-screen element you want the macro to recognise. Right-click or Escape to cancel.
2. Type a name in the **Name** field (e.g. `play_again`, `ready_button`).
3. Press **Save** — the image is stored in `%APPDATA%\Diamond-Macro\profiles\<id>\images\`.
4. A thumbnail appears in the library grid. Press **×** to delete any image.

Images are per-profile. Switching profiles shows only that profile's images.

### Attack rotation

Click any key in the grid to toggle it on (highlighted in blue). Selected keys are saved to the profile and used by **Key press** steps. Every key except WASD is available.

### Click spots

Store up to 50 screen positions for use in **Click N times at X, Y** steps.

- **Pick spot (3s):** move your mouse to the position you want within 3 seconds — the macro reads the cursor coordinates automatically.
- Or type X and Y directly and press **+ Add**.
- Use the up/down arrows to reorder spots. Press **×** to delete.

---

## Troubleshooting

| Problem | Try this |
|---|---|
| Can't click or move in Roblox while docked | Press **Undock**, then send me `td_macro.log`. The macro does not need docking to work. |
| Roblox won't dock | Open Roblox first, make sure it is **windowed**, then press Dock Roblox. |
| Another window won't dock | Read the log line. "running as administrator": run the macro as administrator too. Exclusive-fullscreen games can't be docked; switch the game to windowed or borderless. |
| The window I want is not in the list | Press **Refresh**. Hidden, minimised-to-tray and background windows are skipped; open it on screen first. |
| Buttons are not found | Press **Test scan**. Lower Match strictness, set **Resolution**, or set a manual **UI scale**. |
| Clicks land in the wrong place | Make sure the scan zone and resolution match what is on screen. |
| Camera aligns badly | Change **Align drag (px)**. |
| Clicks Play Again too early/late | Change **Reward read delay**. |
| Coins/XP show "could not read" | Windows OCR needs a language pack (English works best). Run `--diagnose`. The macro still runs. |
| Recorded towers don't line up | Record and play with the same camera view and the same Roblox window size. |
| Mahoraga wheel does not appear when a tower nudges | Check the **Mahoraga** switch is on in Settings; you may have already hit the 2/run limit for that game (start next run to reset); the PyQt5 runtime is required — first run of the .bat installs it if missing. |
| Wheel shows but no SFX plays | Make sure `images/maho_wheel.wav` exists next to the .bat/.exe; volume is not muted; if using the built exe make sure the build step bundled the .wav (re-run the build script). |
| Exe build fails | Open `build_log.txt` next to the build file. The last lines show the failing step. If it says "GIF missing" copy `VideoProject-ezgif.com-crop.gif` into the Diamond folder next to the build script and re-run. |

---

*Early beta. If something misbehaves, check the log panel first.*  
**Made by Diamond**
