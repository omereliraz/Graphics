// Implements an adjusted version of the Blinn-Phong lighting model
float3 blinnPhong(float3 n, float3 v, float3 l, float shininess, float3 albedo)
{
   //Diffuse max (0,dot(n,l) * albedo
	float3 diffuse = max(0, dot(n, l)) * albedo;
    //calculate halfway vector
    float3 halfwayV = normalize(l + v);
    //specular - max{0, dot(n, halfway)}^shininess * 0.4
    float4 specular= pow(max(0, dot(n, halfwayV)), shininess) * 0.4;
    return  diffuse + specular;
}

// Reflects the given ray from the given hit point
void reflectRay(inout Ray ray, RayHit hit)
{
    // calculate reflection direction:
    float3 r = (2 * dot(-ray.direction, hit.normal) * hit.normal) + ray.direction; 
    ray.direction = r;
    // ray energy is multiplied by the specular coefficient of the hit material
    ray.energy = ray.energy * hit.material.specular;
    // move origin of ray to NOT get shadow acne 
    ray.origin = hit.position + EPS * hit.normal;

}

// Refracts the given ray from the given hit point
void refractRay(inout Ray ray, RayHit hit)
{
    float3 normal = hit.normal;
    //set eta to val unless needed to flip
    float eta = 1 / hit.material.refractiveIndex;
    //first check if we are coming from withing transparent object:
    if(dot(normal, ray.direction) > 0) // ray leaving material 
    {
        //flip n and flip n1, n1
        eta = hit.material.refractiveIndex;
        normal = -1 * normal;
    }

    //calculate c1 and c2
    float c1 = abs(dot(hit.normal, ray.direction));
    float c2 = sqrt(1 - (eta * eta) * (1 - c1 * c1));
    //calculate reflection direction 
    float3 t = eta * ray.direction + (eta * c1 - c2) * normal;

    //res of calculations:
    ray.direction = normalize(t);
    ray.origin = hit.position - (EPS * normal); // + or - epsilon 
   
}

// Samples the _SkyboxTexture at a given direction vector
float3 sampleSkybox(float3 direction)
{
    //calculate angle for sky box
    float theta = acos(direction.y) / -PI;
    float phi = atan2(direction.x, -direction.z) / -PI * 0.5f;
    //return skybox at taught in class
    return _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
}