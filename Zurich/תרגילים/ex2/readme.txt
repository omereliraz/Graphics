shirley.m.h
206145245

batsheva77
205505001

website used:
https://docs.unity3d.com/Manual/SL-VertexFragmentShaderExamples.html

Question 1.6: Explain why "Make Flat Shaded" function works - why do separate vertices for
each face cause flat shading?
Answer:
	The color is affected by the light and the light is determined by the surface normal.
	We calculate the surface normal based on the vertices.
	In order to calculate a vertex normal, we use all the different faces that share that vertex.

	In "Make Flat Shaded" - We use another vertex with the same properties (but with a new
	pointer), so each face will still have all the vertices that were in it, but won't have 
	any shared vertices with other faces.

	That way, each vertex (v) is connected to all the other vertices that are in the same 
	face of (v), but because (v) is not included in any other faces (surfaces), its normal 
	will be affected only by its vertex neighbors.

	Instead of having an average normal for each vertex that depends on other normals,
	all vertices that are on the same face will actually be on the same surface (and that
	surface only), meaning they all point to the same direction, so the face will be
	flat and not curved.