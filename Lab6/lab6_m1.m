% Read the image
rgb_image = imread('peppers.png');
%{
% Calculate the number of distinct colors using loops
[h, w, d] = size(rgb_image);

% Pre-allocate memory for the pixel list for better performance.
pixel_list = zeros(h * w, 3);

% Initialize a counter for the list rows
list_idx = 1;

% Loop over every pixel in the image

for r = 1:h      % Loop through rows
    for c = 1:w  % Loop through columns
        % Get the color of the current pixel (r, c)
        % The squeeze() function removes the extra dimensions
        pixel_color = squeeze(rgb_image(r, c, :))';

        % Add the color to our list
        pixel_list(list_idx, :) = pixel_color;
        list_idx = list_idx + 1;
    end
end

% distinct_colors = unique(pixel_list, 'rows');
% n_distinct = size(distinct_colors, 1);

%}

R = rgb_image(:, :, 1); G = rgb_image(:, :, 2); B = rgb_image(:, :, 3);

% Find the unique rows (colors) in the list we created
[x, y, z] = unique([R(:) G(:) B(:)], 'rows', 'stable');

% The number of distinct colors is the number of rows in the resulting matrix
n_distinct = size(x, 1);
fprintf('The number of distinct colors in the original image is %d.\n', n_distinct);

% Apply minimum variance quantization to reduce colors by half
n_quantized = floor(n_distinct / 2);

% rgb2ind with an integer argument performs minimum variance quantization by default
[quantized_image_X, quantized_map] = rgb2ind(rgb_image, n_quantized);

% Convert the indexed image back to RGB for saving
quantized_image_rgb = ind2rgb(quantized_image_X, quantized_map);

% Save the quantized image
imwrite(quantized_image_rgb, 'peppers_quantized.bmp');

% Compare the input and quantized images side-by-side
fprintf('Displaying images for comparison.\n');
fig = figure;
subplot(1, 2, 1);
imshow(rgb_image);
title('Original Image');

subplot(1, 2, 2);
imshow(quantized_image_rgb);
title('Quantized Image');

% Save the figure
saveas(fig, 'peppers_comparison.png');
