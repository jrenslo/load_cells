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
filename = 'data/Phidget_test_2013-08-15_17:35:23.csv';
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

if plotRaw
    f1 = figure;
    hold all
    labels = {}
    for i=1:length(fullData)
        plot(fullData{i}.time,fullData{i}.data);
        labels = [labels,[num2str(fullData{i}.serialNum) '-' num2str(fullData{i}.index)]];
    end
    legend(labels, 'Best');
    xlabel(['time (s) taken in ', num2str(rate),'ms increments']);
    ylabel('mV/V');
    title('Raw Phidget Bridge Data');
end


f2 = figure;
%todo calibrated plots. 


xlabel(['time (s) taken in ', num2str(fullData{1}.rate),'ms increments']);
ylabel('kg');
title('Phidget Bridge Data');
