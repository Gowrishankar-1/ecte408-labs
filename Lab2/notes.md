# **Lab 2: Basic Image Operations**

## **2.1 Learning Objectives**

This lab focuses on fundamental image operations in MATLAB. Key skills to be acquired include:

- Reading and writing various image file formats.
- Displaying images.
- Accessing and modifying individual image pixels.

## **2.2 Key MATLAB Functions and Concepts**

- **Reading an Image:** The `imread('filename')` function is used to read an image file into a matrix. For instance, `a = imread('peppers.png');` stores the image data of 'peppers.png' in the variable 'a'.

- **Displaying an Image:**
  - `imshow(a)`: Displays the image stored in matrix 'a'.
  - `imagesc(a)`: Scales the image data to the full colormap range before displaying.
  - `impixelinfo`: An interactive tool that shows the value of the pixel under the mouse cursor.

- **Image Size:** The `size(a)` function returns the dimensions of the image matrix.
  - `[H, W, ~] = size(a)` will assign the height to H and the width to W.

- **Image Information:** The `imageinfo('filename')` command provides metadata about the image file.

- **Image Structure:**
  - Color images are represented as three-dimensional arrays (height x width x color channels).
  - The three color components (Red, Green, Blue) can be accessed as separate 2D arrays:
    - Red component: `a(:, :, 1)`
    - Green component: `a(:, :, 2)`
    - Blue component: `a(:, :, 3)`

- **Accessing and Modifying Pixel Values:**
  - `a(r, c, :)` accesses the RGB values of the pixel at row `r` and column `c`.
  - To change a pixel's color, you can assign new values to its color channels. For example, to make the pixel at (4, 5) red:

    ```matlab
       a(4, 5, 1) = 255; % Red
       a(4, 5, 2) = 0;   % Green
       a(4, 5, 3) = 0;   % Blue
    ```

- **Color to Grayscale Conversion:** The `rgb2gray(a)` function converts an RGB image 'a' to a grayscale image.

- **Arithmetic Operations:**
  - Image data is often stored as `uint8` (unsigned 8-bit integers) to conserve memory.
  - For arithmetic operations like addition or multiplication, images should first be converted to a floating-point format, such as `double`, using `a_double = double(a);`.
  - After the calculations, the image should be converted back to `uint8` for display or saving: `a_uint8 = uint8(a_double);`.

- **Writing an Image to File:** The `imwrite(A, 'filename.fmt')` function saves the data in matrix A to a file with the specified name and format. For instance:

  ```matlab
  imwrite(gray_image, 'my_image.jpg', 'JPG');
  ```

## **2.3 Exercises**

### **E1: Basic image operations**

This exercise involves the following steps:

1. Read the 'peppers.png' image file.
2. Create a new image by adding a 3-pixel wide red rectangular border to the original image.
3. Save the resulting image as 'peppers_frame.jpg'.

### **E2: Creating a layered image**

This exercise requires creating a composite image by superimposing a foreground image ('foreground.bmp') onto a background image ('landscape.bmp'). The final composite image should be saved as 'composite.bmp'.

Two methods are suggested:

- **Method 1: Linear Combination**
  - This method creates the composite image `C` by taking a weighted average of the two input images `A` (foreground) and `B` (background): `C = λ*A + (1 - λ)*B`, where `λ` is a value between 0 and 1.
  - A drawback of this method is that it tends to reduce the brightness of the background image.
  - Images `A` and `B` must be converted to `double` for the calculation and the resulting image `C` must be converted back to `uint8`.

- **Method 2: Brightness Retention**
  - This approach aims to maintain the original brightness of the background.
  - The pixels from the foreground image (the text) should retain their yellowish color, while the background pixels should keep their original values from 'landscape.bmp'.
  - This requires a more selective method of combining the images, likely involving identifying the non-black pixels in the foreground image and replacing the corresponding pixels in the background image.
