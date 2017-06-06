function [ indicesFilesRelated ] = findRelatedFiles(files, fieldShape)
%FINDRELATEDFILES Find GPS tracks in files that are related with the input
%field shape.
%
% Inputs:
%   - files
%     A struct array representing the GPS log files. Each element contains
%     fields like gpsTime, lat, lon, speed, bearing, etc. Please refer to
%     processGpsDataFiles.m for more details.
%   - fieldShape
%     An alpha shape representing the inner side of the field to be
%     harvested. inShape() will be used for determining the GPS points that
%     are relavant.
%
% Output:
%   - indicesFilesRelated
%     The resulted indices for files that have at least one sample
%     collected in the field specified by fieldShape.
%
% Yaguang Zhang, Purdue, 05/23/2017

indicesFilesRelated = find(arrayfun(@(file) ...
    any(inShape(fieldShape, file.lon, file.lat)), files));

end
% EOF