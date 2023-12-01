vec3 palette ( float t) 
{
    // Palette function with params from http://dev.thi.ng/gradients/
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263, 0.416, 0.557);
    
    return a + b*cos(6.28318*(c*t+d));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    // Normalise to (-1, 1) 
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);
    
    for(float i = 0.0; i < 4.0; i++){
        uv = fract(1.5*uv) - 0.5;

        float d = length(uv) * exp(-length(uv0));
        vec3 col = palette(length(uv0) + i*0.4 - iTime);

        d = 0.125*sin(d*8.0 + iTime);
        d = abs(d);
        d = pow(0.01 / d, 1.2);

        finalColor += (col * d)/(1.0 + i);
    }
    
    // Output to screen
    fragColor = vec4(finalColor, 1.0);
}