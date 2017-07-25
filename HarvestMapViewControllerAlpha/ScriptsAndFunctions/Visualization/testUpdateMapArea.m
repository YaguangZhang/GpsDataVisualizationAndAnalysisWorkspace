%TESTUPDATEMAPAREA
% Update the visible map area. 
%
% Yaguang Zhang, Purdue, 03/02/2015

set(0, 'CurrentFigure', hFigureMapInField);hold on;
geoshow(lati, long);
hAxes = get(hFigureMapInField, 'CurrentAxes');
lonLim = get(hAxes,'Xlim');
latLim = get(hAxes,'Ylim');

[A, R] = wmsread(layer, 'Latlim', latLim, 'Lonlim', lonLim, ...
    'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH);
hMapUpdated = geoshow(A,R); 

uistack(hMapUpdated, 'bottom');
uistack(hMapUpdated, 'up', numMapLayer);
numMapLayer = numMapLayer + 1;

set(hAxes,'Xlim',lonLim);
set(hAxes,'Ylim',latLim);
hold off; grid on;

% EOF