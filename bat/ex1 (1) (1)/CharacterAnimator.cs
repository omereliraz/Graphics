using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
using UnityEngine;
using UnityEngine.Animations;
using Debug = UnityEngine.Debug;

public class CharacterAnimator : MonoBehaviour
{
    public TextAsset BVHFile; // The BVH file that defines the animation and skeleton
    public bool animate; // Indicates whether or not the animation should be running

    private BVHData data; // BVH data of the BVHFile will be loaded here
    private int currFrame = 0; // Current frame of the animation

    private const int HeadSize = 8; 
    private const int BodySize = 2;

    private float startTime, curTime; // times needed for animation update


    // Start is called before the first frame update
    void Start()
    {
        BVHParser parser = new BVHParser();
        data = parser.Parse(BVHFile);
        CreateJoint(data.rootJoint, Vector3.zero);
        
        startTime = Time.deltaTime;
        curTime = Time.deltaTime;
    }

    // Returns a Matrix4x4 representing a rotation aligning the up direction of an object with the given v
    Matrix4x4 RotateTowardsVector(Vector3 v)
    {
        // 2.1 - normalize vector
        Vector3 normalV = Vector3.Normalize(v);
        
        // 2.2 - calculate Theta needed for finding rotation 
        float thetaX = Mathf.Atan2(normalV.y, normalV.z) * Mathf.Rad2Deg - 90;
        float thetaZ = 90 -
            Mathf.Atan2(Mathf.Sqrt(normalV.y * normalV.y + normalV.z * normalV.z), normalV.x) * Mathf.Rad2Deg;
        // creating rotation matrix
        Matrix4x4 rX = MatrixUtils.RotateX(thetaX);
        Matrix4x4 rZ = MatrixUtils.RotateZ(thetaZ);
        
        return (rZ * rX).inverse;
    }

    // Creates a Cylinder GameObject between two given points in 3D space
    GameObject CreateCylinderBetweenPoints(Vector3 p1, Vector3 p2, float diameter)
    {
        // 3.a.1 - create basic cylinder
        GameObject cylinder = GameObject.CreatePrimitive(PrimitiveType.Cylinder); 

        // 3.a.2 - create STR matrix needed for finding M
        Matrix4x4 T = MatrixUtils.Translate((p1+p2) / 2); // get average of two points
        Matrix4x4 R = RotateTowardsVector(p2 - p1); // creating vector from two points
        Matrix4x4 S = MatrixUtils.Scale(new Vector3(diameter, Vector3.Distance(p2, p1) / 2, diameter));
        Matrix4x4 M = T * R * S; // mutliply like we leaner in tirgul  

        // 3.a.3 - apply transormation
        MatrixUtils.ApplyTransform(cylinder, M);
        return cylinder;
    }

    // Creates a GameObject representing a given BVHJoint and recursively creates GameObjects for it's child joints
    GameObject CreateJoint(BVHJoint joint, Vector3 parentPosition) // 1.0
    {
        // 1.1 - 1.2 - create sphere and make the joint a parent of that sphere.
        joint.gameObject = new GameObject(joint.name);
        GameObject sphere = GameObject.CreatePrimitive(PrimitiveType.Sphere); 
        sphere.transform.parent = joint.gameObject.transform; 

        // 1.3 create a matrix that will scale the sphere by factor
        int factor = joint.name == "Head" ? HeadSize : BodySize;
        Matrix4x4 scalingMat = MatrixUtils.Scale(new Vector3(factor, factor, factor));
        MatrixUtils.ApplyTransform(sphere, scalingMat);

        // 1.4 - 1.5 - create matrix to use placing in the correct location  
        Matrix4x4 translateMat = Matrix4x4.Translate(parentPosition + joint.offset);
        MatrixUtils.ApplyTransform(joint.gameObject, translateMat);
        
        Vector3 jointPos = joint.gameObject.transform.position;
        Transform jointTra = joint.gameObject.transform;
        
        //looping over children recursively 
        foreach (var child in joint.children)
        {
            CreateJoint(child, joint.gameObject.transform.position); // 1.6
            
            // 3.b.1 - 3.b.2 - create cylinder and connect between joint and child (also done recursively)
            GameObject cylinder = CreateCylinderBetweenPoints(jointPos, child.gameObject.transform.position, 
                0.5f);
            cylinder.gameObject.transform.parent = jointTra;
        }
        return joint.gameObject;
    }

    // Transforms BVHJoint according to the keyframe channel data, and recursively transforms its children
    private void TransformJoint(BVHJoint joint, Matrix4x4 parentTransform, float[] keyframe)
    {
        // 4.3 
        Matrix4x4 jointMat, T, R; // matrices needed for calculating transfomations
        Matrix4x4[] rotation; // array of rotation matrices for calculating the rotation matrix
        T = (data.rootJoint == joint) ?
            MatrixUtils.Translate(new Vector3(keyframe[joint.positionChannels.x], 
                keyframe[joint.positionChannels.y], keyframe[joint.positionChannels.z]))
            : T = MatrixUtils.Translate(joint.offset); // if is root get info from positionChannels else
                                                       // from joint.offset
                                                       
        // creating array of rotation matrices
        rotation = new []{ MatrixUtils.RotateX(keyframe[joint.rotationChannels.x]),
            MatrixUtils.RotateY(keyframe[joint.rotationChannels.y]),
            MatrixUtils.RotateZ(keyframe[joint.rotationChannels.z])};

        // creating The one and only rotation matrix
        R = rotation[joint.rotationOrder.x] * rotation[joint.rotationOrder.y] * rotation[joint.rotationOrder.z];

        // multiplying like we learning in class 
        jointMat = parentTransform * T * R; // S = parentTransform
        
        MatrixUtils.ApplyTransform(joint.gameObject, jointMat);
        
        //looping over children recursively 
        foreach (BVHJoint child in joint.children)
        {
            TransformJoint(child, jointMat, keyframe);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (animate)
        {
            // 4.1- calculating the correct frame rate
            float animationTime = data.frameLength * data.numFrames; //max time for all animation
            curTime += Time.deltaTime;
            if (curTime - startTime < animationTime)
            {
                currFrame = (int) ((curTime - startTime)/data.frameLength);
                // 4.2 calling TransformJoint on root joint
                TransformJoint(data.rootJoint, Matrix4x4.identity, data.keyframes[currFrame]);
            }
            else
            {
                startTime = Time.deltaTime;
                curTime = Time.deltaTime;
                currFrame = 0;
            }
            
        }
    }
}