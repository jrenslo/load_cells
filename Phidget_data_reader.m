%% Phidget data reader/plotter
% designed to work in conjunction with Bridge_4panel_setup.py
% Jon Renslo
% 8-1-2013\
clearvars -except filename
close all

cd('~/Google Drive/Stanford/Work/BDML/Phigets');

%% File reading and parsing

if ~exist('filename','var')
    print('did not receive filename. defaulting to calibration plot');
    filename = 'data/Phidget_test_2013-08-07_12:40:20.csv';
end

data = csvread(filename);
%{ 
% TODO
% read the latest file
fileList = textscan(ls(),'%s','\n');
fileList = fileList{1};
%}

rate = data(1,1);
gain = data(1,2); %first row holds settings
expectedPoints = data(1,3);
calibData = data(3:(2000/rate)+3,1:end-1);  %truncate bad data often at beginning and end of set
dataToPlot = data((2000/rate)+3:end-1,1:end-1);
time = (0:length(dataToPlot)-1)'*rate/1000;

plotRaw = false;
%% Force Calibration

% tare using first 2 seconds of data

ave = mean(calibData);

%% Data plotting
if plotRaw
    plot(time,dataToPlot);
    legend('Sensor 1','Sensor 2','Sensor 3', 'Sensor 4');
    xlabel(['time (s) taken in ', num2str(rate),'ms increments']);
    ylabel('mV/V');
    title('Raw Phidget Bridge Data');
end
%% postprocessing


f2 = figure;
hold all
plot(time,dataToPlot-repmat(ave,length(dataToPlot),1));
legend('Sensor 1','Sensor 2','Sensor 3', 'Sensor 4');
xlabel(['time (s) taken in ', num2str(rate),'ms increments']);
ylabel('0.1 is about 1kg');
title('Tared Phidget Bridge Data');
