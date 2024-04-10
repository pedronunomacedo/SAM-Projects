function histogram_vector = get_histogram_vector(filepath, color_space, num_bins)
    % Set the default number for num_bins if it's empty
    if nargin < 3 || isempty(num_bins)
        num_bins = 256; % Default number of bins for an 8-bit image
    end

    histogram_vector = [];
    
    % Check if the directory where to save the files exists
    specificDir = ['../outputFiles/1.experiments_with_color_histograms/ex1/' color_space '/'];
    if ~exist(specificDir, 'dir')
        mkdir(specificDir);
    end  

    % 1) Import an image in bitmap format (RGB color space) and display this image on the screen
    img = imread(filepath); % Import the image

    % Check if the image is logical (binary)
    if islogical(img)
        fprintf('Binary images are not supported for color space conversion: %s\n', filepath);
        return;
    end

    % Check if the image is grayscale and convert to three channels if it is
    if ismatrix(img)  % ismatrix checks for 2D matrix which indicates a grayscale image
        img = cat(3, img, img, img); % Concatenate the grayscale image across three channels
    end

    % Display RGB image with all the components
    figure('Name', 'RGB image', 'NumberTitle', 'off');
    imshow(img); % display HSV image
    title('The image is in RGB');

    % Save the original image to a file
    figure(gcf);
    set(gcf, 'Renderer', 'opengl');
    saveas(gcf, [specificDir 'original_rgb_image.png']); % Saves the figure as a PNG file

    % 2) Convert the orginal image (in RGB) to the colar space choosed (HSV or Lab)
    if strcmp(color_space, 'HSV')
        img_converted = rgb2hsv(img);
        color_space_str = 'HSV';
    elseif strcmp(color_space, 'LAB')
        img_converted = rgb2lab(img);
        color_space_str = 'L*a*b';
    else
        error('Unsupported color space specified.');
    end

    % Separate the color components
    component1 = img_converted(:,:,1);
    component2 = img_converted(:,:,2);
    component3 = img_converted(:,:,3);

    if strcmp(color_space, 'LAB')
        % Adjust the a* and b* components for the range [0, 1]
        component1 = component1 / 100;
        component2 = (component2 + 128) / 255;
        component3 = (component3 + 128) / 255;
    end

    % Generate and plot histograms for each component

    if strcmp(color_space, 'HSV')
        title1 = "Component H (" + color_space_str + ")";
        title2 = "Component S (" + color_space_str + ")";
        title3 = "Component V (" + color_space_str + ")";
    else
        title1 = "Component L* (" + color_space_str + ")";
        title2 = "Component a* (" + color_space_str + ")";
        title3 = "Component b* (" + color_space_str + ")";
    end

    figure, subplot(3,1,1), imhist(component1, num_bins), title(title1);
    subplot(3,1,2), imhist(component2, num_bins), title(title2);
    subplot(3,1,3), imhist(component3, num_bins), title(title3);

    % Save the figure to a file
    fullname = "histograms_" + color_space + ".png";
    fullFilePath = fullfile(specificDir, fullname);
    % disp(['Saving to: ', fullFilePath]);  % Verify the path
    saveas(gcf, fullFilePath); % Saves the figure as a PNG file

    % Concatenate the histograms into a single vector
    histogram_vector = [imhist(component1, num_bins); imhist(component2, num_bins); imhist(component3, num_bins)];
    histogram_vector = histogram_vector / sum(histogram_vector); % Normalizing the histogram vector

    % Extract histograms for each channel and concatenate
    for channel = 1:size(img, 3)
        channelHist = imhist(img(:,:,channel), 256); % Using 256 bins
        histogram_vector = [histogram_vector; channelHist]; % Concatenate histograms
    end
end