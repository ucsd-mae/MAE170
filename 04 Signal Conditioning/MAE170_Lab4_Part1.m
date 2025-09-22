clc;
clear;
close all;
 
%% Parameters to set
T = 2; % Total sampling time in seconds
fs = 1000; % sampling frequency target in Hz
cutFreq = 1; % insert your calculated cutoff frequency here
f_min=1; % minimum frequency to be characterized in Hz
f_max=2*cutFreq; % maximmum frequency to be characterized in Hz
f_step=1; % frequency step in Hz
%%
 
f_vec=f_min:f_step:f_max; % initialize vector for frequency sweep
transfer_vec=zeros(length(f_vec),1); % initialize transfer function vector
 
list = visadevlist;
for i=1:height(list)
    c = char(list{i,1});
    if c(1:4) == 'USB0'
        j = i;
    end
end
v = visadev(list{j,1});
writeline(v,"OUTP:LOAD INF");
    
% open object for your "read" arduino
s_read = serialport("COMX",115200); % insert COM port number

for j=1:length(f_vec) % loop over each frequency to be tested
    
    % create the serial objects 
    % you must replace the port name with the port on your machine
    % you can find this through the arduino interface (tools->port)
    % the baud rate must match what you selected in your serial read ...
    % Ardino code
    
    % the first serial object, s_gen, corresponds to the Arduino acting ...
    % as your signal generator
    % the second serial object, s_read, corresponds to the Arduino ...
    % acting as your oscilloscope
    
    % THIS IS FOR EXTRA CREDIT
    % open object for your signal generator arduino
    % this segment sets the frequency of the generated signal
    % s_gen = serialport('COM11',115200); % opens serial connect at specified baud rate
    % pause(5); % pause for 5 seconds while the serial object is opened
    % writeline(s_gen,'%s',int2str(f_vec(j))); % write the signal frequency
    % pause(2);
  
    writeline(v,"APPLy:SIN " + int2str(f_vec(j)) + ",2,1.25"); % sending over a wave

        
    flag=0; %set flag for timer
    i=1; % set sample counter
    dt_set=1/fs; % set time step target
    timer=0; % initialize timer
    L=T*fs*2; % oversized vector length
    time=zeros(L,1); % initialize time vector
    A=zeros(L,1); % initialize amplitude vector
    A_ref=zeros(L,1);
    waittime=.5; %set initial wait time before sampling in seconds
    t=0; % initialize time variable
    ind=0; % initialize index variable
    ind_ref=0;
    a=0; % initialize amplitude variable
    a_ref=0;
    dump=''; % initialize text dump variable
    out=''; % initialize serial output string variable
    tic; % start timer
    
    while toc<waittime % read and dump serial data until wait time is reached
        dump=readline(s_read);
    end
    
    while flag==0
        out=char(readline(s_read)); % reading the serial port
        ind_ref=find(out==',',1); % find index of comma
        ind=find(out==';',1); % find index of semi-colon
        a_ref=str2double(out(1:ind_ref-1)); % get amplitude of output signal
        % get amplitude of reference signal
        a=str2double(strtrim(out(ind_ref+1:ind-1))); 
        t=str2double(strtrim(out(ind+1:end)))/1E6; % get time
        % condition to take sample at set sampling rate
        if (t-timer)>dt_set 
            time(i) = t; % establishing time steps for sampling frequency
            A(i)=a; % add signal amplitude to signal amplitude vector
            A_ref(i)=a_ref; % add reference amplitude to vector
            timer=time(i);
            i=i+1;
            % condition to end loop when end time is reached
            if t>(T+time(1))
                flag=1;
            end
        end
    end
        
    reps=i-1; % get number of samples acquired
    time = time(1:reps)-time(1); % setup a vector for time
    % convert serial amplitude to voltage
    voltage = 5/1023*A(1:reps); 
    % convert serial amplitude to voltage for reference signal
    voltage_ref = 5/1023*A_ref(1:reps); 
    % find the average time interval between samples
    dt_avg = mean(diff(time)); 
    fs_avg=1/dt_avg; % calculate the average sampling frequency from dt_avg
    
    
    %% Create plot
    figure(01); % setup figure 01
