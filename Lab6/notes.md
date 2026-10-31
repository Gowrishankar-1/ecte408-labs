# Lab 6: Color Image Processing

## Mean and Covariance

- **`mean(X)`:** Computes the mean of the elements of a vector `X`.
- **`std(X)`:** Computes the standard deviation of the elements of a vector `X`.
- **`var(X)`:** Computes the variance of the elements of a vector `X`.
- **`cov(X)`:** If `X` is a vector, `cov(X)` returns the variance. If `X` is a matrix where each row is an observation and each column is a variable, `cov(X)` returns the covariance matrix.

Example:

```matlab
X = [112, 207, 239, 150];
mean_X = mean(X);
std_X = std(X);
var_X = var(X);

Z = [112 78 113; 207 100 22; 239 220 205; 150 180 100];
cov_Z = cov(Z);
```

## Color Image Representation in MATLAB

MATLAB supports two types of color image representations:

- **RGB images:** Stored as a 3D array of size H x W x 3. The color of a pixel at `(y, x)` is stored in `a(y, x, :)`.
- **Indexed images:** Consist of a 2D matrix and a color map. The matrix contains indices into the color map.

## Conversion from RGB to indexed image

The `rgb2ind` function can be used to convert an RGB image to an indexed image using one of three methods:

- **Uniform quantization:** Divides the color space into a grid of cubes and represents all colors within a cube with a single color.
- **Minimum variance quantization:** Chooses colors for the colormap that minimize the mean square error between the original and quantized images.
- **Color map approximation:** Matches each color in the input image to the nearest color in a specified colormap.

## Color Spaces

Besides RGB, MATLAB supports other color spaces like:

- **YCbCr:** Widely used in digital image and video compression. It separates the luma component (Y) from the chroma components (Cb and Cr).
- **HSV:** Represents colors in terms of Hue, Saturation, and Value.

## Image Segmentation Based on Color

Image segmentation is the process of partitioning an image into multiple segments. Color-based segmentation groups pixels with similar color properties. The similarity can be measured using Euclidean or Mahalanobis distance.

---

## Answers to Questions

1. **For image 'peppers.png', what is the color at pixel location (x = 50, y = 100)?**
   To find the color of the pixel at (50, 100) in 'peppers.png', you would use the `impixel` function in MATLAB:

   ```matlab
   a = imread('peppers.png');
   pixel_color = impixel(a, 50, 100);
   disp(pixel_color);
   ```

2. **For image Sydney_indexed.bmp, what is the color at pixel location (x = 50, y = 100)?**
   For an indexed image, you first get the index from the image matrix and then use that index to find the color in the colormap.

   ```matlab
   [X, map] = imread('Sydney_indexed.bmp');
   pixel_index = X(100, 50);
   pixel_color = map(pixel_index, :);
   disp(pixel_color);
   ```

3. **Write MATLAB code to produce an indexed image using uniform quantization with a tolerance of 0.5. What is the total number of colors n in the output color map?**

   ```matlab
   a = imread('peppers.png');
   [X_uniform, map_uniform] = rgb2ind(a, 0.5);
   n = size(map_uniform, 1);
   disp(n);
   ```

   The number of colors `n` will be at most `(ceil(1/0.5) + 1)^3 = 27`.

4. **Write MATLAB code to produce an indexed image using minimum-variance quantization. The number of output colors should be the same as in uniform quantization (above).**

   ```matlab
   a = imread('peppers.png');
   [X_minvar, map_minvar] = rgb2ind(a, 0.5);
   n_minvar = size(map_minvar, 1);
   disp(n_minvar);
   [X_minvar, map_minvar] = rgb2ind(a, n_minvar);
   ```

5. **Display the two output images side-by-side using MATLAB function subimage. Which image has a better visual quality? Explain.**

   ```matlab
   figure;
   subplot(1, 2, 1);
   subimage(X_uniform, map_uniform);
   title('Uniform Quantization');

   subplot(1, 2, 2);
   subimage(X_minvar, map_minvar);
   title('Minimum Variance');
   ```

   The image created with minimum variance quantization has better visual quality. This is because it chooses the colors to best represent the original image, while uniform quantization simply divides the color space, which may not be optimal for a specific image.

6. **Write MATLAB code to display the Y, Cb, Cr, H, S, V color components of the image.**

   ```matlab
   a = imread('Sydney.jpg');
   im_ycbcr = rgb2ycbcr(a);
   im_hsv = rgb2hsv(a);

   figure;
   subplot(2,3,1), imshow(im_ycbcr(:,:,1)), title('Y');
   subplot(2,3,2), imshow(im_ycbcr(:,:,2)), title('Cb');
   subplot(2,3,3), imshow(im_ycbcr(:,:,3)), title('Cr');
   subplot(2,3,4), imshow(im_hsv(:,:,1)), title('H');
   subplot(2,3,5), imshow(im_hsv(:,:,2)), title('S');
   subplot(2,3,6), imshow(im_hsv(:,:,3)), title('V');
   ```

7. **Write MATLAB code to create and display an output image, where the S component is increased 3 times, whereas the H and V components are kept the same.**

   ```matlab
   a = imread('Sydney.jpg');
   im_hsv = rgb2hsv(a);
   im_hsv(:,:,2) = im_hsv(:,:,2) * 3;
   im_new = hsv2rgb(im_hsv);
   imshow(im_new);
   ```
