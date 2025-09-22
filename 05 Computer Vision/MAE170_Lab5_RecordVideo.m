%% Motor Control & Video Recording Script
close all;
clear all;
clc;
instrreset;
%%
workingDir = pwd; % set the working directory to the current directory
frames = 200; % set the number of frames to record
 
%% same as previous script
cam=webcam(1); % selects the webcam
cam.Exposure=0; % sets camera exposure to default
cam.Exposure=-2; % sets exposure time (more negative value results in a shorter exposure)
cam.Gain=220; % set the internal amplification of the signal measured for each pixel
cam % displays the webcam settings
preview(cam); 
%% new content -- record video
closePreview(cam);
t = char(datetime('now','Format','hh_mm_ss')); % creating unique timestamp
vidname = ['recorded_video_' t '.avi'];
v_write = VideoWriter(vidname); % define the filename, and setup the video writer
open(v_write); % open the video writer
 
s = serialport("COMX",9600); % open object for your arduino
 
pause(5); % pause for 5 seconds while the serial object is opened
 
writeline(s,'255'); % write motor driving speed
 
for i = 1:frames % Create a loop to acquire each frame
    img = snapshot(cam);
    writeVideo(v_write,img);
end
 
writeline(s,'0'); % turn off motor
flush(s,"output");
clear s; % close serial object
 
close(v_write); % close the video writer