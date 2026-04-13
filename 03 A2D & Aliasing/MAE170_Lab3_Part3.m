 %% Parameters to set
sampleT=1;%Set sampling time in seconds
 
% create the serial object 'dataLogger'
% you must replace the port name with the port on your machine
% you can find this through the arduino interface (tools->port)
% the baud rate must match what you selected in your serial read ...
% Ardino code
dataLogger=serialport("COMX",115200); %Connect to arduino, replace COM_NAME with COM port

dataLogger.flush();
for i=1:10
    readline(dataLogger);
end
%% Read oscilloscope data
[vOscope,tOscope]=oscread();
   
%% Arduino data capture
newV=0;%intialize variables
newT=0;%intialize variables
tempText=readline(dataLogger);
startV = str2double(extractBefore(tempText,','));
startT = str2double(strtrim(extractAfter(tempText,',')));
vArduino = [startV*5.0/1023];
tArduino = [0];
while newT<sampleT
    tempText=readline(dataLogger);
    newV=str2double(extractBefore(tempText,','))*5.0/1023;
    newT=(str2double(strtrim(extractAfter(tempText,',')))-startT)/1E6;
    vArduino = [vArduino newV];
    tArduino = [tArduino newT];
end

%%
filename = sprintf('FREQUENCYHERE_lab3_part3_%s',datetime('now','Format',"yyyy-MM-dd-HH-mm-ss"));
save([filename, '.mat']); % saves the whole workspace

dataLogger.setDTR(false); % this line allows matlab to break connection without waiting for arduino
                          % to respond in a way the arduino isn't looking
                          % for0.0.
clear dataLogger; % delete dataLogger variable so you can use the com port again
disp('Part 3 Capture complete')

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
