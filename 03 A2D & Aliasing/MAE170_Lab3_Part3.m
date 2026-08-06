 %% Parameters to set
sampleT=1;%Set sampling time in seconds
 
% create the serial object 'dataLogger'
% you must replace the port name with the port on your machine
% you can find this through the pico interface (tools->port)

dataLogger=serialport("COMX",115200); %Connect to pico, replace COM_NAME with COM port

dataLogger.flush();
for i=1:10
    readline(dataLogger);
end
%% Read oscilloscope data
[vOscope,tOscope]=oscread();
   
%% Pico data capture
newV=0;%intialize variables
newT=0;%intialize variables
tempText=readline(dataLogger);
startV = str2double(extractBefore(tempText,','));
startT = str2double(strtrim(extractAfter(tempText,',')));
vPico = [startV*5.0/1023];
tPico = [0];
while newT<sampleT
    tempText=readline(dataLogger);
    newV=str2double(extractBefore(tempText,','))*5.0/1023;
    newT=(str2double(strtrim(extractAfter(tempText,',')))-startT)/1E6;
    vPico = [vPico newV];
    tPico = [tPico newT];
end
%% Disconnect pico
dataLogger.setDTR(false); % this line allows matlab to break connection without waiting for pico
                          % to respond in a way the pico  isn't looking
                          % for.
clear dataLogger; % delete dataLogger variable so you can use the com port again
disp('Part 3 Capture complete')
%% Save data
filename = sprintf('FREQUENCYHERE_lab3_part3_%s',datetime('now','Format',"yyyy-MM-dd-HH-mm-ss"));
save([filename, '.mat']); % saves the whole workspace



%% may need to use tmtool to scan for oscilloscope resource
function [wave,time] = oscread()
    list = visadevlist;
    for i=1:height(list)
        c = char(list{i,1});
        if c(1:4) == 'USB0'
            j = i;
        end
    end
        
    % set oscilloscope visa object
    oscObj = visadev(list{j,1}); 
     
    writeline(oscObj,':wav:data?'); % query for data from channel 1
    data = read(oscObj,610); % read data from oscilloscope
    len = length(data);
    timebase = str2double(writeread(oscObj,':TIMebase:SCALe?')); % get timebase
    verticalscale = str2double(writeread(oscObj,':CHANnel1:SCALe?')); % get vertical scale
    verticaloffset = str2double(writeread(oscObj,':CHANnel1:OFFSet?')); % get vertical offset
    wave=(125-data(12:len-1))*verticalscale/25+verticaloffset;
     
    T=timebase*12; % calculate total time
    dt=T/length(wave); % calculate time step
    time=[0:dt:T-dt]; % setup time vector
    clear oscObj list; % clear oscilloscope object
end
