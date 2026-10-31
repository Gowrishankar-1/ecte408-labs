# **Lab 9: Image Processing in the Frequency Domain**

## **The 2-D Discrete Fourier Transform (DFT)**

### **Mathematical Definition**

For an image `f(x, y)` of size M×N:

$$F(u,v) = \sum_{x=0}^{M-1} \sum_{y=0}^{N-1} f(x,y) \exp\left[-j2\pi\left(\frac{ux}{M} + \frac{vy}{N}\right)\right]$$

where:

- `u` = 0, 1, …, M-1 (horizontal frequency index)
- `v` = 0, 1, …, N-1 (vertical frequency index)
- F(u,v) is the frequency representation of f(x,y)

### **Inverse 2-D DFT**

$$f(x,y) = \frac{1}{MN} \sum_{u=0}^{M-1} \sum_{v=0}^{N-1} F(u,v) \exp\left[j2\pi\left(\frac{ux}{M} + \frac{vy}{N}\right)\right]$$

### **Frequency Analysis**

- **Complex representation:** `F(u,v) = R(u,v) + jI(u,v)`
- **Magnitude spectrum:** `|F(u,v)| = √[R²(u,v) + I²(u,v)]` - shows significant frequency components
- **Phase spectrum:** `φ(u,v) = arctan[I(u,v)/R(u,v)]`
- **Normalized frequencies:** u/M and v/N range from [0, 1) or [-0.5, 0.5)

---

## **MATLAB Implementation**

### **Computing the 2-D DFT**

```matlab
F = fft2(f);              % Compute 2-D DFT
F = fft2(f, H, W);        % Specify DFT size (zero-pads to H×W)
```

- `F(1,1)` corresponds to DC component (u=0, v=0)
- `F(3,8)` corresponds to v=2, u=7 (normalized frequencies: 2/N, 7/M)
- H and W often chosen as powers of 2 for computational efficiency

### **Analyzing the DFT**

```matlab
F_mag = abs(F);           % Magnitude spectrum
F_phase = angle(F);       % Phase spectrum

% Visualize magnitude (log scale for large dynamic range)
imagesc(log10(1 + F_mag));
```

### **Inverse DFT**

```matlab
f1 = real(ifft2(F));      % Use real() to discard numerical errors
```

### **Shifting DC Component to Center**

```matlab
Fc = fftshift(F);         % Shift DC to center for visualization

% Centered normalized frequencies [-0.5, 0.5)
u = [0:1/W:1-1/W] - 1/2;
v = [0:1/H:1-1/H] - 1/2;
```

### **Shifting DC Component to Center (Mathematical Representation)**

$$g(x,y) = (-1)^{x+y} f(x,y)$$

---

## **Linear Filtering Using the DFT**

### **Convolution Theorem**

**Key principle:** Convolution in spatial domain = Multiplication in frequency domain

If `g = f * h`, then `G(u,v) = F(u,v) · H(u,v)`

### **Four Steps for DFT-based Filtering**

1. Compute DFT of image: `F = fft2(f, P, Q)`
2. Compute DFT of kernel: `H = fft2(h, P, Q)`
3. Multiply entry-by-entry: `G = F .* H`
4. Inverse DFT: `g = real(ifft2(G))`

### **Avoiding Aliasing**

DFT size must be at least:

- **P ≥ Hf + Hh - 1** (rows)
- **Q ≥ Wf + Wh - 1** (columns)

where Hf×Wf is image size, Hh×Wh is kernel size

### **Custom Function: imfilter_dft**

```matlab
function g = imfilter_dft(f, h)
    [Hf, Wf] = size(f);
    [Hh, Wh] = size(h);
    P = Hf + Hh - 1;
    Q = Wf + Wh - 1;

    F = fft2(double(f), P, Q);
    H = fft2(h, P, Q);
    G = F .* H;

    g_inverse = real(ifft2(G));

    % Extract valid region
    offset_y = floor((Hh+1)/2);
    offset_x = floor((Wh+1)/2);
    g = g_inverse(offset_y:offset_y+Hf-1, offset_x:offset_x+Wf-1);
    g = uint8(g);
end
```

---

## **Common Filters in Frequency Domain**

### **Filter Types**

- **Low-pass filter:** Attenuates high frequencies → smooths image
- **High-pass filter:** Attenuates low frequencies → sharpens edges
- **Band-pass filter:** Keeps specific frequency band
- **Band-stop filter:** Rejects specific frequency band

### **Frequency Distance**

For normalized frequencies u, v ∈ [-0.5, 0.5]:

$$D(u,v) = \sqrt{u^2 + v^2}$$

D₀ = cutoff frequency

### **Ideal Filters**

**Low-pass:**

```matlab
H(u,v) = 1  if D(u,v) ≤ D₀
         0  otherwise
```

**High-pass:**

```matlab
H(u,v) = 0  if D(u,v) ≤ D₀
         1  otherwise
```

**MATLAB Implementation:**

```matlab
[v, u] = dftuv(H, W);
D = sqrt(u.^2 + v.^2);
D0 = 0.2;
H_lp = double(D <= D0);    % Ideal low-pass
H_hp = double(D > D0);     % Ideal high-pass
```

**Characteristics:** Sharp cutoff, may cause ringing artifacts

### **Butterworth Filters**

**Formula:**
$$H(u,v) = \frac{1}{1 + \left(\frac{D(u,v)}{D_0}\right)^{2n}}$$

**MATLAB Implementation:**

```matlab
[v, u] = dftuv(H, W);
D = sqrt(u.^2 + v.^2);
D0 = 0.2;
n = 2;                      % Filter order
H = 1 ./ (1 + (D./D0).^(2*n));
```

**Parameters:**

