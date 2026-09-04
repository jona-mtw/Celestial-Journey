# Devlog 1 - Player Movement 9th Aug 2026
---
Okay I know what your thinking. 12 hours for just player movement. Surely you must be wasting time just to get as much stardance as possible. The thing is.. I've never used Godot before. 

Everything from the node tree, to project settings was all pretty much new to me. I should have honestly done the WarioWave Godot mission thingy, so that I would have at least been fimilarised with how Godot worked in 3D. And here I am thinking about making a game where you explore a procedurally generated world.

Never before have I touched Godot, and I'm dreaming of making a game with procedural terrain, like in Minecraft or No Mans Sky.

---

## Time Waste No. 1 - Learning Godot :godot:

I had to look through the docs just to figure out how to assign a key to going forwards, mind you all the code needed is given to you when you use the PlayerCharacter3D class. This is on of the many things I struggled with in Godot. :sob:

## Time Waste No. 2 - Experimenting with player models in blender :blender:

I experiemented with different styles of player models to use in the game, and I landed on one inspired from the infamous space game Kerbal Space Program. :kerbalspaceprogram:

## Time Waste No. 3 - Being petty about a camera system :camera:

I think this is what took up most of my time. As soon as I made a moveable player that doesn't fall through the ground (a very quickly made glorified cube in blender), I thought about adding a third person camera. 

I initially thought of making it toggleable, like in Minecraft, where you press F5, it toggles between first, second(?) and third person. But you can't change the distance away the camera is from the player in third person. Besides, my stupid ass made it so that each time you pressed F, the camera would keep zooming out endlessly instead of toggling between first and third person.

So instead I made it zoomable, like in Roblox. First I tried to manually change the offset based on the scroll wheel (that took me so much time because I had no clue how to get inputs from the scroll wheel). But that posed a problem, which was that the player could clip through walls.

Then I found there was a literal node called SpringArm3D to do all of this for me :sob:

And its so useful, like I can change how much it zoom's out by my just changing one variable, and it automatically detects collisions an stops clipping through them. This may seem like somehting that is really basic to some of you who have actually cared to read this far (ty btw :)) but this was crazy for me.

---

lmao this feels like smth to convince ppl that i wasnt afk or smth to farm stardust. i PROMISE im not trying to farm them, although i would love to get some, im not trying to cheat the system guys :sob:

<video controls src="Screen Recording 2026-08-08 163323.mp4" title="Title"></video>