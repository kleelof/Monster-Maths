# Monster Maths — Browser Edition

A static HTML, CSS and JavaScript rewrite of the original Flash game. It uses the loose PNG and MP3 files from the original project; no FLA or SWF assets are required at runtime.

## Run locally

The game uses JavaScript modules, so serve the folder over HTTP rather than double-clicking `index.html`:

```sh
cd "/Users/lee/Documents/monster maths"
python3 -m http.server 8000
```

Then open <http://localhost:8000> in a modern browser.

## Controls

- Move: hold the mouse button and move the pointer
- Teleport: hold Space while mouse-moving; release it to recharge
- Answer: number keys and Enter
- Mute: M or the SOUND button

The game is designed for desktop browsers and an 800×500 play area.
