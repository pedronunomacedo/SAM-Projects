function [precision, recall, f1_score] = script4(images_directory, main_image, ground_truth, color_space, num_bins, threshold, k)
    files = dir(images_directory);
    
    % Filter out directories, including '.' and '..'
    files = files(~[files.isdir]);
    num_files = numel(files);
    
    % Define your image database
    image_database = cell(min(num_files, 10), 1);
    for i = 1:num_files
        file_path = fullfile(files(i).folder, files(i).name);
        image_database{i} = file_path;

        if i == 25
            break;
        end
    end

    % Call evaluateAlgorithm function with appropriate parameters
    [precision, recall, f1_score] = evaluateAlgorithm({main_image}, ground_truth, image_database, color_space, num_bins, threshold, k);
end
