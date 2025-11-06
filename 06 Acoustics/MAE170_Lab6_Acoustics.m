%%
clc;
clear;
close all;
instrreset;
warning('off','all');
%% parameters to set
f_tone = 5E3; % frequency of tone to be generated [Hz]
pointsx=1; % number of points x axis to scan
pointsy=1; % number of points y axis to scan
Navg=64; % number of averages
move=10; % distance per step (spatial resolution) [mm]
TmLong=4; % move time long [s]
TmShort=1; % move time short [s]
%% setup recording matrix, gcode initial properties, and open serial objects

% [EDIT THESE COM PORT VALUES]
s_speaker = serialport("COMX",115200); % Serialport connection
% create serial object for speaker Arduino
s_move = serialport("COMX",115200);
% create serial object for Rambo Arduino

disp('Connecting to Arduino & RAMBo...')
pause(3); %initial pause for Rambo
disp('Connected!')

writeline(s_move,'G90'); % set movement to be in absolute coordinates
writeline(s_move,'G92 X0 Y0'); % set current position as origin
writeline(s_move,'G0 F6000'); % set move speed

% writeline(s_move,'G0 Y0 X0'); % backup line to move back to origin
% writeline(s_move,'G0 Y150 X300'); % backup line to move to nearest to speaker position

x=(0:pointsx-1)*move; % create the x movement vector [mm]
y=(0:pointsy-1)*move; % create the y movement vector [mm]

%% Initialize Oscope, Acquire signal to initialize vectors
buffer_size=600; % buffer size

% set up Oscilloscope
list = visadevlist;
for i=1:height(list)
    c = char(list{i,1});
    if c(1:4) == 'USB0'
        j = i;
    end
end
oscObj = visadev(list{j,1});

% [EDIT THE FOLLOWING PARAMETERS BASED ON THE LAB PROCEDURE]
verticalscale1 = .050; % channel 1 vertical scale [V]
verticalscale2 = .020; % channel 2 vertical scale [V]
timebase = 0.0005; % specified timescale [s]
time_offset = .002; % specified time offset [s]

verticaloffset1 = 0; % channel 1 vertical offset [V]
verticaloffset2 = 0; % channel 2 vertical offset [V]

% set oscilloscope properties
write(oscObj, ":CHAN1:SCAL " + verticalscale1);
write(oscObj, ":CHAN2:SCAL " + verticalscale2);
write(oscObj, ":CHAN1:OFFS " + verticaloffset1);
write(oscObj, ":CHAN2:OFFS " + verticaloffset2);
write(oscObj, ":TIMebase:SCALe " + timebase);
write(oscObj, ":TIMebase:OFFSet " + time_offset);

write(oscObj,':wav:data? CHAN1'); % acquire dummy signal to get time vector length

data=read(oscObj, buffer_size, 'uint8');
len=length(data);
wave=data(12:len-1)';
mylen=length(wave);

recMatrix_ref=zeros(mylen,pointsx,pointsy); % initialize recording matrix for sweep
recMatrix_sig=zeros(mylen,pointsx,pointsy); % initialize recording matrix for sweep

T=timebase*12; % calculate total time
dt=T/mylen; % calculate time step
t=0:dt:T-dt; % setup time vector

figure(01); % open a figure
%% Main loop
for i=1:pointsx
    % flip the Y-coordinate array if in an odd X row (return zag)
    if mod(i,2) == 1
        j_array = flip(1:pointsy);
    else
        j_array = 1:pointsy;
    end
    for q=1:pointsy
        j = j_array(q);

        % tell Rambo Arduino to move to measurement position
        writeline(s_move, "G0 Y" + y(j) + " X" + x(i));
        if i == 1 && q == 1
            % additional pause for first movement out
            pause(TmLong);
        end

        for k=1:Navg
            pause(.1*rand); % pause for random time from 0 -> .1 s
            writeline(s_speaker,int2str(f_tone));
            pause(TmShort);
            if k==1 && i==1 && q==1
                pause(1); % pause additional second for the first datapoint
                          % this prevents getting a bad first set of signals
            end
            % write the signal frequency % play 10 cycle, 5 kHz tone
            writeline(oscObj,':wav:data? CHAN1'); % get data from ch1 oscilloscope
            data_ref = read(oscObj, buffer_size, 'uint8');

            pause(0.01); % brief pause in between write/reads to ensure both channels update
            
            writeline(oscObj,':wav:data? CHAN2'); % get data from ch2 oscilloscope
            data_sig = read(oscObj, buffer_size, 'uint8');
    	    wave_ref=(125-data_ref(12:len-1)')*verticalscale1/25-verticaloffset1;
    	    wave_sig=(125-data_sig(12:len-1)')*verticalscale2/25-verticaloffset2;

            % measured data of running averages at each measurement location
            recMatrix_ref(:,i,j)=(recMatrix_ref(:,i,j)*(k-1)+wave_ref)/k;
            recMatrix_sig(:,i,j)=(recMatrix_sig(:,i,j)*(k-1)+wave_sig)/k;

            % plotting
            subplot(311)
            plot(t*1e3,wave_ref/max(abs(wave_ref)),'-o',...
                t*1e3,wave_sig/max(abs(wave_sig)),'-o',...
                'MarkerSize',2)
            xlabel('time (ms)')
            ylabel('amp. (A.U.)')
            ylim([-1.1 1.1])
            title(['Single Acq. ' num2str(k) ', Position (' num2str(i) ',' num2str(j) ')']);
            set(gca,'FontSize',20,'LineWidth',2)

            subplot(312)
            plot(t*1e3,recMatrix_ref(:,i,j),'-o',...
                'MarkerSize',2)
            xlabel('time (ms)')
            ylabel('amp. (V)')
            title('Average ref');
            set(gca,'FontSize',20,'LineWidth',2)

            subplot(313)
            plot(t*1e3,recMatrix_sig(:,i,j),'-o',...
                'MarkerSize',2)
            xlabel('time (ms)')
            ylabel('amp. (V)')
            title('Average sig');
            set(gca,'FontSize',20,'LineWidth',2)

            set(gcf, 'units', 'normalized'); % set plot sizing to normalized units
            % set position of figure on screen [distance from left, top, width, height]
            set(gcf, 'Position', [0.1, 0.1, .6, 0.8]);
            drawnow;

        end
    end
end

% pauses code execution until a button is pressed so that students
% can measure the final position 
disp('Measure the final X & Y position of the microphone, then press any button to finish.')
w = waitforbuttonpress;

% move back to beginning
writeline(s_move,'G0 X0 Y0'); % tell Rambo Arduino to move back to origin
pause(TmLong);

%% save the data and close objects
fclose(oscObj);
delete(oscObj);
clear s_move;
clear s_speaker; % close the serial connection for speaker

save(['acousticscan' num2str(floor(now*1E3)) '.mat']); % save data