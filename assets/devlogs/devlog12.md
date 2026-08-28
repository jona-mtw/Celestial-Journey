# Devlog 12 - General updates 3.0 :shrug-1: 

I PROMISE THIS IS THE LAST ONE GUYS :pray:

## Performance Stats

I added a little HUD showing the FPS, the time it takes to make one frame (has to be below 16.67ms (60fps) or there will be noticeable lag), and the memory usage.

---

## Lighting, Shadows, and World Environment

I slightly changed the shadow bias and normal bias so that shadow artifacts are to a minimum. On top of that, I set it so that shadows aren't cast for the terrain, which unintentionally handles with some of the artifacts, whilst keeping the "shadows" by illuminating the terrain depending on where the `DirectionalLight3d` is, making the "shadows" reponsive to a future day-night cycle. Also the volumetric fog and lighting looks better :happi:

---

## Camera Issues 2.0

So previously I had the player `hide()` when you go into first person, but that also effects the shadows. So instead I made the visor disappear when you go into first person. But then there was another problem. The head would move during the idle and walking animations, which is quite distracting and could be problematic for some players. So I stopped the animtions whilst in first person. It is a very rudimentary fix, since players can look at their shadows and see the lack of animation. Furthermore if I want to add multiplayer in the future, it'll look very weird.

---

## Performance checks

In preparation of the biome generation, I wanted to make sure the performance is fine. It takes a bit for the terrain to generate at the start, but thats common across nearly every game. And this will be lightened a bit when I implement LODs. Once the game is running, it runs relatively fine, except with (very quick) lag spikes when the chunks update. To address this, I'm planning of offloading some of the terrain generation to the GPU, which can calculate normals a LOT more effeciently and quicker than the CPU. 
Current, the CPU calculates all the vertices, indices, normals, and then compiles it into an `ArrayMesh`, which is given to the GPU for rendering. This can put a lot of strain on the CPU, especially later down the line, so it's better and more effiecient if the GPU does the very repetetive calculations, by making it do all the normal calculations, including other stuff.