live demo: https://kstjxy.github.io/hw01-fireball/


# [Project 1: Noise](https://github.com/CIS-566-Fall-2022/hw01-fireball-base)


## Introduction

In this project, I developed a heart-shaped fireball that dynamically evolves with a pulsating effect that expands outward in sync with a heartbeat. To achieve this, I modified the rendering pipeline by creating a screen-sized square that remains fixed and locked in position (no rotation or zoom). The vertex shader passes the unchanged vertex positions directly to the fragment shader. In the fragment shader, I implemented a ray-tracing algorithm alongside noise generation to simulate the transformation of the fireball. The shape and behavior of the fireball are influenced by mouse position detection, adding an interactive element to the visual.


## Noise Generation and Application

The fragment shader employs noise generation to create dynamic and organic effects. The core noise function takes a 3D position (vec3 x), separates its integer and fractional components (floor() and fract()), and applies smooth interpolation to the fractional part. The hash() function generates random values based on the integer coordinates, and linear interpolation ensures smooth transitions between values, resulting in Perlin noise. The fbm() function enhances this by combining multiple layers of noise (multi-octave) at varying frequencies and amplitudes, adding depth and complexity to the effect. These noise values are integrated into the distanceFunc() and volumeFunc() functions to modify the fireball’s appearance, creating intricate variations in its surface and structure.


## Interactivity

Interactivity is a key component of this project. The noise generation is influenced by variables such as frequency, amplitude, and wavelength. I incorporated slider controls for these parameters, allowing real-time adjustments to the fireball’s behavior. Additionally, the fireball is divided into different sections, each of which can have its color changed independently via a color selector in the controller. This adds a layer of customization to the visual effect.


## Extra Features

An added feature of the project is a mouse-based interaction effect. A glowing ring follows the mouse cursor across the screen, influencing the noise pattern and subtly altering the fireball’s appearance. This effect enhances the sense of interactivity and makes the scene feel more responsive and dynamic.


## Picture:

![hw1](https://github.com/user-attachments/assets/4699bd51-04a6-4248-b579-eddb99e9e273)

