%%
% |d| 
% Read input image
f = imread('Lena-gaussian-noise.bmp');
f = double(f);
[H, W] = size(f);

% Create the Butterworth low-pass filter
[v, u] = dftuv(H, W);  % Create frequency grid
D = sqrt(u.^2 + v.^2); % Distance from DC component
D0 = 0.7;              % Cut-off frequency (suitable for noise removal)
n = 3;                 % Filter order (third-order)

% Butterworth filter formula: H(u,v) = 1 / [1 + (D/D0)^(2n)]
Hd = 1 ./ (1 + (D ./ D0).^(2*n));

% Perform filtering in the frequency domain
F = fft2(f);                    % Compute 2-D DFT of input image
Fc = fftshift(F);               % Center the DFT
Hc = fftshift(Hd);              % Center the filter
G = Fc .* Hc;                   % 2-D DFT of output image
g = real(ifft2(G));             % Inverse DFT
g = uint8(g);                   % Convert to unsigned 8-bit image

% Display results
figure;
subplot(1,3,1), imshow(uint8(f)), title('Noisy Image');
subplot(1,3,2), imagesc(Hd), colormap(gray), axis image, title(['Butterworth LPF (D_0 = ', num2str(D0), ', n = ', num2str(n), ')']);
subplot(1,3,3), imshow(g), title('Filtered Output');
