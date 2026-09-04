# Devlog 5 - Procedural Terrain (FINALLY!!) :headbanging_parrot:

---

I made a start at making the procedural terrain and a few other stuff.

---

## Elephant in the Room - Procedural Terrain

Technically calling it procedural terrain is cheating a bit, cos really all it is right now is perlin noise applied to each vertex's height. And with that, you can change the shape of the terrain by changing the values of some variables, like the seed, frequency, and octaves. I exported these variables so I could change them in the editor, and added ```@tool``` at the start so I can see it in the editor.

I'm working on a chunk system, which will load and unload chunks of the world as the player moves about.


---

## Player Model

I finished modelling the player (added this version to the game) and added the bones for rigging, except when I move the arm bone, the helmet deforms, so next time I will be doing some weight painting :mild-panic-intensifies:

Thankfully UV unwrapping is done as well so I should be able to texture everything before the next devlog.

Also, addressing my last devlog, I said Lapse wasn't syncing with hackatime. Turns out, if I just told it to create a new project called Celestial (which is what my project is called on hackatime), it'll just add the time to it, so thats amazing!!!


---

## The ```WorldEnvironment``` Node

I accidentally deleted my old configuration of this node while experimenting with stuff, and so I made some changes to the shading of the world. Next up is to recalculate all the normals of each triangle so shadows can be cast properly. I tried using SSAO, but every time I used that to make some sort of shadow, it changed depending on where the camera was and it made the terrain very pixelated.