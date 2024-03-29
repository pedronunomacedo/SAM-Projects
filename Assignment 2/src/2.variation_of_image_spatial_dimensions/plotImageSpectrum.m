function plotImageSpectrum(img)
    % Calculate the Power Spectral Density (PSD) of the image
    psd = 10*log10(abs(fftshift(fft2(img))).^2 );

    % Create the mesh plot of the PSD
    mesh(psd);
end