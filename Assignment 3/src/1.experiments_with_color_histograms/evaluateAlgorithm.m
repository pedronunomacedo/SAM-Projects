function [precision, recall, f1_score] = evaluateAlgorithm(query_images, ground_truth, image_database, color_space, num_bins, threshold, k)
    tp = 0; fp = 0; fn = 0; % tp: True Positive ; fp: False Positive ; fn: False Negative

    for i = 1:length(query_images)
        % Run the retrieval algorithm to get the indices of similar images
        top_indices = searchAndRetrieve(query_images{i}, image_database, color_space, k, num_bins, threshold);

        if isempty(top_indices)
            top_indices = [];
        end

        % Evaluate the algorithm's performance
        for j = 1:length(top_indices)
            if ismember(top_indices(j), ground_truth{i})
                tp = tp + 1; % True positive: Correctly identified as similar
            else
                fp = fp + 1; % False positive: Incorrectly identified as similar
            end
        end

        fn = fn + (length(ground_truth{i}) - length(intersect(top_indices, ground_truth{i}))); % False negative: Missed similar images
    end

    % Calculate precision, recall, and F1 score
    precision = tp / (tp + fp);
    recall = tp / (tp + fn);
    f1_score = 2 * (precision * recall) / (precision + recall);
end