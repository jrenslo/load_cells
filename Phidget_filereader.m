%% Phidget filereader
% Jon Renslo
% 8-1-2013
% Reads files outputted by PhidgetLoadCellDataRecorder.py

function [data, rate, gain] =  Phidget_filereader(filename)
% PHIDGET_FILEREADER Reads csv files outputted by PhidgetLoadCellDataRecorder.py
%   [data, rate, gain] = Phidget_filereader(filename)
%   data is the raw array of data in the format [index of the load cell, timestamp, value]
%   file named should be in the same directory, else filename can be a path

%% File reading and parsing

data = csvread(filename);

%first row holds metadata
rate = data(1,1);
gainTable = [1 8 16 32 64 128];
gain = gainTable(data(1,2));
expectedPoints = data(1,3);

data = data(2:end,:);
if(length(data)~=expectedPoints)
    sprintf('CAUTION: lost %i packets reading %s',expectedPoints-length(data),filename); 
end

%todo parse different indexes and timestamps

end
