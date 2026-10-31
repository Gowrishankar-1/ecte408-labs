% Quality factors to test
quality_factors = [1, 0.25, 4.00];

% Standard JPEG quantization matrix
quant_base = [16, 11, 10, 16, 24, 40, 51, 61;
              12, 12, 14, 19, 26, 58, 60, 55;
              14, 13, 16, 24, 40, 57, 69, 56;
              14, 17, 22, 29, 51, 87, 80, 62;
              18, 22, 37, 56, 68,109,103, 77;
              24, 35, 55, 64, 81,104,113, 92;
              49, 64, 78, 87,103,121,120,101;
              72, 92, 95, 98,112,100,103, 99];

for idx = 1:length(quality_factors)
    m = quality_factors(idx);

    fprintf('Processing with quality factor m = %.2f\n', m);

    %% Read input image and convert to grayscale
    f_rgb = imread('peppers.png');
    f = rgb2gray(f_rgb);
    f_original = double(f);

    %% Subtract 128 from grayscale image
    f_shifted = f_original - 128;

    %% Divide into 8×8 blocks and compute DCT
    blockSize = [8 8];

    % Apply DCT to each 8×8 block
    F_dct = blockproc(f_shifted, blockSize, @(block) dct2(block.data));

    %% Quantize DCT coefficients
    quant = quant_base * m;

    % Quantization: divide by quantization matrix and round
    F_quantized = blockproc(F_dct, blockSize, @(block) round(block.data ./ quant));

    %% Reverse operations: dequantization and inverse DCT

    % Dequantization: multiply by quantization matrix
    F_dequantized = blockproc(F_quantized, blockSize, @(block) block.data .* quant);

    % Inverse DCT to each 8×8 block
    f_restored_shifted = blockproc(F_dequantized, blockSize, @(block) idct2(block.data));

    % Add back 128
    f_restored = f_restored_shifted + 128;

    % Convert to uint8
    f_restored = uint8(f_restored);

    %% Calculate difference image and MSE
    difference = double(f) - double(f_restored);

    % Calculate MSE
    mse_value = immse(f, f_restored);

    % Calculate PSNR
    psnr_value = psnr(f_restored, f);

    fprintf('MSE = %.4f\n', mse_value);
    fprintf('PSNR = %.2f dB\n', psnr_value);

    %% Display original, restored, and difference images

    % Scale difference image to [0, 255] for display
    diff_min = min(difference(:));
    diff_max = max(difference(:));
    difference_scaled = (difference - diff_min) / (diff_max - diff_min) * 255;
    difference_scaled = uint8(difference_scaled);

    figure();

    subplot(1, 3, 1);
    imshow(f);
    title('Original Grayscale Image');

    subplot(1, 3, 2);
    imshow(f_restored);
    title(sprintf('Restored Image\nMSE = %.2f, PSNR = %.2f dB', mse_value, psnr_value));

    subplot(1, 3, 3);
    imshow(difference_scaled);
    title(sprintf('Difference Image (scaled)\nRange: [%.1f, %.1f]', diff_min, diff_max));

    sgtitle(sprintf('JPEG Baseline Coding with Quality Factor m = %.2f', m));
end
