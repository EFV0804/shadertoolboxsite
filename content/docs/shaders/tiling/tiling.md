---
title:  "tiling"
weight: 2
---
# Tiling
This chapter covers the basic technique used most often in fragment shaders, especially when generating procedural textures: tiling. You can find a ShaderToy implementation below.

<iframe width="504" height="288" frameborder="0" src="https://www.shadertoy.com/embed/DdlSz2?gui=true&t=10&paused=true&muted=false" allowfullscreen></iframe>

## Explanations
### Fragment Coordinates
If we look at a typical fragment shader's main function's signature, on shaderToy for exemple, the input is a set of coordinates, and the output is a color. 

~~~glsl
    main(out vec4 fragColor, in vec2 fragCoord){}
~~~

And that is essentially all we do in fragment shaders, convert coordinates into colors to display. The coordinates we receive as an input correspond to the fragment being rendered.

For more information about the rendering pipeline, you can check out this [channel](https://www.youtube.com/@cem_yuksel) with great lectures given by Cem Yuksel at the University of Utah.

If you're using VsCode with glslCanvas or similar extensions, your main function does not take in any parameters, and instead uses [gl_FragCoord](https://registry.khronos.org/OpenGL-Refpages/gl4/html/gl_FragCoord.xhtml), and gl_FragColor as input and output.
{: .alert .alert-info}

By convention, the coordinates are named st, to differentiate them from uv which is used for textures, and xy, with is used for position, but they correspond to the same idea, a vertical axis and a horizontal axis. The value of gl_FragCoord as it is passed into a fragment shader corresponds to the size of the canvas, or frame, or window, the space which will display the fragments.

We can visualise those coordinates using the color value we return.

~~~glsl
    main(){
        vec2 st = fragCoord;
        vec3 color= vec3(st.s, st.t, 0.0);
        fragColor = vec4(color,1.0);
    }
~~~

<div style="vertical-align:center; text-align:center">
    <img src="/tiling/coordinate_to_color_not_normalised.PNG" width="200" height="200"/>
</div>

And we get yellow, because red + green = yellow, and the red and green component seem to be equal to 1 everywhere on the screen. That's because *fragCoord* corresponds to the size of our canvas, which probably goes way past 1 in value, and the output color varies between 0 and 1.

### Coordinates and Resolution
The fact that our coordinates can't be accuratly represented using color is gonna be a problem for us, because, well it's what we're trying to do. And also because coordinates might change as the canvas might be resized. To fix this we can **normalise** our coordinates, which just means that we can make sure that they go from 0 to 1. A nice, constant, normalised, simple range that we can work with.

For this we'll use the *iResolution* variable is a *uniform*, which can be thought of as sorts of "parameters" passed to our shader by the program running it. In the case where you are using ShaderToy or VsCode extensions, this is a built-in uniform corresponding to the size of the canvas. It's iResolution for ShaderToy and u_resolution for glslCanvas.

To normalise the coordinates, we can simply divide them by the resolution, like we can normalise vectors, by dividing them by their length. Same idea.

~~~glsl
    main(){
        vec2 st = fragCoord.xy/iResolution.xy;
        vec3 color= vec3(st.s, st.t, 0.0);
        fragColor = vec4(color,1.0);
    }
~~~

<div style="vertical-align:center; text-align:center">
    <img src="/tiling/coordinate_to_color.PNG" width="200" height="200"/>
</div>

Now when we map the coordinates to the color, we get two cool gradients. A first red gradient going from 0 to 1, so no red at all to full red, depending on how far along the horizontal axis we are. Same for green. And that's pretty neat. It's important to note that (0,0) is located at the bottom left.

### Tiling
To tile our canvas we can start by scaling up ou coordinates. Say by 3.
~~~glsl
    main(){
        vec2 st = fragCoord.xy/u_resolution.xy;
        st *= 3.;
        vec3 color= vec3(st.s, st.t, 0.0);
        fragColor = vec4(color,1.0);
    }
~~~
<div style="vertical-align:center; text-align:center">
    <img src="/tiling/scaled_coordinates.PNG" width="200" height="200"/>
</div>
 We can see now that our cool gradients are still there, but they stop at a third of the canvas' height. Which makes sens because our coordinates are not normalised anymore. Tragedy. they now go from 0 to 3.

 However, something that still goes from 0 to 1 is the fractional part of the coordinates, meaning anything after the decimal point. We can use that.
 
 We can think of the coordinates as forming two distinctive informations. The first: the fractional part of the coordinate, the normalised tile coordinate, that repeats every tile. the second: the integral part of the coordinate, which changes with every tile.

 <div style="vertical-align:center; text-align:center">
    <img src="/tiling/tile_diagram.png" width=100% height=100%/>
</div>

So if we extract the fractional part of the coordinates and map them to the color, we should get the cool gradients but repeated 3 times. To do that we can use the GLSL built in function *fract()* which return the fractional part of a number, and use the new *f_st* variable as color values. For more info on the *fract()* function: the [Khronos Group Doc](https://registry.khronos.org/OpenGL-Refpages/gl4/html/fract.xhtml)

~~~glsl
    main(){
        vec2 st = fragCoord.xy/u_resolution.xy;
        st *= 3.;
        vec2 f_st = fract(st);
        vec3 color= vec3(f_st.s, f_st.t, 0.0);
        fragColor = vec4(color,1.0);
    }
~~~

 <div style="vertical-align:center; text-align:center">
    <img src="/tiling/scaled_coordinates_fractional.PNG" width=200 height=200/>
</div>

And that's pretty much how we make tiles. For an exemple of how tiling is used, go to the [brick tutorial]({{<ref "/docs\shaders\tutorials\bricks\bricks.md">}} "a tonne of bricks"). And here's the ShaderToy implementation.


<iframe width="640" height="360" frameborder="0" src="https://www.shadertoy.com/embed/DdlSz2?gui=true&t=10&paused=true&muted=false" allowfullscreen></iframe>
