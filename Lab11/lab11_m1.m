%% Read images and store in 4-D array
num_images = 90;

% Read first image to get dimensions
first_image = imread(fullfile('images', 'image-1.jpg'));
[H, W, C] = size(first_image);

% Pre-allocate 4-D array
images = zeros(H, W, C, num_images, 'uint8');

% Read all images in ascending order
fprintf('Reading %d images...\n', num_images);
for k = 1:num_images
    file_name = fullfile('images', ['image-' int2str(k) '.jpg']);
    images(:,:,:,k) = imread(file_name);
end
disp('All images loaded successfully');

%% Write 4-D array to AVI file
fprintf('\nCreating E1-video.avi...\n');
output_video1 = VideoWriter('E1-video.avi');
open(output_video1);
writeVideo(output_video1, images);
close(output_video1);
disp('E1-video.avi created successfully');

%% Create output video with red border and averaged RGB
fprintf('\nProcessing frames for E1-output-video.avi...\n');
output_video2 = VideoWriter('E1-output-video.avi');
open(output_video2);

% Pre-allocate output array
output_images = zeros(H, W, C, num_images, 'uint8');
border_width = 3;

for n = 1:num_images
    frame = images(:,:,:,n);

    % Extract RGB channels
    R = double(frame(:,:,1));
    G = double(frame(:,:,2));
    B = double(frame(:,:,3));

    % Calculate average of RGB for each pixel
    avg = (R + G + B) / 3;

    % Create output frame with averaged RGB
    output_frame = zeros(H, W, 3, 'uint8');
    output_frame(:,:,1) = uint8(avg);  % Red = average
    output_frame(:,:,2) = uint8(avg);  % Green = average
    output_frame(:,:,3) = uint8(avg);  % Blue = average

    % Add red border (3 pixels wide)
    % Top border
    output_frame(1:border_width, :, 1) = 255;
    output_frame(1:border_width, :, 2) = 0;
    output_frame(1:border_width, :, 3) = 0;

    % Bottom border
    output_frame(H-border_width+1:H, :, 1) = 255;
    output_frame(H-border_width+1:H, :, 2) = 0;
    output_frame(H-border_width+1:H, :, 3) = 0;

    % Left border
    output_frame(:, 1:border_width, 1) = 255;
    output_frame(:, 1:border_width, 2) = 0;
    output_frame(:, 1:border_width, 3) = 0;

    % Right border
    output_frame(:, W-border_width+1:W, 1) = 255;
    output_frame(:, W-border_width+1:W, 2) = 0;
    output_frame(:, W-border_width+1:W, 3) = 0;

    % Store output frame
    output_images(:,:,:,n) = output_frame;
end

% Write to video file and close
writeVideo(output_video2, output_images);
close(output_video2);
disp('E1-output-video.avi created successfully');

%% View the output video
fprintf('\nDisplaying output video...\n');
output_mov = immovie(output_images);
movie(output_mov);
