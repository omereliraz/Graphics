// Checks for an intersection between a ray and a sphere
// The sphere center is given by sphere.xyz and its radius is sphere.w

void intersectSphere(Ray ray, inout RayHit bestHit, Material material, float4 sphere)
{
    float3 origin_dist = ray.origin - sphere.xyz; 
    //A = 1
    //using what we learned in class separate the var needed to solve quadratic equation 
    float B = 2 * dot(origin_dist, ray.direction);
    float C = dot(origin_dist, origin_dist) - (sphere.w * sphere.w);

    //calculate discriminant 
    float D = B * B - 4 * C;

    //set current distance to inf
    float temp_dist = 1.#INF;

    if (D < 0) {}// temp_dist = 1.#INF;
    else if (D == 0) //we have one intersect point
        {
        temp_dist = -B / 2;
        }
    else //we have two hit points:
        {
        float t0 = (-B - sqrt(D)) / 2;
        float t1 = (-B + sqrt(D)) / 2;

        //check that t0 and t1 are larger then 0 and choose the minimum
        if (t0 < 0 && t1 >= 0)
        {
            temp_dist = t1;
        }
        else if (t0 >= 0 && t1 < 0)
        {
            temp_dist = t0;
        }
        else if (t0 >= 0 && t1 >= 0)
        {
            temp_dist = min(t0, t1);
        }
        // else: temp_dist = 1.#INF;
        }
    // if we found a legal intersection update best-hit
    if (temp_dist > 0 && temp_dist < bestHit.distance)
    {
        bestHit.distance = temp_dist;
        bestHit.material = material;
        bestHit.position = ray.origin + (temp_dist * ray.direction); // as seen in class
        bestHit.normal = normalize(bestHit.position - sphere.xyz); // normalize new normal (is float3)
    }

}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
void intersectPlane(Ray ray, inout RayHit bestHit, Material material, float3 c, float3 n)
{
    if(dot(ray.direction, n) <= 0) // check if plane and ray have an intersection
    {
        float t = - dot((ray.origin - c), n)/dot(ray.direction, n); //calculate distance of intersection
        if(t > 0 && t < bestHit.distance) //if the distance is smaller then the one best-hit has update
        {
            bestHit.distance = t;
            bestHit.material = material;
            bestHit.normal = n;
            bestHit.position = ray.origin + (ray.direction * t); // calculate intersection= new position
        }
    }
}


