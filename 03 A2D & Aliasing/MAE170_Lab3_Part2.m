%% Parameters to set
T = 5; % Total sampling time in seconds
fs = 10000; % Hz
Vmin = -0.01; % minimum Y value to graph
Vmax = 5.1; % maximum Y value to graph
 
% create the serial object 's'
% you must replace the port name with the port on your machine
% you can find this through the pico interface (tools->port)
% the baud rate must match what you selected in your serial read ...
% pico code
% port_num = serialportlist; % Creates a list of active serial ports

s = serialport("COMX",115200); % Replace COMX with your pico's COM port
flush(s); % Clear buffers on serial object
 
%% Main code
figure(01); % setup figure 01

tic;
% while toc < (T+1)
    
    flag=0; %set flag for timer
    i=1; % set sample counter
    dt_set=1/fs; % set time step target, 
    timer=0; % initialize timer
    L=T*fs*2; % oversized vector length 
    time=zeros(L,1); % initialize time vector
    voltage=zeros(L,1); % initialize amplitude vector
    waittime=1; %set initial wait time before sampling in seconds
    t0 = [];
    
    while toc<waittime % read and dump serial data until wait time is reached
        pause(waittime);
        flush(s);
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

    % --- fast acquisition loop ---
    % Instead of reading one line at a time (readline() is too slow to
    % keep up with the Pico on its own), we grab however many bytes are
    % sitting in the buffer RIGHT NOW in a single read() call, then
    % parse every complete line in that chunk in one sscanf() call.
    leftover = '';       % holds any partial (incomplete) line between reads
    plot_dt = 0.05;        % only redraw the plot ~20 times/sec (not every sample)
    last_plot = 0;
    tic; % re-start timer to use for plot throttling
    while flag == 0
        nbytes = s.NumBytesAvailable;
        if nbytes == 0
            continue % nothing new yet, check again
        end
 
        raw = [leftover, read(s, nbytes, "char")]; % char array of everything available
 
        lastNL = find(raw == newline, 1, 'last');
        if isempty(lastNL)
            leftover = raw; % no complete line yet, keep waiting for more
            continue
        end
        leftover = raw(lastNL+1:end);   % save any partial trailing line for next pass
        chunk = raw(1:lastNL);           % only complete lines
 
        % parse every "adc, time_us" line in the chunk at once
        vals = sscanf(chunk, '%f, %f\n');
        vals = vals(1:2*floor(numel(vals)/2)); % drop a stray unpaired value, if any
        a_all = vals(1:2:end);
        t_all = vals(2:2:end) / 1E6; % convert microseconds to seconds
 
        if isempty(t0)
            t0 = t_all(1);
        end
 
        % keep only samples spaced by at least dt_set 
        for k = 1:numel(t_all)
            if (t_all(k) - timer) > dt_set
                time(i) = t_all(k) - t0; % time relative to first sample
                voltage(i) = a_all(k) * 3.3/(2^10 - 1); % convert to full scale voltage
                timer = t_all(k);
                i = i + 1;
 
                if t_all(k) > (T + t0) % condition to end loop when end time is reached
                    flag = 1;
                    break
                end
            end
        end
 
        % update the plot, but only every plot_dt seconds - not every sample
        if (toc - last_plot) > plot_dt || flag == 1
            plothandle.XData = time(2:max(i-1,2));
            plothandle.YData = voltage(2:max(i-1,2));
            drawnow limitrate; % draw the figure now- live update plot
            last_plot = toc;
        end
    end

    
    reps=i-1;
    time = time(1:reps); % setup a vector for time
    voltage = voltage(1:reps); % match length of voltage vector
    dt_avg = mean(diff(time)); % find the average time interval between samples
    fs_avg=1/dt_avg; % calculate the average sampling frequency from dt_avg
    title(['sampled data: f_{s,average}=' num2str(round(fs_avg)) ' Hz']); % set title as sampling rate
    drawnow;

    %% close serial object
    s.setDTR(false); % this line allows matlab to break connection without waiting for pico
                          % to respond in a way the pico isn't looking
                          % for0.0.
    clear s; % delete dataLogger variable so you can use the com port again
   
    %% Save and wrapup
    filename = sprintf('lab3_part2_%s',datetime('now','Format',"yyyy-MM-dd-HH-mm-ss"));
    save([filename, '.mat'], 'time','voltage'); % save time and voltage to mat file
    csvwrite([filename, '.csv'],[time, voltage]); % save time and voltage to csv file
    saveas(gcf,filename); % save figure



    disp('Part 2 Capture complete')

% end