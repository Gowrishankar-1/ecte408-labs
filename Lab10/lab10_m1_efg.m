%% Lab 10 E1 parts (d-extra), (e), (f), (g)
% Run lab10_m1.m first (it creates T and the cell array B), or paste this
% at the bottom of lab10_m1.m.

%% (d) extra: check ALL 64x64 pairs, not just a few
% Stack every basis image as one column of a 64x64 matrix.
% If the basis images are orthogonal (and unit length), M' * M = identity.
M = zeros(64, 64);
for k = 0:7
    for l = 0:7
        M(:, k*8 + l + 1) = B{k+1, l+1}(:);
    end
end
G = M' * M;                                   % every dot product at once
off_diag = G - diag(diag(G));
fprintf('(d) Largest dot product between DIFFERENT basis images = %.2e\n', max(abs(off_diag(:))));
fprintf('(d) Dot product of each basis image with itself: min %.4f, max %.4f\n', min(diag(G)), max(diag(G)));

%% (e) DCT of one 8x8 block, two ways
I = double(imread('Elaine.tiff'));            % 512x512 greyscale
r = 257; c = 257;                             % top-left corner of the block (any multiple of 8, plus 1)
f = I(r:r+7, c:c+7);

% (i) Using basis images, Equation (10.14): F(k,l) = sum over m,n of f(m,n) * B_{k,l}(m,n)
F_basis = zeros(8, 8);
for k = 0:7
    for l = 0:7
        F_basis(k+1, l+1) = sum(sum(f .* B{k+1, l+1}));
    end
end

% (ii) Using dct2
F_dct2 = dct2(f);

fprintf('(e) Max difference between basis-image DCT and dct2 = %.2e\n', max(abs(F_basis(:) - F_dct2(:))));
disp('F from dct2 (rounded):'); disp(round(F_dct2));

%% (f) Keep top-left triangle, S = 4 (10 of 64 coefficients)
S = 4;
[kk, ll] = ndgrid(1:8, 1:8);                  % kk = row index, ll = column index (1-based)
mask_f = (kk + ll) <= S + 1;                  % shaded cells in Figure 10.1a
[g_f, mse_f, psnr_f] = keep_coeffs(I, mask_f);
fprintf('(f) Top-left triangle S=%d: kept %d/64, MSE = %.2f, PSNR = %.2f dB\n', S, nnz(mask_f), mse_f, psnr_f);

%% (g) Keep bottom-right square, S = 5 (25 of 64 coefficients)
S = 5;
mask_g = (kk >= 9 - S) & (ll >= 9 - S);       % rows 4..8 and columns 4..8, Figure 10.1b
[g_g, mse_g, psnr_g] = keep_coeffs(I, mask_g);
fprintf('(g) Bottom-right square S=%d: kept %d/64, MSE = %.2f, PSNR = %.2f dB\n', S, nnz(mask_g), mse_g, psnr_g);

figure('Name', 'Lab 10 E1 (f) and (g)');
subplot(2,3,1); imshow(uint8(I));   title('Original Elaine');
subplot(2,3,2); imshow(uint8(g_f)); title(sprintf('(f) top-left, 10 coeffs\nPSNR = %.2f dB', psnr_f));
subplot(2,3,3); imshow(uint8(g_g)); title(sprintf('(g) bottom-right, 25 coeffs\nPSNR = %.2f dB', psnr_g));
subplot(2,3,5); imagesc(mask_f); axis image; colormap(gca, gray); title('mask (f)');
subplot(2,3,6); imagesc(mask_g); axis image; colormap(gca, gray); title('mask (g)');
% (g) output is mostly near 0 (black), so also view it auto-scaled:
figure('Name', '(g) auto-scaled'); imshow(g_g, []); title('(g) reconstruction, auto-scaled to show the edges');

%% Local function (must stay at the very end of the script)
function [g, mse_val, psnr_val] = keep_coeffs(I, mask)
    % Blockwise DCT -> zero every coefficient where mask is false -> inverse DCT
    F = blockproc(I, [8 8], @(b) dct2(b.data));
    F = blockproc(F, [8 8], @(b) b.data .* mask);
    g = blockproc(F, [8 8], @(b) idct2(b.data));

    mse_val  = mean((I(:) - g(:)).^2);                 % Equation (10.11)
    psnr_val = 10 * log10(max(I(:))^2 / mse_val);      % Equation (10.12), f_max = max pixel of INPUT
end
