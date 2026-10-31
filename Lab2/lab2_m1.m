% Read the input image
input_image = imread('peppers.png');

% Get image dimensions
[height, width, ~] = size(input_image);

% Create output image (copy of input)
output_image = input_image;

% Create red border

% Top border
output_image(1:3, :, 1) = 255;  % Red channel
output_image(1:3, :, 2) = 0;    % Green channel
output_image(1:3, :, 3) = 0;    % Blue channel

% Bottom border
output_image(height - 3 + 1:height, :, 1) = 255;
output_image(height - 3 + 1:height, :, 2) = 0;
output_image(height - 3 + 1:height, :, 3) = 0;

% Left border
output_image(:, 1:3, 1) = 255;
output_image(:, 1:3, 2) = 0;
output_image(:, 1:3, 3) = 0;

% Right border
output_image(:, width - 3 + 1:width, 1) = 255;
output_image(:, width - 3 + 1:width, 2) = 0;
output_image(:, width - 3 + 1:width, 3) = 0;

% Write the output image to file
imwrite(output_image, 'peppers_frame.jpg');

% Display success message
fprintf('Image processing complete!\n');

% Optional: Display both images for comparison
figure(1);
subplot(1, 2, 1);
imshow(input_image);
title('Original Image');

subplot(1, 2, 2);
imshow(output_image);
title('Image with Red Border');
