# [Project 1: Fireball](https://github.com/CIS-566-Fall-2022/hw01-fireball-base)

## Christine Kneer

Live Demo link: https://jiaomama.github.io/hw01-fireball/

For this assignment, I created a procedural fireball inspired by Sawada Tsunayoshi’s Dying Will flame ability from the anime *Katekyo Hitman Reborn!* series. 

<p align="center">
    <img src="https://github.com/user-attachments/assets/d1fd5fc1-c94a-40a4-b5c1-c19a70f11286" width="600"/>
</p>

<p align="center" float="middle">
  <img src="https://github.com/user-attachments/assets/0019c1ca-910a-4df6-b961-9acf82ed282e" width="25%">
&nbsp; &nbsp; &nbsp; &nbsp;
  <img src="https://github.com/user-attachments/assets/414481b5-8c19-4b65-8f87-529e582fdaa0" width="45%">
</p>


## Vertex Shader Breakdown
The Dying Will Flame has a distinctive shape characterized by two triangles extending outward from the body of the flame. To replicate this iconic shape, the fireball was divided into a top half and a bottom half, each treated differently to achieve the desired effect.

### **Top Half**

<p align="center">
    <img src="https://github.com/user-attachments/assets/ec43fa10-674b-46cd-b3c7-17a505ddb91b" width="400"/>
</p>

- **Triangle Wave**: The iconic triangular shape is created using a triangle wave applied to the vertices. To make them more spread out, I rotated the vertices outward additionally.
- **Distortion**: The vertices are further distorted using a combination of sine and cosine waves of varying magnitudes, giving the flame a more dynamic and natural appearance.
- **Fine Detail**: Finally, a small amount of Fractional Brownian Motion (fBm) noise is applied to add finer details to the flame, enhancing its complexity.

### **Bottom Half**

<p align="center">
    <img src="https://github.com/user-attachments/assets/d81c1545-88ac-4a3e-9207-e19510a1fe39" width="400"/>
</p>

- **Base Shape**: The bottom half maintains a general spherical shape, but with a slight taper towards a point at the center.
- **Radius Adjustment**: The radius is adjusted using a linear interpolation (lerp) based on the absolute value of the x-coordinate, creating the tapered effect.
- **Distortion and Noise**: Similar to the top half, sine and cosine waves of varying magnitudes are applied for a more flame-like appearance, followed by fBm noise for additional detail.

### **Bringing It Together**

<p align="center">
    <img src="https://github.com/user-attachments/assets/ae2096a8-2241-4f83-875a-6aa8f72dfae3" width="600"/>
</p>

- **Smooth Transition**: To ensure a seamless transition between the top and bottom halves of the flame, the radii from both halves are interpolated (lerped) in the middle part of the sphere, resulting in a smooth and cohesive flame shape.
- **Animation**: Distortion are animated using the time variable.

## Fragment Shader Breakdown

### **Diffuse Color**
A vertical gradient is applied to the fireball, blending from u_LowerColor at the bottom to u_UpperColor at the top.

<p align="center">
    <img src="https://github.com/user-attachments/assets/9f091268-5cbb-4cd9-9d84-0a407b375b74" width="400"/>
</p>

### **Perlin Noise for Flame Details**
I wanted more dynamics for my fireball, so I added random spots to the fireball’s surface.These spots are animated over time and appear where the noise value exceeds a set threshold.

<p align="center">
    <img src="https://github.com/user-attachments/assets/d4860e55-b714-4bfd-be74-aae3a14adeb8" width="400"/>
</p>


### **Lighting Effects**
Instead of a PBR approach, I wanted more of a 2D, manga-looking appearance, so I chose to use some variation of **toon shading**. The shader applies toon shading by quantizing the light intensity into distinct bands, giving the flame a cartoon-like appearance with sharp transitions. Meanwhile, I added rim lighting, emphasizing its silhouette. Finally, I adjusted the alpha value to create a slight transparency towards the edges of the flame.

<p align="center">
    <img src="https://github.com/user-attachments/assets/1bcf7b8e-0407-4982-b3c1-396ce7524a0c" width="400"/>
</p>

## Background
I also created an animated sun background that pulses together with the fireball, whose color is a relatively simple gradient (with sin waves) of red, orange, and yellow based on uv.

<p align="center">
    <img src="https://github.com/user-attachments/assets/e125fd23-7246-4b1c-96f7-b45aa9f9d9d9" width="800"/>
</p>


## Objective

Get comfortable with using WebGL and its shaders to generate an interesting 3D, continuous surface using a multi-octave noise algorithm.

## Getting Started

