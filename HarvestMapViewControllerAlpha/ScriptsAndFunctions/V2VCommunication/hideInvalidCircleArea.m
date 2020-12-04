function hideInvalidCircleArea(hFig, maxRadiusAllowed)
%HIDEINVALIDCIRCLEAREA Grey out the plotting region out of a circle
%centered at the origin.
%
% Yaguang Zhang, Purdue, 02/05/2019

% Color for the hidden region.
HIDDEN_REGION_COLOR = get(0,'defaultfigurecolor');
% Number of points for mimicing a circle region.
NUM_PTS_FOR_CIRCLE = 10000;

% Generate a polygon for the region to be hidden. 

% For the circle, we need the last point to be the same as the first one to
% form a closed polygon.
t = (1:(NUM_PTS_FOR_CIRCLE+1)-1)./NUM_PTS_FOR_CIRCLE.*2.*pi;
xsCircle = maxRadiusAllowed.*cos(t);
ysCircle = maxRadiusAllowed.*sin(t);

curFigXLim = get(hFig.CurrentAxes, 'XLim');
xsPlotRegion = curFigXLim([2,1,1,2,2]);
curFigYLim = get(hFig.CurrentAxes, 'YLim');
ysPlotRegion = curFigYLim([2,2,1,1,2]);

% polygonToHide = polyshape({xsPlotRegion, xsCircle}, ...
%     {ysPlotRegion,ysCircle});
% hHiddenRegion = plot(polygonToHide, ...
%     'FaceColor', HIDDEN_REGION_COLOR, 'EdgeColor', 'none');
hHiddenRegion = fill([xsPlotRegion, xsCircle], [ysPlotRegion, ysCircle], ...
    HIDDEN_REGION_COLOR, 'LineStyle', 'none');

set(hFig.CurrentAxes, 'XLim', curFigXLim);
set(hFig.CurrentAxes, 'YLim', curFigYLim);

end

% EOF