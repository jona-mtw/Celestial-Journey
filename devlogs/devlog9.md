# Devlog 8 - Player Animation!!

---

## Walking and Idle Animations

I finished a basic walking and idle animation for the player. The walking animation is also somewhat inspired from the kerbals from KSP. Both the animations are kinda choppy, especially when the animation loops round, but ~~frankly icba~~ I didn't have enough time to fix them rn (mbmb :sob:). Thankfully the walking animation is timed properly so that the player doesn't look like its sliding around.


## Camera updates

I added functionality to the camera where you can freelook around the player when holding the right mouse button. Once released, it goes back to the normal position (motion is lerped).


## Prepartions for next steps

For the next steps, I want to go back to the ```terrain_generation``` program and start to add variation across the world (like biomes, mountains, etc.). I'm also looking to optimise it, making it generate terrain and collisions faster in prepartion for any future implementation of faster travel. So I added functionality that can allow me to make LODs, which will likely be implemented next devlog.