clear; close all; clc;
%% Pollen 

%Load pollen and run both versions 

f = imread('pollen.tif');
g_mine = my_histeq(f);  % my version 
g_matlab = histeq(f);   % matlab version

%show everything side by side

figure('Name','pollen.tif');
subplot(2,3,1); imshow(f);    title('Original');
subplot(2,3,2); imshow(g_mine); title('my\_histeq');
subplot(2,3,3); imshow(g_matlab); title('histeq (MATLAB)');
subplot(2,3,4); imhist(f);       title('Original histogram');
subplot(2,3,5); imhist(g_mine);  title('my\_histeq');
subplot(2,3,6); imhist(g_matlab); title('histeq (MATLAB)');
exportgraphics(gcf, 'task1_pollen.png', 'Resolution',200);

%Measure the differnce with a number not just by eye

diff_img = abs(double(g_mine) - double(g_matlab));
fprintf('pollen vs histeq(f): max differnce = %d, mean difference = %.2f\n', max(diff_img(:)), mean(diff_img(:)));

%Compare with default histeq(64 output level)

g_matlab256 = histeq(f, 256);
diff_img256 = abs(double(g_mine) - double(g_matlab256));
fprintf('pollen vs histeq(f, 256): max difference = %d, mean difference = %.2f\n', ...
    max(diff_img256(:)), mean(diff_img256(:)));

%% Landscape

%Read the image and convert it to gray 

f = rgb2gray(imread('landscape.bmp'));

%Count the gray level

fprintf('landscape: %d distinct grey level\n', numel(unique(f)));

%Run both versions 

g_mine = my_histeq(f);
g_matlab = histeq(f);

% Display landscape results and histograms

figure('Name','landscape.bmp');
subplot(2,3,1); imshow(f); title('Original');
subplot(2,3,2); imshow(g_mine); title('my\_histeq');
subplot(2,3,3); imshow(g_matlab); title('histeq (MATLAB)');
subplot(2,3,4); imhist(f); title('Original histogram');
subplot(2,3,5); imhist(g_mine); title('my\_histeq');
subplot(2,3,6); imhist(g_matlab); title('histeq (MATLAB)');
exportgraphics(gcf, 'task1_landscape.png', 'Resolution', 200);

%Compare with default histeq (64 output level) 

diff_img = abs(double(g_mine) - double(g_matlab));
fprintf('landscape vs histeq(f): max difference = %d, mean difference = %.2f\n', ...
    max(diff_img(:)), mean(diff_img(:)));

%Compare with histeq using 256 levels

g_matlab256 = histeq(f, 256);
diff_img256 = abs(double(g_mine) - double(g_matlab256));
fprintf('landscape vs histeq(f, 256): max difference = %d, mean difference = %.2f\n', ...
    max(diff_img256(:)), mean(diff_img256(:)));