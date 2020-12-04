function [roadPolyshapeLonLat, roadAlphaShapesUtm, shapeZones] ...
    = genRoadPolyshapeLonLat( ...
    filesTruck, maxSpeedInField, extraLonLatOnRoad, ROAD_ALPHA)
%GENROADPOLYSHAPELONLAT Generate a polyshape for the roads based on the
%truck GPS tracks in GPS (lon, lat).
%
% We will (1) create a road alpha shape in the UTM system for the truck GPS
% poins in each different UTM zone and (2) merge them together.
%
% Inputs:
%   - filesTruck
%     Files for trucks.
%   - maxSpeedInField
%     The max speed a truck can run in a field in meters per second.
%   - extraLonLatOnRoad
%     Optional. GPS points on the road from other sources. They will be
%     included in the road polygon if presented.
%   - ROAD_ALPHA
%     Optional. Specifies the value of alpha for creating road shapes in
%     UTM.
%
% Outputs:
%   - roadPolyshapeLonLat
%     The output polyshape in (lon, lat) for the roads.
%   - roadAlphaShapesUtm
%     A cell containing the alpha shapes in the UTM (x,y) system for the
%     roads in each different UTM zone.
%   - shapeZones
%     The UTM zones involved for roadAlphaShapesUtm.
%
% Yaguang Zhang, Purdue, 10/31/2020

% This is necessary to make sure single GPS track can be included in the
% alpha shape. It is also used to, roughly speaking, adjust the distance
% between edge GPS tacks on the road to the edge of the field. If we have a
% truck width of 3.5 m and a road to field distance of 3 m, then
%   roadTileDistDelta = 3.5/2+3 = 4.25 (m).
roadTileDistDelta = 4.25; % In meters.

% Construct GPS Files for Each UTM Zone
lonLatSpeedsTruck = [vertcat(filesTruck.lon), vertcat(filesTruck.lat), ...
    vertcat(filesTruck.speed)];
[xsTruck, ysTruck, zonesTruck] ...
    = deg2utm(lonLatSpeedsTruck(:,2), lonLatSpeedsTruck(:,1));
shapeZones = unique(zonesTruck, 'rows');
numOfShapes = size(shapeZones,1);

if exist('extraLonLatOnRoad', 'var')
    [xsExtra, ysExtra, zonesExtra] ...
        = deg2utm(extraLonLatOnRoad(:,2), extraLonLatOnRoad(:,1));
end

% Initialize an empty polyshape.
roadPolyshapeLonLat = polyshape([nan nan]);
roadAlphaShapesUtm = cell(numOfShapes, 1);

% Compute device sample rate in kHz.
time = filesTruck(1).gpsTime;
deviceSampleRateInKHz = (length(time)-1)/(time(end)-time(1));
deviceSampleRateInHz = deviceSampleRateInKHz*1000;

for idxShape = 1:numOfShapes
    curZone = shapeZones(idxShape, :);
    curBoolsInZone = ismember(zonesTruck, curZone, 'rows');
    
    if exist('extraLonLatOnRoad', 'var')
        curBoolsInZoneExtra = ismember(zonesExtra, curZone, 'rows');
        extraXysOnRoad = [xsExtra(curBoolsInZoneExtra), ...
            ysExtra(curBoolsInZoneExtra)];
    end
    
    % curFileTruck.lat = lonLatSpeedsTruck(curBoolsInFile, 2);
    %curFileTruck.lon = lonLatSpeedsTruck(curBoolsInFile, 1);
    % curFileTruck.speed = lonLatSpeedsTruck(curBoolsInFile, 3);
    
    % Generate an alpha shape in UTM to represent roads in this zone.
    
    %roadAlphaShapesUtm{idxShape} ...
    %     = genRoadAlphaShapeUtmFromFilesTruck(curFileTruck, ...
    %     maxSpeedInField);
    
    if exist('extraXysOnRoad', 'var')
        roadAlphaShapesUtm{idxShape} ...
            = genRoadAlphaShapeUtmFromTruckXYSpeeds( ...
            [xsTruck(curBoolsInZone), ysTruck(curBoolsInZone), ...
            lonLatSpeedsTruck(curBoolsInZone, 3)], ...
            maxSpeedInField, extraXysOnRoad, ...
            roadTileDistDelta, ROAD_ALPHA, deviceSampleRateInHz);
    else
        roadAlphaShapesUtm{idxShape} ...
            = genRoadAlphaShapeUtmFromTruckXYSpeeds( ...
            [xsTruck(curBoolsInZone), ysTruck(curBoolsInZone), ...
            lonLatSpeedsTruck(curBoolsInZone, 3)], ...
            maxSpeedInField, [], ...
            roadTileDistDelta, ROAD_ALPHA, deviceSampleRateInHz);
    end
    
    curRoadPolyshapeLonLat ...
        = alphaShapeUtm2PolyshapeLonLat( ...
        roadAlphaShapesUtm{idxShape}, curZone);
    roadPolyshapeLonLat = union(roadPolyshapeLonLat, ...
        curRoadPolyshapeLonLat);
end
end
% EOF