%% Parameters to set
T = 5; % Total sampling time in seconds
fs = 500; % Hz
Vmin = -0.01; % minimum Y value to graph
Vmax = 5.1; % maximum Y value to graph
 
% create the serial object 's'
% you must replace the port name with the port on your machine
% you can find this through the arduino interface (tools->port)
% the baud rate must match what you selected in your serial read ...
% Ardino code
% port_num = serialportlist; % Creates a list of active serial ports

s = serialport("COMX",115200); % Replace COMX with your Arduino's COM port
flush(s); % Clear buffers on serial object
 
%% Main code
figure(01); % setup figure 01

tic;
while toc < (T+1)
    
    flag=0; %set flag for timer
    i=1; % set sample counter
    dt_set=1/fs; % set time step target, 
    timer=0; % initialize timer
    L=T*fs*2; % oversized vector length 
    time=zeros(L,1); % initialize time vector
    voltage=zeros(L,1); % initialize amplitude vector
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

    %% Create plot
    figure(01); % setup figure 01
    % plot time vs. voltage, set plotting style to line and dots of size 8
    plothandle = plot(time, voltage,'-o','LineWidth',2,'MarkerSize',4);
    xlabel('time (s)'); % x-axis label name
    ylabel('voltage (V)'); % y-axis label name

    xlim([0 T]); % bound x to sample time
    ylim([Vmin, Vmax]); % set y plot range
    title('sampling data...'); % set title as sampling rate
    
    % get current plot axes, set font and line width
    set(gca,'FontSize',22,'LineWidth',2);
    set(gcf, 'units', 'normalized'); % set plot sizing to normalized units
    hold on;
    drawnow;

    
    while flag==0
        out = readline(s);
        out = char(out);
        ind=find(out==',',1);
        a=str2double(out(1:ind-1));
        t=str2double(out(ind+2:end))/1E6;
        if (t-timer)>dt_set % condition to take sample at set sampling rate
            time(i) = t - time(1); % establishing time steps for sampling frequency
            voltage(i)=a * 5/1023; % convert to full scale voltage
            timer=t;
            i=i+1;
            if t>(T+time(1)) % condition to end loop when end time is reached
                flag=1;
            end
        end
        plothandle.XData = time(2:i-1); %update plot data with new time vals
        plothandle.YData = voltage(2:i-1); % update plot data with new volt vals
        drawnow limitrate; % draw the figure now- live update plot
    end

    
    reps=i-1;
    time = time(1:reps); % setup a vector for time
    voltage = voltage(1:reps); % match length of voltage vector
    dt_avg = time(end)/reps; % find the average time interval between samples
    fs_avg=1/dt_avg; % calculate the average sampling frequency from dt_avg
    title(['sampled data: f_{s,average}=' num2str(round(fs_avg)) ' Hz']); % set title as sampling rate
    drawnow;

    %% close serial object
    s.setDTR(false); % this line allows matlab to break connection without waiting for arduino
                          % to respond in a way the arduino isn't looking
                          % for0.0.
    clear s; % delete dataLogger variable so you can use the com port again
   
    %% Save and wrapup
    filename = sprintf('lab3_part2_%s',datetime('now','Format',"yyyy-MM-dd-HH-mm-ss"));
    save([filename, '.mat'], 'time','voltage'); % save time and voltage to mat file
    csvwrite([filename, '.csv'],[time, voltage]); % save time and voltage to csv file
    saveas(gcf,filename); % save figure



    disp('Part 2 Capture complete')

end