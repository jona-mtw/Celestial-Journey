# **Worlds Unbound**

https://github.com/user-attachments/assets/7f53e90c-d294-4298-b332-af277ab2ad35

A game where the player explores procedurally generated planets in realistic orbits in space ships constructed by the player. As of right now (v1.0.1-alpha) this is merely just a terrain engine for my game, which I went through with multiple iterations of terrain.

## Current State
* player movement
* procedural terrain generation
* UI - pause menu, settings menu (just a template, nothing in it right now) and main menu
* basic terrain textures (just 3 colours based on height)

## Installation
* go to releases
* click on v1.0.1-alpha
* download the .exe file

<br>

**Alternatively** (to take a deeper look at the project, and to be able to change the terrain settings in real time):
* install the Godot engine (completely open source and no installer) : https://godotengine.org/
* download the .zip or tar.gz file (whatever your more familiar with, if you do not know what they are, click on .zip)
* extract the file
* import the project into godot, by opening godot, then clicking the import button, and finding the project directory

**What you can do if you open it in Godot:**
If you go to: res://src/levels/terrain.tcsn, then click on the mesh. On the right hand side, click on Surface Material Override, then the little icon next to the reload icon, then terrain.gdshader...
* click and drag on the U and V values to see the terrain moving on a unmoving plane.
* click on heightmap > FastNoiseLite to change the noise settings. Tweak with them until you get something you like (make sure to expand the Fractal panel)
* change the biome heights
* change the overall terrain height
* change the normal basis (sounds complicated, but just drag the values in the matrix until it looks cool)

If you go to res://src/core/main_game/main_game.tscn...
* click on the Player in the scene tree, and change its speed (if the speed is too high, but under 200m/s should be fine, you may clip through the mess)
* click on DirectionalLight3D in the scene tree, and rotate it to see how the terrain would look with the sun at different positions in the sky (looks terrible atm at night)

## Hot Keys
Movement - WASD

Zooming in and out - scroll wheel

Freelook - hold RMB

Pause - escape

Quick Quit - escape then ` (or just press quit once in the pause menu)

Debug Mode - tab (note that the debug info wont go once you press tab again, this is on purpose, but will be changed in the future)


PS. performace is usually above 90fps or less than 15ms, i think there were only lag spikes because i was recording
