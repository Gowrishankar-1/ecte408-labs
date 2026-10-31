# **Lab 3: Image Enhancement Using Point Operations**

## **Key Concepts and MATLAB Functions**

This lab explores image enhancement techniques based on point operations, where a pixel's value is modified independently of its neighbors.

**Intensity Adjustment:** The fundamental principle is to transform an original intensity value `u` to a new intensity value `v` using a function `v = T(u)`.

## **Intensity Adjustment Techniques**

### **1. Image Negative**

Computes the negative of an image, which is useful for enhancing white or gray details embedded in dark regions.

- **MATLAB Implementation:** For an 8-bit image `f` (where L=256), the negative `g` can be computed by subtracting the original image from the maximum pixel value (255).

  ```matlab
  f = imread('mammogram.tif');
  g = 255 - f;
  ```

### **2. Linear and Non-linear Stretching (imadjust)**

The `imadjust` function is a tool for mapping image intensity values.

- **Syntax:**
  `g = imadjust(f, [low_in high_in], [low_out high_out], gamma)`
- **Functionality:**
  - Maps intensity values in image `f` from the range `[low_in high_in]` to the range `[low_out high_out]`.
  - Input and output ranges are specified in the range `[0, 1]`. For `uint8` images, the function automatically scales these to `[0, 255]`.
  - The `gamma` parameter controls the shape of the mapping curve.
    - `gamma = 1`: The mapping is linear (Linear Stretching).
    - `gamma < 1`: The mapping is weighted toward higher (brighter) output values.
    - `gamma > 1`: The mapping is weighted toward lower (darker) output values.
- **Example (Linear Stretching):**

  ```matlab
  f = imread('pollen.tif');
  % Maps intensities from [20 70] to the full [0 255] range
  g = imadjust(f, [20 70]/255, [0 255]/255, 1);
  ```

### **3. Contrast Stretching**

This technique expands the range of intensity levels in an image to span the full dynamic range. The transformation function is given by: `T(u) = 1 / (1 + (m/u)^E)`.

- **Parameters:**
  - `m`: Controls the boundary between dark and bright values.
  - `E`: Controls the slope of the function.
- **MATLAB Implementation:** Note that image data must be converted to `double` for arithmetic operations.

  ```matlab
  f = imread('bone-scan.tif');
  f1 = double(f); % Convert to double for calculations
  m = mean2(f1);  % Example value for m
  E = 2.0;        % Example value for E
  g_double = 1./(1 + (m./(f1 + eps)).^E);
  g = im2uint8(g_double); % Convert back to uint8 for display
  ```

where `eps` is a built-in constant representing smallest incremenet between distinct numbers in float numbers.

---

## **Image Histogram**

A histogram is a graph showing the frequency of each intensity value in an image. It reveals key characteristics like brightness and contrast.

### **1. Histogram Computation (imhist)**

The `imhist` function computes the histogram of an image.

- **Syntax:** `[h, x] = imhist(f, B);`
  - `f`: Input grayscale image.
  - `B`: Number of bins (e.g., 256 for an 8-bit image).
  - `h`: A vector containing the count for each bin.
  - `x`: A vector containing the bin locations (intensity values).
- **Plotting the Histogram:** The `stem` or `plot` function can be used to visualize the histogram.

  ```matlab
  f = rgb2gray(imread('landscape.bmp'));
  [h, x] = imhist(f, 256);
  stem(x, h, '.');
  xlabel('Bin (Intensity Value)');
  ylabel('Count');
  ```

### **2. Normalized Histogram**

A histogram can be normalized so that the sum of its components equals 1. This represents the probability of occurrence of each intensity level.

- **MATLAB Implementation:**

  ```matlab
  p = h / sum(h); % 'p' is the normalized histogram
  ```

## **Histogram Equalization**

This is a technique to improve image contrast by redistributing pixel intensities. The goal is to produce an image with a more uniform histogram.

### **1. Histogram Equalization Function (histeq)**

MATLAB's Image Processing Toolbox provides the `histeq` function to perform this operation automatically.

- **Syntax:** `g = histeq(f);`
  - `f`: The original low-contrast image.
  - `g`: The histogram-equalized output image.

### **2. How Histogram Equalization Works**

It uses an intensity mapping function based on the cumulative sum of the normalized histogram.

- **Cumulative Sum (cumsum):** The `cumsum` function is used to calculate the cumulative distribution function (CDF) from the normalized histogram `p`.
  - **Syntax:** `C = cumsum(p);`
- **Transformation Function:** The new pixel value `T(u)` is calculated as `T(u) = (L-1) * C(u)`, where `L` is the number of intensity levels (e.g., 256) and `C(u)` is the cumulative sum at intensity level `u`.
