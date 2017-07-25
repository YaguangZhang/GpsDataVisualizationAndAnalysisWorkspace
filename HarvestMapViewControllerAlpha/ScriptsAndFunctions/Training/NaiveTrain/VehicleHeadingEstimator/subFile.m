function [ subF ] = subFile(file, idxStart, idxEnd)
%SUBFILE Slice one element of the customized GPS log struct array files.
%
% E.g.'s:
%   - Specify both idxStart and idxEnd.
%     subF = subFile(file, 1, 10);
%   - Use indices.
%     subF = subFile(file, [1,2,5,8]);
%   - Use booleans.
%     subF = subFile(file, file.speed>0);
%
% Yaguang Zhang, Purdue, 05/18/2017

if(nargin<2)
    error('Not enough inputs.');
elseif(nargin==2)
    I = idxStart;
elseif(nargin==3)
    I = idxStart:idxEnd;
else
    error('Too many inputs.');
end

% Fill the fields required.
subF.type = file.type;
subF.id = file.id;
subF.time = file.time(I);
subF.gpsTime = file.gpsTime(I);
subF.lat = file.lat(I);
subF.lon = file.lon(I);
subF.altitude = file.altitude(I);
subF.speed = file.speed(I);
subF.bearing = file.bearing(I);
subF.accuracy = file.accuracy(I);

end
% EOF