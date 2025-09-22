workingDir = pwd; % set the working directory to the current directory
frames = 200; % set the number of frames to record
v_read = VideoReader('YOUR_VIDEO_NAME.avi'); % setup the video reader

mkdir(workingDir,'images'); % make a subfolder to store your images

for i = 1:frames % Create a loop to move through each frame
    img = readFrame(v_read); % read current frame as an image
    name = [sprintf('%03d',i) '.jpg']; % dynamically create a filename for the image
    filename = fullfile(workingDir,'images',name); % add full file path/directory to filename
    imwrite(img,filename,"jpg");  % create the image file
end
