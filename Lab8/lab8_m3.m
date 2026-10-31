%% Load the same splits from Exercise E2 for fair comparison
fprintf('Loading saved data splits from Exercise E2\n');

% Get current directory and BDD100K-Subset path
cur_dir = fileparts(mfilename('fullpath'));
bdd_subset_dir = fullfile(cur_dir, 'BDD100K-Subset');

% Check if splits.mat exists
splits_file = fullfile(bdd_subset_dir, 'splits.mat');
if ~exist(splits_file, 'file')
    error('splits.mat not found at: %s\nPlease run lab8_m2.m first to generate the splits.', splits_file);
end

% Load splits from the BDD100K-Subset directory
load(splits_file, 'gtTrain', 'gtVal', 'gtTest', 'gtShuffled');

% Get class names
if ~exist(bdd_subset_dir, 'dir')
    error('BDD100K-Subset directory not found at: %s', bdd_subset_dir);
end

% Change to BDD100K-Subset directory
original_dir = pwd;
cd(bdd_subset_dir);

% Check if groundTruth.mat exists
if ~exist('groundTruth.mat', 'file')
    cd(original_dir); % Restore original directory
    error('groundTruth.mat not found in: %s', bdd_subset_dir);
end

load('groundTruth.mat');
classNames = string(gTruth.LabelDefinitions.Name);
fprintf('Classes: ');
disp(classNames');

% Restore original directory
cd(original_dir);

%% Apply data augmentation function on training and validation sets

fprintf('Applying Data Augmentation to Training and Validation Sets\n');

% Apply the data augmentation function to training and validation sets
gtTrainAug = transform(gtTrain, @dataAug);
gtValAug = transform(gtVal, @dataAug);

fprintf('Data augmentation applied to training and validation sets\n');

%% Train a new YOLOX detector using the augmented dataset

fprintf('Training YOLOX Detector with Data Augmentation');

% Create YOLOX detector with same configuration as E2
detector = yoloxObjectDetector("small-coco", ...
    classNames, ...
    InputSize=[1024 1024 3]);

% Configure training options (same as E2 for fair comparison)
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

fprintf('Starting training with data augmentation...\n');

% Train the detector if not already trained
check_detector = fullfile(bdd_subset_dir, 'trainedDetector_e3.mat');
cd(bdd_subset_dir); % Change to BDD100K-Subset directory for saving

if ~isfile('trainedDetector_e3.mat')
    fprintf('Starting training...\n');
    trainedDetectorAug = trainYOLOXObjectDetector(gtTrainAug, detector, options);
    % Save the trained detector
    detector_save_path = fullfile(bdd_subset_dir, 'trainedDetector_e3.mat');
    save(detector_save_path, 'trainedDetectorAug');

    fprintf('Augmented trained detector saved to: %s\n', detector_save_path);

    hFig = findall(groot, 'Type', 'Figure', 'Tag', 'TrainingProgressMonitor');
    if ~isempty(hFig)
        exportgraphics(hFig, 'training_progress.png', 'Resolution', 300);
        fprintf('Saved training progress figure as training_progress.png\n');
    end

    % Save the trained detector to BDD100K-Subset directory
    hFig = findall(groot, 'Type', 'Figure', 'Tag', 'TrainingProgressMonitor');
    if ~isempty(hFig)
        exportgraphics(hFig, 'training_progress.png', 'Resolution', 300);
        fprintf('Saved training progress figure as training_progress.png\n');
    end

    % === Save all open figures (classic + UIFigures) as PNG with timestamp ===

    % Grab both classic figures and UIFigures
    hClassic = findall(groot, 'Type', 'Figure');
    hUI = findall(groot, 'Type', 'UIFigure');

    % Combine into one list
    hAll = [hClassic(:); hUI(:)];

    fprintf('Found %d open figures (classic + UIFigure)\n', numel(hAll));

    % Generate timestamp (e.g. 20251004_2030)
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');

    % Loop and save
    for i = 1:numel(hAll)
        file_name = sprintf('training_data_%s_%d.png', timestamp, i);

        try
            % Try exportgraphics (works on both in most cases)
            exportgraphics(hAll(i), file_name, 'Resolution', 300);
            fprintf('Saved figure %d as %s\n', i, file_name);
        catch ME
            % If exportgraphics fails (rare with UIFigures), use exportapp
            try
                exportapp(hAll(i), file_name);
                fprintf('Saved UIFigure %d with exportapp as %s\n', i, file_name);
            catch
                warning('Could not save figure %d: %s', i, ME.message);
            end
        end
    end

else
    load('trainedDetector_e3', 'trainedDetectorAug');
    fprintf('Loaded trainedDetector_e3\n');
end


%% Apply detector to test set and show evaluation metrics

fprintf('Evaluating Augmented Model Performance\n');

% Apply trained detector to test set
results_aug = detect(trainedDetectorAug, gtTest);

% Evaluate performance with default IoU threshold (0.5)
metrics_aug = evaluateObjectDetection(results_aug, gtTest);

% Display evaluation metrics
fprintf('AUGMENTED MODEL EVALUATION METRICS\n');

% Extract Average Precision from ClassMetrics table
ap_values = cell2mat(metrics_aug.ClassMetrics.AP);

fprintf('Mean Average Precision (mAP@0.5): %.4f\n', mean(ap_values));

% Display per-class Average Precision
fprintf('Per-class Average Precision (Augmented Model):\n');
for i = 1:length(classNames)
    if i <= length(ap_values)
        fprintf('%s: %.4f\n', classNames(i), ap_values(i));
    end
end

% Create and display confusion matrix
[confMatrix_aug, confLabels_aug] = confusionMatrix(metrics_aug);
figure('Name', 'Confusion Matrix - Augmented Model', 'Position', [100, 100, 600, 500]);
confusionchart(confMatrix_aug{1}, confLabels_aug);
title('Confusion Matrix - Augmented Model Results');
exportgraphics(gcf, 'confusion_matrix_augmented.png', 'Resolution', 300);
fprintf('Saved confusion matrix figure as confusion_matrix_augmented.png\n');

% Calculate and display precision-recall curves
[precision_aug, recall_aug, scores_aug] = precisionRecall(metrics_aug);
numClasses = length(classNames);

figure('Name', 'PR Curves - Augmented Model', 'Position', [200, 200, 1200, 800]);
for i = 1:numClasses
    subplot(ceil(sqrt(numClasses)), ceil(sqrt(numClasses)), i);

    if ~isempty(precision_aug{i}) && ~isempty(recall_aug{i})
        plot(recall_aug{i}, precision_aug{i}, 'r-', 'LineWidth', 2);
        xlabel('Recall');
        ylabel('Precision');
        grid on;
        axis([0 1 0 1]);

        if i <= length(ap_values)
            ap_value = ap_values(i);
            title(sprintf('%s (AP=%.3f)', char(classNames(i)), ap_value));
        else
            title(char(classNames(i)));
        end
    else
        title(sprintf('%s (No detections)', char(classNames(i))));
    end
end
sgtitle('Precision-Recall Curves - Augmented Model');
exportgraphics(gcf, 'precision_recall_curves_augmented.png', 'Resolution', 300);
fprintf('Saved PR curves figure as precision_recall_curves_augmented.png\n');

%% Visualize detection results on five test images

fprintf('VISUALIZING AUGMENTED MODEL DETECTION RESULTS\n');
fprintf('Press any key to view each detection result...\n');

% Get any random 5 images from test set for visualization
randomIndices = randperm(numpartitions(gtTest), 5);
gtTestVisualize = subset(gtTest, randomIndices);

figure('Name', 'Augmented Model Detection Results', 'Position', [300, 300, 800, 600]);

for i = 1:5
    % Read data from test set
    data = read(gtTestVisualize);  % Read from subset, not original
    testImage = data{1};

    % Apply augmented detector to current test image
    [detectedBoxes, detectedScores, detectedLabels] = detect(trainedDetectorAug, testImage);

    % Display results
    clf;

    % Show image with detections
    if ~isempty(detectedBoxes)
        % Create labels with confidence scores
        labelStrings = cell(size(detectedLabels));
        for j = 1:length(detectedLabels)
            labelStrings{j} = sprintf('%s (%.2f)', string(detectedLabels(j)), detectedScores(j));
        end

        detectedImg = insertObjectAnnotation(testImage, "rectangle", ...
            detectedBoxes, labelStrings, 'TextBoxOpacity', 0.8, 'FontSize', 12);
        imshow(detectedImg);
        title(sprintf('Augmented Model - Test Image %d', i));
    else
        imshow(testImage);
        title(sprintf('Augmented Model - Test Image %d (No Objects Detected)', i));
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

    % Wait for user input
    fprintf('Press any key to continue to next image...\n');
    waitforbuttonpress;
end

%% Compare models and analyze the effect of data augmentation

fprintf('MODEL COMPARISON AND ANALYSIS\n');

% Load the model from Exercise E2 for comparison
e2_detector_file = fullfile(bdd_subset_dir, 'trainedDetector_e2-small-coco-sgdm-epoch50-1024-batch4-val20.mat');
if exist(e2_detector_file, 'file')
    fprintf('Loading E2 model from: %s\n', e2_detector_file);
    load(e2_detector_file, 'trainedDetector');
else
    fprintf('E2 model file not found. Please ensure lab8_m2.m has been run and the model saved.\n');
end

% Apply E2 model to test set
fprintf('Evaluating E2 model (without augmentation)...\n');
results_e2 = detect(trainedDetector, gtTest);
metrics_e2 = evaluateObjectDetection(results_e2, gtTest);

% Extract AP values for both models
ap_e2_values = cell2mat(metrics_e2.ClassMetrics.AP);
ap_aug_values = cell2mat(metrics_aug.ClassMetrics.AP);

% Compare performance metrics
fprintf('PERFORMANCE COMPARISON\n');
fprintf('Model Comparison Results:\n');
fprintf('%-25s | %-15s | %-15s | %-15s\n', 'Metric', 'E2 (No Aug)', 'E3 (Aug)', 'Improvement');
fprintf('%-25s | %-15s | %-15s | %-15s\n', repmat('-', 1, 25), repmat('-', 1, 15), repmat('-', 1, 15), repmat('-', 1, 15));

% Overall mAP comparison
mAP_e2 = mean(ap_e2_values);
mAP_e3 = mean(ap_aug_values);
improvement = mAP_e3 - mAP_e2;
fprintf('%-25s | %-15.4f | %-15.4f | %+.4f\n', 'Mean Average Precision', mAP_e2, mAP_e3, improvement);

% Per-class AP comparison
fprintf('\nPer-class Average Precision Comparison:\n');
fprintf('%-15s | %-10s | %-10s | %-10s\n', 'Class', 'E2 (No Aug)', 'E3 (Aug)', 'Difference');
fprintf('%-15s | %-10s | %-10s | %-10s\n', repmat('-', 1, 15), repmat('-', 1, 10), repmat('-', 1, 10), repmat('-', 1, 10));

for i = 1:length(classNames)
    if i <= min(length(ap_e2_values), length(ap_aug_values))
        ap_e2 = ap_e2_values(i);
        ap_e3 = ap_aug_values(i);
        diff = ap_e3 - ap_e2;
        fprintf('%-15s | %-10.4f | %-10.4f | %+.4f\n', char(classNames(i)), ap_e2, ap_e3, diff);
    end
end

% Create comparison visualization
figure('Name', 'Model Performance Comparison', 'Position', [400, 400, 1000, 600]);

% Bar chart comparing mAP values
subplot(1, 2, 1);
models = {'E2 (No Augmentation)', 'E3 (With Augmentation)'};
mAP_values = [mAP_e2, mAP_e3];
bar(mAP_values);
set(gca, 'XTickLabel', models);
ylabel('Mean Average Precision (mAP)');
title('Overall Performance Comparison');
grid on;

% Per-class comparison
subplot(1, 2, 2);
x = 1:length(classNames);
width = 0.35;
bar(x - width/2, ap_e2_values, width, 'DisplayName', 'E2 (No Aug)');
hold on;
bar(x + width/2, ap_aug_values, width, 'DisplayName', 'E3 (Aug)');
set(gca, 'XTick', x);
set(gca, 'XTickLabel', classNames);
ylabel('Average Precision');
title('Per-Class Performance Comparison');
legend();
grid on;

% Save comparison figure
exportgraphics(gcf, 'model_comparison.png', 'Resolution', 300);
fprintf('Saved model comparison figure as model_comparison.png\n');