function [v, u] = dftuv(H, W)
    % R.C. Gonzalez, R. E. Woods and S. L. Eddins,
    % Digital Image Processing Using MATLAB,
    % Prentice Hall
    p = 0:(H - 1);
    q = 0:(W - 1);
    idx = find(p > H / 2);
    p(idx) = p(idx) - H;
    idx = find(q > W / 2);
    q(idx) = q(idx) - W;
    [v, u] = meshgrid(p / H, q / W);
