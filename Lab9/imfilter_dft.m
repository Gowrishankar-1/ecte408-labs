function g = imfilter_dft(f, h)
    [Hf, Wf] = size(f);  % input image size
    [Hh, Wh] = size(h);  % convolution kernel size
    P = Hf + Hh - 1;     % DFT size vertical
    Q = Wf + Wh - 1;     % DFT size horizontal

    f = double(f);
    F = fft2(f, P, Q);   % DFT of input image
    H = fft2(h, P, Q);   % DFT of convolution kernel
    G = F .* H;          % DFT of output image

    g_inverse = real(ifft2(G)); % Inverse DFT

    % Extract the output image of size HfxWf from g_inverse
    offset_y = floor((Hh + 1) / 2);
    offset_x = floor((Wh + 1) / 2);
    g = g_inverse(offset_y:offset_y + Hf - 1, ...
                  offset_x:offset_x + Wf - 1);
    g = uint8(g);       % Convert to unsigned 8-bit image
