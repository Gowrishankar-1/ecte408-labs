% Read the input images
bg = imread('landscape.bmp');
fg = imread('foreground.bmp');

% Display original images
subplot(1, 3, 1);
imshow(bg);
title('Background Image');

subplot(1, 3, 2);
imshow(fg);
title('Foreground Image');

% Convert to double for calculations
bg_double = double(bg);
fg_double = double(fg);

lambda = 0.7;

% Create composite using linear combination: C = lambda*A + (1-lambda)*B
composite = lambda * bg_double + (1 - lambda) * fg_double;

% Convert back to uint8
composite = uint8(composite);

% Display Method 1 result
subplot(1, 3, 3);
imshow(composite);
title(sprintf('Method 1: Linear Blend (\\lambda=%.1f)', lambda));

% Save Method 1 result
imwrite(composite, 'composite_method.bmp');
fprintf('Image saved as: composite_method.bmp\n');
