%% Phidget calibration filereader
% Jon Renslo
% 8-1-2013
% Reads files outputted by PhidgetLoadCellDataRecorder.py

function out =  readCalibration(filename)
% readCalibration Reads csv files outputted by Phidget_calibrator.py
%   out = Phidget_filereader(filename)
%   out is a struct with data from a bridge. 
%   out.serialNum
%   out.rate
%   out.gain
%   out.data the raw array of data in the format 
%            [serial num, index, calibration constant (kg/analog reading)]
%   file should be in the same directory, or filename can be a path

%% File reading and parsing

fdata = csvread(filename);

%first row holds metadata
% [rate, gain, points recorded]
rate = fdata(1,1);  
gain = fdata(1,2);

fdata = fdata(2:end,:);

temp.rate = rate;
temp.gain = gain;
temp.data = fdata;
temp.getConst = @(serial,index) fdata(fdata(:,1)==serial&fdata(:,2)==index,3);

out = temp;
end
