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
filename = 'data/Phidget_test_2013-08-21_10:48:46.csv';
%}

% use most recent calibration file.  
% Should recalibrate each day data is taken.
calibFilename = 'data/Phidget_calibration_2013-08-20_15:51:58.csv'; 

fullData = readBridgeData(filename);
%returns a cell array of structs

calib = readCalibration(calibFilename);
% use as calibVals.getConst(serial,index) to get calibration constant

%% Data plotting

plotRaw = false;

serials = [293824 293138 293749 293780 293743 293783];
except = [[0 0]];%[[293783 0];[293783,3];[293780,1]];%[[293138 2]; [293138 3]; [293743 1]];

if plotRaw
    hRaw = figure;
    hold all
    labels = {};
    for i=1:length(fullData)
        subplot(2,3,(find(serials==fullData{i}.serialNum)));
        hold all
        if(~(any(except(:,1)==fullData{i}.serialNum&...
                except(:,2)==fullData{i}.index)))
            p = plot(fullData{i}.time,fullData{i}.data+fullData{i}.tareOffset);
            title(num2str(fullData{i}.serialNum));
        end
    end
    %legend(labels, 'Best');
    figure(hRaw);
    %xlabel(['time (s) taken in ', num2str(fullData{1}.rate),'ms increments']);
    %ylabel('mV/V');
    %title('Raw Phidget Bridge Data');
end

hTared = figure('name','Tared Phidget Bridge Data');
hold all
labels = {};
for i=1:length(fullData)
    subplot(2,3,(find(serials==fullData{i}.serialNum)));
    hold all
    if(~(any(except(:,1)==fullData{i}.serialNum&...
            except(:,2)==fullData{i}.index)))
        p = plot(fullData{i}.time,fullData{i}.data);
        title(num2str(fullData{i}.serialNum));
    end
end
%legend(labels, 'Best');
%xlabel(['time (s) taken in ', num2str(fullData{1}.rate),'ms increments']);
%ylabel('mV/V');
%title('Tared Phidget Bridge Data');

%{
hTaredFull = figure('name','Tared Phidget Bridge Data');
hold all
labels = {};
for i=1:length(fullData)
    hold all
    if(~(any(except(:,1)==fullData{i}.serialNum&...
            except(:,2)==fullData{i}.index)))
        p = plot(fullData{i}.time,fullData{i}.data);
        title(num2str(fullData{i}.serialNum));
        labels = [labels,[num2str(fullData{i}.serialNum) '-' num2str(fullData{i}.index)]];
    end
end
%legend(labels, 'Best');
xlabel(['time (s) taken in ', num2str(fullData{1}.rate),'ms increments']);
ylabel('mV/V');
title('Tared Phidget Bridge Data');
%}
    

hCalibrated = figure;
hold all
labels = {};
for i=1:length(fullData)
    hold all
    if(~(any(except(:,1)==fullData{i}.serialNum&...
            except(:,2)==fullData{i}.index)))
        p = plot(fullData{i}.time,fullData{i}.data*calib.getConst(fullData{i}.serialNum,fullData{i}.index));
        labels = [labels,[num2str(fullData{i}.serialNum) '-' num2str(fullData{i}.index)]];
    end
end
%legend(labels, 'Best');
xlabel(['time (s) taken in ', num2str(fullData{1}.rate),'ms increments']);
ylabel('kg');
title('Calibrated Force Plot');

% for 3d animated plot, look at patches (and face filled polygons and
% colormaps) http://www.mathworks.com/help/matlab/ref/patch.html




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

%loop through recording frames for movie 

patch(patchX',patchY','b');


%}



