# Devlog 15 - I'm an Idiot

For the past 95ish hours, I've been working on a way to make procedural terrain for my game. I tried 2 main methods, one centred round the CPU, and one I was building centred around the GPU. The endless chunk seam bugs caused me to burnout/get tired of the entire project, and there was so many stuff (that I won't really be explaining for the sake of my poor reader's sanity) leading to me :sparkles: youtube :sparkles:

I saw this AMAZINGLY smart video by [devmar](https://www.youtube.com/watch?v=rcsIMlet7Fw), showing an alternate way of generating terrain. 

I urge you to watch the video as well, the whole technique is very very clever, and he even goes on to make further videos on making collisions, recalculating normals and adding vegetation, especially if your interested in procedural generation.

After watching this video however, I became incredibly frustrated. I spent nearly 100hrs of my summer making this procedural terrain which I know hadn't gotten anywhere and theres this incredibly smart video from 4yrs ago that pops up on my feed.

Welp, now ig i gotta try out this way, and quick cos my parents are on my tail talking about me finishing this project before school starts :pray: (its my gcse year so ig its valid but still :exhausted:)


## Now what I actually did that counted to my time

Experimented with vertex shaders, and sending heightmaps to vertex shaders to displace. This however caused immense lag and caused VERY ANNOYING chunk seams.