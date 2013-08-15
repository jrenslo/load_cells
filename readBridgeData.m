%% Phidget filereader
% Jon Renslo
% 8-1-2013
% Reads files outputted by PhidgetLoadCellDataRecorder.py

function out =  readBridgeData(filename)
% PHIDGET_FILEREADER Reads csv files outputted by PhidgetLoadCellDataRecorder.py
%   out = readBridgeData(filename)
%   out is a cell array of structs
%   each struct contains data from a load cell. 
%   struct.serialNum - serial number of the bridge to which the load cell
%                       is attached
%   struct.index     - index of the load cell
%   struct.rate      - the rate the data was taken (setting may be higher than
%                       actual rate)
%   struct.gain      - the gain of the load cell
%   struct.data      - a matrix of [timestamp,value] readings
%
%   file named should be in the same directory, else filename can be a path

%% File reading and parsing

data = csvread(filename);

%first row holds metadata
% [rate, gain, points recorded]
rate = data(1,1);
gain = data(1,2);
expectedPoints = data(1,3);

% data is the raw array of data in the format 
% [index of the load cell, timestamp, value, serial number of the bridge]

data = data(2:end,:);
if(length(data)~=expectedPoints)
    sprintf('CAUTION: lost %i packets reading %s',expectedPoints-length(data),filename); 
end
out = {};
for serial=unique(data(:,4))'
    for index = 1:4
       temp.serialNum = serial;
       temp.index = index-1;
       temp.rate = rate;
       temp.gain = gain;
       temp.data = data(data(:,1)==index-1,[2 3]);
       out{length(out)+1} = temp;
    end
end
end