1. Fork and clone [this repository](https://github.com/CIS700-Procedural-Graphics/Project1-Noise).

2. Copy your hw0 code into your local hw1 repository.

3. In the root directory of your project, run `npm install`. This will download all of those dependencies.

4. Do either of the following (but I highly recommend the first one for reasons I will explain later).

    a. Run `npm start` and then go to `localhost:7000` in your web browser

    b. Run `npm run build` and then go open `index.html` in your web browser

    You should hopefully see the framework code with a 3D cube at the center of the screen!


## Developing Your Code
All of the JavaScript code is living inside the `src` directory. The main file that gets executed when you load the page as you may have guessed is `main.js`. Here, you can make any changes you want, import functions from other files, etc. The reason that I highly suggest you build your project with `npm start` is that doing so will start a process that watches for any changes you make to your code. If it detects anything, it'll automagically rebuild your project and then refresh your browser window for you. Wow. That's cool. If you do it the other way, you'll need to run `npm build` and then refresh your page every time you want to test something.

## Publishing Your Code
We highly suggest that you put your code on GitHub. One of the reasons we chose to make this course using JavaScript is that the Web is highly accessible and making your awesome work public and visible can be a huge benefit when you're looking to score a job or internship. To aid you in this process, running `npm run deploy` will automatically build your project and push it to `gh-pages` where it will be visible at `username.github.io/repo-name`.

## Setting up `main.ts`

Alter `main.ts` so that it renders the icosphere provided, rather than the cube you built in hw0. You will be writing a WebGL shader to displace its surface to look like a fireball. You may either rewrite the shader you wrote in hw0, or make a new `ShaderProgram` instance that uses new GLSL files.

## Noise Generation

Across your vertex and fragment shaders, you must implement a variety of functions of the form `h = f(x,y,z)` to displace and color your fireball's surface, where `h` is some floating-point displacement amount.

- Your vertex shader should apply a low-frequency, high-amplitude displacement of your sphere so as to make it less uniformly sphere-like. You might consider using a combination of sinusoidal functions for this purpose.
- Your vertex shader should also apply a higher-frequency, lower-amplitude layer of fractal Brownian motion to apply a finer level of distortion on top of the high-amplitude displacement.
- Your fragment shader should apply a gradient of colors to your fireball's surface, where the fragment color is correlated in some way to the vertex shader's displacement.
- Both the vertex and fragment shaders should alter their output based on a uniform time variable (i.e. they should be animated). You might consider making a constant animation that causes the fireball's surface to roil, or you could make an animation loop in which the fireball repeatedly explodes.
- Across both shaders, you should make use of at least four of the functions discussed in the Toolbox Functions slides.


## Noise Application

View your noise in action by applying it as a displacement on the surface of your icosahedron, giving your icosahedron a bumpy, cloud-like appearance. Simply take the noise value as a height, and offset the vertices along the icosahedron's surface normals. You are, of course, free to alter the way your noise perturbs your icosahedron's surface as you see fit; we are simply recommending an easy way to visualize your noise. You could even apply a couple of different noise functions to perturb your surface to make it even less spherical.

In order to animate the vertex displacement, use time as the third dimension or as some offset to the (x, y, z) input to the noise function. Pass the current time since start of program as a uniform to the shaders.

For both visual impact and debugging help, also apply color to your geometry using the noise value at each point. There are several ways to do this. For example, you might use the noise value to create UV coordinates to read from a texture (say, a simple gradient image), or just compute the color by hand by lerping between values.

## Interactivity

Using dat.GUI, make at least THREE aspects of your demo interactive variables. For example, you could add a slider to adjust the strength or scale of the noise, change the number of noise octaves, etc. 

Add a button that will restore your fireball to some nice-looking (courtesy of your art direction) defaults. :)

## Extra Spice

Choose one of the following options: 

- Background (easy-hard depending on how fancy you get): Add an interesting background or a more complex scene to place your fireball in so it's not floating in a black void
- Custom mesh (easy): Figure out how to import a custom mesh rather than using an icosahedron for a fancy-shaped cloud.
- Mouse interactivity (medium): Find out how to get the current mouse position in your scene and use it to deform your cloud, such that users can deform the cloud with their cursor.
- Music (hard): Figure out a way to use music to drive your noise animation in some way, such that your noise cloud appears to dance.

## Submission

- Update README.md to contain a solid description of your project
- Publish your project to gh-pages. `npm run deploy`. It should now be visible at http://username.github.io/repo-name
- Create a [pull request](https://help.github.com/articles/creating-a-pull-request/) to this repository, and in the comment, include a link to your published project.
- Submit the link to your pull request on Canvas.
