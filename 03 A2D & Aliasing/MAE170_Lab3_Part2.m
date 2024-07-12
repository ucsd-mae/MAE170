close all; %close all open windows
clear all; %clear all variables
clc; %clear output screen
 
%% Parameters to set
T = 5; % Total sampling time in seconds
fs = 500; % Hz
 
% create the serial object 's'
% you must replace the port name with the port on your machine
% you can find this through the arduino interface (tools->port)
% the baud rate must match what you selected in your serial read ...
% Ardino code
% port_num = serialportlist; % Creates a list of active serial ports

s = serialport("COMX",115200); % Replace COMX with your Arduino's COM port
 
%% Main code
figure(01); % setup figure 01

tic;
while toc < (T+1)
    
    flag=0; %set flag for timer
    i=1; % set sample counter
    dt_set=1/fs; % set time step target
    timer=0; % initialize timer
    L=T*fs*2; % oversized vector length 
    time=zeros(L,1); % initialize time vector
    A=zeros(L,1); % initialize amplitude vector
    waittime=1; %set initial wait time before sampling in seconds
    t=0; % initialize time variable
    ind=0; % initialize index variable
    a=0; % initialize amplitude variable
    dump=''; % initialize text dump variable
    out=''; % initialize serial output string variable
    tic; % start timer
    
    while toc<waittime % read and dump serial data until wait time is reached
        dump = readline(s);
    end
    
    while flag==0
        out = readline(s);
        out = char(out);
        ind=find(out==',',1);
        a=str2double(out(1:ind-1));
        t=str2double(out(ind+2:end))/1E6;
        if (t-timer)>dt_set % condition to take sample at set sampling rate
            time(i) = t; % establishing time steps for sampling frequency
            A(i)=a;
            timer=time(i);
            i=i+1;
            if t>(T+time(1)) % condition to end loop when end time is reached
                flag=1;
            end
        end
    end
    clear s;
    
    reps=i-1;
    time = time(1:reps)-time(1); % setup a vector for time
    voltage = 5/1023*A(1:reps); % convert serial amplitude to voltage
    dt_avg = time(end)/reps; % find the average time interval between samples
    fs_avg=1/dt_avg; % calculate the average sampling frequency from dt_avg
   
    %% Create plot
    figure(01); % setup figure 01
    % plot time vs. voltage, set plotting style to line and dots of size 8
    plot(time, voltage(1:reps),'-o','LineWidth',2,'MarkerSize',4);
    xlabel('time (s)'); % x-axis label name
    ylabel('voltage (V)'); % y-axis label name
    ylim([min(voltage)-abs(0.1*max(voltage)) ...
        max(voltage)+abs(0.1*max(voltage))]); % set y plot range
    title(['f_{s,average}=' num2str(round(fs_avg)) ' Hz']); % set title as sampling rate
    
    % get current plot axes, set font and line width
    set(gca,'FontSize',22,'LineWidth',2);
    set(gcf, 'units', 'normalized'); % set plot sizing to normalized units
    drawnow % draw the figure now

    save('MAE170_lab3part2','time','voltage'); % save time and voltage to mat file
    csvwrite('MAE170_lab3part2',[time, voltage]); % save time and voltage to csv file
    saveas(gcf,'MAE170_lab3part2'); % save figure
end
