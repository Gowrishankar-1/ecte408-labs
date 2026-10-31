x = -5:0.05:5; % Vector of x values
y = zeros(size(x)); % Preallocate y values

for i = 1:length(x)
    y(i) = lab1_m2(x(i)); % Compute f(x) for each x
end

plot(x, y); % Plot the function
xlabel('x');
ylabel('f(x)');
title('Plot of lab1-m2 function');
grid on;
