%% Phidget filereader
% Jon Renslo
% 8-1-2013
% Reads files outputted by PhidgetLoadCellDataRecorder.py

function out =  readBridgeData(filename)
% PHIDGET_FILEREADER Reads csv files outputted by PhidgetLoadCellDataRecorder.py
%   out = readBridgeData(filename)
%   out is a struct with data from a bridge. 
%   out.serialNum
%   out.rate
%   out.gain
%   out.data -a cell array of the data from each load cellls. each element
%             is an array in the form [timestamp, value]
%   file named should be in the same directory, else filename can be a path

%% File reading and parsing

data = csvread(filename);

%first row holds metadata
% [rate, gain, points recorded]
rate = data(1,1);
gainTable = [1 8 16 32 64 128];
gain = gainTable(data(1,2));
expectedPoints = data(1,3);

% data is the raw array of data in the format 
% [index of the load cell, timestamp, value, serial number of the bridge]

data = data(2:end,:);
if(length(data)~=expectedPoints)
    sprintf('CAUTION: lost %i packets reading %s',expectedPoints-length(data),filename); 
end

%todo parse different indexes and timestamps
temp.serialNum = data(1,4);
temp.rate = rate;
temp.gain = gain;
temp.data = {}; %a cell array of matricies {index} (timestamp, value)
for i = 1:4
   temp.data{i} = data(data(:,1)==i-1,[2 3]); 
end
out = temp;
end
