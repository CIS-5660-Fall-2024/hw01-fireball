# [Project 1: Noise](https://github.com/CIS-566-Fall-2022/hw01-fireball-base)
## Lewis Ghrist : Black Hole / Fire Ball?
## Black Hole : Mode 0
VERTEX SHADER: The base structure is simply a bias displacement along the XZ plane. This gives the base bulge to the sphere and is scaled by the "rad" control. Ontop of that base shape a simple noise is applied to add some variation to the shape. To get that rotation and vortex look, the x and z positions were offset using polar coordinates, a strength parameter, and time. A final layer of time offset fbm noise is then added to add more details and deformations. Note this final noise is passed into the vertex shader for coloring. 

FRAGMENT SHADER: The fragment shader uses a itterative lerp calls with the distance from the origin and a fresnell effect to color the center of the black hole in a way that preserves the outer ring. The outer color comes from a simple procedural cosine based color pallet ([ty IQ](https://iquilezles.org/articles/palettes/)), with some slight additions based on that camera falloff used for the center. The t value passed in this procedural pallet is the noise passed from the vertex shader, giving a more fitting pattern of colors to the swirls. 

![](BlackHole_V1.png)

## White Hole? : Mode 1
VERTEX SHADER: The vertex shader is mostly the same, with the exception of that initial xz bulge being altered. The base "magic" vector which defines the x and z axis to displace along, get altered using a lerp with the cross product between the surface normal and the view vector to that position. This causes a weird warping effect which I was not expecting, but thought looked cool enough to include. A triangle wave displacement was also added ontop to give more detail around the edges. The time offset variable I had was also reversed to give a spiraling outwards effect.

FRAGMENT SHADER: Again, the fragment shader was just a modification of the black hole coloring, using a similar method. I reversed the inside sphere colors and changed the color pallet.

![](WhiteHole_V1.png)
![](WhiteHole_V2.png)

## Background
The background is simply a very large cube that surrounds the entire scene. The vertex shader doesn't do any deformations since I want the sky box to be still. In the fragment shader I use a step function with a worley noise to isolate small points of light as a stary background. Some procedural color is applied based on a noise.




