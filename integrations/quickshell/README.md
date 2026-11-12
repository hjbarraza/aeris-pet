Bar widget for a Quickshell bar: `Pet.qml` (the paw icon) and `PetPopup.qml` (the menu).
They use the AERIS shell's `qs.Commons` (Theme, Shell) and `qs.Ui` (StatusModule, Caption)
singletons; adapt those imports to your own bar. Wire them up in your bar like this:

    Pet { id: petIcon; onClick: () => petPopup.toggle() }
    ...
    PetPopup { id: petPopup; anchor.window: bar; anchorItem: petIcon }
    IpcHandler { target: "pet"; function menu(): void { petPopup.open() } }

The pet's right click runs `aeris-shell -q pet menu`, which calls that IPC target.

`PetLane.qml` is the pet living in the bar (`aeris-pet where bar`): it walks the bar, dives
under icon groups and reacts to notifications. `pet.qml` is a standalone Quickshell config
that runs only the bar pet, for a Waybar desktop; it expects to sit next to a `Bar/` folder
holding `PetLane.qml` and `PetPopup.qml` (as in `~/.config/quickshell/aeris/`).
