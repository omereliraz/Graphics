using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

/**
 * A helper class CCMeshData to hold the data needed for the Catmull-Clark subdivision algorithm
 */
public class CCMeshData
{
    public List<Vector3> points; // Original mesh points
    public List<Vector4> faces; // Original mesh quad faces. A list of quad faces of the original mesh.
    // Each face defined by 4 indices of vertices in the points list

    public List<Vector4> edges; // Original mesh edges. A list of all unique edges in the mesh defined by points & faces
    public List<Vector3> facePoints; // Face points, as described in the Catmull-Clark algorithm
    public List<Vector3> edgePoints; // Edge points, as described in the Catmull-Clark algorithm
    public List<Vector3> newPoints; // New locations of the original mesh points, according to Catmull-Clark
}

/**
 * The Catmull-Clark subdivision algorithm class
 */
public static class CatmullClark
{
    private static readonly int InitIdx = -1;
    private static readonly int Npoints = 4;
    private static readonly float EPSILON = 0.001f;

    // Returns a QuadMeshData representing the input mesh after one iteration of Catmull-Clark subdivision.
    public static QuadMeshData Subdivide(QuadMeshData quadMeshData)
    {
        // Create and initialize a CCMeshData corresponding to the given QuadMeshData
        CCMeshData meshData = new CCMeshData();
        meshData.points = quadMeshData.vertices;
        meshData.faces = quadMeshData.quads;
        meshData.edges = GetEdges(meshData);
        meshData.facePoints = GetFacePoints(meshData);
        meshData.edgePoints = GetEdgePoints(meshData);
        meshData.newPoints = GetNewPoints(meshData);

        // Combine facePoints, edgePoints and newPoints into a subdivided QuadMeshData
        
        // Part 2.2
        List<Vector3> returnPoints = GetAllNewPoints(meshData.facePoints, meshData.newPoints, meshData.edgePoints);
        var returnFaces = GetAllNewFaces(meshData);
        return new QuadMeshData(returnPoints, returnFaces);
    }
    
    // Returns a list of all edges in the mesh defined by given points and faces.
    // Each edge is represented by Vector4(p1, p2, f1, f2)
    // p1, p2 are the edge vertices
    // f1, f2 are faces incident to the edge. If the edge belongs to one face only, f2 is -1
    public static List<Vector4> GetEdges(CCMeshData mesh) // Part 1
    {
        Dictionary<Vector2, List<int>> edgesDict = new Dictionary<Vector2, List<int>>(new Vector2Compater());
        for (var faceIdx = 0; faceIdx < mesh.faces.Count; faceIdx++) // go over all faces
        {
            var face = mesh.faces[faceIdx];
            for (var j = 0; j < 4; j++) // go over all edges in that face and add it to the dictionary
            {
                var curEdge = new Vector2(face[j], face[(j + 1) % 4]);
                if (edgesDict.ContainsKey(curEdge))
                {
                    edgesDict[curEdge].Add(faceIdx);
                }
                else
                {
                    edgesDict.Add(curEdge, new List<int>() {faceIdx});
                }
            }
        }
        var toReturn = new List<Vector4>();
        foreach (var pair in edgesDict)
        {
            if (pair.Value.Count == 1) // add '-1' to edges that belongs to one face
            {
                edgesDict[pair.Key].Add(-1);
            }
            toReturn.Add(new Vector4(pair.Key.x, pair.Key.y, pair.Value[0], pair.Value[1]));
        }
        return toReturn;
    }

    // Returns a list of "face points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetFacePoints(CCMeshData mesh) // Part 2.1
    {
        List<Vector3> toReturn = new List<Vector3>();
        for (int i = 0; i < mesh.faces.Count; i++)
        {
            //sum up the vertices using idx of the current mesh
            Vector3 sum = mesh.points[(int) mesh.faces[i].x] + mesh.points[(int) mesh.faces[i].y] +
                          mesh.points[(int) mesh.faces[i].z] + mesh.points[(int) mesh.faces[i].w];
            sum = sum / Npoints;
            toReturn.Add(sum);
        }

        return toReturn;
    }

    // Returns a list of "edge points" for the given CCMeshData, as described in the Catmull-Clark algorithm 
    public static List<Vector3> GetEdgePoints(CCMeshData mesh) // Part 2.1
    {
        List<Vector3> toReturn = new List<Vector3>();
        for (var i = 0; i < mesh.edges.Count; i++)
        {
            Vector4 edgie = mesh.edges[i];
            Vector3 sum = mesh.points[(int) edgie.x] + mesh.points[(int) edgie.y] + mesh.facePoints[(int) (edgie.z)];
            var div = 3; 
            if (Math.Abs(mesh.edges[i].w - (-1)) > EPSILON)
            {
                sum += mesh.facePoints[(int) (edgie.w)];
                div = Npoints;
            }

            toReturn.Add(sum / div);
        }
        return toReturn;
    }

