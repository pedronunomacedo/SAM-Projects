% spatial frequency (SF) filtering
clear; close all; clc;
filename = 'peppers.png';
% Read file and convert to grayscale
if ndims(imread(filename)) == 3
    originalImage = rgb2gray(imread(filename));
else
    originalImage = imread(filename);
end
% Compute the 2D FFT function
originalFFT = fftshift(fft2(originalImage));
% calculate the number of points for FFT (power of 2)
%FFT_pts = 2 .^ floor(log2(size(originalImage)));
FFT_pts = 2 .^ ceil(log2(size(originalImage)));

%% Filter design
[f1,f2] = freqspace(FFT_pts,'meshgrid');
SF = sqrt(f1.^2 + f2.^2);
% Choose filter type
filterType = 'bandpass';
Hd = ones(size(f1));
cutoffFreq = 0.6;
cutoffFreq2 = 0.3;
Bandpass = Hd;
Lowpass = Hd;
Highpass = Hd;
Bandpass((SF < cutoffFreq2) | (SF > cutoffFreq)) = 0;
Lowpass(SF > cutoffFreq) = 0;
Highpass(SF < cutoffFreq) = 0;
%% Display parameters
show_log_amp = true; % flag to show log SF spectrum instead of SF spectrum
min_amp_to_show = 10 ^ -10; % small positive value to replace 0 for log SF spectrum
switch filterType
    case 'lowpass'
        filt = Lowpass;
    case 'bandpass'
        % SF-bandpass and orientation-unselective filter
        filt = Bandpass;
    case 'highpass'
        filt = Highpass;
end

% Perform the filtering operation in Fourier Domain
filteredFFT = filt .* originalFFT; % SF filtering
filteredImage = real(ifft2(ifftshift(filteredFFT))); % IFFT
filteredImage = filteredImage(1: size(originalImage, 1), 1: size(originalImage, 2));
filteredFFT = fftshift(fft2(filteredImage));
filteredFFT = abs(filteredFFT);
%%
figure(1);
colormap gray;
% original image
subplot(2, 3, 1);
imagesc(originalImage);
colorbar;
axis square;
set(gca, 'TickDir', 'out');
title('original image');
xlabel('x');
ylabel('y');