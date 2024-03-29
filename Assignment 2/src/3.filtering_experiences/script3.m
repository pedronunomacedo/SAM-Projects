function [] = script3 (filepath)
    filters = {'average', 'disk', 'gaussian', 'laplacian', 'log', 'motion', 'prewitt', 'sobel'}; % fspecial filter type
    options = {'symmetric', 'replicate', 'circular', 'same', 'full', 'corr', 'conv'}; % imfilter options that control the filtering operation
    
    for i = 1:length(filters)
        for j = 1:length(options)
            filter = filters{i};
            option = options{j};
            
            % Call your function with the current set of parameters
            filterExperience(filepath, filter, i, option, j);
        end
    end