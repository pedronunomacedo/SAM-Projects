function script2(filepath)
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

        % 3) Convert the image to YCbCr color space and display that image on the screen
        
        imageYCbCr = rgb2ycbcr(imageRGB);
        
        
        % Display HSV image with all the components
        figure('Name', 'YCbCr image', 'NumberTitle', 'off');
        imshow(imageYCbCr); % display HSV image
        title('The image is in YCbCr');

        Y = imageYCbCr(:, :, 1); % Hue channel
        Cb = imageYCbCr(:, :, 2); % Saturation channel
        Cr = imageYCbCr(:, :, 3); % Value channel

        figure('Name', 'YCbCr image separated by each component', 'NumberTitle', 'off');
        title('YCbCr image separated by each component');
        subplot(2,3,2),imshow(imageRGB); title('original image');
        subplot(2,3,4),imshow(Y); title('componente Y (YCbCr)');
        subplot(2,3,5),imshow(Cb); title('componente Cb (YCbCr)');
        subplot(2,3,6),imshow(Cr); title('componente Cr (YCbCr)');
            
    end