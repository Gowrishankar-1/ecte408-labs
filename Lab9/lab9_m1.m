% Read input image
f = imread('Lena.bmp');
f = double(f);
[H, W] = size(f);

% Create the ideal high-pass filter
[v, u] = dftuv(H, W);  % Create frequency grid
Hd = zeros(H, W);      % Allocate and initialize ideal high-pass filter
D0 = 0.04;             % Cut-off frequency (suitable value for high-pass)

% Find (u,v) pairs where distance > cut-off frequency
idx = sqrt(u.^2 + v.^2) > D0;
% For these (u,v) pairs, set frequency response to 1
Hd(idx) = 1;

% Perform filtering in the frequency domain
F = fft2(f);                    % Compute 2-D DFT of input image
Fc = fftshift(F);               % Center the DFT
Hc = fftshift(Hd);              % Center the filter
G = Fc .* Hc;                   % 2-D DFT of output image
g = real(ifft2(G));             % Inverse DFT
g = uint8(g);                   % Convert to unsigned 8-bit image

% Display results
figure;
subplot(1,3,1), imshow(uint8(f)), title('Original Image');
subplot(1,3,2), imagesc(Hc), colormap(gray), axis image, title(['Ideal High-Pass Filter (D_0 = ', num2str(D0), ')']);
subplot(1,3,3), imshow(g), title('High-Pass Filtered Output');
