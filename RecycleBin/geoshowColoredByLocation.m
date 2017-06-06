function [hRoute, hMapImage] = geoshowColoredByLocation(hMapAxes,routeInfo)
% GEOSHOWCOLOREDBYLOATION Show the route colored according to GPS point's
% location on a map.
%
% This function will draw the routes specifed by routeInfo on map, with GPS
% points in the field colored with yellow and those on the road colored
% with blue.
%
% Inputs:
%
%   - hMapAxes
%
%   The handle to the axes where the plot happens.
%
%   - routeInfo
%
%   A structure with filed lati, long (specifying coordinates of the route)
%   and locationRef (specifying the location of the coordinates, with 0
%   being in the field and -100 being on the road.)
%
% Outputs:
%
%   - hRoute, hMapImage
%
%   Handles to the route and the map image background, respectively. Note
%   that hRoute is a structure with fields "onRoad" and "inField".
%
% Yaguang Zhang, Purdue, 03/30/2015

% Set current figure.
axes(hMapAxes);
hold on;

% First, show the colored route pioints.
disp(' ');
disp('geoshowColoredByLocation: Plotting the route...');
tic;

% The whole route.
geoshow(routeInfo.lati, routeInfo.long, ...
    'DisplayType', 'line', ...
    'LineStyle', '--', ...
    'LineWidth', 2, ...
    'Color', 'k');
% Record the visible area.
lonLim = get(hMapAxes,'Xlim');
latLim = get(hMapAxes,'Ylim');

% On the road. Blue "*".
indicesSamplesOnRoad = routeInfo.locationsRef<0;
hRoute.onRoad = geoshow(...
    routeInfo.lati(indicesSamplesOnRoad), ...
    routeInfo.long(indicesSamplesOnRoad), ...
    'DisplayType', 'point', 'Marker', '*',...
    'LineWidth', 2, 'MarkerSize', 5, ...
    'MarkerEdgeColor', 'blue');
% Infield. Yellow "o".
indicesSamplesInField = routeInfo.locationsRef==0;
hRoute.inField = geoshow(...
    routeInfo.lati(indicesSamplesInField), ...
    routeInfo.long(indicesSamplesInField), ...
    'DisplayType', 'point', 'Marker', 'o',...
    'LineWidth', 2, 'MarkerSize', 5, ...
    'MarkerEdgeColor', 'yellow');

set(hMapAxes,'Xlim',lonLim);
set(hMapAxes,'Ylim',latLim);

% Add map background to the plot.
disp(' ');
disp('geoshowColoredByLocation: Downloading the satellite image...');
tic;

% % The size of the satellite images to download.
% IMAGE_HEIGHT = 480;
% IMAGE_WIDTH = 640;

% 
% try
%     info = wmsinfo('http://raster.nationalmap.gov/arcgis/services/Orthoimagery/USGS_EROS_Ortho_SCALE/ImageServer/WMSServer?request=GetCapabilities&service=WMS','TimeoutInSeconds', 10);
%     layer = info.Layer(1);
%     
%     [A, R] = wmsread(layer, 'Latlim', latLim, 'Lonlim', lonLim, ...
%         'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH, 'TimeoutInSeconds', 10);
% catch err1
%     disp(err1.message);
%     error('Satellite image server we used is not working now. Please try later.');
% end
% toc;
% disp('geoshowColoredByLocation: Done!');
% 
% disp(' ');
% disp('geoshowColoredByLocation: Rendering the map...');
% tic;
% 
% handles.hMapUpdated = geoshow(A,R);
% 
% % Set the satellite image to be the background.
% uistack(handles.hMapUpdated, 'bottom');
% handles.numMapLayer = 1;
% 
% set(hAxes,'Xlim',lonLim);
% set(hAxes,'Ylim',latLim);
% 
% hold off;
% grid on;

end