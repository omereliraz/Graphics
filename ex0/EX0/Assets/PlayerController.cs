using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public float movementForce = 500; // Controls player movement power
 //   public float decelerationMultiplier = 0.5f;
    private Transform t;
    private Rigidbody body;
    Vector3 zeroVec = new Vector3(0.0f, 0.0f, 0.0f);

    // Start is called before the first frame update
    void Start()
    {
        t = GetComponent<Transform>();
        t.position = new Vector3(0.0f, 1.0f, 0.0f);
        body = GetComponent<Rigidbody>();
//        body.drag = 5;
    }

    // Update is called once per frame
    void Update()
    {
        // Implement movement logic here
        if (Input.GetKey(KeyCode.UpArrow))
        {
            body.AddForce(movementForce * Time.deltaTime * Vector3.forward);
        }
        else if (Input.GetKey(KeyCode.DownArrow))
        {
            body.AddForce((-1) * movementForce * Time.deltaTime * Vector3.forward);
        }
        else if (Input.GetKey(KeyCode.RightArrow))
        {
            body.AddForce(movementForce * Time.deltaTime * Vector3.right);
        }
        else if (Input.GetKey(KeyCode.LeftArrow))
        {
            body.AddForce((-1) * movementForce * Time.deltaTime * Vector3.right);
        }
/*        else
        {
            body.velocity = Vector3.zero;
            body.angularVelocity = Vector3.zero;
        }*/
    }
}
