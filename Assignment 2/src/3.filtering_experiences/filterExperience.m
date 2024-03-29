function [] = filterExperience (filename, filterType, filterIdx, option, optionIdx, varargin)
    % função para ampliar ou reduzir dimensoes espaciais da imagem "zone-plate"
    % N: Recebe as dimensoes N da imagem de teste a construir, 
    % factor: o factor de ampliacao/reducao para aplicar ? imagem de teste criada,
    % metodo:  string para indicar o metodo de interpolação a usar:
    %       - nearest; 
    %       - bilinear;
    %       - bicubic;
    %       - box;
    %       - triangle;
    %       - cubic;
    %       - lanczos2;
    %       - lanczos3;
    % Usa a função built-in imresize(I, scale,'method') do Matlab
    % Usa a função "imzoneplate(N)"
    % Retorna as imagens reduzidas ou ampliadas pelos dois métodos

    % Define the user parameters string
    userParams = sprintf('\\bf Filter: \\rm %s\n\\bf Option: \\rm %s\n\\bf', filterType, option);

    hFig = figure('Position', [100, 100, 1200, 800]); % Adjust the position and size as needed
    set(hFig, 'Name', 'Filtering experiences', 'NumberTitle', 'off')

    % Add the annotation to the figure
    annotation('textbox', [0.87, 0.94, 0.15, 0], 'String', userParams, ...
               'FontSize', 10, 'HorizontalAlignment', 'center', ...
               'VerticalAlignment', 'middle', 'EdgeColor', 'none', ...
               'BackgroundColor', 'white');

    % Check if the image file exists
    if ~exist(filename, 'file')
        error('The specified image file does not exist.');
    end

    % Read the image from the file
    originalImage = imread(filename);

    switch lower(filterType)
        case 'average'
            % varargin{1} is the size of the filter (HSIZE - default is 50)
            if numel(varargin) >= 1
                h = fspecial('average', varargin{1});
            else
                h = fspecial('average', 50);
            end
        case 'disk'
            % varargin{1} is the radius of the filter (RADIUS - default is
            % 10)
            if numel(varargin) >= 1
                h = fspecial('disk', varargin{1});
            else
                h = fspecial('disk', 10);
            end
        case 'gaussian'
            % varargin{1} is the size of the filter (HSIZE - default is [3 3]); varargin{2} is the
            % standard deviation (positive) (SIGMA - default is 0.5)
            if numel(varargin) >= 1
                h = fspecial('gaussian', varargin{1}, varargin{2});
            else
                h = fspecial('gaussian', 20, 0.5);
            end
        case 'laplacian'
            % varargin{1} is the shape of the filter and must be in the
            % range [0.0, 1.0] (ALPHA - default is 0.2)
            if numel(varargin) >= 1
                h = fspecial('laplacian', varargin{1});
            else
                h = fspecial('laplacian', 0.2);
            end
        case 'log'
            % varargin{1} is the size of the filter (HSIZE - default is [5 5]); varargin{2} is
            % the standard deviation (positive) (SIGMA - default is 0.5)
            if numel(varargin) >= 1
                h = fspecial('log', varargin{1}, varargin{2});
            else
                h = fspecial('log');
            end
        case 'motion'
            % varargin{1} is the size of a linear motion of the a camera (LEN - default is 9); varargin{2} is
            % the angle (in degreees and in a counter-clockwise direction) (THETA - default is 0)
            if numel(varargin) >= 1
                h = fspecial('motion', varargin{1}, varargin{2});e
            else
                h = fspecial('motion');
            end
        case 'prewitt'
            % no additional variables
            h = fspecial('prewitt');
        case 'sobel'
            % no additional variables
            h = fspecial('sobel');
        otherwise
            error(["Unknown filter type '", filterType, "'!"]);
    end

    % Apply the filter to the image using imfilter
    filteredImage = imfilter(originalImage, h, option);

    % Check if working directory (to save file) exist
    % Check if the directory exists, if not, create it
    disp(['filterIdx = ' string(filterIdx)]);
    disp(['optionIdx = ' string(optionIdx)]);
    specificDir = '../outputFiles/3.filtering_experiences/' + string(filterIdx) + '.filter_' + filterType;
    if ~exist(specificDir, 'dir')
        mkdir(specificDir);
    end    

    % Create a figure for the histogram plot without showing the window
    subplot(1, 2, 1);
    imshow(originalImage);
    title('Original Image');
    
    subplot(1, 2, 2);
    imshow(filteredImage);
    title(['Filtered Image - ' filterType]);
    
    sgtitle('Filtering experiences');
    
    % Save the figure
    fullFilePath = specificDir + '/' + string(optionIdx) + '.option_' + option +'.png';
    if exist('exportgraphics', 'file') == 2
        exportgraphics(gcf, fullFilePath, 'ContentType', 'image');
    else
        saveas(gcf, fullFilePath);
    end
    
end