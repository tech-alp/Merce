#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 surfaceSize;
    vec4 cornerRadii; // top left, top right, bottom right, bottom left
    vec4 color;      // Qt supplies QColor uniforms with premultiplied alpha
    float progress;
    float intensity;
    float bandWidth;
    float pixelSize;
} ubuf;

void main()
{
    vec2 size = max(ubuf.surfaceSize, vec2(0.0));
    if (size.x <= 0.0 || size.y <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    vec2 position = qt_TexCoord0 * size;
    vec2 centered = position - size * 0.5;
    vec4 radii = clamp(ubuf.cornerRadii, 0.0, min(size.x, size.y) * 0.5);
    float radius = centered.y < 0.0
        ? (centered.x < 0.0 ? radii.x : radii.y)
        : (centered.x < 0.0 ? radii.w : radii.z);
    vec2 corner = abs(centered) - size * 0.5 + radius;
    float distanceToEdge = min(max(corner.x, corner.y), 0.0)
        + length(max(corner, vec2(0.0))) - radius;
    float coverage = 1.0 - smoothstep(-max(ubuf.pixelSize, 0.001), 0.0, distanceToEdge);

    float halfBand = max(1.0, size.x * clamp(ubuf.bandWidth, 0.0, 1.0)) * 0.5;
    float travel = size.x + size.y * 0.35 + 2.0 * halfBand;
    float center = -halfBand + clamp(ubuf.progress, 0.0, 1.0) * travel;
    float band = 1.0 - smoothstep(0.0, halfBand,
                                abs(position.x + position.y * 0.35 - center));

    fragColor = ubuf.color * (coverage * band * clamp(ubuf.intensity, 0.0, 1.0)
                             * ubuf.qt_Opacity);
}
