# aeris-pet

A small desktop pet for Linux on Hyprland: a grey-and-white dragon in the spirit of Haku (serpentine
body, four jointed legs with clawed paws, whiskers, horns), or a raven. It lives on a transparent
overlay above your windows, outside any terminal.

It walks along the bottom of the screen, flies in arcs, perches on window title bars, pecks at
crumbs you drop, dances when clicked, sleeps when idle, and says things in speech bubbles. It also
keeps an eye on the machine: low battery, pending updates and Tailscale being down.

One Python file: GTK 3 + cairo, drawn procedurally, sounds synthesized on first run.

## Controls

| Input | What it does |
|---|---|
| left click | dance and say something |
| double click | fly up and perch on a window's title bar |
| middle click | drop crumbs on the floor |
| drag and throw | carry it, let go and it flies |
| right click | open the pet menu in the bar (Quickshell integration) |

## Command line

```
aeris-pet                    run the pet (one instance; starting it twice does nothing)
aeris-pet set dragon|raven   choose the pet, starting it if needed
aeris-pet start | quit | toggle
aeris-pet status             JSON for a bar module: {"text", "class", "pet", "running"}
```

The choice is stored in `~/.local/state/aeris-pet/pet`. Speech lines come from
`~/.config/tinyraven/greetings.txt` (one per line, `#` comments), with a few built-in fallbacks.

## Install

Requirements: Hyprland, Python 3, PyGObject with GTK 3 and PangoCairo, pycairo, and `pw-play`
(PipeWire) for sounds. On Arch: `pacman -S python-gobject python-cairo gtk3 pipewire`.

```
install -m755 aeris-pet ~/.local/bin/aeris-pet
```

Then add the window rule in `integrations/hyprland/pet-rule.lua` to your Hyprland config.
It matters: the pet is a full-screen transparent window, so without `no_blur` Hyprland blurs
every window behind it, and without `no_focus` a click on the pet takes the keyboard away from
your apps. (The pet also adds the rule at runtime through `hyprctl eval`, for Hyprland's Lua
config.)

### Bar menu

- **Waybar:** `integrations/waybar/` has a `custom/pet` module and a dropdown menu (Waybar 0.11+).
- **Quickshell:** `integrations/quickshell/` has a paw icon and popup for a Quickshell bar.

## Test hooks

`AERIS_PET_DEMO=1` drops crumbs shortly after start; `AERIS_PET_STATS=1` prints frame timing;
`AERIS_PET=raven` overrides the stored choice for one run.

## Next: pets that visit each other

Plans for pets on different machines meeting over a Tailscale tailnet (visiting, letters to a
local Ollama model, battery vigils, waves when a friend comes online) are in
[docs/network-ideas.md](docs/network-ideas.md). Not built yet.

Part of AerisOS.
