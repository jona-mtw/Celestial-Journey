# Devlog 8 - Player Model and other assets!

---

## Player Model

Finally finished the player model, which is all textured, rigged and animated with walking, running, jumping floating and falling animations. Despite doing 3D modelling before, I've never actually rigged anything myself. I have used rigs before on a pre-made Steve (from Minecraft) model, but I didn't make all the bones myself, I just rotated the bones on certain keyframes. For my player model, I added the bones, parented them, weight painted and then moved them to make animations.


## Finished the settings menu

It's now functional, with it being possible to change the various terrain generation settings, with an added advanced settings mode where you can actually change every single variable used to generate the terrain. With the settings menu also came....


## The main menu!!

I added a main menu, which a background that I made in blender, using the player model and a model of the sun.


## Stupid Bugs

So when trying to break the terrain generation, I set the speed of the player to like 300 (which it will never be in the game except when in a space ship) but when I tried to do that, the game kept crashing, spitting out an error saying that something didn't exist. It was coming from my ```unload_terrain()``` function. Basically how it works is it checks for all the instances of the ```MeshInstance3D``` node, and checks the name of it. For every chunk that is created, I assigned a unique name to it on creation based on the ```x``` and ```y``` coordinates of it. The function would checking all the nodes, and seeing which ones were out of the "```collision_chunk_size```" radius, and then would delete them. But when going super fast, the processing of things got all weird, meaning that when it tried to delete a chunk, and if it didn't exist, it would crash. So I added a simple ```if``` statement ```if len(child_name_array) > 2:``` (basically it would check if the length of the name was long enough to see if there was the coord data). Stupidly I wrote the greater than sign the wrong way round, which led to me being stumped for SO long on why the terrain was just not unloading.

tldr: > was the wrong way round and cost me hours.