function g = my_histeq(f)
%Step 1 Compute the image histogram h
L = 256;
h = zeros(L, 1);
[rows, cols] = size(f);

for row = 1:rows
    for col = 1:cols
        x = double(f(row,col));
        h(x + 1) = h(x + 1) + 1;
    end
end

%Step 2 normalised histogram p
p = h / sum(h);  % fraction of pixels at each grey level
%Step 3 cumulative sum C, C answers which fraction is dark or darker
c = cumsum(p);   % C(k) = fraction of pixels at level k-1 or darker

%Step 4 Map every pixel using T(u) = (L-1) * C(u) 
g = zeros(rows, cols);

for row = 1:rows
    for col = 1: cols
        u = double(f(row, col));
        g(row, col) = (L-1) * c(u+1);
    end
end

g = uint8(g);    % Turns the result into a proper image type and rounds it up

end