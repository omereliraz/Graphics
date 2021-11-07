using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterAnimator : MonoBehaviour
{
    public TextAsset BVHFile; // The BVH file that defines the animation and skeleton
    public bool animate; // Indicates whether or not the animation should be running

    private BVHData data; // BVH data of the BVHFile will be loaded here
    private int currFrame = 0; // Current frame of the animation



    // Start is called before the first frame update
    void Start()
    {
        BVHParser parser = new BVHParser();
        data = parser.Parse(BVHFile);
        //print(data.rootJoint.name);
        CreateJoint(data.rootJoint, Vector3.zero);
        // Vector3 v1 = new Vector3(0,1,0);
        // Vector3 v2 = new Vector3(1,7,6);
        // Matrix4x4 r = RotateTowardsVector(v2);
        // Vector3 result = r.MultiplyVector(v1);
        // print(r.ToString());
        // print(result.ToString());
        // Matrix4x4 rCorrect = MatrixUtils.RotateTowardsVector(v2);
        // Vector3 resultCorrect = rCorrect.MultiplyVector(v1);
        // print(rCorrect.ToString());
        // print(resultCorrect.ToString());
        //CreateCylinderBetweenPoints(new Vector3(0,0,0), new Vector3(0,10,0), 0.5f);
    }

    // Returns a Matrix4x4 representing a rotation aligning the up direction of an object with the given v
    Matrix4x4 RotateTowardsVector(Vector3 v)
    {
        // calculate angle sof rotation on axes
        Vector3 normV = v.normalized;
        float thetaX = Mathf.Atan2(normV.y, normV.z);
        float thetaZ = Mathf.Atan2(Mathf.Sqrt(normV.y*normV.y + normV.z*normV.z), normV.x);
        float thetaXDeg = 90 - (thetaX * Mathf.Rad2Deg); 
        float thetaZDeg = 90 - (thetaZ * Mathf.Rad2Deg);
        return MatrixUtils.RotateX(thetaXDeg) * MatrixUtils.RotateZ(-thetaZDeg);

    }

    // Creates a Cylinder GameObject between two given points in 3D space
    GameObject CreateCylinderBetweenPoints(Vector3 p1, Vector3 p2, float diameter)
    {
        GameObject bone = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        Matrix4x4 scaleMat = MatrixUtils.Scale(new Vector3(diameter,  Vector3.Distance(p2, p1) / 2 , diameter));
        Matrix4x4 rotMat = RotateTowardsVector(p2 - p1);
        Matrix4x4 transMat = MatrixUtils.Translate((p1 + p2) / 2);
        Matrix4x4 TRS = transMat * rotMat * scaleMat;
        // apply transformation matrix
        MatrixUtils.ApplyTransform(bone, TRS);
        return bone;
    }

    // Creates a GameObject representing a given BVHJoint and recursively creates GameObjects for it's child joints
    GameObject CreateJoint(BVHJoint joint, Vector3 parentPosition)
    {
        if (joint.isEndSite) // end condition
        {   
            return joint.gameObject;
        }
        
        // create empty game object for each joint
        joint.gameObject = new GameObject(joint.name);
        
        // create sphere primitive for joint object as son of joint game object
        GameObject jointSphere = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        jointSphere.transform.parent = joint.gameObject.transform;
        
        // scale sphere representation of joint
        int scaleInt = 2;
        if (joint.name == "Head")
        {
            scaleInt = 8;
        }        
        
        // Vector3 scaleVec = new Vector3(scaleInt, scaleInt, scaleInt);
        Matrix4x4 scaleMat = MatrixUtils.Scale(new Vector3(scaleInt, scaleInt, scaleInt));
        MatrixUtils.ApplyTransform(jointSphere, scaleMat);

        // construct translation matrix that positions joint relative to parent
        Vector3 translationVec = joint.offset + parentPosition;
        
        // apply translation to joint
        MatrixUtils.ApplyTransform(joint.gameObject, MatrixUtils.Translate(translationVec));
 

        // Vector3 jointPos = joint.gameObject.transform.position;
        // Transform jointTra = joint.gameObject.transform;
        // recursively create joint objects
        foreach (BVHJoint child in joint.children)
        {
            CreateJoint(child, translationVec);
            // GameObject cylinder = CreateCylinderBetweenPoints(jointPos, child.gameObject.transform.position, 
            //     0.5f);
            // cylinder.gameObject.transform.parent = jointTra;
            GameObject bone = CreateCylinderBetweenPoints(joint.gameObject.transform.position,
             joint.gameObject.transform.position+child.offset, 0.5f);
            bone.gameObject.transform.parent = joint.gameObject.transform;
        }
        return joint.gameObject;
    }

    // Transforms BVHJoint according to the keyframe channel data, and recursively transforms its children
    private void TransformJoint(BVHJoint joint, Matrix4x4 parentTransform, float[] keyframe)
    {
        // Your code here
    }

    // Update is called once per frame
    void Update()
    {
        if (animate)
        {
            // Your code here
        }
    }
}
