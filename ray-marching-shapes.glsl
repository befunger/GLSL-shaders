#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURFACE_DIST .01

// Return closest distance to a cube
float GetDistCube(vec3 p){
    vec3 pos = vec3(-2, .5, 6);
    vec3 scale = vec3(.5);
    return length(max(abs(p-pos)-scale, 0.));
}

// Returns closest distance to a sphere
float GetDistSphere(vec3 p){
    vec4 s1 = vec4(0, 1, 6, 1);
    return length(p-s1.xyz)-s1.w; // Distance to sphere center - sphere radius
}
// Returns distance to an infinitely spanning slanted roof of spheres
float GetDistSphereRoof(vec3 p){
    vec4 s1 = vec4(round(p.x), max(15.-0.5*p.z, 0.), round(p.z), 0.5);
    float sphereDist = length(p-s1.xyz)-s1.w; // Distance to sphere center - sphere radius
    return sphereDist;
}

// TODO: Add cylinder

// TODO: Add pill shape

// TODO: Add triangle/pyramid

// Returns closest distance to example terrain
float GetDist(vec3 p){
    float plane = p.y; // Distance from xz plane is y coordinate
    float sphere = GetDistSphere(p);
    float cube = GetDistCube(p);
    float ballRoof = GetDistSphereRoof(p);
    float d = min(plane, sphere);
    d = min(d, cube);
    d = min(d, ballRoof);
    return d;
}


// RayMarching loop
float RayMarch(vec3 ro, vec3 rd){
    float dO = 0.; // Distance marched
    for(int i=0; i<MAX_STEPS; i++){ // MAX_STEPS to prevent running forever
        vec3 p = ro+dO*rd;
        float dS = GetDist(p); // Returns the distance to the desired object and add it to dO 
        dO += dS;
        if(dS<SURFACE_DIST || dO>MAX_DIST) break; // End if we get close enough or reach a max dist from camera
    }
    return dO;
}

// Gets the normal vector of the surface at a point p using small offsets in the x,y, and z direction
vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(.01, 0);
    vec3 n = d - vec3( // Get dist from point at small ofset dx,dy,dz
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));

    return normalize(n);
}

// Returns light at point using simple dot product between surface normal and light direction
float GetLight(vec3 p){
    vec3 lightPos = vec3(0, 10, 6); // Light at 4 units above center sphere
    lightPos.xz += vec2(sin(iTime), cos(iTime)); // Move the light source in circle in xz plane
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p); 
    
    float dif = clamp(dot(n, l), 0., 1.); // Clamp to [0, 1] as dot prod can be [-1, 1]
    // Add shadow casting
    float d_light = RayMarch(p+n*SURFACE_DIST*5., l); // Distance marching from p towards light source (add small normal component to move away from surface before marching)
    if(d_light<length(lightPos-p)) dif *= .1; // Reduce brightness to 10% if in cast shadow
    return dif;
}

// Main function
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from -0.5 to 0.5)
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;

    vec3 col = vec3(0);
    vec3 ro = vec3(0, 3, 0); // Camera position (Floating 1 unit above ground)
    vec3 rd = normalize(vec3(uv.x, uv.y, 0.5)); // Ray direction

    float d_obj = RayMarch(ro, rd); // Get intercept distance from ro in direction rd
    
    vec3 p = ro + rd * d_obj; // Intercept point
    float dif = GetLight(p); // Diffusion
    col = vec3(dif);
    
    fragColor = vec4(col,1.0);
}