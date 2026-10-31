function g = rotate_image(f, theta)
% ROTATE_IMAGE  Rotates image f clockwise about its centre by theta degrees
% (Lab 5, Exercise E3). Does not use imrotate or imtransform.
%   Uses inverse mapping and nearest-neighbour interpolation.

% Step 0: Angle in radians, cos and sin
t = theta * pi / 180;        % degrees -> radians
c = cos(t);
s = sin(t);

% Step 1: Size of the output image (Lab 5, page 43)
[H, W] = size(f);                          % input height and width
Ho = round(H * abs(c) + W * abs(s));       % output height
Wo = round(H * abs(s) + W * abs(c));       % output width
g  = zeros(Ho, Wo, 'like', f);             % black output image, same type as f

% Centres of the input and output images
cw = (W + 1) / 2;    cz = (H + 1) / 2;     % input centre  (column, row)
cx = (Wo + 1) / 2;   cy = (Ho + 1) / 2;    % output centre (column, row)

% Step 2: For each output pixel, find where it came from (inverse mapping)
for y = 1:Ho
    for x = 1:Wo
        % Move origin to the output centre
        xc = x - cx;
        yc = y - cy;

        % Inverse rotation (rotate by -theta)
        wc =  xc * c + yc * s;
        zc = -xc * s + yc * c;

        % Move back to input image coordinates, nearest neighbour
        w = round(wc + cw);      % input column
        z = round(zc + cz);      % input row

        % Copy the pixel if it lies inside the input image
        if w >= 1 && w <= W && z >= 1 && z <= H
            g(y, x) = f(z, w);   % MATLAB index is (row, column)
        end
    end
end
end