# Devlog 6 - Chunks \#1

---

Previously, I had it so that the entire world was one big mesh, that could not be expanded without unloading and reloading the whole thing and more. This is obviously very inefficient, especially if I want the terrain to load in and out based on where the player is. Chunks is the answer to that. Split the world into chunks of your choice (I chose 16x16), and load/unload just the chunks you need to, not the whole thing.

It seemed easy for me at first, clearly it wasn't (the #1 for the header, ik this isnt gonna be the only devlog on this :sob:).

---

## Bug 1 - The Normals aren't normal :nerdy:

Last devlog, I talked about calculating the normals, which went smoothly. For the old mesh. You see, to calculate normals, you need the vertices surrounding the vertex your trying to find out, and with chunks, that meant every 16 vertices, the normals were being calculated incorrectly, causing seams to be found in the terrain. However, since we did calculate the normals (for the most part, some pretty nice shadows have been cast on our terrain).

Despite it being a bug, it is useful to find out where the chunk boundaries are, which is EXTREMELY useful for debugging, so I haven't tried fixing it just yet.


## Bug 2 - Not so Good Performance :exhausted:

After dividing the terrain into chunks, and making new chunks generate when the player moved into a new chunk, I tested it out. And every time I tried to cross a chunk border, there would be a huge lag spike. This would be caused by the fact the game prioritised the generation of chunks instead of the game. Thankfully I was able to make it so that the chunks would load whenever the processor was ready, to make sure not to overload it too much.


## Bug 3 - (Lack of) Collisions :shocked:

Another reason why chunks are useful is for limiting the area with active collisions. When the terrain was one big mesh, the entire mesh had active collisions, which would all be checking if something hit it. Which is why I limited the area with collisions to a small radius around the player. While coding it, many logic erros came up, such as one that caused the collisions to just not work. :blobby-confused: 
