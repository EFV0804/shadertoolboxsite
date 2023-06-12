---
title:  "2D"
weight: 2
---
# 2D Shapes
2D, one less dimension to deal with, ideal for busy people. This section will cover basic 2D Signed Distance Functions, and some of the things you can do with them.

## Signed Distance Functions

Signed Distance Functions are wonderful tools used to describe shapes with mathematical formulas. These descriptions can then be used with various rendering and shading techniques that need to use shapes. In the fragment shader world, it is used a lot with a rendering technique called [raymarching](..\..\rendering_techniques\raymarching.md).

The basic idea is a function that takes a point, and return a distance from that point to the implicit geometry, that's the *distance* part of the name. They are called *signed* distance functions, because the distance returned can be positive, if the point is outside the shape, 0 if it's exactly on the surface, or -1 if it's inside the shape.

Inigo Quilez has a lot of them listed on his [website](https://iquilezles.org/articles/distfunctions/). However he doesn't give explanations for them, so below are explanations on how to come up with some of these functions. A lot of these I understood from the wonderful [The Art of Code](https://www.youtube.com/@TheArtofCodeIsCool/featured) channel who gives theoritical explanations of these functions and then implements them in ShaderToy. I highly recommend his videos.

I'll be repeating a lot of what The Art of Code covers, but I'll try to break down the math a bit more, for the math impaired like me. You can never have too many diagrams.

## Circle

It is the simplest! And it's the same for 2D and 3D. You can find the ShaderToy implementation of what follows [here](https://www.shadertoy.com/view/dl2XDV).

The function looks like this:

~~~glsl
float sdfCircle(vec3 p, float r){
    return length(p)-r;
}
~~~

It takes in the a vector3 _p_, which in this case will be the current coordinate, and a float _r_, the radius.

In order to return the distance to the surface of the circle, we can start by mesuring the distance between the current coordinate's position and the circle's position. To get the distance to the surface, we simply substract the radius from that distance.

<div style="vertical-align:middle; text-align:center">
    <img src="\shapes\2D\SDF_Circle.png"/>
</div>

Implementated in the main function it looks like this:

~~~glsl

    void mainImage( out vec4 fragColor, in vec2 fragCoord )
    {
        vec2 st = (fragCoord.xy-0.5*iResolution.xy)/iResolution.y;
        float d = sdCircle(st,0.2);
        
        vec3 col = vec3(0.);
        
        if(d>0.){
            col = vec3(0.);
        }
        else{
            col = vec3(1.);
        }

        fragColor = vec4(col,1.0);
    }

~~~

Here we set the color to black if the distance from the current fragment coordinate to the circle is greater than 0, so if the current fragment is *outside* the circle. If it's within the circle, the color gets set to white.

For an explanation on the length function, see [here](..\..\math\math.md).

