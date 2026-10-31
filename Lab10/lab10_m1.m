%% Compute the DCT transformation matrix
N = 8;
T = dctmtx(N);

fprintf('DCT Transformation Matrix T:\n');
disp(T);

%% Compute and display basis image B_{3,5}
k = 3;
l = 5;

% Compute basis image
B_3_5 = T(k+1, :)' * T(l+1, :);

figure();
imagesc(B_3_5); % Scales full range properly
axis image; % Keep aspect ratio
axis off; % Turn off axis ticks
title(sprintf('Basis Image B_{%d,%d}', k, l));
xlabel('n');
ylabel('m');

%% Compute and display all basis images
B = cell(8, 8);  % Cell array to store all 64 DCT basis images

figure();
for k = 0:7
    for l = 0:7
        % Generate basis image: B_{k,l}(m,n) = T(k+1,:)' * T(l+1,:)
        B{k+1, l+1} = T(k+1, :)' * T(l+1, :);

        % Display in 8x8 subplot grid
        subplot(8, 8, k*8 + l + 1);
        imagesc(B{k+1, l+1});
        axis image;
        axis off;
    end
end
sgtitle('All 64 DCT Basis Images (k = 0:7, l = 0:7)');

%% Verify orthogonality
fprintf('Verifying Orthogonality\n');

% Test a few pairs to verify orthogonality
test_cases = [
    0, 0, 0, 1;
    0, 0, 1, 0;
    2, 3, 4, 5;
    4, 2, 6, 7;
    3, 5, 3, 5;  % Same pair (should not be zero)
    7, 6, 7, 6;  % Same pair (should not be zero)
    0, 0, 0, 0;  % Same pair (should not be zero)
    6, 7, 6, 7;  % Same pair (should not be zero)
];

for i = 1:size(test_cases, 1)
    k1 = test_cases(i, 1);
    l1 = test_cases(i, 2);
    k2 = test_cases(i, 3);
    l2 = test_cases(i, 4);

    % Compute orthogonality condition
    is_orthogonal = sum(sum(B{k1+1, l1+1} .* B{k2+1, l2+1}));

    fprintf('B_{%d,%d} · B_{%d,%d} = %.0f \n', k1, l1, k2, l2, abs(is_orthogonal));
end