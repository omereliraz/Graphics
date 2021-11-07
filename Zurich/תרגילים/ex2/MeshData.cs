using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class MeshData
{
    public List<Vector3> vertices; // The vertices of the mesh 
    public List<int> triangles; // Indices of vertices that make up the mesh faces
    public Vector3[] normals; // The normals of the mesh, one per vertex

    // Class initializer
    public MeshData()
    {
        vertices = new List<Vector3>();
        triangles = new List<int>();
    }

    // Returns a Unity Mesh of this MeshData that can be rendered
    public Mesh ToUnityMesh()
    {
        Mesh mesh = new Mesh
        {
            vertices = vertices.ToArray(),
            triangles = triangles.ToArray(),
            normals = normals
        };

        return mesh;
    }

    // Calculates surface normals for each vertex, according to face orientation
    public void CalculateNormals()
    {
        //1.4
        //start normals 
        normals = new Vector3[vertices.Count];
        //loop over vertices: 
        for (int i = 0; i < triangles.Count ; i+=3)
        {
            Vector3 p1 = vertices[triangles[i]];
            Vector3 p2 = vertices[triangles[i + 1]];
            Vector3 p3 = vertices[triangles[i + 2]];
            //cross p
            Vector3 n = Vector3.Cross((p1-p3),(p2-p3));
            //normalize
            n = n.normalized;
            

            //add to normals array to calculate later the vertex normal
            normals[triangles[i]] += n;
            normals[triangles[i +1]] += n;
            normals[triangles[i +2]] += n;

        }

        // loop over all vertices and normalize the normal (that we got from the prev calculations) 
        // to get the average vertex normal
        for (int i = 0; i < vertices.Count; i++)
        {
            normals[i] = normals[i].normalized;
        }
    }

    // Edits mesh such that each face has a unique set of 3 vertices
    public void MakeFlatShaded()
    {
        //1.5
        bool[] idxIsUsed = new bool[vertices.Count];
        for (int i = 0; i < triangles.Count; i++)
        {
            if (!idxIsUsed[triangles[i]]){
                idxIsUsed[triangles[i]] = true;
            }
            else
            {
                //add new vertices
                vertices.Add(new Vector3(vertices[triangles[i]].x, vertices[triangles[i]].y, vertices[triangles[i]].z));
                // change face idx
                triangles[i] = vertices.Count - 1;
            }
        }
    }
}