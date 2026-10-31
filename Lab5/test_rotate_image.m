% TEST_ROTATE_IMAGE  Tests rotate_image on Lena.bmp with theta = 30 degrees
% (Lab 5, Exercise E3).
clear; close all; clc;

f = imread('Lena.bmp');
theta = 30;

g = rotate_image(f, theta);      % rotate clockwise by 30 degrees

fprintf('Input size:  %d x %d\n', size(f, 1), size(f, 2));
fprintf('Output size: %d x %d\n', size(g, 1), size(g, 2));

figure('Name', 'Image rotation');
subplot(1,2,1); imshow(f); title('Lena.bmp');
subplot(1,2,2); imshow(g); title('Rotated clockwise by 30^o');
exportgraphics(gcf, 'task3_rotation.png', 'Resolution', 200);