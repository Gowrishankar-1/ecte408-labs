f     = imread('Lena-salt-pepper-noise.bmp');   % noisy input
f_ref = imread('Lena.bmp');                     % clean image (from Lab 5)

M_values = [1 3 5 9 13];                        % centre weights to test

figure('Name', 'CWM filter results');
subplot(2,3,1); imshow(f); title('Noisy input');

for k = 1:numel(M_values)
    M = M_values(k);
    g = cw_median_filter(f, M);

    % Noise left: % of pixels that are pure black or pure white
    noise_left = 100 * mean(g(:) == 0 | g(:) == 255);
    % PSNR against the clean image (higher = closer to clean)
    p = psnr(g, f_ref);

    subplot(2,3,k+1); imshow(g);
    if M == 1
        title('M = 1 (median filter)');
    else
        title(sprintf('CWM, M = %d', M));
    end

    fprintf('M = %2d: noise left = %5.2f %%, PSNR = %.2f dB\n', M, noise_left, p);
end

fprintf('Input:  noise = %5.2f %%, PSNR = %.2f dB\n', ...
    100 * mean(f(:) == 0 | f(:) == 255), psnr(f, f_ref));

exportgraphics(gcf, 'task2_cwm.png', 'Resolution', 200);