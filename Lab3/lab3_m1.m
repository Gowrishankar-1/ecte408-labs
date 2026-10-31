f = imread('landscape.bmp'); % Read image
f = rgb2gray(f); % Convert to grayscale
h = compute_histogram(f, 256);

% Calculate histogram using MATLAB's built-in function for comparison
[matlab_h, x] = imhist(f);

% Plot
figure(1);
subplot(1, 2, 1);
stem(0:255, h, '.'); % Histogram
title('My Histogram Function'); % Graph title
xlabel('Bin');
ylabel('Count');
grid on; % Labels and grid

subplot(1, 2, 2);
stem(x, matlab_h, '.'); % Histogram
title('MATLAB imhist()'); % Graph title
xlabel('Bin');
ylabel('Count');
grid on; % Labels and grid

A = (h == matlab_h);
disp(logical(all(A == A(1))));

%% Part c

g = imread('landscape.bmp'); % Read image
g = rgb2gray(g); % Convert to grayscale
bin_size = 128;
h2 = compute_histogram(g, bin_size);

% Calculate histogram using MATLAB's built-in function for comparison
[matlab_h2, x2] = imhist(g, bin_size);

% Plot
figure(2);
subplot(1, 2, 1);
stem(0:127, h2, '.'); % Histogram
title('My Histogram Function'); % Graph title
xlabel('Bin');
ylabel('Count');
grid on; % Labels and grid

subplot(1, 2, 2);
stem(0:127, matlab_h2, '.'); % Histogram
title('MATLAB imhist()'); % Graph title
xlabel('Bin');
ylabel('Count');
grid on; % Labels and grid
disp(logical(all(A == A(1))));

%% Part c2

g = imread('landscape.bmp'); % Read image
g = rgb2gray(g); % Convert to grayscale
bin_size = 64;
h2 = compute_histogram(g, bin_size);

% Calculate histogram using MATLAB's built-in function for comparison
[matlab_h2, x2] = imhist(g, bin_size);

% Plot
figure(2);
subplot(1, 2, 1);
stem(0:63, h2, '.'); % Histogram
title('My Histogram Function'); % Graph title
xlabel('Bin');
ylabel('Count');
grid on; % Labels and grid

subplot(1, 2, 2);
stem(0:63, matlab_h2, '.'); % Histogram
title('MATLAB imhist()'); % Graph title
xlabel('Bin');
ylabel('Count');
grid on; % Labels and grid
disp(logical(all(A == A(1))));
