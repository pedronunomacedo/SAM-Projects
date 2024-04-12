function top_k_indices = searchAndRetrieve(main_image_path, num_bins, color_space, k, threshold, relevant_images, image_database_paths)
    images_directory = '../resources';
    
    %{
    % Get folder images
    imageFiles = dir(images_directory); % Add other file extensions if necessary
    imageFiles = imageFiles(~[imageFiles.isdir]);
    image_database_paths = arrayfun(@(file) fullfile(images_directory, file.name), imageFiles, 'UniformOutput', false);

    % Remove the main image from the database paths
    image_database_paths = image_database_paths(~strcmp(image_database_paths, main_image_path));
    %}
    
    % Fetch the histogram of the main image
    main_image_histogram = get_histogram(main_image_path, num_bins, color_space);

    % Initialize a matrix to hold all histograms for the image database
    database_histograms = zeros(length(image_database_paths), num_bins * 3);

    % Compute histograms for each image in the database
    for i = 1:length(image_database_paths)
        database_histograms(i, :) = get_histogram(image_database_paths{i}, num_bins, color_space);
    end

    % Placeholder for similarity scores
    similarity_scores = struct;
    valid_indices = [];
    
    % Calculate the similarity scores
    valid_indices_idx = 1;
    image_scores = struct('name', {}, 'index', 0, 'scores', {});
    for i = 1:length(image_database_paths)
        database_histogram = get_histogram(image_database_paths{i}, num_bins, color_space);
        
        
        % Calculate Euclidean distance
        euclidean_distance = norm(main_image_histogram - database_histogram); % or euclidean_distance = sqrt(sum((Hf - Hg) .^ 2))
    
        % Calculate cosine similarity
        cosine_similarity = dot(main_image_histogram, database_histogram) / (norm(main_image_histogram) * norm(database_histogram));
    
        % Calculate intersection distance (normalize histograms to have the same scale)
        histogram_vector1 = main_image_histogram / sum(main_image_histogram);
        histogram_vector2 = database_histogram / sum(database_histogram);
        intersection_distance = sum(min(main_image_histogram, database_histogram));
    
        % Choose one distance of the 3
        distance = euclidean_distance;

        % Check if the euclidean_distance is below the threshold
        if distance < threshold
            % Store this image's information, including scores
            image_scores(end+1) = struct( ...
                                    'name', image_database_paths{i}, ...
                                    'index', i, ...
                                    'scores', struct( ...
                                        'euclidean_distance', euclidean_distance, ...
                                        'cosine_similarity', cosine_similarity, ...
                                        'intersection_distance', intersection_distance ...
                                    ));
        else
            % Option to exclude or mark non-qualifying images, e.g., by adding with Inf scores
            % Uncomment the following line to include images that do not meet the threshold with Inf scores
            image_scores(end+1) = struct( ...
                                    'name', image_database_paths{i}, ...
                                    'index', i, ...
                                    'scores', struct( ...
                                        'euclidean_distance', Inf, ...
                                        'cosine_similarity', Inf, ...
                                        'intersection_distance', Inf ...
                                    ));
        end
    end

    % Extract Euclidean distances
    euclidean_distances = arrayfun(@(x) x.scores.euclidean_distance, image_scores);

    % Sort and get indices
    [~, sortedIndices] = sort(euclidean_distances, 'ascend');

    % Reorder the structured array
    sorted_image_scores = image_scores(sortedIndices);
    
    % Select top k indices
    top_k_indices = sorted_image_scores(1:min(k, length(sorted_image_scores)));
    
    % Now, map these indices to their filenames
    top_k_filenames = cell(1, length(top_k_indices));

    % Extract the filenames from the struct array
    for i = 1:length(top_k_indices)
        top_k_filenames{i} = top_k_indices(i).name;
    end

    % Calculate performance metrics
    evaluatePerformance(top_k_filenames, relevant_images, image_database_paths);

    indices = arrayfun(@(x) x.index, top_k_indices);
    names = arrayfun(@(x) x.name, top_k_indices, 'UniformOutput', false);
    scores = arrayfun(@(x) x.scores, top_k_indices, 'UniformOutput', false);

    top_k_indices_struct = struct('index', num2cell(indices), 'name', names, 'scores', scores);
    
    fprintf("\n\n\n");
    disp('---');
    for idx = 1:length(top_k_indices_struct)
        disp(['Index: ', num2str(top_k_indices_struct(idx).index)]);
        disp(['Name: ', top_k_indices_struct(idx).name]);
        disp('Scores: ');
        disp(top_k_indices_struct(idx).scores);
        
        disp('---'); % Separator for clarity
    end
    
    top_k_indices = arrayfun(@(x) x.index, top_k_indices);
