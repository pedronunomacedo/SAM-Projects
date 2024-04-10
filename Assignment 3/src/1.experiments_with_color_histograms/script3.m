function script3(images_directory, k)    
    % Get a list of all files in the directory
    % List all files in the directory
    files = dir(images_directory);
    
    % Filter out directories, including '.' and '..'
    files = files(~[files.isdir]);
    num_files = numel(files);

    if num_files < k
        k = num_files;
    end

    % Define the colors spaces list
    color_spaces = {'LAB'}; % {'HSV', 'LAB'}

    for i = 1:length(color_spaces)
        % Iterate over each image in the directory
        for main_index = 1:num_files
            % Use the current image as the main image
            main_image_path = fullfile(files(main_index).folder, files(main_index).name);

            % Get main image histogram
            main_image_histogram = get_histogram_vector(main_image_path, color_spaces{i});
            
            % Display which image is being processed
            fprintf("Processing main image: %s\n", files(main_index).name);
            
            % Generate indices for the remaining images
            remaining_indices = setdiff(1:num_files, main_index);
            
            selected_images = [];
            curr_image_idx = 1;
            num_tries = 3;
            fprintf("BEFORE!");
            while (numel(selected_images) ~= 9 && num_tries > 0)
                % Randomly select 9 distinct images from the remaining ones
                possible_images = remaining_indices(randperm(length(remaining_indices), 10));
                for j = 1:numel(possible_images)
                    candidate_histogram = get_histogram_vector(fullfile(files(possible_images(j)).folder, files(possible_images(j)).name), color_spaces{i});
                    if length(main_image_histogram) == length(candidate_histogram)
                        selected_images{curr_image_idx} = files(possible_images(j));
                        curr_image_idx = curr_image_idx + 1;
                    end
                end
                num_tries = num_tries - 1;
                fprintf("num_tries: %d \n", num_tries);
            end
            fprintf("AFTER!");
            
            % Create an image database with the selected images
            image_database = cell(1, 9);
            for j = 1:numel(selected_images)
                image_database{j} = fullfile(selected_images{j}.folder, selected_images{j}.name);
            end



            % Print the image_database
            fprintf('Image Database Contents:\n');
            for idx = 1:numel(image_database)
                fprintf('Image %d: %s\n', idx, image_database{idx});
            end



        
            % Call the searchAndRetrieve function with the main image and the selected image database
            % Assuming k = 9 since we are retrieving 9 images to compare
            top_k_indices = searchAndRetrieve(main_image_path, image_database, color_spaces{i}, k);
        
            % Process the top_k_indices if needed, for example, to display which images are most similar
    
            % Open the file for writing

            % Construct the directory path
            [~, filename, ~] = fileparts(fullfile(files(main_index).folder, files(main_index).name));
            resultsDir = fullfile('..', 'outputFiles', '1.experiments_with_color_histograms', 'ex3', filename);
            if ~exist(resultsDir, 'dir')
                mkdir(resultsDir);
            end
              

            % Save the results to the main_image folder
            fprintf("[%s] Saving info...", files(main_index).name);
            resultsFilePath = fullfile(resultsDir, 'similarity_results.txt');
            fileID = fopen(resultsFilePath, 'w');
            fprintf(fileID, "Main Image: %s\n\n", files(main_index).name);
            fprintf(fileID, "Comparison Images:\n");

            for j = 1:numel(selected_images)
                fprintf(fileID, "%d: %s\n", j, image_database{j});
            end
        
            fprintf(fileID, "\nTop %d Similar Images:\n", numel(top_k_indices));
            for j = 1:numel(top_k_indices)
                fprintf(fileID, "%d: %s\n", j, image_database{top_k_indices(j)});
            end
        
            % Close the file
            fclose(fileID);

            break;
        end
        break;
    end
end