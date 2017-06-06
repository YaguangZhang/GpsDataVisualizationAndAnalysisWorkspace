% GEOSHOWCOLOREDBYLOATION Show the route colored according to GPS point's
% location on a map.
%
% This script will draw the routes specifed by routeInfo on map, with GPS
% points in the field colored with yellow and those on the road colored
% with blue.
%
% The variable needed:
%
%   - routeInfo
%
%   A structure with filed lati, long (specifying coordinates of the route)
%   and locationRef (specifying the location of the coordinates, with 0
%   being in the field and -100 being on the road.)
%
% Variables that will be updated:
%
%   - hRoute, hMapImage
%
%   Handles to the route and the map image background, respectively. Note
%   that hRoute is a structure and its fields "onRoad" and "inField" will
%   be updated here.
%
% Yaguang Zhang, Purdue, 03/30/2015

% On the road. Blue "*".
boolsSamplesOnRoad = routeInfo.locationsRef<0;
hRoute.onRoad = geoshow( ...
    routeInfo.lati(boolsSamplesOnRoad), ...
    routeInfo.long(boolsSamplesOnRoad), ...
    'DisplayType', 'point', 'Marker', '+',...
    'LineWidth', 1, 'MarkerSize', 3, ...
    'MarkerEdgeColor', 'blue');
% Infield. Yellow "o".
boolsSamplesInField = routeInfo.locationsRef==0;
hRoute.inField = geoshow( ...
    routeInfo.lati(boolsSamplesInField), ...
    routeInfo.long(boolsSamplesInField), ...
    'DisplayType', 'point', 'Marker', 'o',...
    'LineWidth', 1, 'MarkerSize', 3, ...
    'MarkerEdgeColor', 'yellow');

% EOF