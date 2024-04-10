function script2(images_directory)
    % Get a list of all files in the directory
    % List all files in the directory
    files = dir(images_directory);
    
    % Filter out directories, including '.' and '..'
    files = files(~[files.isdir]);

    % Define the colors spaces list
    color_spaces = {'LAB'}; % {'HSV', 'LAB'}

    % Go through all the files inside the images directory
    for i = 1:length(color_spaces)

        for j = 1:length(files)
            [~, filename1, ~] = fileparts(fullfile(files(j).folder, files(j).name));

            for k = 1:length(files)
                [~, filename2, ~] = fileparts(fullfile(files(k).folder, files(k).name));
                fprintf("Processing '%s' and '%s' files \n", files(j).name, files(k).name);

                % Construct the directory path
                full_directory = fullfile('..', 'outputFiles', '1.experiments_with_color_histograms', 'ex2', color_spaces{i}, filename1, filename2);
                
                % Check if the directory exists
                if exist(full_directory, 'dir')
                    fprintf("Directory exists, skipping: (%s,%s) \n", files(j).name, files(k).name);
                else
                    fprintf("Processing images (%s,%s) \n", files(j).name, files(k).name);
                    file_path1 = fullfile(files(j).folder, files(j).name);
                    file_path2 = fullfile(files(k).folder, files(k).name);
                    compare_images(file_path1, file_path2, color_spaces{i});
                end
            end
        end
    end
end