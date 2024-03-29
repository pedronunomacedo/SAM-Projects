function [] = script2 ()
    Ns = [64, 128, 256, 512]; % Array of image sizes
    factors = [0.5, 2, 3]; % Array of scale factors (reduction and amplification)
    methods = {'nearest', 'bilinear', 'bicubic', 'box', 'triangle', 'cubic', 'lanczos2', 'lanczos3'}; % Interpolation methods
    
    for i = 1:length(Ns)
        for j = 1:length(factors)
            for k = 1:length(methods)
                N = Ns(i);
                factor = factors(j);
                metodo = methods{k};
                
                % Call your function with the current set of parameters
                ampliaReduz(N, factor, metodo);
            end
        end
    end