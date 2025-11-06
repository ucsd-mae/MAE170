close all;
clear;
clc;

%%
maxTemp = 35; % max temperature to achieve, in Celsius
avg=3; % number of repetitions

%%
for av = 1:avg
    
    % connect to arduino
    disp('Connecting to Arduino...');
    s = serialport("COMX", 9600);
    pause(3);

    % initialize temperature and time vectors, loop counter
    tempPlateC = [];
    tempAmbC = [];
    time = [];
    i = 1;
    
    % send signal to arduino to begin routine
    writeline(s, string(maxTemp));
    disp('Waiting for cycle to begin...');
    pause(3);
    figure(01);
    disp(['Beginning cycle ' num2str(av)])

    while true
        % read data being sent from Arduino while test is running
        out = char(readline(s));
        
        % check for special case where Arduino sends completion flag
        % in order to break out of the while loop
        if out(1) == 'C'
            break
        end

        % parse the string sent by Arduino into Tplate, Tamb and millis 
        index1 = find(out==',',1);
        index2 = find(out==';',1);
        tPlate = str2double(out(1:index1-1));
        tAmb = str2double(out(index1+1:index2-1));
        milli = str2double(out(index2+1:end)) / 1E3;
    
        % append latest datapoint to vectors
        time(i) = milli;
        tempPlateC(i) = tPlate;
        tempAmbC(i) = tAmb;

        % plot latest data
        plot(time, tempPlateC, '-or', time, tempAmbC, '-ob')
        xlabel('Time (s)');
        ylabel('Temperature (C)');
        ylim([15 maxTemp+5]);
        title(['Convection over flat plate Iteration ' num2str(av)]);
        legend('Plate', 'Ambient')
        drawnow()
        
        % increment loop counter
        i = i + 1;
    end
    
    % save data for this iteration
    disp('Cycle Complete! Saving Data...')
    n = convertTo(datetime("now"), 'posixtime');
    save(['lab6' 'Average' num2str(av) '-' ...
        num2str(floor(n)) '.mat']);
    
    clear tempPlateC tempAmbC time s;
    close;

    if av ~= avg
        % Pause time is required to ensure that the Arduino has enough
        % time to reenter standby mode & be ready to receive the command
        % to begin the next cycle. 
        disp('Waiting for test to reset...')
        pause(2);
        disp('Next cycle will begin in 5 seconds...')
        disp(' ')
        pause(5);
    end

end
disp('Test Complete!')