- D₀ = cutoff frequency
- n = filter order (higher n → sharper transition)

**Characteristics:** Smooth transition, no ringing

### **Gaussian Filters**

**Formula:**
$$H(u,v) = \exp\left[-\frac{D^2(u,v)}{2\sigma^2}\right]$$

**MATLAB Implementation:**

```matlab
[v, u] = dftuv(H, W);
D = sqrt(u.^2 + v.^2);
sigma = 0.1;
H = exp(-(D.^2)./(2*sigma^2));
```

**Parameter:** σ = standard deviation (controls smoothing amount)

**Characteristics:** Very smooth, no ringing

### **High Boost Filter**

Enhances high frequencies while preserving low frequencies:

$$H(u,v) = k - H_{lp}(u,v)$$

where k > 1 (boost factor) and Hlp is a Gaussian low-pass filter

**MATLAB Implementation:**

```matlab
% Create Gaussian low-pass
[v, u] = dftuv(H, W);
D = sqrt(u.^2 + v.^2);
sigma = 0.1;
H_lp = exp(-(D.^2)./(2*sigma^2));

% Create high boost
k = 2.5;
H_highboost = k - H_lp;

% Apply filter
F = fft2(f);
G = F .* H_highboost;
g = real(ifft2(G));
```

**Applications:** Image sharpening, edge enhancement

---

## **Helper Function: dftuv**

Generates normalized frequency grids:

```matlab
[v, u] = dftuv(H, W);
```

- Creates matrices u and v of size W×H
- Values range from -0.5 to 0.5
- Used to compute D(u,v) = √(u² + v²)

---

## Practice Question Answer

### **Section 9.3 (f)**

```matlab
f1 = imread('hstripes.bmp');
F1 = fft2(f1);
F1_mag = abs(F1);

f2 = imread('vstripes.bmp');
F2 = fft2(f2);
F2_mag = abs(F2);

f3 = imread('dstripes.bmp');
F3 = fft2(f3);
F3_mag = abs(F3);

f1_reconstructed = real(ifft2(F1));
error = mse(double(f1), double(f1_reconstructed));
disp(['Mean-Square-Error: ', num2str(error)]);

figure;
% Show all originals, magnitude spectrums, and the reconstructed image
subplot(2,4,1), imshow(f1), title('hstripes.bmp');
subplot(2,4,2), imshow(log(1 + F1_mag), []), title('Magnitude Spectrum of hstripes');
subplot(2,4,3), imshow(f2), title('vstripes.bmp');
subplot(2,4,4), imshow(log(1 + F2_mag), []), title('Magnitude Spectrum of vstripes');
subplot(2,4,5), imshow(f3), title('dstripes.bmp');
subplot(2,4,6), imshow(log(1 + F3_mag), []), title('Magnitude Spectrum of dstripes');
subplot(2,4,7), imshow(f1_reconstructed, []), title('Reconstructed hstripes');
subplot(2,4,8), text(0.1, 0.5, ['MSE: ', num2str(error)]), axis off;
```

### **Section 9.4 (b)**

The function computes the convolution of image `f` with kernel `h` by transforming both to the frequency domain using `fft2` with zero-padding to size P×Q (which prevents aliasing), multiplying them element-wise, then applying the inverse DFT. After obtaining the inverse transform, it extracts only the valid central region of size Hf×Wf by calculating appropriate offsets based on the kernel size, discarding the padded boundaries.

### **Section 9.4 (c-f)**

```matlab
% (c) Apply 5×5 averaging filter using imfilter_dft
f = imread('Lena.bmp');
h = fspecial('average', 5);
g_dft = imfilter_dft(f, h);

% (d) Compare with imfilter from Lab 4
g_spatial = imfilter(f, h, 'conv');

% Comparing the results from both methods
figure;
subplot(1,2,1), imshow(g_dft), title('DFT filtering');
subplot(1,2,2), imshow(g_spatial), title('Spatial filtering');

% (e) Measure processing times for 5×5 filter
tic;
g_dft = imfilter_dft(f, h);
time_dft_5x5 = toc;

tic;
g_spatial = imfilter(f, h, 'conv');
time_spatial_5x5 = toc;

fprintf('5×5 Filter:\n');
fprintf('  imfilter_dft time: %.4f seconds\n', time_dft_5x5);
fprintf('  imfilter time: %.4f seconds\n', time_spatial_5x5);

% (f) Compare processing times for 99×99 filter
h_large = fspecial('average', 99);

tic;
g_dft_large = imfilter_dft(f, h_large);
time_dft_99x99 = toc;

tic;
g_spatial_large = imfilter(f, h_large, 'conv');
time_spatial_99x99 = toc;

fprintf('\n99×99 Filter:\n');
fprintf('  imfilter_dft time: %.4f seconds\n', time_dft_99x99);
fprintf('  imfilter time: %.4f seconds\n', time_spatial_99x99);
fprintf('\nSpeedup factor: %.2fx\n', time_spatial_99x99/time_dft_99x99);
```

**Results:**

```text
5×5 Filter:
  imfilter_dft time: 0.0184 seconds
  imfilter time: 0.0034 seconds

99×99 Filter:
  imfilter_dft time: 0.0248 seconds
  imfilter time: 0.0060 seconds

Speedup factor: 0.24x
```

**Observation:**

Contrary to theoretical expectations, direct spatial convolution (`imfilter`) outperforms the DFT-based method (`imfilter_dft`) for both small and large kernels in this implementation.

This unexpected result is due to the provided `imfilter_dft` implementation padding to size `(Hf + Hh - 1) × (Wf + Wh - 1)`, which creates large, non-power-of-2 dimensions that are inefficient for FFT computation. A properly optimized FFT-based implementation using power-of-2 padding would show the expected speedup for large kernels.
