# Devlog 11 - General updates 2.0 :shrug-1: 

## Editor Tools!! - (to see the terrain in the editor)

So in a previous devlog, I think I talked about how I added `@tool` in my terrain generation program to be able to see it in the editor. Once I made it dependent on the player position, it didn't generate in the editor because the player wasn't loaded in. So now I made it so that if the script was running while the editor (not the game) is open, the terrain would generate around `(0, 0)` based on how ever big the render distance is. Also I made it so that if you tweak the value of any of the primary noise settings in the editor, it updates in the editor. 

On top of that, I set the viewport to display wireframe so that I can see the triangles at different resolutions, which is where I came across:....


### FLOATING POINT ERRORS!!! :cheer-cat: ~~(yay :exhausted: )~~

I noticed that if I set the resolution to a decimal value that was not a power of 2, the triangles would be off by some amount, causing neighbouring triangles to overlap each other, causing normal and collision problems. The resolution variable is going to be eventually used for LODs, so since I'll be the only setting it, I'll just make sure to use a value thats a power of 2 :smirk-hole: 

The reason why this happens is because 16 (my chunk size) can be multplied and divided by 0.125 (2^-3) evenly to create an integer, compared to 0.1 which results in 1.6. Any smaller power of two is rounded it to the nearest 3dp, so 0.0625 (2^-4) doesn't work. 

---

## Camera Issues

So I made functionality with the camera where you can scroll to zoom the camera in and out, and if you scroll far enough in, you'll be in first person, much like how it works in Roblox. There was one problem though. Since the material for the visor on the player model was somewhat transluscent, your view would get darker. Also, you could free look inside the helmet, looking at the areas I ~~wasn't bothered to model and texture~~ hadn't modelled. So I disabled that in first person.

---

## The biggest timewaste of my life

In an attempt to offload some of the generation to the GPU for more effecient parallel processing, I tried to figure out which parts of the algorthim were going to be handled by the CPU and GPU. There were some that had to be handled by the CPU, and there was no choice about those, and they were: collisions and figuring out what chunks should be rendered. At first I thought, how about I offload nearly everything to the GPU, including the noise function. Then I learnt that `FastNoiseLite` didn't exist in `.gdshader`. So I did what any normal person would do, and CODE PERLIN NOISE BY HAND. I spent HOURS learning everything my dumbass could about it: vectors, normals, gradients, deviation, erosional generation, and finite difference approximation. At least I probably learnt something useful for FSMQ 🤷 (a British maths exam most students do in yr11 along with their other GCSEs).

