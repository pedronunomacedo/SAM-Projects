function script1(filepath)
    % 1) Import an image in bitmap format (RGB color space) and display this image on the screen
    
    
    imageRGB = imread(filepath); % Import the image
    % Display RGB image with all the components
    figure('Name', 'RGB image', 'NumberTitle', 'off');
    imshow(imageRGB); % display HSV image
    title('The image is in RGB');

    
    title('Displayed Image'); % Add a title to the figure window
    
    % Check if the image is in grayscale (single channel) or if the image is RGB
    if size(imageRGB, 3) == 1
        % Image is in grayscale
        imshow(imageRGB);
        title('The image is in grayscale');
    else
        % Image is in RGB scale
        imshow(imageRGB); % display original image
        title('The image is in RGB');

        % Separate each RGB component into a different matrix and display each one of them on the screen
        R = imageRGB(:, :, 1); % Red channel
        G = imageRGB(:, :, 2); % Green channel
        B = imageRGB(:, :, 3); % Blue channel
        
        figure('Name', 'RGB image', 'NumberTitle', 'off');
        subplot(2,3,2),imshow(imageRGB); title('original image');
        subplot(2,3,4),imshow(R); title('componente R (RGB)');
        subplot(2,3,5),imshow(G); title('componente G (RGB)');
        subplot(2,3,6),imshow(B); title('componente B (RGB)');

        pause; % Wait for the user to press any key to continue

        % 3) Convert the image to HSV color space and display that image on the screen
        
        imageHSV = rgb2hsv(imageRGB);
        
        % Display HSV image with all the components
        figure('Name', 'HSV image', 'NumberTitle', 'off');
        imshow(imageHSV); % display HSV image
        title('The image is in HSV');

        H = imageHSV(:, :, 1); % Hue channel
        S = imageHSV(:, :, 2); % Saturation channel
        V = imageHSV(:, :, 3); % Value channel

        figure('Name', 'HSV image separated by each component', 'NumberTitle', 'off');
        title('HSV image separated by each component');
        subplot(2,3,2),imshow(imageRGB); title('original image');
        subplot(2,3,4),imshow(H); title('componente H (HSV)');
        subplot(2,3,5),imshow(S); title('componente S (HSV)');
        subplot(2,3,6),imshow(V); title('componente V (HSV)');
            
    end