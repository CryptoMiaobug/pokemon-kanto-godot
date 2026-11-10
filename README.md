# Pokémon Kanto · Godot Recreation Prototype

English | [简体中文](README.zh-CN.md)

A standalone, unofficial Pokémon fan project built with Godot and GDScript. Map layouts primarily follow Pokémon Red, with selected assets and implemented battle mechanics from FireRed. This project is not affiliated with the original rights holders.

**The game supports English and Simplified Chinese. Press F8 on the map to switch languages.** The preference is saved separately from game progress; player nicknames and mail remain unchanged.

## Getting started

Install **Godot 4.7.2**, import the root `project.godot` file in the Project Manager, allow assets to import, and run the main scene. Alternatively, run this from the project directory:

```sh
godot --path .
```

The executable name depends on your Godot installation. Engine binaries, exported builds, and a browser version are not included.

## Features

- Kanto maps and an implemented eight-badge storyline, Elite Four, Champion, and Hall of Fame registration.
- Wild encounters and catching, a six-Pokémon party, PC storage, experience, leveling, and selected evolution methods.
- Shops, inventory, healing, HMs/TMs, and persistent story progress.
- Single and double battles, with an implemented subset of moves and abilities.

This is an evolving prototype, not a complete recreation of the original games. Species, abilities, move combinations, and original move animations are not all implemented. A continuous playthrough from a fresh save without development aids has not been verified. Some side quests, state persistence cases, and mechanic combinations remain unverified. Development shortcuts are still present; this is not a final balanced release.

## Controls

- **Overworld:** WASD / arrow keys to move; E / Enter to interact; P for party; B for bag; O for evolution stones; K for key items.
- **HMs:** M / N / J / L / I open the teaching interfaces for Cut / Surf / Strength / Fly / Flash respectively. F uses Fly, V toggles cycling, U uses Flash, F6 uses Rock Smash, and F7 uses Waterfall. Moves, badges, and location requirements apply; follow the on-screen prompts.
- **Battles:** 1 Fight, 2 Bag, 3 Pokémon, 4 Run. Use numbered choices in submenus and Esc to go back. Catching and fleeing are unavailable in trainer battles.
- **Saving:** F5 saves; F10 saves and exits if saving succeeds. Save data is stored as `progress.json` under Godot's `user://` directory, whose location depends on your operating system. Back up important saves yourself.

## Project layout

- `scripts/` — game logic.
- `scenes/` — Godot scenes.
- `data/` — runtime data.
- `assets/` — artwork, fonts, and source records.

## Credits and licensing

See [third-party sources](THIRD_PARTY.md) and the source records and license notices shipped with the assets. Source attribution does not establish permission to redistribute original game artwork. Redistribution rights for the original game assets have not been established individually. No blanket open-source license is granted for the entire project.

## Localization checks

English and Chinese display checks cover representative movement, interactions, battle inputs, purchase success/cancel, story choices, and save/restart with nickname and individual-ID preservation. These are isolated checks with fixture setup, not a natural full playthrough or exhaustive NPC coverage. Some unimplemented interactions exist only as source data.
