 %% Parameters to set
sampleT=0.25;%Set sampling time in seconds
 
% create the serial object 'dataLogger'
% you must replace the port name with the port on your machine
% you can find this through the pico interface (tools->port)

dataLogger=serialport("COMX",115200); %Connect to pico, replace COM_NAME with COM port

pause(0.25);

%% Read oscilloscope data
[vOscope,tOscope]=oscread();
   
%% Pico data capture
i=1; % keep track of number of samples ingested
flag=0; % flag when enough samples have been ingested
t0 = []; % placeholder for initial time value to reference time to
leftover = ''; % placeholder for any uningested string that may develop

L=sampleT*2e4*2; % oversized vector length 
tPico=zeros(L,1); % initialize time vector
vPico=zeros(L,1); % initialize amplitude vector

    % --- fast acquisition loop ---
    % Instead of reading one line at a time (readline() is too slow to
    % keep up with the Pico on its own), we grab however many bytes are
    % sitting in the buffer RIGHT NOW in a single read() call, then
    % parse every complete line in that chunk in one sscanf() call.
    leftover = '';       % holds any partial (incomplete) line between reads

    dataLogger.flush();
    readline(dataLogger); % read 1 line so that we start on a clean line
    while flag == 0
        nbytes = dataLogger.NumBytesAvailable;
        if nbytes == 0
            continue % nothing new yet, check again
        end
 
        raw = [leftover, read(dataLogger, nbytes, "char")]; % char array of everything available
 
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
 
 
        for k = 1:numel(t_all)
            tPico(i) = t_all(k) - t0; % time relative to first sample
            vPico(i) = a_all(k) * 3.3/(2^10 - 1); % convert to full scale voltage
            timer = t_all(k);
            i = i + 1;

            if t_all(k) > (sampleT + t0) % condition to end loop when end time is reached
                flag = 1;
                break
            end
        end
    end

    % trim oversized vectors
    tPico = tPico(1:i-1);
    vPico = vPico(1:i-1);



%% Disconnect pico
dataLogger.setDTR(false); % this line allows matlab to break connection without waiting for pico
                          % to respond in a way the pico  isn't looking
                          % for.
clear dataLogger; % delete dataLogger variable so you can use the com port again
disp('Part 3 Capture complete')

%% Save data
filename = sprintf('FREQUENCYHERE_lab3_part3_%s',datetime('now','Format',"yyyy-MM-dd-HH-mm-ss"));
save([filename, '.mat']); % saves the whole workspace



%% Extended memory oscope capture
function [wave,time] = oscread()
    %% Config
    chan        = 1;
    memDepth    = "NORMal";     % "NORMal" or "LONG"
    readTimeout = 3;         % s
    
    list = visadevlist;
    for i=1:height(list)
        c = char(list{i,1});
        if c(1:4) == 'USB0'
            j = i;
        end
    end

    oscObj = visadev(list{j,1});
    oscObj.Timeout = readTimeout;
    
    writeline(oscObj, ":ACQuire:NORM");
    writeline(oscObj, ":ACQuire:MEMDepth " + memDepth);   % set while running if the scope rejects it when stopped
    writeline(oscObj, ":WAVeform:POINts:MODE RAW");
    writeline(oscObj, ":STOP");
    
    flush(oscObj);
    pause(0.25);
    writeline(oscObj, ":WAVeform:DATA? CHANnel" + chan);
    raw = read(oscObj, 3064);    

    writeline(oscObj, ":RUN");
    
    % scaling: query the preamble-type values rather than assuming 25 codes/div
    vscale  = str2double(writeread(oscObj, ":CHANnel"+chan+":SCALe?"));
    voffset = str2double(writeread(oscObj, ":CHANnel"+chan+":OFFSet?"));
    fs      = str2double(writeread(oscObj, ":ACQuire:SAMPlingrate? CHANnel"+chan)); 
    
    wave = ((125 - double(raw(64:end)))*vscale/25 - voffset).';       % check sign convention of offset against your screen
    time = ((0:numel(wave)-1)/fs).';
    clear oscObj list; % clear oscilloscope object
end