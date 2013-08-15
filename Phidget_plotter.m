%% Phidget data reader/plotter
% designed to work in conjunction with Bridge_4panel_setup.py
% Jon Renslo
% 8-1-2013\
clearvars -except filename
close all

cd('~/Google Drive/Stanford/Work/BDML/Phigets');


%% File reading and parsing

if ~exist('filename','var')
    sprintf('did not receive filename, defaulting to calibration plot');
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
rawTestData = data((2000/rate)+3:end-1,1:end-1);
time = (0:length(testData)-1)'*rate/1000;

% todo update the script to accomodate the new file format (timestamp,
% index, value)
for i=0:3
    dataToPlot{i+1} = data(data(:,2)==i,:);
end

plotRaw = false;
%% Force Calibration

% tare using first 2 seconds of data

ave = mean(calibData);
testData = rawTestData-repmat(ave,length(rawTestData),1);

% calibrated using Benchmarker. k in kg/analog reading

k = [ -12.244354940302859 -10.132204228799910  -9.816710675107348  -9.742828210185712];
testData = testData*diag(k);

%% Data plotting
if plotRaw
    plot(time,testData);
    legend('Sensor 1','Sensor 2','Sensor 3', 'Sensor 4');
    xlabel(['time (s) taken in ', num2str(rate),'ms increments']);
    ylabel('mV/V');
    title('Raw Phidget Bridge Data');
end

f2 = figure;
hold all
plot(time,testData);
legend('Sensor 1','Sensor 2','Sensor 3', 'Sensor 4');
xlabel(['time (s) taken in ', num2str(rate),'ms increments']);
ylabel('kg');
title('Tared Phidget Bridge Data');
