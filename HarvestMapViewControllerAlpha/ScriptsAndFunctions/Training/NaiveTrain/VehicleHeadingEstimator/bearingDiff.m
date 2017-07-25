function [ diff ] = bearingDiff( bearing1, bearing2, USE_DEGREE )
%BEARINGDIFF Compute the angle difference for twp bearings.
%
% Input:
%   - bearing1, bearing2
%     We will treat bearing1 as the reference direction, and compute the
%     angle from it to the direction specified by bearing2.
%
% Outputs:
%   - diff
%     The angle from bearing1 to beaing2. By default, this should be from
%     [0, 180] degrees for counter clockwise rotation, and (-180, 0) for
%     clockwise rotation. If USE_DEGREE is set to be true, radian will be
%     used as diff's unit.
%
% Yaguang Zhang, Purdue, 05/17/2017

if nargin < 3
    USE_DEGREE = false;
end
[ x, y ] = pol2cart(degtorad(bearing1-bearing2), 1);
[ diff , ~ ] = cart2pol( x , y );

if USE_DEGREE
    diff = radtodeg(diff);
end

end
% EOF