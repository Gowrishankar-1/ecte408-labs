# Lab 8: Deep Learning and Object Detection - Electronic Lab Logbook

## Object Detection Overview

Object detection combines two key tasks:

- **Classification:** What types of objects are present in the image?
- **Localization:** Where are these objects located?

Unlike image classification (which only determines what objects are present), object detection also determines where objects are located by drawing bounding boxes around them.

## Detecting Objects with Pretrained Networks

### YOLOX Object Detector

YOLOX (You Only Look Once X) is a state-of-the-art object detection network that balances speed and accuracy. It can recognize 80 different object types from the COCO dataset.

**YOLOX base network options:**

- `nano-coco`: Smallest, fastest, lower accuracy
- `tiny-coco`: Small, fast, good balance
- `small-coco`, `medium-coco`, `large-coco`: Progressively larger and more accurate

### Basic Object Detection Workflow

**Loading an image:**

```matlab
img = imread("street_scene.png");
imshow(img);
```

**Loading a pretrained YOLOX detector:**

```matlab
detector = yoloxObjectDetector("nano-coco");
```

**Note:** First-time use requires downloading the pretrained network and installing the Automated Visual Inspection Library for Computer Vision Toolbox.

**Investigating detector classes:**

```matlab
classNames = detector.ClassNames;  % Shows 80 COCO dataset classes
```

**Detecting objects:**

```matlab
[bbox, score, label] = detect(detector, img);
```

**Output parameters:**

- `bbox`: Bounding box coordinates [x, y, width, height] for each detection
- `score`: Confidence score (0-1) for each detection
- `label`: Predicted class name for each detection

**Displaying results:**

```matlab
results = table(bbox, score, label);  % Tabular view
detectedImg = insertObjectAnnotation(img, "rectangle", bbox, label);
imshow(detectedImg);
```

## Training Custom YOLO Detector Using Transfer Learning

### Organizing Data with Labels

**Working with labeled datasets:**

```matlab
cd path_to_the_dataset;
load('groundTruth.mat', 'gTruth');
```

**Converting ground-truth data:**

```matlab
[imds, bboxds] = objectDetectorTrainingData(gTruth);
```

**Inspecting dataset classes:**

```matlab
classNames = string(gTruth.LabelDefinitions.Name);
counts = countEachLabel(bboxds);
```

**Creating combined datastore:**

```matlab
gtData = combine(imds, bboxds);
```

## Splitting Data for Training and Testing

**Recommended data distribution:**

- Training: 70%
- Validation: 10%
- Testing: 20%

**Determining data counts:**

```matlab
numFiles = numpartitions(gtData);
numTrain = floor(numFiles * 0.7);
numVal = floor(numFiles * 0.1);
```

**Shuffling and splitting:**

```matlab
gtShuffled = shuffle(gtData);
gtTrain = subset(gtShuffled, 1:numTrain);
gtVal = subset(gtShuffled, numTrain+1:numTrain+numVal);
gtTest = subset(gtShuffled, numTrain+numVal+1:numFiles);
```

**Analyzing dataset distribution:**

```matlab
bxTrain = gtTrain.UnderlyingDatastores{2}; % Get label datastore
trainCounts = countEachLabel(bxTrain); % Count labels in training set
```

## Defining and Configuring the Detector

**Creating detector with custom classes:**

```matlab
detector = yoloxObjectDetector(base_network, classNames, InputSize=[320 320 3]);
```

**Input size:** `[320 320 3]` represents height, width, and channels. Smaller sizes = faster processing but potentially lower accuracy.

**Training options:**

```matlab
options = trainingOptions("sgdm", ...
    Momentum=0.9, ...
    ResetInputNormalization=false, ...
    MiniBatchSize=8, ...
    MaxEpochs=10, ...
    Metrics=mAPObjectDetectionMetric(Name="mAP50"), ...
    ObjectiveMetricName="mAP50", ...
    ValidationData=gtVal, ...
    ValidationFrequency=20, ...
    Plots="training-progress");
```

**Training the detector:**

```matlab
trainedDetector = trainYOLOXObjectDetector(gtTrain, detector, options); % Train the detector
save('trainedYOLOXDetector.mat', 'trainedDetector'); % Save trained model to file
```

## Using the Trained Detector

**Basic detection:**

```matlab
[dbox, dscore, dlabel] = detect(trainedDetector, testImage);
```

**Detection with threshold:**

```matlab
[dbox, dscore, dlabel] = detect(trainedDetector, testImage, Threshold=0.75); % Higher threshold = fewer detections
```

**Visualization:**

```matlab
detectedIm = insertObjectAnnotation(testImage, "rectangle", dbox, dlabel);
imshow(detectedIm);
```

**Batch detection on test dataset:**

```matlab
results = detect(trainedDetector, gtTest);
```

## Evaluating Network Performance

**Detection Categories:**

- **True Positives (TP):** Correct detections where actual objects exist
- **False Positives (FP):** False detections where no actual object exists
- **False Negatives (FN):** Objects present but detector fails to identify them

**Intersection over Union (IoU):**
Measures spatial accuracy of detections by quantifying bounding box overlap with ground truth.

```math
IoU = Area of Intersection / Area of Union
```

### Confusion Matrix

A confusion matrix summarizes detection performance across all classes, showing counts of TP, FP, and FN for each class.

Diagonal elements represent correct detections (TP), while off-diagonal elements represent misclassifications (FP and FN).

### Performance Metrics

**Precision:**

