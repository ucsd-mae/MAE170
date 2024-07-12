clear
close all

%%
% Connect to the Arduino
arduino = serialport('COM5', 9600);
waitTime = 300; % data collection time, in seconds

% intialize empty data arrays
t = [];
Tchb = [];
Hchb = [];
Tamb = [];
Hamb = [];


figure(1);
xlabel('Time (s)')
ylabel('%RH')
% read data from the Arduino
tic;
while toc < waitTime
    l = strtrim(readline(arduino));
    data = split(l,",");
    t 	 = [t, str2double(data(1))];
    Tchb = [Tchb , str2double(data(2))];
    Hchb = [Hchb , str2double(data(3))];
    Tamb = [Tamb , str2double(data(4))];
    Hamb = [Hamb , str2double(data(5))];
    
    plot(t, Hchb);
    hold on
    plot(t, Hamb);
    drawnow()
    hold off
end
