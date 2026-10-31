# **Lab 5: Geometric Transformation of Images**

## **Key Points**

- **Geometric Transformation:** The process of mapping image pixel locations from an input image `f` to an output image `g`. An input pixel at location `(w, z)` is copied to a new location `(x, y)` in the output image.
  - `g(x, y) = f(w, z)`
  - The relationship is defined by a mapping function: `(x, y) = T(w, z)`

- **Matrix Representation:** Geometric transformations can be expressed using a 3-by-3 matrix `T` in homogeneous coordinates.

  ```matlab
  [x y 1] = [w z 1] * T
  ```

- **Common Transformation Types & Matrices:**
  - **Translation:** Shifts an image horizontally by `tx` and vertically by `ty`.

    ```matlab
    T = [1  0  0;
         0  1  0;
         tx ty 1]
    ```

  - **Scaling (Resizing):** Scales an image by a factor of `sx` horizontally and `sy` vertically.

    ```matlab
    T = [sx 0  0;
         0  sy 0;
         0  0  1]
    ```

  - **Rotation:** Rotates an image clockwise about the origin (0, 0) by an angle `θ`.

    ```matlab
    T = [cos(θ)  sin(θ) 0;
         -sin(θ) cos(θ) 0;
         0       0      1]
    ```

  - **Shear:** Skews an image with shear factors `α` (horizontal) and `β` (vertical).

    ```matlab
    T = [1  β  0;
         α  1  0;
         0  0  1]
    ```

- **Complex Transformations:**
  - **Affine:** A combination of translation, scaling, shear, and rotation. It preserves parallel lines and has six parameters.

    ```matlab
    T = [t11 t12 0;
        t21 t22 0;
        t31 t32 1]
    ```

  - **Projective:** A more general transform where parallel lines can converge. It preserves straight lines and has eight parameters.

    ```matlab
    T = [t11 t12 t13;
        t21 t22 t23;
        t31 t32 1]
    ```

- **Geometric Transformations in MATLAB:**
  - **Primary Functions:** A two-step process is generally used:
    1. **`maketform`**: Creates a transform structure.

       Syntax: `tform = maketform('affine', T);` where `T` is the 3x3 transformation matrix.

    2. **`imtransform`**: Applies the created transform to an image.

       Syntax: `g = imtransform(f, tform);` where `f` is the input image.

  - **Combining Transformations:** Applying multiple affine transforms (`T1`, `T2`, `T3`) in sequence is the same as applying a single composite transform `T`, which is the product of the individual matrices.
    - `T = T1 * T2 * T3`

  - **Finding a Transform from Points:** The `cp2tform` function can determine the parameters for a projective transform if four corresponding points between the input and output images are known.
    - Syntax: `tform = cp2tform(input_points, output_points, 'projective');`

  - **Simple Transformation Functions:**
    - **Resizing:** `g = imresize(f, scale);` or `g = imresize(f, [rows cols]);`
    - **Rotating:** `g = imrotate(f, angle);` (Note: Rotates counter-clockwise).
    - **Cropping:** `g = imcrop(f, [min_col min_row width height]);`

---

## **Answers to Lab Questions**

## **Section 5.3.1. a)**

```matlab
f = imread('Lena.bmp'); % read an image
%% Create a description of the desired transform
% Create 3-by-3 transformation matrix
alpha = pi/6;
T = [cos(alpha) sin(alpha) 0;
-sin(alpha) cos(alpha) 0;
0 0 1]
% Create TFORM structure
tform = maketform('affine', T)
%% Apply the transform on the input image
g = imtransform(f, tform);
imshow(g)
```

For angles of 90, 135, and -45, set `alpha = pi/2`, `alpha = 3 * pi/4` and `alpha = -pi/4` respectively.

## **Section 5.3.1 b)**

- **For scaling the input image by a factor of 1.5 horizontally and 2 vertically:**
  - **Transform Matrix:**

    ```matlab
    T_scale = [1.5  0   0;
               0    2   0;
               0    0   1];
    ```

- **For shearing the input image by a factor of 0.2 in the horizontal direction:**
  - **Transform Matrix:**

    ```matlab
    T_shear = [1   0   0;
               0.2 1   0;
               0   0   1];
    ```

- **For translating the input image by 50 pixels horizontally and 100 pixels vertically:**
  - **Transform Matrix:**

    ```matlab
    T_translate = [1   0   0;
                   0   1   0;
                   50  100 1];
    ```

**Program for the transformations:**

```matlab
f = imread('Lena.bmp'); % read image
% Create TFORM structure
tform = maketform('affine', T) % Where T is one of the matrices above
%% Apply the transform on the input image
g = imtransform(f, tform);
imshow(g)
```

## **Section 5.3.2 a)**

- The transformation types for the given matrices are:
  - **T1:** This is a **Rotation** matrix, with a clockwise rotation angle of `π/6` radians (30°).
  - **T2:** This is a **Scaling** matrix, with a horizontal scale factor `sx` of 1.5 and a vertical scale factor `sy` of 2.
  - **T3:** This is a **Shear** matrix, with a horizontal shear factor `α` of 0.2.

## **Section 5.3.2 b)**

Compute and show the output image when we apply the three transformations, first T1, then T2, and finally T3 on input image Lena.bmp.

```matlab
alpha = pi/6;
T1 = [cos(alpha) sin(alpha) 0; -sin(alpha) cos(alpha) 0; 0 0 1];

T2 = [1.5 0 0; 0 2 0; 0 0 1];

T3 = [1 0 0; 0.2 1 0; 0 0 1];

figure;

f = imread('Lena.bmp'); % read image
subplot(221); imshow(f)
title('Original Image')

% Apply T1
tform1 = maketform('affine', T1);
g1 = imtransform(f, tform1);
subplot(222); imshow(g1)
title('After T1 (rotation)')

% Apply T2
tform2 = maketform('affine', T2);
g2 = imtransform(g1, tform2);
subplot(223); imshow(g2)
title('After T2 (scaling)')

% Apply T3
tform3 = maketform('affine', T3);
g3 = imtransform(g2, tform3);
subplot(224); imshow(g3)
title('After T3 (shearing)')
```

## **Section 5.3.2 c)**

Calculate the product T of T1, T2 and T3. Compute the output image when the geometric transformation given by T is applied on input image Lena.bmp.

```matlab
alpha = pi/6;
T1 = [cos(alpha) sin(alpha) 0; -sin(alpha) cos(alpha) 0; 0 0 1];

T2 = [1.5 0 0; 0 2 0; 0 0 1];

T3 = [1 0 0; 0.2 1 0; 0 0 1];

T = T1 * T2 * T3;

% Apply the composite transform
tform = maketform('affine', T);
g = imtransform(f, tform);
figure; subplot(121); imshow(f); title('Original Image');
subplot(122); imshow(g); title('After Composite Transform');
```

## **Section 5.3.2 d)**

Comment on the results of comparing images from part (b) and (c):

The output images from part (b) (applying transforms T1, T2, and T3 sequentially) and part (c) (applying the single composite transform `T = T1 * T2 * T3`) are quite close to each other. This is because matrix multiplication is associative, and applying a series of linear transformations is mathematically equivalent to applying a single, combined transformation represented by the product of the individual transformation matrices.
