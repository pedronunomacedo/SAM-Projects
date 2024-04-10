function [] = script4 (filepath)
    % Check if working directory (to save file) exist
    % Check if the directory exists, if not, create it
    specificDir = '../outputFiles/1.experiments_with_color_spaces/ex4/';
    if ~exist(specificDir, 'dir')
        mkdir(specificDir);
    end    

    % Load an image
    img = imread(filepath);

    % Extract the name of the file
    [~, filename, ~] = fileparts(filepath);

    % Convert the image to L*a*b color space
    cform = makecform('srgb2lab');
    lab_img = applycform(im2double(img), cform);

    % RGB Histograms provide information about the distribution of red, green, and blue primary colors in an image. 
    % They are useful for understanding the brightness and contrast in terms of primary colors.
    figure('Name','RGB Histograms');
    for i = 1:3
        subplot(3,1,i);
        histogram(img(:,:,i), 'BinWidth', 1);
        xlim([0 255]);
        title(['RGB Channel ', num2str(i)]);
    end
    
    % Lab Histograms provide a different type of information. 
    % The L* channel shows the luminance or brightness levels, where higher values represent brighter pixels. 
    % The a* and b* channels represent color opponents, where a* ranges from green to red and b* ranges from blue to yellow. 
    % These histograms are useful for understanding the color distribution and luminance in a more perceptually uniform space compared to RGB.
    figure('Name','L*a*b Histograms');
    
    % L Channel
    subplot(3,1,1);
    histogram(lab_img(:,:,1), 'BinWidth', 1);
    title('L* Channel');
    
    % a* Channel
    subplot(3,1,2);
    histogram(lab_img(:,:,2), 'BinWidth', 1);
    title('a* Channel');
    
    % b* Channel
    subplot(3,1,3);
    histogram(lab_img(:,:,3), 'BinWidth', 1);
    title('b* Channel');
    
    % Save the figure to a file
    fullname = [filename '_histograms.png'];
    saveas(gcf, [specificDir fullname]); % Saves the figure as a PNG file
end