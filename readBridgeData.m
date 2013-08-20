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
%   struct.time      - vector of timestamps 
%   struct.data      - vector of readings from the sensor
%   struct.raw       - raw data from the csv file.
%
%   file named should be in the same directory, else filename can be a path

%% File reading and parsing

raw = csvread(filename);
%first row holds metadata
% [rate, gain, points recorded]
rate = raw(1,1);
gain = raw(1,2);
expectedPoints = raw(1,3);

calibData = raw(raw(:,5)==1,:);


% data is the raw array of data in the format 
% [index of the load cell, timestamp, value, serial number of the bridge]

data = raw(2:end,:);
data = data(data(:,5)~=1,:);
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
       temp.tareOffset = mean(calibData(calibData(:,1)==index-1&calibData(:,4)==serial,3));
       temp.time = data(data(:,1)==index-1&data(:,4)==serial,2);
       temp.data = data(data(:,1)==index-1&data(:,4)==serial,3)-temp.tareOffset;
       temp.raw  = raw;
       out{length(out)+1} = temp;
    end
end
end
