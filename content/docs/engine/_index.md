---
weight: 3
bookFlatSection: true
title: "Shader Editor"
_build:
    list: false
    render: true
---
<div style="text-align: justify">

# Shader Editor

> "If you spend too much time thinking about a thing you'll never get it done." - Bruce Lee


These wise words have been the moto of this project.

The goal is to make standalone shader editor using the Vulkan API to support vertex, fragment and compute shader development.
Originally I wanted to make this editor to protype shaders without having to switch an engine like Unity. It quickly turned into an excuse to learn Vulkan and the rendering pipeline, and to improve my C++ skills.

The key features were making a rendering engine capable of supporting all the listed shaders, an engine capable of managing actors, loading meshes, manipulating cameras and making a GUI to input shader code, and to tweak values on the fly.

## Rendering Engine
The first thing I did was to tackle the Vulkan part of the engine. The thing with Vulkan is that it's highly customisable, and as with most things in life, when given too many choices it's hard to make a decision. So I figured that for the sake of my own time and sanity, I should start by wrapping up some of the Vulkan features into classes as a way of organising my code, avoiding redundant code and more importantly limiting the customisation choices that can be made. 

I started by setting up a basic pipeline with vertex and fragment shaders to draw the classic triangle. I used that first setup to encapsulate the main elements used, pipelines, buffers, materials, shaders, swapchain and renderpasses. 

## Engine


## GUI



</div>