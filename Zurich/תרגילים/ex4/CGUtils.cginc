#ifndef CG_UTILS_INCLUDED
#define CG_UTILS_INCLUDED

#define PI 3.141592653

// A struct containing all the data needed for bump-mapping
struct bumpMapData
{ 
    float3 normal;       // Mesh surface normal at the point
    float3 tangent;      // Mesh surface tangent at the point
    float2 uv;           // UV coordinates of the point
    sampler2D heightMap; // Heightmap texture to use for bump mapping
    float du;            // Increment size for u partial derivative approximation
    float dv;            // Increment size for v partial derivative approximation
    float bumpScale;     // Bump scaling factor
};


// Receives pos in 3D cartesian coordinates (x, y, z)
// Returns UV coordinates corresponding to pos using spherical texture mapping
float2 getSphericalUV(float3 pos)
{
    // Your implementation
	float3 r = sqrt(pow(pos.x, 2) + pow(pos.y, 2) + pow(pos.z, 2));
	float theta = atan2(pos.z, pos.x);
	float phi = acos(pos.y / r);
	float2 res;
	res.x = 0.5 + theta / (2 * PI);
	res.y = 1 - (phi / PI);
	return res;
}

// Implements an adjusted version of the Blinn-Phong lighting model
fixed3 blinnPhong(float3 n, float3 v, float3 l, float shininess, fixed4 albedo, fixed4 specularity, float ambientIntensity)
{
    //Ambient ؂ ambientIntensitĀ * albedo
	float4 ambient  = ambientIntensity * albedo;
	//Diffuse ؂ max(0, n*l)ֹ * albedo
	float4 diffuse = max(0, dot(n, l)) * albedo;
	//caluclate halfway vector
	float3 halfwayV = normalize(l + v); // without /2
	//Specular ؂ maxָ(0, n*h)^shininess * specularity
	float4 shine = pow(max(0, dot(n, halfwayV)), shininess) * specularity;
    return (ambient + diffuse + shine);
}

// Returns the world-space bump-mapped normal for the given bumpMapData
float3 getBumpMappedNormal(bumpMapData i)
{
    // calculate derivetive f'(x)
	sampler2D heightMap = i.heightMap;
	float f_du = (tex2D(heightMap, i.uv + i.du) - tex2D(heightMap, i.uv)) / i.du;
	float f_dv = (tex2D(heightMap, i.uv + i.dv) - tex2D(heightMap, i.uv)) / i.dv;

	//cross proudct and normolize res = nh
	float3 nh = normalize(float3(-f_du * i.bumpScale, -f_dv * i.bumpScale, 1));

	//calculate the binormla
	float3 binormal = cross(i.tangent, i.normal);

	// remember that nz comes before ny
    return nh.x * i.tangent + nh.z * i.normal + nh.y * binormal;
}


#endif // CG_UTILS_INCLUDED
