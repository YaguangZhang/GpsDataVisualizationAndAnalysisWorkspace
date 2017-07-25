% INITIALIZEMAPWITHROUTESCOLOREDBYLOCATIONSREF Plot in the current axes the routes which are colored according to locationsRef with a map as the background.
% 
% Variables needed:
%
%   - routeInfo
%
%   A structure with fields lati, long and locationsRef for the current
%   route.
%
% Handles we will get: 
%
%   - hRoute
%
%   A structure with fields wholeRoute, onRoad and inField, which are for
%   the route plot of the whole route, points on the road and points in the
%   field, respectively.
%   
%   - hMapUpdated
%
%   A cell with handles to the background maps. The handle of thefirst map
%   added to the plot is hMapUpdated{1}. Updates will be added to this cell
%   if any updating-current-map script (e.g. updateCollectorMap.m) is used.
%
% Yaguang Zhang, Purdue, 04/02/2015

% First, show the whole route. (Grey)
hAxesCollectorMap = gca;
hRoute.wholeRoute = geoshow(routeInfo.lati, routeInfo.long, ...
    'DisplayType', 'line', ...
    'LineStyle', '-', ...
    'LineWidth', 1, ...
    'Color', [0.5 0.5 0.5]);

% Reset the visible area to be roughly a square. And move it to the left
% side of the figure.
lonLim = get(gca,'Xlim');
latLim = get(gca,'Ylim');

[latLim, lonLim] = adjustLatLonLim(latLim, lonLim);
set(gca, 'Xlim', lonLim, 'Ylim', latLim, 'Units','normalized');
axesPosition = get(gca,'Position');
axesPosition(1) = 0;
set(gca, 'Position', axesPosition);

hold on;

% Show the colored route pioints.
disp(' ');
disp('geoshowColoredByLocation: Plotting the route...');
tic;
% Infield: yellow. On the road: blue.
geoshowColoredByLocation;

% Add map background to the plot.
disp(' ');
disp('geoshowColoredByLocation: Downloading the satellite image...');
tic;

% The size of the satellite images to download.
IMAGE_HEIGHT = 480; %960;
IMAGE_WIDTH = 640; %1280;

try
    info = wmsinfo('http://raster.nationalmap.gov/arcgis/services/Orthoimagery/USGS_EROS_Ortho_SCALE/ImageServer/WMSServer?request=GetCapabilities&service=WMS','TimeoutInSeconds', 10);
    layer = info.Layer(1);
    
    flagValidImage = false;
    imageHeight = IMAGE_HEIGHT;
    imageWidth = IMAGE_WIDTH;
    while(~flagValidImage)
        [A, R] = wmsread(layer, 'Latlim', latLim, 'Lonlim', lonLim, ...
            'ImageHeight', imageHeight, 'ImageWidth', imageWidth, 'TimeoutInSeconds', 10);
        
        % Increase the image size if the image obtained is not valid.
        if ~(all(A(1:end)==0)||all(A(1:end)==255))
            flagValidImage = true;
        else
            imageHeight = imageHeight*2;
            imageWidth = imageWidth*2;
        end
    end
catch err1
    disp(err1.message);
    error('Satellite image server we used is not working now. Please try later.');
end
toc;
disp('geoshowColoredByLocation: Done!');

disp(' ');
disp('geoshowColoredByLocation: Rendering the map...');
tic;

numMapLayer = 1;
% We store all the handles to the satellite images in a cell so that we can
% ignore them when we want to select GPS points of the route.
hMapUpdated = cell(1,1);
hMapUpdated{numMapLayer} = geoshow(A,R);

% Set the satellite image to be the background.
uistack(hMapUpdated{numMapLayer}, 'bottom');

hold off;

toc;
disp('geoshowColoredByLocation: Done!');

% EOF