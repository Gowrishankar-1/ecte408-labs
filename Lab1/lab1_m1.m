%% Section 1 - using for loop
A = 0;
for i = 1:100
    A = A + i^3;
end
disp(A);

%% Section 2 - using while loop
A = 0;
i = 1;
while i <= 100
    A = A + i^3;
    i = i + 1;
end
disp(A);
