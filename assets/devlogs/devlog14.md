# Devlog 14 - LOD chunks 

10hrs to do practically do something I've already done? (i had already made a chunk system in previous devlogs)

Well, whilst some of that time was transferring code from my old commits to the current one and making sure it works, most of the time I spent on this devlog was spent on :sparkles: "optimisation" :sparkles:


## Optimisation

First of all, I added LODs into the chunk mesh. What this means is that since further away chunks take up less of your screen, the level of detail (LOD) is reduced the further away it is. I had already made the script that handled the creation of those different meshes with different LODs, so in this devlog, I added it to the main terrain generation script, and assigned each LOD to a certain distance, so that any chunk with a certain distance has a certain LOD.

---

In my last version of the terrain generation, I relied on the name of the `MeshInstance3d` nodes created to identify what chunk they were. I realised when making this updated version that it was prone to failure, since if the node did not exist or a node with the same name were some how added to the scene tree, errors would be raised or at the very least, a logic error would occur. To recetify this, I switched to using dictionaries to house all the information of all the chunks:
```gdscript
chunks: Dictionary[Vector2i, int] = {
	Vector2i(0, 0): 0,
	Vector2i(0, 1): 0,
	#etc
}
```

The key is chunk coordinate, and the value is the LOD (0 being the highest, 4 being the lowest)

---

Every time I wanted to update the terrain, I would search the scene tree if a particular node was unwanted (again, by looking at the name) and then generating the rest of the ones wanted. 

This way would not work with LODs, since some chunks may still exist, but may have to change LOD depending on where the player is. So I made use of the dictionary and also created a new one that would store the chunks that I want created. It would loop through the dictionarys, checking certain conditions, and the terrain would be updated. All this looping is somewhat inefficient, and did cause some lag spikes, so I will try to fix that next devlog by only checking the chunks that would be affected based on which way the player moved.

---

To help with the looping, I created chunk and lod lookup tables, that can be offset based on the players_position. These lookup tables are only changed when the render distance is changed, so the same calculation doesn't have to run hundreds of times in 16ms (60 fps).