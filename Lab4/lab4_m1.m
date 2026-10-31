%% Read and display input image
f = imread('licence-plate.bmp');
f_double = double(f); % Convert to double for processing

% Display original image
figure(1);
subplot(2, 2, 1);
imshow(f);
title('Original Image');

%% Noise Removal
% h = fspecial('gaussian', 5, 1.5); % Gaussian filter for noise removal
% f_filtered = imfilter(f_double, h);
f_filtered = medfilt2(f_double, [3 3]); % Median filter for noise removal
subplot(2, 2, 2);
imshow(f_filtered, []);
title('After Noise Removal');

%% Image Sharpening
h = fspecial('unsharp', 0.3); % Sharpening filter
f_sharpened = imfilter(f_filtered, h); % Apply sharpening filter
subplot(2, 2, 3);
imshow(f_sharpened, []);
title('After Image Sharpening');

%% Contrast Enhancement
f_contrast = histeq(uint8(f_sharpened)); % Histogram equalization for contrast enhancement
subplot(2, 2, 4);
imshow(f_contrast, []);
title('Contrast Enhanced');

%% Convert back to uint8 for display and save
final_result = uint8(f_contrast);
imwrite(final_result, 'enhanced_licence_plate.bmp');
