# Devlog 7 - Chunks \#2

---


## Bugs
Managed to fix all the bugs related to this part of terrain generation. :partyparrot:

---

### Weird chunk errors

There was an if statement (I changed it out for something else that's more efficient) that was like:
```if abs(player_position.x - chunk_pos.x) > collision_chunk_size or abs(player_position.y - chunk_pos.y) > collision_chunk_size```

This logic error create weird stuttering issues and lag. The fix was to switch ```or``` with ```and```.
:face_exhaling-hole:


### Normals

DEFINITELY the bane of my existence. I know roughly what normals are due to me doing 3D modelling/rendering, but I have no clue how it *actually* works. And plus, I've barely covered the maths I need for this in school, so I spent sooo much time (much of which wasn't recorded) just researching about normals and how they work.

I think that definitely helped me find a solution to the annoying chunk borders and random artifacts found inside each chunk.:godot-tired: 


### Chunk Sizing

I stupidly and randomly changed the chunk size from 16 to 10, which worked completely fine, except for the fact that the player script was still using the 16x16 chunk system, causing the generation to lag behind, eventually leading to the player falling off the map.

---

## New Features
There were also some :sparkles: features :sparkles:  that I added.

---

### Colour

I added colour to the world, and if I match it to the fog and sky, I think it would look AMAZING :pupper-sparkle: 

I will make it so that the colour does vary across the planet.


### Player

I added the rig and refined the topology for animation.