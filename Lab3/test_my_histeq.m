%% landscape.bmp

% Read in a test image
input_image = imread('landscape.bmp');

% Call the histogram equalization function
output_image = my_histeq(input_image);

% Compute with MATLAB built-in function histeq
output_image_matlab = histeq(input_image);

% Display the results
figure;
subplot(1, 2, 1);
imshow(output_image);
title('Equalized Image (Custom)');

subplot(1, 2, 2);
imshow(output_image_matlab);
title('Equalized Image (MATLAB)');

% Find the maximum absolute difference between the two images
max_diff = max(abs(double(output_image(:)) - double(output_image_matlab(:))));
fprintf('Maximum absolute difference between custom and MATLAB equalized images: %d\n', max_diff);

% Check if both images are the same
if isequal(output_image, output_image_matlab)
    disp('The custom and MATLAB equalized images are the same.');
else
    disp('The custom and MATLAB equalized images are different.');
end

%% mammogram.tif

% Read in a test image
input_image = imread('mammogram.tif');

% Call the histogram equalization function
output_image = my_histeq(input_image);

% Compute with MATLAB built-in function histeq
output_image_matlab = histeq(input_image);

% Display the results
figure;
subplot(1, 2, 1);
imshow(output_image);
title('Equalized Image (Custom)');

subplot(1, 2, 2);
imshow(output_image_matlab);
title('Equalized Image (MATLAB)');

% Find the maximum absolute difference between the two images
max_diff = max(abs(double(output_image(:)) - double(output_image_matlab(:))));
fprintf('Maximum absolute difference between custom and MATLAB equalized images: %d\n', max_diff);

% Check if both images are the same
if isequal(output_image, output_image_matlab)
    disp('The custom and MATLAB equalized images are the same.');
else
    disp('The custom and MATLAB equalized images are different.');
end

%% pollen.tif

% Read in a test image
input_image = imread('pollen.tif');

% Call the histogram equalization function
output_image = my_histeq(input_image);

% Compute with MATLAB built-in function histeq
output_image_matlab = histeq(input_image);

% Display the results
figure;
subplot(1, 2, 1);
imshow(output_image);
title('Equalized Image (Custom)');

subplot(1, 2, 2);
imshow(output_image_matlab);
title('Equalized Image (MATLAB)');

% Find the maximum absolute difference between the two images
max_diff = max(abs(double(output_image(:)) - double(output_image_matlab(:))));
fprintf('Maximum absolute difference between custom and MATLAB equalized images: %d\n', max_diff);

% Check if both images are the same
if isequal(output_image, output_image_matlab)
    disp('The custom and MATLAB equalized images are the same.');
else
    disp('The custom and MATLAB equalized images are different.');
end