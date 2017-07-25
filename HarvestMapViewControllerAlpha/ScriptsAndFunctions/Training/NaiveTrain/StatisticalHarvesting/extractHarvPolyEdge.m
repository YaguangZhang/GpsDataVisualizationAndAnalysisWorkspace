function [ harvPolyEdgeStaPt, harvPlyEdgeEndPt ] ...
    = extractHarvPolyEdge( x, y, heading, gpsAccuracy, headerWidth )
%EXTRACTHARVPOLYEDGE Extract the edge for the UTM GPS sample (x,y).
%
% The result will be a line segment that is perpendicular to the heading
% direction and with lenght 3 standard dev of the GPS sample + headerWidth.
%
% Inputs:
%   - x, y
%     Scalars or vectors. The UTM coordinates of the GPS sample.
%   - heading
%     A scalar or a vector. The heading in the true north east manner. It
%     should be from (0, 360] in degree.
%   - gpsAccuracy
%     A scalar or a vector. The GPS accuracy from the Android app. It
%     represents the horizontal accuracy as the radius of 68% confidence.
%     We will treat it as one standard deviation.
%   - headerWidth
%     A scalar. The width of the combine harvester's header in meters.
%
% Outputs:
%   - harvPolyEdgeStaPt, harvPlyEdgeEndPt
%     The start and end ponts of the resulted line segment, each in the
%     form of [x, y] (if more than 1 input GPS points are provided, this
%     will be one row corresponding the one input point).
%
% Yaguang Zhang, Purdue, 05/22/2017

trucRadius = 3.*gpsAccuracy+headerWidth/2;

% Start point.
leftDir = lefthandSideOfHeading(heading);
harvPolyEdgeStaPt = [x+sind(leftDir).*trucRadius, ...
    y+cosd(leftDir).*trucRadius];

% End point.
rightDir = righthandSideOfHeading(heading);
harvPlyEdgeEndPt = [x+sind(rightDir).*trucRadius, ...
    y+cosd(rightDir).*trucRadius];

% For debugging.
% numOfPt = length(x);
% xs = [harvPolyEdgeStaPt(:,1)';harvPlyEdgeEndPt(:,1)'];
% xs = [xs;nan(1, numOfPt)];
% ys = [harvPolyEdgeStaPt(:,2)';harvPlyEdgeEndPt(:,2)'];
% ys = [ys;nan(1, numOfPt)];
% figure;hold on;
% plot(x,y,'.k');
% plot(harvPolyEdgeStaPt(:,1),harvPolyEdgeStaPt(:,2),'xb');
% plot(harvPlyEdgeEndPt(:,1),harvPlyEdgeEndPt(:,2),'*b');
% plot(xs(:),ys(:),'r');
% hold off;axis equal;

end
% EOF