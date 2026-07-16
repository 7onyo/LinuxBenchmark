# Linux Gaming Benchmark

A DIY tool for repeatable game benchmarking on Linux using keyboard input recording and playback via `evemu`, with FPS logging powered by MangoHud.

Built for fun and experimentation - the goal is to get consistent, repeatable benchmarks across different runs, hardware configurations, and power modes.

> [!WARNING]
> **DO NOT use this in online games and/or games that have anti-cheat software.** This tool injects virtual keyboard input, which may be flagged by anti-cheat systems and result in a ban.

## Demos

### Record Metro Exodus Demo
<video src="https://github.com/user-attachments/assets/3c7a5fab-91ab-4dcd-a343-414091f1dc32" controls="controls" width="100%"></video>

### Play Metro Exodus Demo
<video src="https://github.com/user-attachments/assets/c5bead01-675b-43f3-9372-1106019519b8" controls="controls" width="100%"></video>

*Note: Play demos for Batman Arkham Knight and Wolfenstein The New Order are also available in the `media/` directory.*

## How It Works

1. **Record** - Capture keyboard inputs while playing through a repeatable game segment (e.g., a saved checkpoint or level start).
2. **Play** - Replay those exact inputs on subsequent runs while MangoHud logs FPS data to a CSV.
3. **Analyze** - Compare the resulting FPS logs across different configurations.

## Limitations

This approach is **not practical for general-purpose benchmarking** because:

- Only keyboard input is recorded (mouse recording was attempted but proved unreliable)
- Requires games with level/manual save so the test path is repeatable
- Only works in offline games without anti-cheat
- Even like this, the playback of an `evemu` recording cannot be 100% the same across runs if game mechanics are involved (sliding, drifting, etc.) with different outcomes

### Better Alternatives

- Games with built-in benchmark modes
- Hardware input replay via bot/motor-driven keyboard and mouse

## Repo Structure

```
.
├── scripts/
│   ├── .env            # Configuration (keyboard name, recording filename)
│   ├── record.sh       # Record keyboard inputs from a physical keyboard
│   └── play.sh         # Replay inputs on a virtual keyboard + MangoHud logging
├── macros/             # Stored .evemu macro files (recorded input sequences)
├── data/               # MangoHud FPS log CSVs and benchmark results
├── media/              # Demo videos
├── LICENSE             # Project license
└── README.md
```

## Prerequisites

- **Linux** with root access (`sudo`)
- **evemu** - for recording and playing back input events
  ```bash
  # Debian/Ubuntu
  sudo apt install evemu-tools
  # Arch
  sudo pacman -S evemu
  ```
- **MangoHud** - for FPS overlay and logging
  ```bash
  # Debian/Ubuntu
  sudo apt install mangohud
  # Arch
  sudo pacman -S mangohud
  ```
- A game with a **repeatable segment** (manual/quick save, level restart, etc.)

## MangoHud Setup in Steam

Add the following to a game's **Launch Options** in Steam:

```
mangohud %command%
```

To enable FPS logging, make sure your MangoHud config includes:

```ini
log_duration=0 # unlimited logging, not stopped after x amount of time
output_folder=/path/to/data
```

Or use **GOverlay** for a graphical MangoHud configuration tool. The default MangoHud toggle for logging is `Shift+F2`, which is what `play.sh` injects automatically.

## Configuration

Before running the scripts, edit `scripts/.env` to match your setup:

```ini
KEYBOARD_NAME="ITE Tech. Inc. ITE Device(8910) Keyboard"
RECORDING_FILE="game_path.evemu"
```

| Variable | Description |
|----------|-------------|
| `KEYBOARD_NAME` | Your physical keyboard's device name (used by `record.sh`) |
| `RECORDING_FILE` | Filename for the `.evemu` recording (used by both scripts) |

To find your keyboard's device name:

```bash
sudo evemu-record
```

## Usage

### 1. Record a Macro

Run the recording script with `sudo` (required for raw input access):

```bash
sudo ./scripts/record.sh
```

- You have **5 seconds** to switch to your game window after running the script.
- Play through the segment you want to benchmark.
- Press `Ctrl+C` to stop recording.
- Delete the last lines from the `.evemu` recording (these contain your `Alt+Tab` and `Ctrl+C` key presses).
- The output `.evemu` file (set by `RECORDING_FILE` in `.env`) contains the recorded keyboard events.

### 2. Play Back & Benchmark

Make sure the recorded `.evemu` file matches the `RECORDING_FILE` value in `.env`, then run:

```bash
sudo ./scripts/play.sh
```

- You have **10 seconds** to Alt+Tab into your game.
- The script creates a virtual keyboard, sends `Shift+F2` to start MangoHud logging, replays the macro, then sends `Shift+F2` again to stop logging.
- Check your MangoHud output folder for the resulting CSV.

### 3. Analyze Results

Compare the CSV logs across different runs - varying hardware, drivers, kernel versions, power profiles, etc.

## Explanation / Details

The scripts use **evemu** under the hood:

| Tool | Purpose |
|------|---------|
| `evemu-record` | Captures raw input events from a physical device |
| `evemu-device` | Creates a virtual input device from a recording |
| `evemu-play` | Replays recorded events through the virtual device |
| `evemu-event` | Sends individual synthetic input events |

The playback script automatically brackets the macro with `Shift+F2` key presses to toggle MangoHud's FPS logging, so the CSV captures exactly the benchmarked segment.

