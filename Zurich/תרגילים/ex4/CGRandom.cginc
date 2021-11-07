#ifndef CG_RANDOM_INCLUDED
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11
#define CG_RANDOM_INCLUDED

// Returns a psuedo-random float between -1 and 1 for a given float c
float random(float c)
{
    return -1.0 + 2.0 * frac(43758.5453123 * sin(c));
}

// Returns a psuedo-random float2 with componenets between -1 and 1 for a given float2 c 
float2 random2(float2 c)
{
    c = float2(dot(c, float2(127.1, 311.7)), dot(c, float2(269.5, 183.3)));

    float2 v = -1.0 + 2.0 * frac(43758.5453123 * sin(c));
    return v;
}

// Returns a psuedo-random float3 with componenets between -1 and 1 for a given float3 c 
float3 random3(float3 c)
{
    float j = 4096.0 * sin(dot(c, float3(17.0, 59.4, 15.0)));
    float3 r;
    r.z = frac(512.0*j);
    j *= .125;
    r.x = frac(512.0*j);
    j *= .125;
    r.y = frac(512.0*j);
    r = -1.0 + 2.0 * r;
    return r.yzx;
}

// Interpolates a given array v of 4 float2 values using bicubic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
//
// [0]=====o==[1]
//         |
//         t
//         |
// [2]=====o==[3]
//
float bicubicInterpolation(float2 v[4], float2 t)
{
    float2 u = t * t * (3.0 - 2.0 * t); // Cubic interpolation

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 4 float2 values using biquintic interpolation
// at the given ratio t (a float2 with components between 0 and 1)
float biquinticInterpolation(float2 v[4], float2 t)
{
    //= 6x^5 – 15x^4 + 10x^3 =  t^3(6*t^2 - 15*t + 10)
    float2 u = (t * t * t) * ((t * t * 6) -(15 * t) + 10);

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);

    // Interpolate in the y direction and return
    return lerp(x1, x2, u.y);
}

// Interpolates a given array v of 8 float3 values using triquintic interpolation
// at the given ratio t (a float3 with components between 0 and 1)
float triquinticInterpolation(float3 v[8], float3 t)
{
    //= 6x^5 – 15x^4 + 10x^3 =  t^3(6*t^2 - 15*t + 10)
    float3 u = (t * t * t) * ((t * t * 6) - (15 * t) + 10);

    // Interpolate in the x direction
    float x1 = lerp(v[0], v[1], u.x);
    float x2 = lerp(v[2], v[3], u.x);
	float x3 = lerp(v[4], v[5], u.x);
	float x4 = lerp(v[6], v[7], u.x);
    
    // Interpolate in the y direction
	float x12 = lerp(x1, x2 , u.y);
	float x34 = lerp(x3, x4 , u.y);

    // Interpolate in the z direction and return
    return lerp(x12, x34, u.z);
}

// Returns the value of a 2D value noise function at the given coordinates c
float value2d(float2 c)
{
    //TODO check this
    //find 4 cornors of grid containing c
    float2 top_right = float2(ceil(c.x), ceil(c.y));
    float2 bot_right = float2(ceil(c.x), floor(c.y));
    float2 top_left = float2(floor(c.x), ceil(c.y));
    float2 bot_left = float2(floor(c.x), floor(c.y));

    //use their coordinates to sample the given function random2 (use the first value)
    float2 rand_top_right = random2(top_right).x;
    float2 rand_bot_right = random2(bot_right).x;
    float2 rand_top_left = random2(top_left).x;
    float2 rand_bot_left = random2(bot_left).x;
    //use bicubic interpolation to calculate the color
    float2 randVec[4] = {rand_bot_left, rand_bot_right, rand_top_left, rand_top_right};
   
    return bicubicInterpolation(randVec, frac(c));
}

