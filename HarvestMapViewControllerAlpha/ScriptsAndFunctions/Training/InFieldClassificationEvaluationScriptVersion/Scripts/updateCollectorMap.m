%UPDATECOLLECTORMAP Update the visible map area for the location info collector. 
%
% Yaguang Zhang, Purdue, 03/31/2015

disp(' ')
disp('CollectorGUI: Updating map...')

set(0, 'CurrentFigure', hCollectorFig);hold on;

hAxes = get(hCollectorFig, 'CurrentAxes');
lonLim = get(hAxes,'Xlim');
latLim = get(hAxes,'Ylim');

[A, R] = wmsread(layer, 'Latlim', latLim, 'Lonlim', lonLim, ...
    'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH);
hMapUpdated{numMapLayer+1} = geoshow(A,R); 

uistack(hMapUpdated{numMapLayer+1}, 'bottom');
uistack(hMapUpdated{numMapLayer+1}, 'up', numMapLayer);
numMapLayer = numMapLayer + 1;

set(hAxes,'Xlim',lonLim);
set(hAxes,'Ylim',latLim);
hold off;

disp('CollectorGUI: Done!')

% EOF