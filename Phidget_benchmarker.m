%% Phidget benchmarker
% by Jon Renslo
% 8/7/13 for the BDML
% for Phidget wheatstone bridge 1046 with 4 20kg load cells
% 

clearvars -except filename
close all

cd('~/Google Drive/Stanford/Work/BDML/Phigets');

%% File reading and parsing

[data, rate, gain] = Phidget_filereader('data/Phidget_test_2013-08-07_16:50:11.csv');

sensor1 = data(data(:,2)==0,[1 3]);
sensor2 = data(data(:,2)==1,[1 3]);
sensor3 = data(data(:,2)==2,[1 3]);
sensor4 = data(data(:,2)==3,[1 3]);

% inspect and record period measuring 100g weight
figure(1);plot(sensor1(:,1),sensor1(:,2));title('sensor1'); %1.1 to 1.35
figure(2);plot(sensor2(:,1),sensor2(:,2));title('sensor2'); %1.8 to 2.1
figure(3);plot(sensor3(:,1),sensor3(:,2));title('sensor3'); %2.45 to 2.85
figure(4);plot(sensor4(:,1),sensor4(:,2));title('sensor4'); %3.25 to 3.75

%% extract calibration constant

extractMean = @(vals,low,high) mean(vals(vals(:,1)<high&vals(:,1)>low,2));

ofst1 = extractMean(sensor1,5000,10000);
ofst2 = extractMean(sensor2,5000,17000);
ofst3 = extractMean(sensor3,5000,23000);
ofst4 = extractMean(sensor4,5000,30000);

k(1) = extractMean(sensor1,11000,13500) - ofst1;
k(2) = extractMean(sensor2,18000,21000) - ofst2;
k(3) = extractMean(sensor3,24500,28500) - ofst3;
k(4) = extractMean(sensor4,32500,37500) - ofst4;

calWeight = .1; % in kg

k = calWeight/k; % k = kg/analog reading