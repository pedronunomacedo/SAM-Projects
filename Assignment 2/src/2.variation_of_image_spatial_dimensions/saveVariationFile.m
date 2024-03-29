function saveVariationFile(Z, directory, filename, image_title)
    % Ensure the directory exists
    if ~exist(directory, 'dir')
        mkdir(directory); % Create the directory if it does not exist
    end

    % Full path for the file
    fullPath = fullfile(directory, filename);

    % Create a figure for the histogram plot without showing the window
    f = figure('Visible', 'off');

    % Create the histogram plot
    histogram(Z(:), 50);
    
    % Add a title to the plot
    title(image_title);

    % Save the figure
    if exist('exportgraphics', 'file') == 2
        exportgraphics(gca, fullPath, 'ContentType', 'image');
    else
        saveas(f, fullPath);
    end

    % Close the figure
    close(f);
end