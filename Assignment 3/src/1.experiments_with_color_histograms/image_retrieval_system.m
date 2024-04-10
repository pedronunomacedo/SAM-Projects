function image_retrieval_system(images_directory, queryImageFile)
    % Your image database, replace with your actual images
    imageFiles = dir(images_directory); % Add other file extensions if necessary
    imageFiles = imageFiles(~[imageFiles.isdir]);
    imageDatabase = {imageFiles.name};

    % Parameter to choose color space: 'HSV' or 'Lab'
    colorSpace = 'HSV';

    % Load query image
    queryHist = get_histogram_vector(queryImageFile, colorSpace);

    % Store histograms and filenames
    histograms = [];
    filenames = {};

    % Build histograms for the database
    for i = 1:15 % length(imageDatabase)
        histograms(i) = get_histogram_vector(fullfile(images_directory, imageDatabase{i}), colorSpace);
        filenames{i} = imageDatabase{i};
    end

    % Find similar images
    top_k = 5; % Number of top similar images to retrieve
    [topIndices, scores] = retrieveSimilarImages(queryHist, histograms, top_k);

    % Display top k similar images
    figure;
    for i = 1:length(topIndices)
        subplot(1, top_k, i);
        imshow(imread(filenames{topIndices(i)}));
        title(sprintf('Score: %.2f', scores(i)));
    end
    
    % Perform evaluation and display Precision, Recall, and F1 score
    evaluatePerformance(scores);
end

function histVector = getImageHistogram(img, colorSpace)
    if strcmp(colorSpace, 'HSV')
        img = rgb2hsv(img);
    elseif strcmp(colorSpace, 'Lab')
        img = rgb2lab(img);
    end

    % Assuming img is now in the chosen color space
    % Initialize histogram vector
    histVector = [];
    
    % Extract histograms for each channel and concatenate
    for channel = 1:size(img, 3)
        channelHist = imhist(img(:,:,channel), 256); % Using 256 bins
        histVector = [histVector; channelHist]; % Concatenate histograms
    end
end

function [topIndices, scores] = retrieveSimilarImages(queryHist, histograms, top_k)
    num_images = size(histograms, 1);
    scores = zeros(1, num_images);
    
    % Calculate similarity scores
    for i = 1:size(histograms, 1)
        scores(i) = compareHistograms(queryHist, histograms(i)); % You'll need to define this function
    end

    % Sort scores and get top k indices
    [sortedScores, sortedIndices] = sort(scores, 'descend');
    topIndices = sortedIndices(1:top_k);
    scores = sortedScores(1:top_k);
end

function evaluatePerformance(scores)
    % Placeholder for true labels and retrieved labels
    % In practice, you need to have a labeled dataset to determine these values
    trueLabels = [1, 0, 1]; % dummy values, replace with actual labels
    retrievedLabels = scores > 0.5; % dummy threshold, replace with an actual threshold

    % Calculate Precision, Recall, and F1 score using trueLabels and retrievedLabels
    TP = sum(retrievedLabels & trueLabels);
    FP = sum(retrievedLabels & ~trueLabels);
    FN = sum(~retrievedLabels & trueLabels);

    Precision = TP / (TP + FP);
    Recall = TP / (TP + FN);
    F1 = 2 * (Precision * Recall) / (Precision + Recall);

    fprintf('Precision: %.2f\n', Precision);
    fprintf('Recall: %.2f\n', Recall);
    fprintf('F1 Score: %.2f\n', F1);
end

function distance = compareHistograms(hist1, hist2)
    % Compare two histograms using Euclidean distance
    distance = sqrt(sum((hist1 - hist2) .^ 2));
end
