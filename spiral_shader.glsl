const float pi = 3.141592654;

// Palette function with params from http://dev.thi.ng/gradients/
vec3 palette ( float t) 
{
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);
    
    return a + b*cos(6.28318*(c*t+d));
}

// Returns a moving spiral from uv
float spiral (vec2 uv)
{
    float a = 1.0;  // Number of "tails" branching from center.
    float b = 3.0;  // Density of spiral (number of rings on screen)
    float c = 1.0;  // Amount of fisheye effect (Try ~10 for De Moivre patterns!)
    float d = 0.5;  // Speed of propagation 
    
    // Polar coordinates for spiral
    float r = length(uv);
    float theta = atan(uv.y, uv.x);
    
    return fract(0.5* a * theta / pi + b * pow(r, c) - d * iTime);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    // Normalise to (-1, 1) 
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    float d_spiral = spiral(uv);
    
    vec3 col = palette(length(uv));

    vec3 final_color = d_spiral * col;

    fragColor = vec4(final_color, 1.0);
}