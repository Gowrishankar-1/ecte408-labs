% Load the Image
f = imread('Book.bmp');

% Display the image to let the user pick points
f1 = figure;
imshow(f);
title('Distorted Input Image - Click on the 4 corners of the book cover');

% Use ginput to select the four corners from the distorted image
disp('Click on the four corners of the book cover in this order: top-left, top-right, bottom-right, bottom-left.');

% Initialize an empty matrix to store the points
input_points = zeros(4, 2);

hold on; % Keep the image displayed while adding plots on top
for i = 1:4
    % ginput(1) waits for a single mouse click
    [x, y] = ginput(1);

    % Store the coordinates in our matrix
    input_points(i, :) = [x, y];

    % Plot a red cross at the clicked location to provide visual feedback.
    plot(x, y, 'r+', 'MarkerSize', 15, 'LineWidth', 2);
end
hold off; % Release the plot

% Extract the four corner points
topLeft = input_points(1, :);
topRight = input_points(2, :);
bottomRight = input_points(3, :);
bottomLeft = input_points(4, :);

% Calculate the lengths of the top/bottom and left/right sides using distance formula.
width_top = sqrt(sum((topRight - topLeft).^2));
width_bottom = sqrt(sum((bottomRight - bottomLeft).^2));

height_left = sqrt(sum((bottomLeft - topLeft).^2));
height_right = sqrt(sum((bottomRight - topRight).^2));

% Average the lengths of the opposing sides
avg_width = (width_top + width_bottom) / 2;
avg_height = (height_left + height_right) / 2;

% Round pixel dimensions to the nearest whole number.
output_width = round(avg_width);
output_height = round(avg_height);

disp(['Automatically determined output size: ', num2str(output_width), ' x ', num2str(output_height)]);

% Define the corner points for the desired rectangular output image
output_points = [1, 1                           % Top-left
                 output_width, 1                % Top-right
                 output_width, output_height    % Bottom-right
                 1, output_height];             % Bottom-left

% Calculate the Transformation
tform = cp2tform(input_points, output_points, 'projective');

% Apply the Transformation
g = imtransform(f, tform, 'XData', [1 output_width], 'YData', [1 output_height]);

% Display the Results
close(f1);
figure;
subplot(1, 2, 1);
imshow(f);
title('Original Distorted Photo');
subplot(1, 2, 2);
imshow(g);
title('Geometrically Corrected Photo');
