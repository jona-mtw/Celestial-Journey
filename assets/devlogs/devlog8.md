# Devlog 8 - Player Model and other assets!

---

## Player Model

I finished with texturing, rigging and weight painting. :partyparrot:
Next Step is to make the walking and jumping animations.


## Worked on the settings menu

I updated the setting menu layout to account for different settings I'll add in the future


## Stupid Bugs

So when trying to break the terrain generation, I set the speed of the player to like 300 (which it will never be in the game except when in a space ship) but when I tried to do that, the game kept crashing, spitting out an error saying that something didn't exist. It was coming from my ```unload_terrain()``` function. Basically how it works is it checks for all the instances of the ```MeshInstance3D``` node, and checks the name of it. For every chunk that is created, I assigned a unique name to it on creation based on the ```x``` and ```y``` coordinates of it. The function would checking all the nodes, and seeing which ones were out of the "```collision_chunk_size```" radius, and then would delete them. But when going super fast, the processing of things got all weird, meaning that when it tried to delete a chunk, and if it didn't exist, it would crash. So I added a simple ```if``` statement ```if len(child_name_array) > 2:``` (basically it would check if the length of the name was long enough to see if there was the coord data). Stupidly I wrote the greater than sign the wrong way round, which led to me being stumped for SO long on why the terrain was just not unloading.

tldr: > was the wrong way round and cost me hours.