    // Returns a list of new locations of the original points for the given CCMeshData, as described in the CC algorithm 
    public static List<Vector3> GetNewPoints(CCMeshData mesh) // Part 2.1
    {
        List<Vector3> edgeMidPoints = GetEdgeMidPoints(mesh);
        Vector3[] fAvreage = new Vector3[mesh.points.Count]; // faces average 
        Vector3[] rAvreage = new Vector3[mesh.points.Count]; // r = edge mid-points
        int[] n = new int[mesh.points.Count]; // n = number of edges neighboring the point
        Vector3[] newPostion = new Vector3[mesh.points.Count];

        for (int i = 0; i < mesh.edges.Count; i++)
        {
            Vector4 edgie = mesh.edges[i]; //Reminder: edgie.x = p1, edgie.y = p2, edgie.z = f1, edgie.w = f2

            //calculate f
            fAvreage[(int) edgie.x] += mesh.facePoints[(int) edgie.z];
            fAvreage[(int) edgie.y] += mesh.facePoints[(int) edgie.z];
            if (Math.Abs(edgie.w - (-1)) > EPSILON)
            {
                fAvreage[(int) edgie.x] += mesh.facePoints[(int) edgie.w];
                fAvreage[(int) edgie.y] += mesh.facePoints[(int) edgie.w];
            }
            //calculate r
            rAvreage[(int) edgie.x] += edgeMidPoints[i];
            rAvreage[(int) edgie.y] += edgeMidPoints[i];
            //calculate n
            n[(int) edgie.x]++;
            n[(int) edgie.y]++;
        }
        
        for (int i = 0; i < mesh.points.Count; i++)
        {
            // we iterate over all edges, each point will add its face-average-sum twice,
            // once for each edge on the same face, so we divide by 2:
            fAvreage[i] = fAvreage[i] / (n[i] * 2);
            rAvreage[i] /= n[i];
            newPostion[i] = (fAvreage[i] + 2 * rAvreage[i] + (n[i] - 3) * mesh.points[i]) / n[i];
        }
        return newPostion.ToList();
    }
    
    //writing an equality comparer to be able to check both directions of an edge 
    public class Vector2Compater : EqualityComparer<Vector2>
    {
        private static readonly float EPSILON = 0.001f;

        public override bool Equals(Vector2 v1, Vector2 v2)
        {
            Vector2 v3 = new Vector2(v2.y, v2.x);
            return (Vector2.Distance(v1, v2) < EPSILON) || (Vector2.Distance(v1, v3) < EPSILON);
        }

        public override int GetHashCode(Vector2 obj)
        {
            return obj.x.GetHashCode() + obj.y.GetHashCode();
        }
    }
    
    //function to return a list of edge midpoints
    private static List<Vector3> GetEdgeMidPoints(CCMeshData mesh) 
    {
        List<Vector3> toReturn = new List<Vector3>();
        for (var i = 0; i < mesh.edges.Count; i++)
        {
            Vector4 edgie = mesh.edges[i];
            Vector3 sum = mesh.points[(int) edgie.x] + mesh.points[(int) edgie.y];
            toReturn.Add(sum / 2);
        }
        return toReturn;
    }

    // Return combined new points list of facePoints, edgePoints and newPoints into a
    private static List<Vector3> GetAllNewPoints(List<Vector3> facePoints, List<Vector3> newPoints, List<Vector3> edgePoints)
    {
        List<Vector3> returnPoints = new List<Vector3>();
        returnPoints.AddRange(facePoints);
        returnPoints.AddRange(newPoints);
        returnPoints.AddRange(edgePoints);
        return returnPoints;
    }

    // Return all the faces of the new mesh
    private static List<Vector4> GetAllNewFaces(CCMeshData meshData)
    {
        List<Vector4> faces = meshData.faces;
        var returnFaces = new Vector4[faces.Count * Npoints]; //from each face we create 4 faces in the new mesh
        var shiftPointsIndx = faces.Count; // shift indexes to match the new points array
        var shiftEdgesIndx = shiftPointsIndx + meshData.points.Count; // shift indexes to match the new points array
        Dictionary<Vector2, int> edgeIdxDict = GetEdgeToIdxDictionary(meshData, shiftEdgesIndx);
        
        for (var faceIdx = 0; faceIdx < faces.Count; faceIdx++)
        {
            int[] edgeIdx = {InitIdx, InitIdx, InitIdx, InitIdx}; //{p0-p1, p1-p2, p2-p3, p3-p0}
            float[] faceVertex = { faces[faceIdx].x, faces[faceIdx].y, faces[faceIdx].z,
                faces[faceIdx].w };
            for (var pointInFace = 0; pointInFace < Npoints; pointInFace++)
            {
                var edgeFromFace = new Vector2(faceVertex[pointInFace], faceVertex[(pointInFace + 1) % Npoints]);
                if (edgeIdxDict.ContainsKey(edgeFromFace))
                {
                    edgeIdx[pointInFace] = edgeIdxDict[edgeFromFace];
                }
            }
            returnFaces[faceIdx * Npoints] = new Vector4(faceIdx, edgeIdx[0], faceVertex[1] + shiftPointsIndx, edgeIdx[1]);
            returnFaces[faceIdx * Npoints + 1] = new Vector4(faceIdx, edgeIdx[1], faceVertex[2] + shiftPointsIndx, edgeIdx[2]);
            returnFaces[faceIdx * Npoints + 2] = new Vector4(faceIdx, edgeIdx[2], faceVertex[3] + shiftPointsIndx, edgeIdx[3]);
            returnFaces[faceIdx * Npoints + 3] = new Vector4(faceIdx, edgeIdx[3], faceVertex[0] + shiftPointsIndx, edgeIdx[0]);
        }
        return returnFaces.ToList();
    }
    
    // create edge to index dictionary
    private static Dictionary<Vector2, int> GetEdgeToIdxDictionary(CCMeshData meshData, int shiftEdgesIndx)
    {
        var edgeIdxDict = new Dictionary<Vector2, int>(new Vector2Compater());
        for (var i = 0; i < meshData.edges.Count; i++)
        {
            edgeIdxDict[new Vector2(meshData.edges[i].x, meshData.edges[i].y)] = i + shiftEdgesIndx;
        } //dict (p1,p2) = edgeIdx

        return edgeIdxDict;
    }
}