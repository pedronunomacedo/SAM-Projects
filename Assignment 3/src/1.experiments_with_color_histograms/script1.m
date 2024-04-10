function script1(images_directory)    
    % Get a list of all files in the directory
    % List all files in the directory
    files = dir(images_directory);
    
    % Filter out directories, including '.' and '..'
    files = files(~[files.isdir]);

    % Define the colors spaces list
    color_spaces = {'HSV', 'LAB'};
    
    % Go through all the files inside the images directory
    for i = 1:length(files)
        file_path = fullfile(files(i).folder, files(i).name);
        fprintf('Processing %s\n', files(i).name);
        for j = 1:length(color_spaces)
            get_histogram_vector(file_path, color_spaces(j));
        end
    end
end