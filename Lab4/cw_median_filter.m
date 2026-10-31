function g = cw_median_filter(f, M)
[height, width] = size(f);   % size of input image
g = zeros(height, width);    % allocate memory for output image

for y = 1:height
    for x = 1:width
        x1 = x - 2;   % left column of the 5x5 window
        x2 = x + 2;   % right column of the 5x5 window
        y1 = y - 2;   % top row of the 5x5 window
        y2 = y + 2;   % bottom row of the 5x5 window

        % When the neighbourhood exceeds the image boundary, adjust coordinates
        x1 = max(x1, 1);
        x2 = min(x2, width);
        y1 = max(y1, 1);
        y2 = min(y2, height);

        window = f(y1:y2, x1:x2);   % 5 x 5 window
        window = window(:);         % rearrange window into a column vector

        centre = f(y, x);                    % centre pixel value
        extra  = repmat(centre, M - 1, 1);   % M-1 extra copies of the centre
        window = [window; extra];            % centre now appears M times

        g(y, x) = median(window);   % output pixel = median of weighted list
    end
end

g = uint8(g);   % convert to 8-bit image
end