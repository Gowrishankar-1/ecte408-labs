# **Lab 11: Video Processing in MATLAB and Simulink**

## **Reading and Viewing Video**

### **Creating a Video Object**

To read a video file, use `VideoReader` to construct a video object:

```matlab
video_object = VideoReader('carphone.avi');
```

### **Video Properties**

**Number of frames:**

```matlab
N = video_object.NumberOfFrames;
```

**Frame dimensions:**

```matlab
H = video_object.Height;  % Height of each frame
W = video_object.Width;   % Width of each frame
```

### **Reading Video Frames**

**Read all frames:**

```matlab
images = read(video_object);
```

- `images` is a 4-D array of size H × W × 3 × N
- Video frame n is stored at `images(:, :, :, n)`

**Read specific frames:**

```matlab
a = read(video_object, 10);        % Read frame 10
b = read(video_object, [2, 20]);   % Read frames 2 to 20
```

**Display a single frame:**

```matlab
c = images(:,:,:,1);  % Extract frame 1
imshow(c);            % Display frame 1
```

### **Viewing Video**

Convert image array to MATLAB movie format:

```matlab
mov = immovie(images);
```

Display the video:

```matlab
movie(mov);
```

---

## **Processing and Creating Video**

### **VideoWriter Object**

To create an output video file:

```matlab
output_object = VideoWriter('output.avi');
open(output_object);
```

### **Writing Frames to Video**

Write 4-D array to video file:

```matlab
writeVideo(output_object, images);
```

Close the video file when done:

```matlab
close(output_object);
```

---

## **MATLAB Movies**

### **Movie Structure**

A MATLAB movie is an array of structures where each element is a **frame**.

**Extracting a frame:**

```matlab
frame = mov(10);  % Extract movie frame 10
```

**Frame structure:**

```matlab
frame =
    cdata: [288x352x3 uint8]
    colormap: []
```

**Fields:**

- `cdata`: Pixel values matrix (H × W × 3 for color images)
- `colormap`: Color map (empty for true-color images)

**Displaying a frame:**

```matlab
imshow(frame.cdata);
```

### **Creating MATLAB Frames**

**From an image variable:**

```matlab
a = imread('carphone_010.bmp');
frame = im2frame(a);
```

**From a MATLAB plot:**

```matlab
[X, Y, Z] = peaks(50);
surfc(X, Y, Z);
frame = getframe;
imshow(frame.cdata);
```

### **Adding Frames to Movies**

Use array indexing to insert frames:

```matlab
mov(5) = frame;  % Insert frame as 5th movie frame
```

### **Saving Movies to AVI Files**

**Method 1: Using `movie2avi`**

```matlab
movie2avi(mov, 'output.avi', 'compression', 'none');
```

**Method 2: Using `writeVideo`**

```matlab
output_object = VideoWriter('output.avi');
writeVideo(output_object, mov);
close(output_object);
```

---

## **Video Processing Using Simulink**

### **Creating a Simulink Model**

1. In Simulink start page, select **Blank Model**
2. Save the model (e.g., 'rotate_video.slx')
3. Check that **Computer Vision Toolbox** is installed via Library Browser

### **Key Simulink Blocks**

**From Multimedia File** (Computer Vision System Toolbox → Sources)

- Reads video from file
- Configuration parameters:
  - Input file name: 'carphone.avi'
  - Inherit sample time from file: ticked
  - Number of times to play the file: inf

**Insert Text** (Computer Vision Toolbox → Text & Graphics)

- Adds text overlay to video
- Configuration parameters:
  - Text: 'Rotated video (30 deg)'
  - Location: [100 5]
  - Color: [0 1 0]
  - Opacity: 0.5

**Rotate** (Search in Library Browser)

- Applies rotation transformation
- Set angle in radians: pi/6

**Video Viewer:** Displays video output

**To Multimedia File:** Saves video to AVI file

### **Simulation Configuration**

Configure via **Simulation → Configuration Parameters**:

- Stop time: inf
- Solver type: fixed-step
- Solver: discrete

### **Running the Model**

- Start: **Simulation → Start**
- Stop: **Simulation → Stop**

---

## Practice Question Answer

### **Section 11.2.2 (d)**

```matlab
% Create video object
video_object = VideoReader('carphone.avi');

% Read all frames
images = read(video_object);

% Convert to MATLAB movie and view
mov = immovie(images);
movie(mov);

% Open output video file
output_object = VideoWriter('output_grayscale.avi');
open(output_object);

% Generate output video frames
N = video_object.NumberOfFrames;
H = video_object.Height;
W = video_object.Width;

% Pre-allocate output array
output_images = zeros(H, W, 3, N, 'uint8');

for n = 1:N
    image = images(:,:,:,n);              % One frame (color)
    gray_image = rgb2gray(image);         % Convert to grayscale

    % Convert grayscale back to 3-channel format for video
    output_image(:,:,1) = gray_image;
    output_image(:,:,2) = gray_image;
    output_image(:,:,3) = gray_image;

    output_images(:,:,:,n) = output_image; % Store in output array
end

% Write to video file and close
writeVideo(output_object, output_images);
close(output_object);

% Convert to MATLAB movie and view
output_mov = immovie(output_images);
movie(output_mov);
```
