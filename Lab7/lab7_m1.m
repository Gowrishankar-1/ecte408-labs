% Load Pretrained Network
[net, classNames] = imagePretrainedNetwork("googlenet");

% Create an image datastore for the collection of images.
imds = imageDatastore('image_collection');

% Classify all images in the datastore.
all_scores = minibatchpredict(net, imds);

% Display predicted and actual labels for each image
for i = 1:length(imds.Files)
    scores_i = all_scores(i,:); % Scores for all classes for image i
    label_i = scores2label(scores_i, classNames); % Convert scores to label
    [~, filename, ~] = fileparts(imds.Files{i}); % Extract filename
    fprintf('Predicted Label: %s\tActual Label: %s\n', label_i, filename);
end

% Show all images in a grid with their predicted labels
figure;
for i = 1:length(imds.Files)
    subplot(3, 3, i);
    imshow(readimage(imds, i));
    title(string(scores2label(all_scores(i,:), classNames)));
end

% Visualize prediction scores for a specific image
img_index = 1; % First image
img = readimage(imds, img_index); % Read the image
scores = all_scores(img_index, :); % Scores for all classes for the selected image

% Find the predicted label for the selected image
[~, max_idx] = max(scores); % Index of the highest score
predicted_label = classNames{max_idx}; % Predicted label

% Display the image with its predicted label
figure;
imshow(img);
title(['Image ', num2str(img_index), ' - Predicted Label: ', char(predicted_label)]);

% Create a bar chart of the prediction scores that are above a threshold
threshold = 0.01;
high_scores_idx = find(scores > threshold); % Indices of scores above threshold
high_scores_values = scores(high_scores_idx); % Values of scores above threshold
high_scores_names = classNames(high_scores_idx); % Corresponding class names

figure;
bar(high_scores_values); % Create bar chart
title(['Prediction Scores > ', num2str(threshold), ' for Image ', num2str(img_index)]);
xlabel('Class');
ylabel('Prediction Score');
set(gca, 'xticklabel', high_scores_names); % Set x-axis labels to class names