```math
Precision = TP / (TP + FP)
```

Proportion of correct detections out of all detections made.

**Recall:**

```math
Recall = TP / (TP + FN)
```

Proportion of objects correctly detected out of all ground truth objects.

**Average Precision (AP):**
Area under the Precision-Recall curve for a given class.

```math
AP = ∫ Precision d(Recall)
```

**mean Average Precision (mAP):**

Mean of all AP values across all classes.

```math
mAP = (1/N) * Σ(AP_i) for i=1 to N
```

### Evaluation Implementation

**Computing evaluation metrics:**

```matlab
metrics = evaluateObjectDetection(results, gtTest);  % Default IoU = 0.5
metrics = evaluateObjectDetection(results, gtTest, 0.75);  % Custom IoU threshold
```

**Confusion matrix:**

```matlab
[matrix, labels] = confusionMatrix(metrics); % Calculate confusion matrix
confusionchart(matrix{1}, labels); % Visualize confusion matrix
```

**Precision-Recall analysis:**

```matlab
[precision, recall, scores] = precisionRecall(metrics); % Get precision and recall values
figure;
plot(recall{1}, precision{1}); % Plot PR curve for first class
xlabel('Recall'); ylabel('Precision');
title('Precision-Recall Curve for Class 1'); grid on;
```

**AP and mAP values:**

```matlab
avgPrecision = metrics.AveragePrecision;
meanAP = mean(avgPrecision);
```

## Data Augmentation

Data augmentation synthetically introduces variation into training data to reduce bias and improve generalization.

**Common augmentation techniques:**

- Rotation and reflection (different viewing angles)
- Resizing, cropping, translation (different sizes and positions)
- Color jittering (brightness, contrast, saturation adjustments)

**Applying augmentation to datastores:**

```matlab
dsTransformed = transform(ds, @functionName);
gtTrainAug = transform(gtTrain, @dataAug);
gtValAug = transform(gtVal, @dataAug);
```

---

## Practice Question Answer

**Practice from Section 8.4.2:**

**Complete runnable code to plot Precision-Recall curves for each class:**

```matlab
% Load ground truth data
load('groundTruth.mat', 'gTruth');
% Extract old file paths
oldPaths = gTruth.DataSource.Source;

% Build new file paths
newBase = 'E:\ecte408\Labs\Lab8\BDD100K-Subset\images\';
[~, fileNames, ext] = cellfun(@fileparts, oldPaths, 'UniformOutput', false);
newPaths = fullfile(newBase, strcat(fileNames, ext));

% Wrap the new image datastore into a groundTruthDataSource
imds = imageDatastore(newPaths);
dataSource = groundTruthDataSource(imds);

% Rebuild groundTruth object with updated paths
gTruth = groundTruth(dataSource, gTruth.LabelDefinitions, gTruth.LabelData);

% Convert ground truth into datastores
[imds, bboxds] = objectDetectorTrainingData(gTruth);
gtData = combine(imds, bboxds);

% Split data (70% train, 10% validation, 20% test)
numFiles = numpartitions(gtData);
numTrain = floor(numFiles * 0.7);
numVal = floor(numFiles * 0.1);

gtShuffled = shuffle(gtData);
gtTrain = subset(gtShuffled, 1:numTrain);
gtVal = subset(gtShuffled, numTrain+1:numTrain+numVal);
gtTest = subset(gtShuffled, numTrain+numVal+1:numFiles);

% Get class names
classNames = string(gTruth.LabelDefinitions.Name);

% Create and configure YOLOX detector
detector = yoloxObjectDetector("nano-coco", classNames, InputSize=[320 320 3]);

% Training options
options = trainingOptions("sgdm", ...
    Momentum=0.9, ...
    ResetInputNormalization=false, ...
    MiniBatchSize=8, ...
    MaxEpochs=10, ...
    Metrics=mAPObjectDetectionMetric(Name="mAP50"), ...
    ObjectiveMetricName="mAP50", ...
    ValidationData=gtVal, ...
    ValidationFrequency=20, ...
    Plots="training-progress");

% Train the detector
trainedDetector = trainYOLOXObjectDetector(gtTrain, detector, options);

% Evaluate on test set
results = detect(trainedDetector, gtTest);
metrics = evaluateObjectDetection(results, gtTest);

% Extract precision and recall data
[precision, recall, scores] = precisionRecall(metrics);
numClasses = length(classNames);

% Create figure for PR curves
figure('Position', [100, 100, 1200, 800]);

% Plot PR curve for each class
for i = 1:numClasses
    subplot(ceil(sqrt(numClasses)), ceil(sqrt(numClasses)), i);

    % Extract precision and recall for current class
    classPrecision = precision{i};
    classRecall = recall{i};

    % Plot PR curve
    plot(classRecall, classPrecision, 'b-', 'LineWidth', 2);
    xlabel('Recall');
    ylabel('Precision');
    title(['PR Curve - ', char(classNames(i))]);
    grid on;
    axis([0 1 0 1]);

    % Add AP value to title
    if i <= length(metrics.AveragePrecision)
        ap_value = metrics.AveragePrecision(i);
        title(['PR Curve - ', char(classNames(i)), sprintf(' (AP=%.3f)', ap_value)]);
    end
end

% Add overall title
sgtitle('Precision-Recall Curves for All Classes');

% Display overall mAP
meanAP = mean(metrics.AveragePrecision);
fprintf('Mean Average Precision (mAP): %.4f\n', meanAP);
```