% plot time vs. voltage for output signal
    subplot(221)
    plot(time, voltage(1:reps),'-o','LineWidth',2,'MarkerSize',4);
    xlabel('time (s)'); % x-axis label name
    ylabel('voltage (V)'); % y-axis label name
    ylim([min(voltage)-abs(0.1*max(voltage)) ...
        max(voltage)+abs(0.1*max(voltage))]); % set y plot range
    title(['f_{s,average}=' num2str(round(fs_avg)) ' Hz']); % set title as sampling rate
    
    % get current plot axes, set font and line width
    set(gca,'FontSize',22,'LineWidth',2);
    set(gcf, 'units', 'normalized'); % set plot sizing to normalized units
    
    % plot time vs. voltage for reference signal
    subplot(222)
    plot(time, voltage_ref(1:reps),'-ok','LineWidth',2,'MarkerSize',4);
    xlabel('time (s)'); % x-axis label name
    ylabel('voltage (V)'); % y-axis label name
    ylim([min(voltage_ref)-abs(0.1*max(voltage_ref)) ...
        max(voltage_ref)+abs(0.1*max(voltage_ref))]); % set y plot range
    title('Reference signal'); % set title as sampling rate
    
    % get current plot axes, set font and line width
    set(gca,'FontSize',22,'LineWidth',2);
    set(gcf, 'units', 'normalized'); % set plot sizing to normalized units
    
    % calculate Power spectral density (PSD) for the output signal
    [PSD,f_psd] = periodogram(voltage-mean(voltage),rectwin(reps),...
        reps,fs_avg,'onesided');
    FT=sqrt(PSD); % convert Arduino PSD to Fourier magnitude
    
    [FT_max,ind_max]=max(FT); % find the maximum of the output signal FT
    
    % calculate Power spectral density (PSD) for the reference signal
    [PSD_ref,f_psd] = periodogram(...
        voltage_ref-mean(voltage_ref),rectwin(reps),...
        reps,fs_avg,'onesided');
    FT_ref=sqrt(PSD_ref); % convert Arduino PSD to Fourier magnitude
    
    % find the maximum of the reference signal FT
    [FT_max_ref,ind_max_ref]=max(FT_ref);
    
    % calculate the transfer function value at this frequency
    % e.g. the output divided by the input
    transfer_vec(j)=FT_max/FT_max_ref; 
    
    % plot the FT spectra for the output and reference signals
    subplot(223)
    plot(f_psd,FT_ref,'k-o',f_psd(ind_max_ref),FT_max_ref,'gx',...
        f_psd,FT,'b-o',f_psd(ind_max),FT_max,'rx',...
        'LineWidth',2,'MarkerSize',4);
    xlabel('frequency (Hz)'); % x-axis label name
    ylabel('|FT|'); % y-axis label name
    title(['FFT of AC signals (f_{in}=' int2str(f_vec(j)) ' Hz)']); % set title as sampling rate
    xlim([0 f_max*2]);
    
    % get current plot axes, set font and line width
    set(gca,'FontSize',22,'LineWidth',2);
    set(gcf, 'units', 'normalized'); % set plot sizing to normalized units
    
    % plot the transfer function
    subplot(224)
    plot(f_vec,transfer_vec,'r-o','LineWidth',2,'MarkerSize',4);
xlabel('frequency (Hz)'); % x-axis label name
    ylabel('|FT|_{max}/|FT|_{max,ref}'); % y-axis label name
    title('Transfer Function'); % set title as sampling rate
    xlim([f_min f_max]);
    
    % get current plot axes, set font and line width
    set(gca,'FontSize',22,'LineWidth',2);
    set(gcf, 'units', 'normalized'); % set plot sizing to normalized units
    
    % set position of figure on screen [distance from left, top, width, height]
    set(gcf, 'Position', [0.1, 0.1, .6, 0.8]);
    drawnow;
    
end

% Be sure to change filenames if you don’t want to overwrite your data!
save('MAE170_lab4','f_vec','transfer_vec'); 
% save frequency and gain to mat file
csvwrite('MAE170_lab4.csv',[f_vec',transfer_vec]);
% save frequency and gain to csv file
saveas(gcf,'MAE170_lab4');
% save figure
