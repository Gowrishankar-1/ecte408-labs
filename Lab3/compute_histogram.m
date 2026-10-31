function h = compute_histogram(f, bin_size)
    % Quantize pixel values to bin_size bins
    f = double(f); % Ensure double for calculation
    f = floor(f * bin_size / 256); % Map [0,255] to [0,bin_size-1]

    [rows, cols] = size(f);
    h = zeros(bin_size, 1);

    for r = 1:rows
        for c = 1:cols
            pix = f(r, c);
            h(pix + 1) = h(pix + 1) + 1;
        end
    end
end