// figure out the orientation of the plane - because we know that the plane is axis aligned
// so use surface normal n to figure out which orientation it has
bool chooseCellColor(float3 c, float3 n)
{
    float row, column;
    if (n.x == 1) //the plan is yz
        {
        row = c.y, column = c.z;
        }
    else if (n.y == 1) //the plane is xz
        {
        row = c.x, column = c.z;

        }
    else // if (n.z == 1) //the plane is xy
        {
        row = c.x, column = c.y;

        }
    //choose row color according to the row we are on 
    bool row_color = frac(row) <= 0.5;
    bool column_color = frac(column) <= 0.5;
    return row_color ^ column_color; // ^ is xor operator
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
// The material returned is either m1 or m2 in a way that creates a checkerboard pattern 
void intersectPlaneCheckered(Ray ray, inout RayHit bestHit, Material m1, Material m2, float3 c, float3 n)
{
    
    if(dot(ray.direction, n) <= 0)
    {
        //calculate new distance as we deed b4
        float t = - dot((ray.origin - c), n)/dot(ray.direction, n);
        // if t is better then current distance update:
        if(t > 0 && t < bestHit.distance)
        {
            bestHit.distance = t;
            bestHit.normal = n;
            bestHit.position = ray.origin + (ray.direction * t);
            //check which Material to use 
            bool cellColor = chooseCellColor(bestHit.position, n);
            Material material =  m1;
            if(cellColor)
            {
                material = m2;
            }
            bestHit.material = material;
            
        }
    }
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c)
{
    // calculate the normal of tringal
    float3 n = normalize(cross((a-c), (b-c)));
    //if we have intersection between surface of triangle and ray
    if(dot(ray.direction, n) <= 0)
    {
        //calculate t
        float t = - dot((ray.origin - c), n)/dot(ray.direction, n);
        // if t is legal
        if(t > 0 && t < bestHit.distance)
        {
            //calculate new location and check if it falls in limits of triangle 
            float3 temp_p = ray.origin + (ray.direction * t);
            float b_a = dot(cross((b-a), (temp_p - a)),n);
            float c_b = dot(cross((c-b), (temp_p - b)),n);
            float a_c = dot(cross((a-c), (temp_p - c)),n);
            //if ray does fall in limits of triangle- update 
            if(b_a >= 0 && c_b >= 0 && a_c >= 0)
            {
                //p is on plane
                bestHit.distance = t;
                bestHit.normal = n;
                bestHit.position = temp_p;
                bestHit.material = material;

            }
        }
    }    
}


// Checks for an intersection between a ray and a 2D circle
// The circle center is given by circle.xyz, its radius is circle.w and its orientation vector is n 
void intersectCircle(Ray ray, inout RayHit bestHit, Material material, float4 circle, float3 n)
{
    //Checks for a collision between a ray and a circle
    // check if intersects with plane of Circle
    if(dot(ray.direction, n) <= 0)
    {
        float t = - dot((ray.origin - circle.xyz), n)/dot(ray.direction, n); //indecation intersection with plan
        float3 int_point = ray.origin + ray.direction * t; //calculate new location
        //next check if is smaller then rad
        bool in_rad = (dot(int_point - circle.xyz, int_point - circle.xyz)-(circle.w * circle.w)) <= 0; 
        
        if(t > 0 && t < bestHit.distance && in_rad) //else no chance of interaction
        {

            bestHit.distance = t;
            bestHit.material = material;
            bestHit.normal = n;
            bestHit.position = ray.origin + (ray.direction * t);

        }

    }
    
}


// Checks for an intersection between a ray and a cylinder aligned with the Y axis
// The cylinder center is given by cylinder.xyz, its radius is cylinder.w and its height is h
void intersectCylinderY(Ray ray, inout RayHit bestHit, Material material, float4 cylinder, float h)
{

    // will draw the needed Circles for top and bottom of Cylinder  -- circle - (x,y + height/2, z, r)
    intersectCircle(ray, bestHit, material, float4(cylinder.x, cylinder.y + h/2  , cylinder.z, cylinder.w), float3(0,1,0));
    intersectCircle(ray, bestHit, material, float4(cylinder.x, cylinder.y - h/2  , cylinder.z, cylinder.w), float3(0,-1,0));

    float ori_x_cyl = (-2 * ray.direction.x * cylinder.x);
    float ori_z_cyl = (-2 * ray.direction.z * cylinder.z);

    // calculate the needed vals for quadratic equation 
    float A = pow(ray.direction.x,2) + pow(ray.direction.z,2); 

    float B = (2 * ray.direction.x * ray.origin.x) + (2 * ray.direction.z * ray.origin.z) + ori_x_cyl + ori_z_cyl;

    float C = pow(ray.origin.x,2) + pow(ray.origin.z,2) - (2 * ray.origin.x * cylinder.x) -
        (2 * ray.origin.z * cylinder.z) + pow(cylinder.x,2) + pow(cylinder.z,2)- pow(cylinder.w, 2); 

    //calculate discriminant
    float D = B * B - 4 * A * C;

    float temp_dist = 1.#INF;

    if(D < 0)
    {
        temp_dist = 1.#INF;
    }
    else if (D == 0) //we have one intersect point
        {
        temp_dist = -B / (2 * A);
        }
    else //we have two hit points:
        {
        float t0 = (-B - sqrt(D)) / (2 * A);
        float t1 = (-B + sqrt(D)) / (2 * A);

        //check that t0 and t1 are larger then 0 and choose the minimum
        if (t0 < 0 && t1 >= 0)
        {
            temp_dist = t1;
        }
        else if (t0 >= 0 && t1 < 0)
        {
            temp_dist = t0;
        }
        else if (t0 >= 0 && t1 >= 0)
        {
            temp_dist = min(t0, t1);
        }
        // else: temp_dist = 1.#INF;
        }
    //calculate to set limit on height of Cylinder
    float pos = float3(ray.origin + (temp_dist * ray.direction)).y;
    bool in_limited_hight = (pos <= cylinder.y + h/2) && (pos >= cylinder.y - h/2);

    //if we found a better hit then update 
    if (temp_dist > 0 && temp_dist < bestHit.distance && in_limited_hight)
    {
        bestHit.distance = temp_dist;
        bestHit.material = material;
        bestHit.position = ray.origin + (temp_dist * ray.direction);
        bestHit.normal = normalize(bestHit.position - float3(cylinder.x, bestHit.position.y, cylinder.z));

    }
}
