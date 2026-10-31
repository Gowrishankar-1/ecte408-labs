% LAB8_E3  Effect of data augmentation on YOLOX training (Lab 8, Exercise E3).
clear; close all; clc;
addpath(fileparts(mfilename('fullpath')));                    % so dataAug.m is found
cd(fullfile(fileparts(mfilename('fullpath')), 'BDD100K-Subset'));

%% (a) Load the E2 splits and apply data augmentation
load('splits.mat', 'gtTrain', 'gtVal', 'gtTest');             % same splits as E2
load('groundTruth.mat', 'gTruth');
classNames = string(gTruth.LabelDefinitions.Name);

gtTrainAug = transform(gtTrain, @dataAug);                    % Section 8.6(b)
gtValAug   = transform(gtVal,   @dataAug);

%% (b) Train a new YOLOX detector on augmented data (same settings as E2)
detector = yoloxObjectDetector("small-coco", classNames, InputSize=[640 640 3]);
options = trainingOptions("sgdm", ...
    InitialLearnRate=1e-3, Momentum=0.9, ResetInputNormalization=false, ...
    MiniBatchSize=8, MaxEpochs=10, ...
    Metrics=mAPObjectDetectionMetric(Name="mAP50"), ObjectiveMetricName="mAP50", ...
    ValidationData=gtValAug, ValidationFrequency=45, ...      % augmented validation, Section 8.6(c)
    ExecutionEnvironment="auto", Plots="training-progress");
trainedDetector = trainYOLOXObjectDetector(gtTrainAug, detector, options);
save('trainedDetector_e3.mat', 'trainedDetector');

%% (c) Evaluate the E3 model on the test set
results_e3 = detect(trainedDetector, gtTest);
metrics_e3 = evaluateObjectDetection(results_e3, gtTest);

%% (d) Visualise detections on five test images (one figure per image)
if ~exist('trainedDetector', 'var')                 % lets this section run on its own
    load('trainedDetector_e3.mat', 'trainedDetector');
    load('splits.mat', 'gtTest');
end
for i = 1:5
    data = read(subset(gtTest, i));                 % i-th test image
    I = data{1};
    [bbox, ~, label] = detect(trainedDetector, I);
    figure('Name', sprintf('E3 test image %d', i));
    if isempty(bbox)
        imshow(I);
    else
        imshow(insertObjectAnnotation(I, "rectangle", bbox, label, FontSize=18));
    end
    title(sprintf('E3 detections: test image %d', i));
    exportgraphics(gcf, sprintf('task4_e3_test%d.png', i), 'Resolution', 200);
end
%% (e) Compare with the E2 model on the same test set
S = load('trainedDetector_e2.mat', 'trainedDetector');
results_e2 = detect(S.trainedDetector, gtTest);
metrics_e2 = evaluateObjectDetection(results_e2, gtTest);

fprintf('\n%-15s %8s %8s\n', 'Class', 'E2 AP', 'E3 AP');
for i = 1:numel(classNames)
    fprintf('%-15s %8.3f %8.3f\n', classNames(i), ...
        metrics_e2.averagePrecision("ClassName", classNames(i)), ...
        metrics_e3.averagePrecision("ClassName", classNames(i)));
end
fprintf('%-15s %8.3f %8.3f\n', 'mAP', ...
    mean(metrics_e2.averagePrecision), mean(metrics_e3.averagePrecision));