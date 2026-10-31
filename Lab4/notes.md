# **Lab 4: Image Processing in the Spatial Domain**

## **2-D Convolution and Correlation**

- **Convolution vs Correlation:**
  - In 2-D convolution, we compute the output image by convolving the input image with a convolution kernel
  - In 2-D correlation, we compute the output image by correlating the input image with a correlation mask
  - The 2-D convolution of an image with kernel h is the same as 2-D correlation with mask m if m is obtained by rotating h by 180°

- **Convolution Process:**
  - **Step 1:** Rotate the convolution kernel h by 180° to obtain correlation mask m
  - **Step 2:** Slide m over the input image so its center coincides with the target position
  - **Step 3:** Multiply m and the input pixels underneath it, then sum all the products

## **MATLAB Functions for 2-D Operations**

- **imfilter Function:**
  - For 2-D convolution: `g = imfilter(f, h, 'conv')`
  - For 2-D correlation: `g = imfilter(f, m, 'corr')`
  - Difference is in the third parameter

- **rot90 Function:**
  - `m = rot90(h, 2);` - Rotates kernel h counter-clockwise by 180°
  - Used to obtain correlation mask from convolution kernel

- **fspecial Function:** Generates predefined convolution kernels
  - `h = fspecial('average', 5)` - Creates 5×5 averaging filter
  - `h = fspecial('gaussian', 5, 0.5)` - Creates 5×5 Gaussian filter with $\sigma$ = 0.5
  - `h_unsharp = fspecial('unsharp', 0.2)` - Creates unsharp masking filter

## **Linear Image Filtering Applications**

### **Image Smoothing (Low-pass Filters)**

- **Purpose:** Remove noise from images
- **Characteristics of smoothing filters:**
  - All coefficients are positive
  - Sum of all coefficients equals 1
- **Side effects:** Blur the image, especially noticeable at edges

- **Types of Smoothing Filters:**
  - **Averaging Filter:** All coefficients are the same, `h(u,v) = 1/M²` where M is kernel size
  - **Gaussian Low-pass Filter:** Based on Gaussian function `G(x,y) = e^(-(x-μₓ)²+(y-μᵧ)²)/(2σ²))`
    - Requires normalization so all coefficients sum to 1
    - Parameter $\sigma$ controls the amount of smoothing

### **Image Sharpening**

- **Unsharp Masking Technique:**
  - Finds the 'unsharp' component through low-pass filtering
  - Subtracts this component from original to get edge image
  - Adds edge image back to original to make edges crisper
  - Single filter kernel: `h = [0 -α 0; -α (1+4α) -α; 0 -α 0]` where α is scalar parameter, α > 0

### **Edge Detection**

- **Linear filters for edge detection:**
  - **Prewitt Operators:** Eight different operators for detecting edges in specific directions
    - P₁ detects horizontal edges
    - P₈ detects vertical edges
    - P₂ detects diagonal edges
  - **Sobel Operators:** Eight different operators similar to Prewitt
    - S₁ detects horizontal edges
    - S₈ detects vertical edges
    - S₂ detects diagonal edges

- **Edge Detection Process:**
  1. Apply horizontal and vertical operators separately
  2. Calculate edge strength along x and y directions
  3. Combine results: `edge_magnitude = sqrt(edge_x.^2 + edge_y.^2)`
  4. Apply threshold to determine edge pixels

## **Nonlinear Image Filtering**

### **Median Filter**

- **Concept:** Output pixel is the median of neighboring pixels (not linear combination)
- **Process:**
  1. Define neighborhood (e.g., 3×3 or 5×5)
  2. Sort pixel values in ascending order
  3. Select middle value as output

- **MATLAB Implementation:**
  - Built-in function: `g = medfilt2(f, [m n])` where [m n] is filter size
  - Custom implementation using `median()` function on pixel neighborhoods

- **Applications:** Particularly effective for removing salt-and-pepper noise

### **Boundary Handling**

- When filter neighborhood exceeds image boundaries:
  - Adjust coordinates: `x1 = max(x1, 1); x2 = min(x2, width)`
  - Similarly for y coordinates: `y1 = max(y1, 1); y2 = min(y2, height)`
