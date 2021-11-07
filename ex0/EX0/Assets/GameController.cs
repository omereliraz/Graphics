using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameController : MonoBehaviour
{
    public static int FIELD_SIZE = 30; // Width and height of the game field
    public static float COLLISION_THRESHOLD = 1.5f; // Collision distance between food and player 
    public GameObject playerObject; // Reference to the Player GameObject
    public GameObject cameraObject;

    private GameObject food; // Represents the food in the game

    private static float minPos = (float) - FIELD_SIZE / 2;
    private static float maxPos = (float) FIELD_SIZE / 2;

    private float diffX;
    private float diffZ;

    public static int score = 0;

    private Vector3 cameraToPlayer;

    // Start is called before the first frame update
    void Start()
    {
        food = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
        SpawnFood();
        cameraToPlayer = cameraObject.transform.position - playerObject.transform.position;
    }

    // Positions the food at a random location inside the field
    void SpawnFood()
    {
        food.transform.position = new Vector3(UnityEngine.Random.Range(minPos, maxPos), 0.0f, UnityEngine.Random.Range(minPos, maxPos));
    }

    // Update is called once per frame
    void Update()
    {
        diffX = food.transform.position[0] - playerObject.transform.position[0];
        diffZ = food.transform.position[2] - playerObject.transform.position[2];
        if ((diffX < COLLISION_THRESHOLD) && (diffX > -COLLISION_THRESHOLD) && (diffZ < COLLISION_THRESHOLD) && (diffZ > -COLLISION_THRESHOLD))
        {
            print(++score);
            SpawnFood();
        }
        cameraObject.transform.position = playerObject.transform.position + cameraToPlayer;
    }
}