end

function histogram_vector = get_histogram(image_path, num_bins, color_space)
    % Read the image
    img = imread(image_path);
    
    % Convert image to double precision for histogram computation
    img = im2double(img);

    % Check if the image is grayscale and convert to three channels if it is
    if ismatrix(img)  % ismatrix checks for 2D matrix which indicates a grayscale image
        img = cat(3, img, img, img); % Concatenate the grayscale image across three channels
    end
    
    % Convert to the specified color space
    switch color_space
        case 'RGB' % No conversion needed for RGB
            % No action required
        case 'HSV'
            img = rgb2hsv(img);
        case 'LAB'
            img = rgb2lab(img);
        otherwise
            error('Unsupported color space.');
    end
    
    % Preallocate a vector to hold the combined histogram
    histogram_vector = zeros(1, num_bins * 3);
    
    % Compute and concatenate the histogram for each channel
    for channel = 1:3
        % Extract the channel
        channel_data = img(:, :, channel);
        
        % Compute the histogram
        % Note: For non-RGB color spaces, the range of values might differ.
        if strcmp(color_space, 'HSV')
            % HSV values range from 0 to 1
            [hist_counts, ~] = imhist(channel_data, num_bins);
        elseif strcmp(color_space, 'LAB')
            % L* from 0 to 100, a* and b* can have wider ranges depending on the colorspace implementation
            % Adjust the range as necessary for your application
            minVal = min(channel_data(:));
            maxVal = max(channel_data(:));
            [hist_counts, ~] = imhist(channel_data, num_bins, 'BinLimits', [minVal, maxVal]);
        else
            % For RGB and any other color spaces treated like RGB
            [hist_counts, ~] = imhist(channel_data, num_bins);
        end
        
        % Normalize the histogram to have sum equal to 1
        hist_counts = hist_counts / sum(hist_counts);
        
        % Insert the normalized histogram into the histogram vector
        histogram_vector((channel-1)*num_bins + 1 : channel*num_bins) = hist_counts;
    end
end



function [] = evaluatePerformance(retrieved_images, expected_images, image_database_paths)
    fprintf("retrieved_images:");
    disp(retrieved_images);
    fprintf("\n");

    fprintf("expected:");
    disp(expected_images);

    TP = sum(ismember(retrieved_images, expected_images));
    FP = sum(~ismember(retrieved_images, expected_images));
    FN = sum(~ismember(expected_images, retrieved_images));
    TN = length(image_database_paths) - (TP + FP + FN);

    fprintf('TP: %d\n', TP);
    fprintf('FP: %d\n', FP);
    fprintf('FN: %d\n', FN);
    fprintf('TN: %d\n\n\n', TN);
    
    Accuracy = (TP + TN) / (TP + TN + FP + FN);
    Precision = TP / (TP + FP);
    Recall = TP / (TP + FN);
    F1 = 2 * (Precision * Recall) / (Precision + Recall);
    
    fprintf('Accuracy: %.2f\n', Accuracy);
    fprintf('Precision: %.2f\n', Precision);
    fprintf('Recall: %.2f\n', Recall);
    fprintf('F1 Score: %.2f\n', F1);
end
