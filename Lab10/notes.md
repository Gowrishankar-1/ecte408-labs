# **Lab 10: Discrete Cosine Transform and Image Compression**

## **The Discrete Cosine Transform (DCT)**

### **Definition**

The 2-D DCT represents an image as a weighted sum of cosine waves with varying spatial frequencies.

**Forward DCT:**

For image f of size H×W, the DCT coefficient at position (k,l) is:

$$F(k,l) = \alpha_k\alpha_l \sum_{m=0}^{H-1} \sum_{n=0}^{W-1} f(m,n) \cos\left(\frac{\pi(2m+1)k}{2H}\right) \cos\left(\frac{\pi(2n+1)l}{2W}\right)$$

where:

$$\alpha_k = \begin{cases} \sqrt{\frac{1}{H}} & \text{if } k = 0 \\ \sqrt{\frac{2}{H}} & \text{if } k \neq 0 \end{cases}$$

$$\alpha_l = \begin{cases} \sqrt{\frac{1}{W}} & \text{if } l = 0 \\ \sqrt{\frac{2}{W}} & \text{if } l \neq 0 \end{cases}$$

**Inverse DCT:**

$$f(m,n) = \sum_{k=0}^{H-1} \sum_{l=0}^{W-1} \alpha_k\alpha_l F(k,l) \cos\left(\frac{\pi(2m+1)k}{2H}\right) \cos\left(\frac{\pi(2n+1)l}{2W}\right)$$

### **Key Properties**

- **Linear and invertible:** Original image can be perfectly reconstructed from DCT coefficients
- **DCT coefficient F(k,l):** Controls proportions of sinusoidal terms; larger values indicate more significant frequencies
- **Energy compaction:** For continuous-tone images (photographs), DCT coefficients at higher frequencies (large k, l) are close to zero
- **Compression potential:** High-frequency coefficients can be discarded or coarsely quantized without significant distortion

---

## **MATLAB Implementation**

### **Forward DCT**

#### **Method 1: Using FFT (for large images)**

```matlab
F = dct2(f);
```

- Uses Fast Fourier Transform algorithm
- DCT obtained by discarding sine (complex) components from DFT
- Efficient for large images

#### **Method 2: Using transformation matrix (for small images, e.g., 8×8)**

```matlab
T = dctmtx(N);        % Generate DCT transformation matrix
F = T * f * T';       % Compute DCT via matrix multiplication
```

- Suitable for small image blocks (e.g., 8×8 pixels in JPEG)

### **Inverse DCT**

#### **Method 1: Using idct2**

```matlab
g = idct2(F);
```

#### **Method 2: Using transformation matrix**

```matlab
g = T' * F * T;
```

### **Image Quality Metrics**

**Mean Square Error (MSE):**

$$MSE = \frac{1}{HW} \sum_{m=0}^{H-1} \sum_{n=0}^{W-1} [f(m,n) - g(m,n)]^2$$

**Peak Signal-to-Noise Ratio (PSNR):**

$$PSNR = 10 \log_{10}\left(\frac{f_{max}^2}{MSE}\right) \text{ dB}$$

where f_max is the maximum pixel value in the input image.

- **High PSNR** = low distortion
- **Typical range for compression:** 20-40 dB

---

## **DCT Basis Images**

### **Formula**

For a given pair (k,l), the basis image B\_{k,l} is:

$$B_{k,l}(m,n) = \alpha_k\alpha_l \cos\left(\frac{\pi(2m+1)k}{2H}\right) \cos\left(\frac{\pi(2n+1)l}{2W}\right)$$

where m = 0,1,...,H-1 and n = 0,1,...,W-1.

### **Properties**

- For DCT size H×W, there are H×W basis images
- **Forward DCT in terms of basis images:**

$$F(k,l) = \sum_{m=0}^{H-1} \sum_{n=0}^{W-1} f(m,n) \cdot B_{k,l}(m,n)$$

- **Inverse DCT in terms of basis images:**

$$f(m,n) = \sum_{k=0}^{H-1} \sum_{l=0}^{W-1} F(k,l) \cdot B_{k,l}(m,n)$$

- **Orthogonality:** Basis images are orthogonal to each other. For any two pairs (k,l) ≠ (k',l'):

$$\sum_{m=0}^{H-1} \sum_{n=0}^{W-1} B_{k,l}(m,n) \cdot B_{k',l'}(m,n) = 0$$
