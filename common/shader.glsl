#version 330

in vec2 texcoord;
uniform sampler2D tex;
uniform float opacity;
uniform float u_ditherIntensity;

vec4 default_post_processing(vec4 c);

vec4 window_shader() {
    vec2 texsize = textureSize(tex, 0);
    vec4 color = texture2D(tex, texcoord / texsize, 0);
    float luminance = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    float noise = sin(dot(texcoord * 100.0, vec2(12.9898, 78.233))) * 0.5 + 0.5;
    luminance = luminance + (noise - 0.5) * 0.1; // coefficient of dithering
    luminance = clamp(luminance, 0.0, 1.0);
    vec4 grayscaleColor = vec4(vec3(luminance), color.a);
    grayscaleColor *= opacity;
    return default_post_processing(grayscaleColor);
}
