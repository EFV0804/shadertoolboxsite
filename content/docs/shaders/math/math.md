---

title:  "math"
---

<script type="text/javascript" async
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
</script>

# Math
I can't seem to get used to the traditional math syntax, everything seems a lot simpler in code form in my eyes. So I made this page as quick reference to look up formulas and what the code form looks like.

# Vectors
## Vector normalisation
A normalised, or unit, vector, is a vector with the same direction as the given vector but with a length of 1.
How to get a normlised, or unit, vector from a given vector:
$$
\hat{v} = \frac{\vec{v}}{\left \| \vec{v} \right \|}
$$
Or to put it in a more code friendly way:
~~~ glsl
    vec3 normalised_v = v/v_length;
~~~
 and in GLSL:

 ~~~ glsl
    vec3 normalised_v = normlize(v);
 ~~~

## Dot products
In algebra a dot product is equivalent to this operation:

$$
\vec{a} \cdot \vec{b} = (a_{x}b_{x})+(a_{y}b_{y})+ ... + (a_{n}b_{n})
$$

and in GLSL:
~~~glsl
float d = dot(a,b);
~~~
A dot product is defined by the following formula, where $\Theta$ is the angle between a and b:
$$
\vec{a} \cdot \vec{b} = \left\| \vec{a}  \right\|\left\| \vec{b}  \right\| \cos\Theta
$$

That doesn't really help by itself. But if we also know that \\( \cos \frac{\pi}{2} = 0 \frac{\pi}{2} \\) means 90° for the math impaired like me, then we know that:
$$\vec{a} \cdot \vec{b} = 0$$
And that incredibly useful, because it means that we can use a dot product of two vectors to know if they are perpendicular or _orthogonal_.

Another cool thing to know: if two vectors are codirectional, meaning the angle between them is 0, and $\cos0 = 1$, then:
$$
\vec{a} \cdot \vec{b} = \left\| \vec{a}  \right\|\left\| \vec{b}  \right\|
$$

Firstly that can help us know if to vectors are parallel or not. And secondly, this implies that if we do a dot product of a vector with itself the dot product is equal to the length of the vector times itself:

$$
\vec{a} \cdot \vec{a} = \left\| \vec{a}  \right\|\left\| \vec{a}  \right\|
$$
or 
$$
\vec{a} \cdot \vec{a} = \left\| \vec{a}  \right\|^{2}
$$

and that in turn implies:
$$
\left\| \vec{a}  \right\| = \sqrt{\vec{a} \cdot \vec{a}}
$$

and that's the same thing as:

$$
\left\| \vec{a}  \right\| = \sqrt{a_{1}^{2}+ a_{2}^{2} + ... +a_{n}^{2} }
$$

Which is how we figure out the length of a vector. Neat.

## Vector Magnitude
As explained right above the formula for the magnitude or length of a vector is:

$$
\left\| \vec{v}  \right\| = \sqrt{v_{1}^{2}+ v_{2}^{2} + ... +v_{n}^{2} }
$$

In code form:
~~~glsl
    vec3 v;
    float v_length = sqrt(v.x*v.x + v.y*v.y);
~~~

in GLSL:
~~~glsl
    vec3 v;
    float v_length = length(v);
~~~
## Vector Projection
A vector projection is like rotating a vector until it is parallel to another vector. It can also be thought of as the shadow that a vector would project onto another vector. To figure out what the vector projection of a vector onto another is, we need to figure out the __scalar projection__. Once we have that, we can figure the vector projection.


<div style="vertical-align:middle; text-align:center">
    <img src="/math/vector_projection.png"/>
</div>

---
### Properties of vector projecitons
* projb a = 0 if \\(\Theta\\) = 90°
* projb a and \\(\vec{b}\\) have the same direction if 0° ≤ \\(\Theta$ < 90°\\)
* projb a and \\(\vec{b}\\) have opposite directions if 90° <  \\(\Theta$ ≤ 180°\\)


------
There are two ways of calculating that projected scalar and vector: either with the angle \\(\Theta\\) if it is known, or with vector a and b.
### Vector projection in term of \\(\Theta\\)
The formula for the scalar projection looks like this:

$$
scalar = {\left \|\vec{a} \right \|} cos \Theta
$$
 and the vector projection looks like this, \\(\hat{b}\\) meaning a unit vector with same direction as \\(\vec{b}\\):

 $$
projba = scalar\, \hat{b}
 $$

 or if we expend that using the formula for unit/normalised vectors:

 $$
projba = \left (\left \| \vec{a} \right \|\cos \Theta   \right )\frac{\vec{b}}{\left \| \vec{b} \right \|}
 $$

And in code would look something like this:
~~~glsl
vec3 proj = (length(a)*cos(theta))*normalize(b);
~~~

-----------
### Vector projection in terms of a and b
When we don't know what \\(\Theta\\) is, wee can figure it out using the following property of a dot product:

$$
\frac{\vec{a}\cdot\vec{b} }{\left \|\vec{a} \right \| \left \| \vec{b} \right \|} = \cos \Theta 
$$

So the scalar projection formula in terms of \\(\Theta\\) that we saw before becomes:
$$
scalar = {\left \|\vec{a} \right \|}\frac{\vec{a}\cdot \vec{b}}{\left \| \vec{a} \right \|\left \| \vec{b} \right \|}
$$
Which can be simplified to:
$$
scalar = \frac{\vec{a}\cdot \vec{b}}{\left \| \vec{b} \right \|}
$$

Now to figure out the vector projection, which is still  \\(proj=scalar \,\hat{b}\\), we can do this:

$$
proj = \frac{\vec{a}\cdot \vec{b}}{\left \| \vec{b} \right \|} \frac{\vec{b}}{\left \| \vec{b} \right \| }
$$

or:
$$
proj = (\vec{a} \cdot\hat{b})\hat{b}
$$

All that to say that to get a vector projection in code you can use the following code without having to wonder if you know \\(\Theta\\) or not:

~~~glsl
vec3 proj = dot(a,normalize(b))*normalize(b);
~~~