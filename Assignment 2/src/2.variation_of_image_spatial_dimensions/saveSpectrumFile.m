function saveSpectrumFile(img, filename, image_title)
    % Calculate the Power Spectral Density (PSD) of the image
    psd = 10*log10(abs(fftshift(fft2(img))).^2 );

    % Create a figure for the mesh plot without showing the window
    f = figure('Visible', 'off');

    % Create the mesh plot of the PSD
    mesh(psd);

    % Add a title to the plot
    title(image_title);

    % Save the figure to a file
    if exist('exportgraphics', 'file') == 2
        exportgraphics(gca, filename, 'ContentType', 'image');
    else
        saveas(f, filename);
    end

    % Close the figure
    close(f);
end
