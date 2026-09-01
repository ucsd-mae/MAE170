Fs = 400; % dummy sampling rate of 400 Hz
time = (0:1/Fs:1); % Time vector for 1 second at sampling frequency Fs
signal = sin(2*pi*30*time); % Sine wave signal at 30 Hz

% Comment out lines above and set time equal to tPico and signal equal
% to vPico


figure(1);
plot(time, signal,'-ob','LineWidth',2,'MarkerSize',4);
set(gca,'FontSize',22,'LineWidth',2);
xlabel('time (s)')
ylabel('Amplitude (a.u.)');

[freq, amp]=MAE170fft(time, signal); % 

figure(2)
plot(freq, amp,'-ob','LineWidth',2,'MarkerSize',4);
set(gca,'FontSize',22,'LineWidth',2);
xlabel('frequency [Hz]')
ylabel('|FT|');

%% Save and wrapup
filename = sprintf('lab3_fft_%s',datetime('now','Format',"yyyy-MM-dd-HH-mm-ss"));
save([filename, '.mat']); % save time and voltage to mat file
saveas(gcf,filename); % save figure


%% FFT function
function [frequencyVar, amplitudeVar] = MAE170fft(tVar, yVar)
    % to account for jitter in serial transfer induced delay in pico sample
    % rate, we use the non-uniform fourier transform to analyze our data. 
    % to account for the behavior of frequency analysis via non-uniform
    % fourier transform, we map our resultant data onto the periodogram
    % power spectral graph by folding the results above the nyquist
    % frequency onto the lower frequencies.
    reps=length(tVar); % obtain number of samples
    fs=1/mean(diff(tVar)); % calculate mean sampling rate
    % calculate oscilloscope signal PSD
    PSD = nufft(yVar, tVar*fs);
    % look at all frequencies up to nyquist frequency
    frequencyVar = (0:floor(reps/2) - 1)/reps * fs;
    amplitudeVar = abs(PSD(1:floor(reps/2))); 
    % fold the frequencies from the nyquist frequency up to the end over
    % onto the lower frequency space.
    % this is analagous to using a 'onesided' frequency range in the
    % periodogram function 
    % https://www.mathworks.com/help/signal/ref/periodogram.html#mw_f2a46c4b-836f-4aca-9c1d-a9066d72b2b8
    amplitudeVar = amplitudeVar + flip(paddata(abs((PSD(floor(reps/2)+2:end))), length(amplitudeVar)));
end
