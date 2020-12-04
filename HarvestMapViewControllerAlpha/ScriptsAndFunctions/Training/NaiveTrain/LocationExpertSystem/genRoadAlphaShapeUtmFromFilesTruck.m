function [roadAlphaShapeUtm, zone] ...
    = genRoadAlphaShapeUtmFromFilesTruck( ...
    filesTruck, maxSpeedInField, roadTileDistDelta, maxSpeedOnRoad)
%GENROADALPHASHAPEUTMFROMFILESTRUCK Generate an alpha shape for the roads
%based on the truck GPS tracks.
%
% We will locate the truck GPS points with a speed higher than
% maxSpeedInField (i.e., for sure on the road) and include a small area
% around it as on the road.
%
% Inputs:
%   - filesTruck
%     Files for trucks. A struct array with required fields lat, lon, and
%     speed.
%   - maxSpeedInField
%     The max speed a truck can run in a field in m/s.
%   - roadTileDistDelta
%     Optional. For each point, we will include four more point, up, down,
%     left, and right to the orignal one, with the distance
%     roadTileDistDelta in meter.
%   - maxSpeedOnRoad
%     Optional. The max speed a truck can run on the road in m/s. This
%     value will be used as alpha in creating the road shape.
%
% Outputs:
%   - roadAlphaShapeUtm
%     The output alpha shape in the UTM (x,y) system for the roads.
%   - zone
%     The UTM zone. Note that all the GPS points involved should be in the
%     same UTM zone.
%
% Yaguang Zhang, Purdue, 10/31/2020

%% Parameters

if ~exist('roadTileDistDelta', 'var')
    roadTileDistDelta = 0.5; % In meters.
end

if ~exist('maxSpeedOnRoad', 'var')
    maxSpeedOnRoad = 30; % In m/s. Used as alpha.
end

%% Locate On-Road Samples

boolsOnRoad = vertcat(filesTruck.speed)>maxSpeedInField;

lonLatsOnRoad = [vertcat(filesTruck.lon), vertcat(filesTruck.lat)];
lonLatsOnRoad = lonLatsOnRoad(boolsOnRoad,:);

%% Construct the Alpha Shape in UTM

[xs, ys, zones] = deg2utm(lonLatsOnRoad(:,2), lonLatsOnRoad(:,1));
zone = zones(1,:);
assert(size(unique(zones, 'rows'),1)==1, ...
    'All the GPS points should be in the same UTM zone!');

xs = [xs; xs+roadTileDistDelta; xs; xs-roadTileDistDelta; xs];
ys = [ys; ys+roadTileDistDelta; ys; ys-roadTileDistDelta; ys];
roadAlphaShapeUtm = alphaShape(xs, ys, maxSpeedOnRoad);

end
% EOF