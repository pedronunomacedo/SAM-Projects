function compare_images(filepath1, filepath2, color_space)
    % Get file1 and file2 informations
    [~,filename1,~] = fileparts(filepath1);
    [~,filename2,~] = fileparts(filepath2);
    
   % Check if the directory where to save the files exists
    full_directory = ['../outputFiles/1.experiments_with_color_histograms/ex2/' color_space '/' filename1 '/' filename2 '/'];
    if ~exist(full_directory, 'dir')
        mkdir(full_directory);
    end  

    % Attempt to open the file for appending
    fileID = fopen(fullfile(full_directory, 'similarity_info.txt'), 'a');
    
    % Check if the file was successfully opened
    if fileID == -1
        error('Failed to open file for writing.');
    end
    
    
    % Generate histogram vectors for both the images
    histogram_vector1 = get_histogram_vector(filepath1, color_space);

    if isempty(histogram_vector1)
        disp(['Skipping comparison due to unsupported image format: ', filepath1]);
        return;  % Skip this comparison
    end


    histogram_vector2 = get_histogram_vector(filepath2, color_space);

    if isempty(histogram_vector2)
        disp(['Skipping comparison due to unsupported image format: ', filepath2]);
        return;  % Skip this comparison
    end

    disp(norm(histogram_vector1 - histogram_vector2));

    % Calculate Euclidean distance
    euclidean_distance = norm(histogram_vector1 - histogram_vector2); % or euclidean_distance = sqrt(sum((Hf - Hg) .^ 2))

    % Calculate cosine similarity
    cosine_similarity = dot(histogram_vector1, histogram_vector2) / (norm(histogram_vector1) * norm(histogram_vector2));

    % Calculate intersection distance (normalize histograms to have the same scale)
    intersection_distance = sum(min(histogram_vector1, histogram_vector2)) / sum(max(histogram_vector1, histogram_vector2));

    % Write the distance informations into the information file
    fprintf(fileID, 'Distances: \n');
    fprintf(fileID, '\teuclidian_distance = %f\n', euclidean_distance);
    fprintf(fileID, '\tcosine_similarity = %f\n', cosine_similarity);
    fprintf(fileID, '\tintersection_distance = %f\n', intersection_distance);
    fprintf(fileID, '------------- \n');
    fprintf(fileID, 'Similarities \n');


    % Set a threshold for deciding if images are similar or not
    euclidean_threshold = sqrt(length(histogram_vector1)) * 0.1; % 10% of the max possible distance
    cosine_threshold = 0.8;  % Indicates vectors are closely aligned
    intersection_threshold = 0.5;  % 50% intersection

    % Check if images are similar based on Euclidean distance
    if euclidean_distance < euclidean_threshold
        disp('Images are similar based on Euclidean distance.');
        fprintf(fileID, '\tImages %s and %s are similar based on Euclidean distance: %f .\n', filename1, filename2, euclidean_distance);
        % display_images_side_by_side(filepath1, filepath2);
        % sgtitle('Images are similar based on Euclidean distance');
    end

    % Check if images are similar based on cosine similarity
    if cosine_similarity > cosine_threshold
        disp('Images are similar based on cosine similarity.');
        fprintf(fileID, '\tImages %s and %s are similar based on cosine similarity: %f.\n', filename1, filename2, cosine_similarity);
        % display_images_side_by_side(filepath1, filepath2);
        % sgtitle('Images are similar based on cosine similarity');
    end

    % Check if images are similar based on intersection distance
    if intersection_distance > intersection_threshold
        disp('Images are similar based on intersection distance.');
        fprintf(fileID, '\tImages %s and %s are similar based on intersection distance: %f.\n', filename1, filename2, intersection_distance);
        % display_images_side_by_side(filepath1, filepath2);
        % sgtitle('Images are similar based on intersection distance');
    end

    % Close the file
    fclose(fileID);
end