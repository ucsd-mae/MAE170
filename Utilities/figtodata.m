fig = openfig("FIGURE_FILENAME.fig"); % open the figure file

% figure index = 1 by default, may be different if multiple subplots
% you can see the list of subplots by calling fig.Children
figure_index = 1;

% get the specific subplot of interest
sub = fig.Children(figure_index);

% find the lines of data in that subplot
% assuming there is only 1 line of data in the plot, extract the X,Y data
line = findobj(sub, 'Type', 'Line');
x = line.XData;
y = line.YData;

% save the data
save('extracted_data', 'x', 'y')
