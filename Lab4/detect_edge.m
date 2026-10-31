% Written by Lam Phung
f = rgb2gray(imread('shapes.bmp')); % Read input image
figure(1);
subplot(2, 2, 1);
imshow(f);
title('Input image');
f = double(f);

%% Linear image filtering
hx = [1  1  1; 0  0  0; -1 -1 -1]; % Prewitt horizontal operator
hy = [1  0 -1; 1  0 -1;  1  0 -1]; % Prewitt vertical operator
edge_x = imfilter(f, hx, 'conv');   % Edge strength along x direction
edge_y = imfilter(f, hy, 'conv');   % Edge strength along y direction

%% Show edge detection based on individual operator
% Consider a pixel as an edge pixel if edge strength exceeds a threshold
edge_threshold = 1;
subplot(2, 2, 3);
imshow(abs(edge_x) > edge_threshold);
title('Horizontal operator');
subplot(2, 2, 4);
imshow(abs(edge_y) > edge_threshold);
title('Vertical operator');

%% Combining both horizontal and vertical filter outputs
edge_magnitude = sqrt(edge_x.^2 + edge_y.^2); % Combined edge strength
edge_threshold = 1;
edge_map = (edge_magnitude >= edge_threshold);
subplot(2, 2, 2);
imshow(edge_map);
title('Edges based on both operators');

%% Show edge directions
[H, W] = size(f);
[x, y] = meshgrid(1:W, 1:H);
figure(2);
quiver(x, y, edge_x, edge_y);
axis image;
axis ij;
