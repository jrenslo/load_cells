%% Phidget data reader/plotter
% designed to work in conjunction with Bridge_4panel_setup.py
% Jon Renslo
% 8-1-2013\
clearvars -except filename
close all

%% File reading and parsing

cd('~/Google Drive/Stanford/Work/BDML/Phigets');

if ~exist('filename','var')
    sprintf('did not receive filename, defaulting to calibration plot');
    filename = 'data/Phidget_test_2013-08-07_12:40:20.csv';
end


% the filename is read from the python script running this plotter. to run
% manually, uncomment and set filename here
% {
filename = 'data/Phidget_test_2013-08-19_09:54:52.csv';
%}

% use most recent calibration file.  
% Should recalibrate each day data is taken.
calibFilename = ''; 

fullData = readBridgeData(filename);
%returns a cell array of structs

%calibVals = readCalibration(calibFilename);
% use as calibVals.getConst(serial,index) to get calibration constant

%% Data plotting

plotRaw = true;

serials = [293824 293138 293749 293780 293743 293783];

if plotRaw
    hold all
    labels = {};
    for i=1:length(fullData)
        figure(find(serials==fullData{i}.serialNum));
        hold all
        p = plot(fullData{i}.time,fullData{i}.data+fullData{i}.tareOffset);
        title(num2str(fullData{i}.serialNum));
    end
    %legend(labels, 'Best');
    xlabel(['time (s) taken in ', num2str(fullData{1}.rate),'ms increments']);
    ylabel('mV/V');
   % title('Raw Phidget Bridge Data');
end
%{
f1 = figure;
hold all
labels = {};
for i=1:length(fullData)
    figure(find(serials==fullData{i}.serialNum));
    hold all
    p = plot(fullData{i}.time,fullData{i}.data*calib.getConst(fullData{i}.serial,fullData{i}.index));
    title(num2str(fullData{i}.serialNum));
    labels = [labels,[num2str(fullData{i}.serialNum) '-' num2str(fullData{i}.index)]];
end
legend(labels, 'Best');
xlabel(['time (s) taken in ', num2str(fullData{1}.rate),'ms increments']);
ylabel('kg');
%title('Calibrated Force Plot');

% for 3d animated plot, look at patches (and face filled polygons and
% colormaps) http://www.mathworks.com/help/matlab/ref/patch.html

%}


%{
% animated fill plot

sq = @(x,y) deal([x x+3 x+3 x],[y,y,y+3,y+3]);

numInRow = [4 5 6 5 4];
offset = [4 2 0 2 4];
size = 3;
patchX = [];
patchY = [];
gap = 1;

for row=1:5
    for startX = offset(row) : size + gap : ...
                 numInRow(row)*(size+gap)+offset(row)-1
        startY = (row-1)*(size+gap);
        [x, y] = sq(startX,startY);
        patchX = [patchX;x];
        patchY = [patchY;y];
    end
end
axis([-2 25 -2 20]);

loop through recording frames for movie 

patch(patchX',patchY','b');


%}



