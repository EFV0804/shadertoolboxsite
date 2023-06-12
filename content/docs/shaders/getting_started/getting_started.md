---
title:  "getting started"
weight: 1
---
# Learning the basics
To learn to learn the basics of shader editing I've listed the most useul ressources below:

* [The Book of Shaders](https://thebookofshaders.com/) - by [Patricio Gonzalez Vivo](https://patriciogonzalezvivo.com/). It's one of the best ressource to begin shader editing.
* [Inigo Quilez's website](https://iquilezles.org/) - It's not as easy to get into as The Book of Shaders, but it has a lot of very good functions, tutorials, and articles.
* [The Art of Code channel](https://www.youtube.com/@TheArtofCodeIsCool) - Some of us learn a lot better through video. He's uses ShaderToy so it's very easy to get up to speed and follow along.

# Editing

## Online editors
Another option is online editors. There are a lot of them, I'll list a few here.
* [ShaderToy Editor](https://www.shadertoy.com/new) - by Inigo Quilez and Pol Jeremias. It's probably the biggest and most active community. It's a great way to get inspiration and feedback. Fragment shaders only
* [glslEditor](https://thebookofshaders.com/edit.php#12/stippling.frag) - by Patricio Gonzalez Vivo, the same person who brought us glslCanvas and [The Book of Shaders](https://thebookofshaders.com/).
* [GLSL SANDBOX](https://glslsandbox.com/) - Not as active as ShaderToy but has an interesting gallery of shaders. Fragment shaders only.
* [Shdr](http://shdr.bkcore.com/) - allows for vertex and fragment shaders.
* [GSN Composer](https://www.gsn-lib.org/) - A code and node system
* [Shader Factory](https://shader-factory.herokuapp.com/) - simple, it allows for vertex and fragment shaders, and texture input.
* [Shader Playground](https://shader-playground.timjones.io/#) - Allows to manually set compilers

There are a bunch of them.



## VsCode + glslCanvas
If the ShaderToy interface is not doing it for you, or you want to be able to work offline, you can easily set up [VsCode](https://code.visualstudio.com/) to code shaders with the [glslCanvas extension](https://marketplace.visualstudio.com/items?itemName=circledev.glsl-canvas). It's quite complete as it allows passing custom uniforms, and textures, and has a lot of useful features like a color picker. It only requires to be installed as a Vscode extension to work. 

To display a shader, simply open the shader code file in VsCode and hit `ctrl+shift+p` and run the command "Show glslCanvas" which will create a new tab containing a WebGL render of your shader.

<div style="vertical-align:middle; text-align:center">
<figure>
    <img src="/getting_started/vscode_setup.PNG" />
        <figcaption>glslCanvas setup in VsCode</figcaption>
</figure>
</div>



## Standalone
If you need a more complete approach that allows for vertex, geometry or compute shaders for example, you might want to use either an engine like Unity, a standalone editor. I know of only one:

* [SHADERed](https://shadered.org/)