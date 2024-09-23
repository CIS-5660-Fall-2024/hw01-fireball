# [Project 1: Noise](https://github.com/CIS-566-Fall-2022/hw01-fireball-base)

<img width="1439" alt="Screenshot 2024-09-22 at 8 43 54 PM" src="https://github.com/user-attachments/assets/e4828209-f1fb-453b-810c-1fe59e47ae7a">

Fireball in LSD lava noise thing.

Used multiple noise functions to make the spikes on the fireball move, and use a seperate noise function to make the tip of the fireball move around. Then, I nested FBMs to get a marbley noise, displaced the position vector using iTick to make it look like the noise was rising up (even on the floor and ceiling). The surroundings are a large cube acting like a background (without the floor for improved performance). The floor is a larger plane. I added some uniform variables to let the user enter the colour of the floor and ceiling using dat.GUI. The walls lerp between the two. The fireball also mixes its own colour with both those colours to make it look like the light is reflecting off it. Also added a slider that allowed the user to change the fireball's size. 
