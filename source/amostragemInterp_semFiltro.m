% This function subsamples by a factor k a non compressed audio file
% and interpolates it by the same factor to reset the number of samples 
% (to allow computing the SNR)
% Does not use pre filtering. 
% Based on down4up4_nofilt de Yao Wang, Polytechnic University, 1/11/2004
% 
% Esta funcao faz a sub-amostragem de um ficheiro de audio nao comprimido
%por um factor k e a sua interpolacao pelo mesmo factor para repor o
%numero de amostras. A interpolacao e feita pela repeticaoo de cada amostra k vezes.
% Nao utiliza pre-filtragem.
% Baseado em down4up4_nofilt de Yao Wang, Polytechnic University, 1/11/2004

function[]=amostragemInterp_semFiltro(ficheiroOriginal,ficheiroInterpolado,k)

fprintf('\n Importing the original audio\n');
[y,fs]=audioread(ficheiroOriginal);

%verificar numero de canais (estereo ou mono). Se estereo, usar apenas um
%canal (adicionado em Fev 2022)
info=audioinfo(ficheiroOriginal);
if info.NumChannels>1
    y=y(:,1);
end

% display the information of original audio
info

% tornar a sequencia multipla de k
orig_length=length(y); N=floor(orig_length/k)*k; y = y(1:N);
% display the length of original audio as a multiple of k
fprintf('\n the number of samples in the original audio: ') 
N

% tocar a musica original e mostrar a sua forma de onda
sound(y,fs); %plays the sound
figure(1);
subplot(1,3,1), bar(y(2000:2060),0.02), title('original waveform in [0.0417s, 0.0429s]'); % shows values of the 
% samples of the signal, between instant 0.0417s and 0.0429s
% note that the sample values may have negative values. A reasonable representation to choose is to
% consider the ambient pressure zero, with higher and lower pressures being positive and negative.
% Another reasonable representation is to take ambient pressure as half-scale, with lower pressures 
% below and higher pressures above half. Remember that Sound is fundamentally a pressure wave,
% made up of "peaks" which are regions of pressure higher than the ambient pressure and "troughs" 
% which are regions of pressure lower than the ambient pressure. Whether a signed or unsigned 
% representation is used is only a matter of history and convention. 16-bit audio is usually 
% represented as signed but 8-bit audio is usually not.

axis tight; % sets the axis limits to the range of the data.

% constroi e mostra o espectro do sinal de som usando freqz
npfft=4096; %nº de pontos para o espectro
T=1/fs;
t=[0:T:0.04-T]; % 40 milissegundos de sinal correspondentes a 1920 amostras
[H, W] = freqz(y, 1.0, npfft, fs); 
subplot(1,3,2), plot(W, abs(H));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Spectrum of original audio');
% mostrar forma de onda completa
samples=[0:length(y)-1];
subplot(1,3,3), plot(samples/fs, y);
xlabel('Time (s)');
ylabel('Amplitude');
title('complete waveform of original audio');

fprintf('\n Press a key to continue\n');
pause

% sub-amostragem sem filtro: reter uma em cada k amostras
fprintf('\n The subsampled audio\n');
x=zeros(N/k,1);

x=y(1:k:N);

% display the length of subsampled audio
fprintf('\n the number of samples in the subsampled audio: ') 
length(x)

% save the subsampled audio
audiowrite('Mozart10secSubSampled.wav',x,fs/k);

%reproduzir e mostrar o som sub-amostrado
sound(x,fs/k);
figure(2);
subplot(1,3,1),bar(x(2000/k:2060/k),0.02);
axis tight;
title('Subsampled audio in in [0.0417s, 0.0429s]');
%mostrar o espectro
npfft=2048;
T=1/fs;
t=[0:T:0.04-T]; % 40 milissegundos de sinal
[H, W] = freqz(x, 1.0, npfft, fs); 
subplot(1,3,2), plot(W, abs(H));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Spectrum of the subsampled audio');
% mostrar forma de onda completa
samples=[0:length(x)-1];
subplot(1,3,3), plot(samples/(fs/k), x);
xlabel('Time (s)');
ylabel('Amplitude');
title('complete subsampled waveform');

fprintf('\n Carregue numa tecla para continuar\n');
pause

%interpolacao para repor numero de amostras (repete k vezes cada amostra)
fprintf('\n The interpolated sound\n');
z=zeros(N,1);
%copia cada amostra de x para z k vezes cada
for(i=0:1:k-1)
    z(1+i:k:N)=x;
end

% display the length of interpolated audio
fprintf('\n the number of samples in the interpolated audio: ') 
length(z)

% save the interpolated audio
audiowrite('Mozart10secInterpolated.wav', z,fs);


%toca e mostra o som interpolado
sound(z,fs);
figure(3);
subplot(1,3,1),bar(z(2000:2060),0.02);
axis tight;
title('interpolated waveform in [0.0417s, 0.0429s]');
%mostrar o espectro
npfft=2048;
T=1/fs;
t=[0:T:0.04-T]; % 40 milissegundos de sinal
[H, W] = freqz(z, 1.0, npfft, fs); 
subplot(1,3,2), plot(W, abs(H));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Spectrum of the interpolated audio');
% mostrar forma de onda completa
samples=[0:length(z)-1];
subplot(1,3,3), plot(samples/fs, z);
xlabel('Time (s)');
ylabel('Amplitude');
title('complete interpolated waveform');

fprintf('\n Carregue numa tecla para continuar\n');
pause

%guarda sinal interpolado
audiowrite(ficheiroInterpolado,z,fs);

% Calcular o erro quadratico medio MSE e PSNR (Peak Signal to Noise Ratio)
% usa apenas as N amostras do sinal original, N multiplo de k
crop=y(1:1:N);
D=crop-z;
MSE=mean(D.^2);
MSE2 = sum(sum((crop - z).^2))/N;
MAXy=max(y);
PSNR = 10*log10((double(MAXy^2))/MSE2);
fprintf('\nErro entre o sinal original e o interpolado = %g\n\n',MSE);
fprintf('\nPSNR do sinal interpolado = %g\n\n',PSNR);

