function [] = ampliaReduz (N, factor, metodo)

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
    userParams = sprintf('\\bf N: \\rm %d\n\\bf Factor: \\rm %0.2f\n\\bf Method: \\rm %s', N, factor, metodo);
       
    hFig = figure('Position', [100, 100, 1200, 800]); % Adjust the position and size as needed
    set(hFig, 'Name', 'Variation of image spatial dimensions', 'NumberTitle', 'off')
    % Add the annotation to the figure
    annotation('textbox', [0.87, 0.94, 0.15, 0], 'String', userParams, ...
               'FontSize', 10, 'HorizontalAlignment', 'center', ...
               'VerticalAlignment', 'middle', 'EdgeColor', 'none', ...
               'BackgroundColor', 'white');
    
    methods = {'nearest', 'bilinear', 'bicubic', 'box', 'triangle', 'cubic', 'lanczos2', 'lanczos3'}; % imresize possible methods
    
    if ~any(strcmp(metodo, methods))
        error("Variable value '" + metodo + "' is not a valid method." + newline + "Possible methods: " + strjoin(methods, ', '));
    end
       
    Z=imzoneplate(N); % image created with size NxN

    % se se tratar de uma redução (factor<1) obtem a imagem apenas por
    % elimina??o de amostras e depois usa imresize
    if factor<1
        factorReducao=1/factor;
        Zreduzida = Z(1:factorReducao:end,1:factorReducao:end);
        %figure(2);
        %imshow(Zreduzida)
        %title('Zreduzida por eliminacao')
        
        % agora obtem nova imagem reduzida usando imresize com o método escolhido
        ZreduzidaMatlab=imresize(Z, factor, metodo);
        %figure(3);
        %imshow(ZreduzidaMatlab);
        %title('Zreduzida com imresize');
    
        % retorna as imagens reduzidas com os dois métodos
        resultado1=Zreduzida;
        resultado2=ZreduzidaMatlab;
    
    else
        % come?a por ampliar apenas por repeticao de pixels criando uma matriz
        % de zeros com as dimensoes desejadas
        Zampliada=zeros(factor*N,factor*N);   
        for(i=1:1:N)
            for(j=1:1:N)
                for(k=(factor*i)-1:1:(factor*i)-1+(factor-1))
                    for(l=(factor*j)-1:1:(factor*j)-1+(factor-1))
                        Zampliada(k,l)=Z(i,j); % duplicates each pixel in a square of factorxfactor
                    end
                end
            end
        end
        %figure(2);
        %imshow(Zampliada);
        %title('Z ampliada por repeticao');
        
        % agora amplia usando imresize com o método escolhido
        ZampliadaMatlab=imresize(Z, factor, metodo);
    
        %figure(3);
        %imshow(ZampliadaMatlab);
        %title('Z ampliada com imresize');

        % retorna as imagens ampliadas com os dois métodos
        resultado1=Zampliada;
        resultado2=ZampliadaMatlab;
    end

    % saveas(resultado1, fullfile('../outputFiles' ,['2.variation_of_image_spatial_dimensions/', 'size_' num2str(N)], metodo, 'processed_image.png'));
    % saveas(resultado2, fullfile('../outputFiles' ,['2.variation_of_image_spatial_dimensions/', 'size_' num2str(N)], metodo, 'processed_image_with_matlab.png'));
    
    % Check if working directory (to save file) exist
    % Check if the directory exists, if not, create it
    baseDir = '../outputFiles/2.variation_of_image_spatial_dimensions/';
    specificDir = fullfile(baseDir, ['size_' num2str(N)], metodo);
    if ~exist(specificDir, 'dir')
        mkdir(specificDir);
    end    



    % ----- Original image -----
    % Display original image
    subplot(3, 3, 1);
    imshow(Z);
    title('Original Image');
    imwrite(Z, fullfile(specificDir, '1.1.original_image.png'));
    
    % Display spectral density graph of original image
    subplot(3, 3, 4);
    plotImageSpectrum(Z);
    title('Spectral Density - Original Image');
    saveSpectrumFile(Z, fullfile(specificDir, '1.2.spectral_density_original_image.png'), 'Spectral Density - Original Image');
    
    % Display variation of signal in space graph of original image
    subplot(3, 3, 7);
    histogram(Z(:), 50);
    title('Variation of Signal in Space - Original Image');
    saveVariationFile(Z, specificDir, '1.3.variation_of_signal_original_image.png', 'Variation of Signal in Space - Original Image');
    


    % ----- Processed image by repetition -----
    % Display image processed by repetition
    subplot(3, 3, 2);
    imshow(resultado1);
    title('Image processed by repetition');
    imwrite(Z, fullfile(specificDir, '2.1.image_processed_by_repetition.png'));
    
    % Display spectral density graph of image processed by repetition
    subplot(3, 3, 5);
    plotImageSpectrum(resultado1);
    title('Spectral Density - Image processed by repetition');
    saveSpectrumFile(resultado1, fullfile(specificDir, '2.2.spectral_density_image_processed_by_repetition.png'), 'Spectral Density - Image processed by repetition');
    
    % Display variation of signal in space graph of image processed by repetition
    subplot(3, 3, 8);
    histogram(resultado1(:), 50);
    title('Variation of Signal in Space - Image processed by repetition');
    saveVariationFile(resultado1, specificDir, '2.3.variation_of_signal_image_processed_by_repetition.png', 'Variation of Signal in Space - Image processed by repetition');



    % ----- Processed image by imresize -----
    % Display image processed by imresize
    subplot(3, 3, 3);
    imshow(resultado2);
    title('Image processed by imresize');
    imwrite(Z, fullfile(specificDir, '3.1.image_processed_by_imresize.png'));
    
    % Display spectral density graph of image processed by imresize
    subplot(3, 3, 6);
    plotImageSpectrum(resultado2);
    title('Spectral Density - Image processed by imresize');
    saveSpectrumFile(resultado2, fullfile(specificDir, '3.2.spectral_density_image_processed_by_imresize.png'), 'Spectral Density - Image processed by imresize');
    
    % Display variation of signal in space graph of image processed by imresize
    subplot(3, 3, 9);
    histogram(resultado2(:), 50);
    title('Variation of Signal in Space - Image processed by imresize');
    saveVariationFile(resultado2, specificDir, '3.3.variation_of_signal_image_processed_by_imresize.png', 'Variation of Signal in Space - Image processed by imresize');



    % ----- Statistics -----
    sgtitle('Image Analysis Results');

    % Save the figure
    fullFilePath = fullfile(specificDir, '4.final_graphs.png');
    
    if exist('exportgraphics', 'file') == 2
        exportgraphics(gcf, fullFilePath, 'ContentType', 'image');
    else
        saveas(gcf, fullFilePath);
    end