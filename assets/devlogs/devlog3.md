# Devlog 3 - Flat Plane 11th Aug 22026

I know this sounds INCREDIBLY trivial, but I finally figured out how to make a flat plane in Godot, that can be used to make an actual terrain.

There were 2 main ways that I could have used to make this:

## Method 1:

I can use a PlaneMesh and then subdivide it down into triangles. Then use vertex shaders or custom scripts to displace the plane as a whole based on noise.

| Pros | Cons |
| --- | --- |
| fast to make (just need to subdivide mesh) | not much control (Godot handles each vertex)
| really thats all of the pros, but it is really | hard to make large maps with |
| a lot faster than Method 2 | hard to make chunks with to improve performace
| | thus difficult to make an infinite terrain with |

---

## Method 2:

I can use an ArrayMesh, where I create the grid from scratch, telling Godot how to connect every single vertex to create triangles. The downside to this is how long this took. I know it seems short compared to my first devlog (I think the main reason I took so long in that one was not only because I was learning Godot, but it was also because I was experimenting with player models on Blender but hopefully now I’ll be more time efficient) but it is still more time consuming to tell Godot how to connect each and every vertex. I was in fact so stumped on how to go about doing this that it suddenly came to me when I was playing with my little cousin. I even noted down how to do it on my phones notes app (excuse my bad handwriting I was in the car writing with my finger) :/

| Pros | Cons |
| ---| --- |
| more control over each vertex (you build the grid manually) | time consuming (you build the grid manualy)
| easy to chunk (because you have control over each vertex) | |
| more efficient (idrk how, maybe its cos its less work for the CPU because I'm telling it how to make each triangle?) | |

---

In order to make the actually interesting part of the terrain (which btw I haven't done in this devlog, I guess this is just like a future plans part) I can use either vertex shaders or custom scripts to make noise in the terrain. Both of these have their respective use cases, and I wouldn’t be able to say one is better than the other for my case. 


## Vertex Shaders:
GPU based
no collisions (purely visual)
written in Godot Shader Language (which is written in C, which is terrifying for me who practically only knows Python (GDScript and Python are similar enough for me))

## Custom Scripts:
CPU based
can create collisions (actually changes the vertex's height)
written in GDScript (happy days (ik I can write it in C#, but I'm staying far away from that))

Despite my fear of anything not similar to Python, I will still need to use vertex Shaders. And I will explain that in my next devlog because this is getting too long.

Now onto my struggles incredible skill when making a.. flat plane in Godot.

I chose to do Method 2, because of it’s functionality later down the line. But that means I have to tell Godot what vertices to make, and how to connect them up. Obviously that was as simple as could be.. (you can see my failures in the screen recordings below)