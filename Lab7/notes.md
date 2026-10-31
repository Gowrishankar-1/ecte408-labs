# Lab 7: Convolutional Neural Networks and Image Classification

## Introduction to Convolutional Neural Networks (CNNs)

CNNs are neural networks specifically designed for processing two-dimensional structures like images. Unlike traditional fully connected neural networks, CNNs preserve spatial relationships between pixels and are particularly effective for image recognition tasks.

**Common CNN Layers:**

- Input image layer
- Convolutional layers
- Activation layers
- Pooling layers
- Fully connected (FC) layers
- Softmax layer

## Image Classification with Pretrained Networks

### Loading and Classifying Images

**Loading an image:**

```matlab
img = imread("peppers.png");
```

**Loading a pretrained network:**

```matlab
net = imagePretrainedNetwork;  % Loads SqueezeNet by default
[net, classNames] = imagePretrainedNetwork;  % Also returns class names
```

**Loading specific networks:**

```matlab
[net,classNames] = imagePretrainedNetwork("googlenet"); % Load GoogLeNet
```

**Classifying an image:**

```matlab
scores = minibatchpredict(net,img);  % Returns prediction scores
label = scores2label(scores,classNames);  % Gets the predicted label
```

### Visualizing Predictions

The deep network outputs numeric values for each neuron (one per class), representing the probability assigned to each class.

**Creating prediction charts:**

```matlab
bar(scores);  % Show scores for all classes
title('Prediction Scores for All Classes');
xlabel('Class Index');
ylabel('Prediction Score');
```

## Working with Image Collections Using Datastores

Datastores act as references to data sources (like folders of image files) without importing the actual data until needed.

**Creating a datastore:**

```matlab
ds = imageDatastore("*.png");  % For all PNG files in current folder

ds = imageDatastore("folder_path", IncludeSubfolders=true, FileExtensions=".jpg"); % For all JPG files in specified folder and subfolders
```

**Reading from datastores:**

- `read` - imports one image at a time, in order
- `readimage` - imports a single image: `img = readimage(ds, n)`
- `readall` - imports all images into a cell array

**Making predictions with datastores:**

```matlab
preds = minibatchpredict(net, ds);  % Matrix with one row per image, one column per class
```

## Transfer Learning for Custom Applications

Transfer learning modifies a pretrained network for specific classification tasks by retraining on new data.

**Requirements for transfer learning:**

- Labeled images
- Modified pretrained network
- Loss function (cross-entropy for classification)
- Training algorithm options

### Organizing Data with Labels

**Creating labeled datastores:**

```matlab
folder_path = 'Traffic_Sign_Recognition_Dataset'; % Path to image folder
ds = imageDatastore(folder_path, ...
    IncludeSubfolders=true, ...
    LabelSource='foldernames');
classNames = categories(ds.Labels); % Get class names
```

### Splitting Data for Training and Testing

**Splitting by proportion:**

```matlab
[trainImgs, testImgs] = splitEachLabel(imds, p);  % p = proportion (0-1)
```

**Splitting by number:**

```matlab
[trainImgs, testImgs] = splitEachLabel(imds, n);  % n = exact number
```

**Random splitting:**

```matlab
[trainImgs, testImgs] = splitEachLabel(imds, p, 'randomized');
```

### Setting up Transfer Learning

**Customizing pretrained network:**

```matlab
net = imagePretrainedNetwork('name', NumClasses=n); % Customize for n classes of interest
deepNetworkDesigner(net);  % View modified architecture
```

### Image Preprocessing

**Getting network input size:**

```matlab
inputSize = net.Layers(1).InputSize;
```

**Resizing images in datastore:**

```matlab
auds = augmentedImageDatastore([M N], imds);  % Resize to M x N
resizeTrainImgs = augmentedImageDatastore([224 224], trainImgs);  % For GoogLeNet
```

### Training the Network

**Setting training options:**

```matlab
opts = trainingOptions('sgdm', ...
    MaxEpochs=10, ...
    Metrics='accuracy', ...
    Plots='training-progress');
```

**Training the network:**

```matlab
[tsnet, info] = trainnet(resizeTrainImgs, net, 'crossentropy', opts);
save("trained_tsnet.mat", "tsnet");  % Save trained network
```

**Training metrics:**

- **Training accuracy:** Percentage of training images classified correctly (should increase)
- **Training loss:** Measure of prediction error (should decrease toward zero)

**Accessing training history:**

```matlab
th = info.TrainingHistory;
plot(th.Loss);  % Plot training loss
```

## Evaluating Network Performance

**Obtaining prediction scores:**

```matlab
tsScores = minibatchpredict(tsnet, resizeTestImgs); % Prediction scores for test images
classes = categories(ds.Labels); % Class names
```

**Getting predicted classes:**

```matlab
preds = scores2label(tsScores, classes); % Predicted labels for test images
```

**Measuring performance:**

```matlab
metrics = testnet(tsnet, resizeTestImgs, 'accuracy'); % Returns accuracy, precision, recall, F1 score
```

**Creating confusion matrix:**

```matlab
confusionchart(classes, preds); % Rows: true classes, Columns: predicted classes
```

**Confusion matrix interpretation:**

- Diagonal elements: correct classifications
- Off-diagonal elements: misclassifications
- Element (j,k): count of images from class j predicted as class k

---

## Practice Questions

**Practice from Section 7.3.2:**

a) **Creating a bar chart for prediction values above 0.01:**

b) **Finding the class with highest prediction score:**

```matlab
% Load the image
img = imread("peppers.png");

% Load pretrained network and get class names
[net, classNames] = imagePretrainedNetwork;

% Classify the image
scores = minibatchpredict(net, img);
label = scores2label(scores, classNames);

% a) Create a bar chart of prediction values above threshold 0.01
threshold = 0.01;
highScoreIndices = find(scores > threshold);
highScoreValues = scores(highScoreIndices);

figure;
bar(highScoreIndices, highScoreValues);
title('Prediction Scores Above 0.01');
xlabel('Class Index'); ylabel('Prediction Score');

% Display the high scoring classes
fprintf('Classes with scores above %.2f:\n', threshold);
for i = 1:length(highScoreIndices)
    classIndex = highScoreIndices(i);
    fprintf('Class %d (%s): %.4f\n', classIndex, classNames{classIndex}, scores(classIndex));
end

% b) Find the class with the highest prediction score
[maxScore, maxIndex] = max(scores);
highestClass = classNames{maxIndex};
fprintf('\nClass with highest prediction score:\n');
fprintf('Class %d (%s): %.4f\n', maxIndex, highestClass, maxScore);
```
