% IMAGE_HEIGHT = 480;
% IMAGE_WIDTH = 640;
% Get map info:
% Elapsed time is 0.428318 seconds.
% Download image:
% Elapsed time is 0.562930 seconds.
% Show image:
% Elapsed time is 0.460191 seconds.

% IMAGE_HEIGHT = 240;
% IMAGE_WIDTH = 320;
% Get map info:
% Get map info:
% Elapsed time is 0.382871 seconds.
% Download image:
% Elapsed time is 0.234455 seconds.
% Show image:
% Elapsed time is 0.084481 seconds.


IMAGE_HEIGHT = 240;
IMAGE_WIDTH = 320;

disp('Get map info:')
tic;
info = wmsinfo('http://raster.nationalmap.gov/arcgis/services/Orthoimagery/USGS_EROS_Ortho_SCALE/ImageServer/WMSServer?request=GetCapabilities&service=WMS');
layer = info.Layer(1);
toc;

lati = files(77).lat;
long = files(77).lon;

hFigure = figure;hold on;
hRoute = geoshow(lati, long);
hAxes = get(hFigure, 'CurrentAxes');
lonLim = get(hAxes,'Xlim');
latLim = get(hAxes,'Ylim');

disp('Download image:')
tic;
[A, R] = wmsread(layer, 'Latlim', latLim, 'Lonlim', lonLim, ...
    'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH);
toc;
disp('Show image:')
tic;
geoshow(A,R);
toc;

uistack(hRoute, 'top');
set(hAxes,'Xlim',lonLim);
set(hAxes,'Ylim',latLim);

hold off; grid on;