%Function
% writing my own function my_histeq.m which is my equaliser
% Pollen.tf is grey and flat -looking because all its pixel value are
% squeezed into a narrow range, roughly 70 to 140, instead of using the full
% 0 (black) to 255( white). 
% Low contract means everything looks similar
%Histogram = x-axis -> brightness 0-255, y-axis -> how many pixel have that
%brightness therefore for pollen all the bars are bunched together in the
%middle. 

% Goal is to spread those bars out across the 0-255 range, so dark things
% get darker, bright things get brighter, and you can see details.

% Steps: 1) count the pixels at each brightness (h = histogram)
% 2) Turn counts into fractions p ( p=h/total pixels)
% 3) Running total of fractions  c ( c= cumsum(p))
% 4) for each pixel u , new values = 255 x c(U) -> g (output image)


% why this order as you cant build C without P and you cant build P without
% building H as each step need one before.

% why we use a function instead of the script: as it takes the input and
% return an output : g = my_histeq(f)
% That lest you reuse it on any image with one line. You retest script then
% just calls it twice, once for landscape and once for pollen.

f = imread('pollen.tif');
imshow(f)
figure, imhist(f)
