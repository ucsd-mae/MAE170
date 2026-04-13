Fs = 400; % dummy sampling rate of 400 Hz
time = (0:1/Fs:1); % Time vector for 1 second at sampling frequency Fs
signal = sin(2*pi*30*time); % Sin wave signal at 30 Hz

% Comment out lines above and set time equal to tArduino and signal equal
% to vArduino

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
reps=length(tVar); % obtain number of samples
fs=1/mean(diff(tVar)); % calculate mean sampling rate
% calculate oscilloscope signal PSD
[PSD,f_psd] = periodogram(yVar,...
    rectwin(reps),reps,fs,'onesided');

frequencyVar = f_psd;
amplitudeVar = sqrt(PSD);
end
