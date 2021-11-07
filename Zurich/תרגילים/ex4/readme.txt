shirley.m.h
206145245

batsheva77
205505001

website used:
https://www.youtube.com/watch?v=2qF6W6z6VHk
https://docs.unity3d.com/Packages/com.unity.shadergraph@7.1/manual/Arccosine-Node.html
https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Sign-Node.html
https://docs.unity3d.com/Packages/com.unity.shadergraph@6.9/manual/Step-Node.html
https://answers.unity.com/questions/609021/how-to-fix-transparent-rendering-problem.html
https://catlikecoding.com/unity/tutorials/scriptable-render-pipeline/transparency/

About the bonus:
We were inspired by Escher's work:
https://www.wikiart.org/en/m-c-escher/sphere-spirals
We decided to create a shader\material with the same illusation of spiral transparent colored object.

We loved the idea of creating a shader using code only (without an image as texture) and decided to make it colorful with a gradient.
The value of the color of each pixel is decided by the position of the point, like Jonathan showed us in the TA.
We decided to make a moving material (like the waves of the water), so the spiral is animated spinning around the objects surface.

At first, when we made the spiral transparent, the back of the object wasn't visible. This is because Unity only renders the front by default.
We wanted the material to be transparent in a way so that you could see the back part of the object.
After some research we found 'Cull Off' option, that turns off Unity's Culling optimization - that does not render polygons that are not facing the viewer. 
After doing that, all faces are properly drawn, and we get the transparent effect we wanted.

We wrote the code of the shader in a way that allows the user to change its properties from the scene:
- shouldAnimate: a toggle that controls whether the shader move or stay static
- numOfRibbons: an integer that defines the number of spirals in the shader.
- speed: a float number which defines the speed of the spinning.
- distance_reciprocal: a float number that controls the curviness of the ribbons. Lower values will create curvier spirals.

Please notice this shader can be a heavy load on the computer while running (when animated), because the color of every pixel - and not just the pixels in the front - is calculated at all times.

We hope you will like our shader!