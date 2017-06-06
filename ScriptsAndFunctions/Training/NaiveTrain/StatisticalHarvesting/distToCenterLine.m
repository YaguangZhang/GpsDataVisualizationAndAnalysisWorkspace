function [ dist ] = distToCenterLine( x, y, x0, y0, heading )
%DISTTOCENTERLINE Compute the distance from (x,y) to the line specified by
%point (x0, y0) and the heading.
%
% Inputs:
%   - x, y
%     Scalars or vectors. The input point(s).
%   - x0, y0
%     Scalars. The reference point on the line.
%   - heading
%     A scalar from (0, 360]. The true north east angle for the line.
%
% Output:
%   - dist
%     The resulted distance.
%
% Yaguang Zhang, Purdue, 05/22/2017

% We know the reference point is already on the line.
x1 = x0;
y1 = y0; 
% Get another reference point on the line.
x2 = x0*(1+sind(heading));
y2 = y0*(1+cosd(heading)); 

dist = abs((y2-y1).*x - (x2-x1).*y + x2*y1 - y2*x1) ...
    ./sqrt((y2-y1)^2+(x2-x1)^2);

end
% EOF