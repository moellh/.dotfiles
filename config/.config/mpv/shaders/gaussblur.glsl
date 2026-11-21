// Light 5x5 Gaussian blur on luma (sigma ~0.8), before upscaling
//!HOOK LUMA
//!BIND HOOKED
//!DESC Gaussian blur (luma)
vec4 hook() {
    const float w[3] = float[](0.4950, 0.2376, 0.0149); // normalized 1D weights, sigma 0.8
    vec4 c = vec4(0.0);
    for (int y = -2; y <= 2; y++)
        for (int x = -2; x <= 2; x++)
            c += HOOKED_texOff(vec2(x, y)) * w[abs(x)] * w[abs(y)];
    return c;
}
