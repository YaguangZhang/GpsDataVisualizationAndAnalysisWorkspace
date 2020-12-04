function jsonCell = polyshapeLonLat2jsonCell(polyshapeLonLat)
%POLYSHAPELONLAT2JSONCELL Convert a [lon, lat] polyshape to a Matlab
%cell which could be translated by jsonencode to a Leaflet.js JSON
%polygon, possibly with holes.
%
% This is used to export field polygons to a JSON file for the OADA data
% stream emulator.
%
% Yaguang Zhang, Purdue, 11/22/2020

numOfBounds = numboundaries(polyshapeLonLat);
jsonCell = cell(numOfBounds, 1);

for idxB = 1:numOfBounds
    [curBLons, curBLats] = boundary(polyshapeLonLat, idxB);    
    curNumOfBPts = length(curBLons);
    curBCell = cell(curNumOfBPts, 1);
    for idxBPt = 1:curNumOfBPts
        curBCell{idxBPt} = [curBLats(idxBPt), curBLons(idxBPt)];
    end
    jsonCell{idxB} = curBCell;
end
end
% EOF