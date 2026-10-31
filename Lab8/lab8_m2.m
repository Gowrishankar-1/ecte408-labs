%% Load, inspect, prepare and split the dataset

% Load ground truth data
cur_dir = fileparts(mfilename('fullpath'));
if ~ endsWith(cur_dir, 'Labs\Lab8\BDD100K-Subset')
    cd(fullfile(cur_dir, 'BDD100K-Subset'));
end
load('groundTruth.mat');

% Display dataset information
fprintf('Number of images: %d\n', length(gTruth.DataSource.Source'));

% Convert ground-truth data to datastores
[imds, bboxds] = objectDetectorTrainingData(gTruth);

% Get class names from dataset
classNames = string(gTruth.LabelDefinitions.Name);
fprintf('Classes in dataset: ');
disp(classNames');

% Count instances of each class
counts = countEachLabel(bboxds);
fprintf('Class distribution:\n');
disp(counts);

% Create combined datastore
gtData = combine(imds, bboxds);

% Determine data counts (70% train, 10% validation, 20% test)
numFiles = numpartitions(gtData);
numTrain = floor(numFiles * 0.7);
numVal = floor(numFiles * 0.1);

fprintf('Dataset split:\n');
fprintf('Total files: %d\n', numFiles);
fprintf('Training: %d (70%%)\n', numTrain);
fprintf('Validation: %d (10%%)\n', numVal);
fprintf('Testing: %d (20%%)\n', numFiles - numTrain - numVal);

% Shuffle the dataset for random distribution
gtShuffled = shuffle(gtData);

% Split the dataset
gtTrain = subset(gtShuffled, 1:numTrain);
gtVal = subset(gtShuffled, numTrain+1:numTrain+numVal);
gtTest = subset(gtShuffled, numTrain+numVal+1:numFiles);

% Analyze training data distribution
bxTrain = gtTrain.UnderlyingDatastores{2};
trainCounts = countEachLabel(bxTrain);
fprintf('Training set class distribution:\n');
disp(trainCounts);

% Save splits for reproducibility
save('splits.mat', 'gtTrain', 'gtVal', 'gtTest', 'gtShuffled');
fprintf('Data splits saved to splits.mat\n');

%% Configure and train YOLOX detector

% Create YOLOX detector with custom classes
detector = yoloxObjectDetector("small-coco", ...
    classNames, ...
    InputSize=[1024 1024 3]);

fprintf('YOLOX detector created with input size [1024 1024 3]\n');

% Configure training options
options = trainingOptions("sgdm", ...
    InitialLearnRate=1e-3, ...
    Momentum=0.9, ...
    ResetInputNormalization=false, ...
    MiniBatchSize=4, ...
    MaxEpochs=50, ...
    Metrics=mAPObjectDetectionMetric(Name="mAP50"), ...
    ObjectiveMetricName="mAP50", ...
    ValidationData=gtVal, ...
    ValidationFrequency=10, ...
    ExecutionEnvironment="auto", ...
    Plots="training-progress");


% Train the detector if not already trained
if ~isfile('trainedDetector_e2-small-coco-sgdm-epoch50-1024-batch4-val20.mat')
    fprintf('Starting training...\n');
    trainedDetector = trainYOLOXObjectDetector(gtTrain, detector, options);
    % Save the trained detector
    save('trainedDetector_e2-small-coco-sgdm-epoch50-1024-batch4-val20.mat', 'trainedDetector');
    fprintf('Trained detector saved to trainedDetector_e2-small-coco-sgdm-epoch50-1024-batch4-val20.mat\n');
    hFig = findall(groot, 'Type', 'Figure', 'Tag', 'TrainingProgressMonitor');
    if ~isempty(hFig)
        exportgraphics(hFig, 'training_progress.png', 'Resolution', 300);
        fprintf('Saved training progress figure as training_progress.png\n');
    end
else
    load('trainedDetector_e2-small-coco-sgdm-epoch50-1024-batch4-val20.mat', 'trainedDetector');
    fprintf('Loaded existing trained detector from trainedDetector_e2-small-coco-sgdm-epoch50-1024-batch4-val20.mat\n');
end

%% Apply detector to test set and show evaluation metrics

% Apply trained detector to test set
fprintf('Evaluating trained detector on test set...\n');
results = detect(trainedDetector, gtTest);

% Evaluate performance with default IoU threshold (0.5)
metrics = evaluateObjectDetection(results, gtTest);

% Display evaluation metrics
fprintf('\nEVALUATION METRICS\n');
fprintf('Mean Average Precision (mAP@0.5): %.4f\n', mean(metrics.averagePrecision));

% Display per-class Average Precision
fprintf('\nPer-class Average Precision:\n');
for i = 1:length(classNames)
    ap_val = metrics.averagePrecision("ClassName", classNames(i));
    fprintf('%s: %.4f\n', classNames(i), ap_val);
end

% Analyze detection results in detail
fprintf('\nDETAILED ANALYSIS:\n');
fprintf('Total test samples: %d\n', height(results));

% Count detections per class
detectionCounts = table();
for i = 1:length(classNames)
    className = classNames(i);
    classDetections = 0;
    totalConfidence = 0;

    for j = 1:height(results)
        if ~isempty(results.Labels{j})
            classCount = sum(results.Labels{j} == className);
            classDetections = classDetections + classCount;

            % Sum confidence scores for this class
            if classCount > 0
                classIndices = results.Labels{j} == className;
                totalConfidence = totalConfidence + sum(results.Scores{j}(classIndices));
            end
        end
    end

    avgConfidence = 0;
    if classDetections > 0
        avgConfidence = totalConfidence / classDetections;
    end

    fprintf('Class %s: %d detections, avg confidence: %.3f\n', ...
        className, classDetections, avgConfidence);
end

% Create and display confusion matrix
[confMatrix, confLabels] = confusionMatrix(metrics);
figure('Name', 'Confusion Matrix', 'Position', [100, 100, 600, 500]);
confusionchart(confMatrix{1}, confLabels);
title('Confusion Matrix - Object Detection Results');

exportgraphics(gcf, 'confusion_matrix.png', 'Resolution', 300);
fprintf('Saved confusion matrix figure as confusion_matrix.png\n');


% Calculate and display precision-recall curves
[precision, recall, scores] = precisionRecall(metrics);
numClasses = length(classNames);

figure('Name', 'Precision-Recall Curves', 'Position', [200, 200, 1200, 800]);
for i = 1:numClasses
    subplot(ceil(sqrt(numClasses)), ceil(sqrt(numClasses)), i);

    if ~isempty(precision{i}) && ~isempty(recall{i})
        plot(recall{i}, precision{i}, 'b-', 'LineWidth', 2);
        xlabel('Recall');
        ylabel('Precision');
        grid on;
        axis([0 1 0 1]);

        if i <= length(metrics.averagePrecision)
            ap_value = metrics.averagePrecision("ClassName", classNames(i));
            title(sprintf('%s (AP=%.3f)', char(classNames(i)), ap_value));
        else
            title(char(classNames(i)));
        end
    else
        title(sprintf('%s (No detections)', char(classNames(i))));
    end
end
sgtitle('Precision-Recall Curves for All Classes');

exportgraphics(gcf, 'precision_recall_curves.png', 'Resolution', 300);
fprintf('Saved PR curves figure as precision_recall_curves.png\n');

%% Visualize detection results on five test images

fprintf('\nVISUALIZING DETECTION RESULTS \n');
fprintf('Press any key to view each detection result...\n');

% Get any random 5 images from test set for visualization
randomIndices = randperm(numpartitions(gtTest), 5);
gtTestVisualize = subset(gtTest, randomIndices);

% Visualize detection results on test images
figure('Name', 'Detection Results', 'Position', [300, 300, 800, 600]);

for i = 1:5
    % Read image and ground truth from test set
    data = read(gtTestVisualize);  % Read from subset, not original
    testImage = data{1};  % Extract the image from the cell array
    testInfo = data{2};   % Extract the bbox info

    % Apply detector to current test image
    [detectedBoxes, detectedScores, detectedLabels] = detect(trainedDetector, testImage);

    % Display results
    clf; % Clear current figure

    % Show original image with detections
    if ~isempty(detectedBoxes)
        % Create labels with confidence scores
        labelStrings = cell(size(detectedLabels));
        for j = 1:length(detectedLabels)
            labelStrings{j} = sprintf('%s (%.2f)', string(detectedLabels(j)), detectedScores(j));
        end

        detectedImg = insertObjectAnnotation(testImage, "rectangle", ...
            detectedBoxes, labelStrings, 'TextBoxOpacity', 0.8, 'FontSize', 12);
        imshow(detectedImg);
        title(sprintf('Test Image %d - Detected Objects', i));
    else
        imshow(testImage);
        title(sprintf('Test Image %d - No Objects Detected', i));
    end

    % Display detection summary
    fprintf('Image %d: %d objects detected\n', i, size(detectedBoxes, 1));
    if ~isempty(detectedLabels)
        uniqueLabels = unique(detectedLabels);
        for j = 1:length(uniqueLabels)
            count = sum(detectedLabels == uniqueLabels(j));
            fprintf('  - %s: %d detection(s)\n', string(uniqueLabels(j)), count);
        end
    end

    % Wait for user input before showing next image
    fprintf('Press any key to continue to next image...\n');
    waitforbuttonpress;
end
close all;
fprintf('Visualization complete!\n');