// Returns the value of a 2D Perlin noise function at the given coordinates c
float perlin2d(float2 c)
{
    //find cornor points
    float2 top_right = float2(ceil(c.x), ceil(c.y));
    float2 bot_right = float2(ceil(c.x), floor(c.y));
    float2 top_left = float2(floor(c.x), ceil(c.y));
    float2 bot_left = float2(floor(c.x), floor(c.y));

    // generate 2 psudo-randome numbers that represent gradient vector
    //use their coordinates to sample the given function random2 (use the first value)
    float2 rand_top_right = random2(top_right);
    float2 rand_bot_right = random2(bot_right);
    float2 rand_top_left = random2(top_left);
    float2 rand_bot_left = random2(bot_left);

    //calculate 4 distance vectors
    float2 distance_top_right = top_right - c;
    float2 distance_bot_right = bot_right - c;
    float2 distance_top_left = top_left - c;
    float2 distance_bot_left = bot_left - c;
        
    //calculate dot product of distance vectors and gradient vector
    float2 dot_top_right = dot(rand_top_right, distance_top_right).x;
    float2 dot_bot_right = dot(rand_bot_right, distance_bot_right).x;
    float2 dot_top_left = dot(rand_top_left, distance_top_left).x;
    float2 dot_bot_left = dot(rand_bot_left, distance_bot_left).x;

    //use bicubic to interperlate
    float2 randVec[4] = {dot_bot_left, dot_bot_right, dot_top_left, dot_top_right};
    //normolize and render
	return biquinticInterpolation(randVec, frac(c));
    //return bicubicInterpolation(randVec, frac(c));

}

// Returns the value of a 3D Perlin noise function at the given coordinates c
float perlin3d(float3 c)
{             
	//get cell coordinates       
    float3 top_right_front = float3(ceil(c.x), ceil(c.y), floor(c.z));
    float3 bot_right_front = float3(ceil(c.x), floor(c.y),floor(c.z));
    float3 top_left_front = float3(floor(c.x), ceil(c.y), floor(c.z));
    float3 bot_left_front = float3(floor(c.x), floor(c.y), floor(c.z));       
    float3 top_right_back = float3(ceil(c.x), ceil(c.y), ceil(c.z));
    float3 bot_right_back = float3(ceil(c.x), floor(c.y),ceil(c.z));
    float3 top_left_back = float3(floor(c.x), ceil(c.y), ceil(c.z));
    float3 bot_left_back = float3(floor(c.x), floor(c.y), ceil(c.z));

	//get randome vals- all 8
    float3 rand_top_right_front = random3(top_right_front);
    float3 rand_bot_right_front = random3(bot_right_front);
    float3 rand_top_left_front = random3(top_left_front);
    float3 rand_bot_left_front = random3(bot_left_front);
    float3 rand_top_right_back = random3(top_right_back);
    float3 rand_bot_right_back = random3(bot_right_back);
    float3 rand_top_left_back = random3(top_left_back);
    float3 rand_bot_left_back = random3(bot_left_back);

	//calculate 8 distance vectors
	float3 dist_top_right_front = top_right_front -c;
	float3 dist_bot_right_front = bot_right_front -c;
	float3 dist_top_left_front = top_left_front -c;
	float3 dist_bot_left_front = bot_left_front -c;
	float3 dist_top_right_back = top_right_back -c;
	float3 dist_bot_right_back = bot_right_back -c;
	float3 dist_top_left_back = top_left_back -c;
	float3 dist_bot_left_back = bot_left_back -c;

    //calculate dot product of distance vectors and gradient vector
	float3 dot_top_right_front = dot(rand_top_right_front, dist_top_right_front);
	float3 dot_bot_right_front= dot(rand_bot_right_front, dist_bot_right_front);
	float3 dot_top_left_front = dot(rand_top_left_front, dist_top_left_front);
	float3 dot_bot_left_front = dot(rand_bot_left_front, dist_bot_left_front);
	float3 dot_top_right_back = dot(rand_top_right_back, dist_top_right_back);
	float3 dot_bot_right_back = dot(rand_bot_right_back, dist_bot_right_back);
	float3 dot_top_left_back = dot(rand_top_left_back, dist_top_left_back);
	float3 dot_bot_left_back = dot(rand_bot_left_back, dist_bot_left_back);

    //use triqui to interperlate
    float3 randVec[8] = {dot_bot_left_front, dot_bot_right_front, dot_top_left_front, dot_top_right_front, 
							dot_bot_left_back, dot_bot_right_back, dot_top_left_back, dot_top_right_back};

	return triquinticInterpolation(randVec, frac(c));

}


#endif // CG_RANDOM_INCLUDED
