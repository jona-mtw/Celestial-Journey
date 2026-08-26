# Devlog 10

Alright, so ik I said I would work on the procedural terrain, but instead I worked on:...


## Debugging Tools!! (yayy! :partyparrot:)

When ```tab``` is pressed, it toggles on debug mode, where all meshes turn into wireframes (to check LOD) and chunk boudaries are shown. There are problems with chunk boundaries not despawning when the terrain its on is gone, but that's fixed when you toggle debug mode again :). I could fix it but ~~icba~~ I have other stuff that needs to be prioritsed.


## Resizabile UI

So before, if you resized the window, the pause menu and settings menu would be offset from the centre and wouldn't scale with the window. Now when you scale it, the pause and settings menu stay in the centre and scale accordingly.