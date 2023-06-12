---
title: "worley"

---
# Worley Noise
---
<iframe width="504" height="288" frameborder="0" src="https://www.shadertoy.com/embed/dtGXRD?gui=true&t=10&paused=true&muted=false" allowfullscreen></iframe>

## Intro
Worley noise was created by Steven Worley and used to make procedural texture for things like, water caustics, stone, cells. The basic logic of the algorithm behind this noise is to measure the distance from every position to  arbitrary points in space (2D or 3D), and to then use that distance to represent something. 
In the case of a fragment shader we would measure the distancec from every fragment coordinate to the arbirtary points, and use the distance as a color value.



---
## Implementation
### A single point
We can start to implement Worley noise with a single point at the center of the canvas, and measuring the distance to that.

~~~ glsl
    vec2 p = vec2(0.5);
    float d = length(st - p);
    vec3 color = vec3(d);
~~~

This code should get us a concentric grey gradient like this:


<div style="vertical-align:middle; text-align:center">
    <img src="/noise/worley/single_point_gradient.PNG"/>
</div>

---
### Several points
We can then use the classic [tiling method](../tiling/tiling.md) and draw a point per tile.

~~~ glsl

    vec2 st *= 3.;
    vec2 f_st = fract(st);
    vec2 p = vec2(0.5);
    float d = length(f_st - p);
    vec3 color = vec3(d); 
~~~

<div style="vertical-align:middle; text-align:center">
    <img src="/noise/worley/tiled_gradient_no_points.PNG"/>
</div>

---
### Visualising the points
So far so good. We can draw the distance to several dots on a canvas. We can add a visual representation of the dots, to help us visualise what is happening. Right now it's not hard to visualise where the dots are, but it might get trickier later and we should think about it now.
~~~ glsl

    color.r += step(0.001, dot(d,d));
~~~

First we get the magnitude of a vec2(d,d). We can simply pass *d* into the dot() function and it will be read as a vec2(d) rather than a single float.

Then using a *[step()](https://registry.khronos.org/OpenGL-Refpages/gl4/html/step.xhtml)* function we can get a value of 0 for everything smaller than 0.001, and 1 for the rest. That gives us a black dot, but also overrides the grey gradient. We can simply inverse our step function but substracting it to 1 to get a white dot and keep our gradient.

<div style="vertical-align:middle; text-align:center">
    <img src="/noise/worley/tiled_gradient.PNG"/>
</div>

---
### The apparent randomness of nature
Our current code looks like a worley noise, if all dots stay neatly in the center of their tile. However, one of the reasons to use the worley noise is to try to reproduce patterns visible in nature. And nature rarely centers things in tiles.

A good start to get a more "natural" looking noise is to add randomness. We could give the points a random position for exemple.

We can use this random function, that I won't explain here, or maybe anywhere else because generating pseudo random numbers on a computer is whole other thing and it can get complicated. Or in short: I'm not sure how it works. But I do know that it takes in a vec2, and returns the fractional part of a "random" vec2. Which is great because that means normalised coordinates for us.

Another important thing to bear in mind with random functions like this: they work with a seed, each unique seed returns a random value. If we keep a record of the seeds, we can get the same random value again and again.

~~~ glsl
vec2 random2( vec2 p )
{
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}
~~~

With this function we can generate a random position for our point when we declare it. We use the *i_st* coordinate as the input to the random function. We do this so that every time we run our shader, at every fragment, the point corresponding to the tile is always in the same postion. Meaning the tile coordinate is used as the random *seed*.

~~~ glsl
    st *= 3.;

    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float d = 0.;

    vec2 p = vec2(random2(i_st));
    d = length(f_st- p);

    vec3 color = vec3(d); 
~~~

And now we can see that illusion of continuity between the tiles is completly broken. The way we measure the distance to the point simply does not account for any of the neighbouring tile.

<div style="vertical-align:middle; text-align:center">
    <img src="/noise/worley/random_position_broken.PNG"/>
</div>
 
---
### Accounting for the neighbouring tiles
To give the impression of continuity we need to check the distance not only from each fragment position in a tile, *f_st*, but also to other points in the other tiles. However, each point doesn't need to check the distance to every other point, just the ones next to it, it's friendly  and loving neighbours.



We can give those neighbours their own coordinate relative to the current main tile, *i_st*, using the logic below.
<div style="vertical-align:middle; text-align:center">
    <img src="/noise/worley/loving_neighbours.PNG"/>
</div>

Using these coordinates, we can make two nested for loops to iterate over the neighbours of a given tile.

~~~ glsl

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            ...
        }
    }
~~~

We can then use the coordinates of the neighbouring tiles with the current tile coordinates to generate the random position.

 We also need to make sure to only keep the closest distance from any given point.

~~~ glsl

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            vec2 neighbour = vec2(x,y);
            vec2 p = vec2(random2( i_st + neighbour));

            min_d = length(p - f_st);
            
            if (min_d < d){
                d = min_d;
            }
        }
    }
~~~

<div style="vertical-align:middle; text-align:center">
    <img src="/noise/worley/random_position_broken_even_worse.PNG"/>
</div>

It gives us these wild looking tiles with a bunch of dots, and despair begins to set in.

But it's all good, because what's happening here basically is that each tile now contains it's own "proprietary" point, and the "proprietary" point of each one of its neighbour. Or in the words of our lord and saviour Inigo Quilez:

>[My implementation does not generate the points in "domain" space, but in "cell" space [...]](https://iquilezles.org/articles/smoothvoronoi/)

If you're into pattern recognition, and you have some time on your hands, you might be able to tell that the tiles have a lot of points in common. That's because they have neighbours in common.

<!-- And in case you don't have time on your hand to stare at points, here's a neat diagram:


            DIAGRAM OF ORIGINAL DOTS + NEIGHBOURING DOTS -->

Now the only thing left to do is measure the distance to each point. The idea here is to measure the distance to each neighbouring point, but withing one tile, in *cell space*. So the distance from *f_st* to *p* (which is normalised), plus the neighbour integral position.

~~~ glsl

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            vec2 neighbour = vec2(x,y);
            vec2 p = vec2(random2( i_st + neighbour));
            min_d = length(p + neighbour - f_st);
        }
    }
~~~


<div style="vertical-align:middle; text-align:center">
    <img src="/noise/worley/random_position_fixed.PNG"/>
</div>

And now we get worley noise that we can tile! Hurray!

It's worth noting that inverting a worley noise gives very satisfying, although some say gross, results.

<div style="vertical-align:middle; text-align:center">
    <img src="/noise/worley/inversed_worley.PNG"/>
</div>

---

## Resources
- [Book of Shaders, Cellular Noise]()
- [Inigo Quilez, Smooth Voronoi](https://iquilezles.org/articles/smoothvoronoi/)