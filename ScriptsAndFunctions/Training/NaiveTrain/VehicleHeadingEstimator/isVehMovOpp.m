function [ decision ] = isVehMovOpp( bearingForward, bearing )
%ISVEHMOVOPP Determine whether the direction specified by bearing is
%backward to that by bearingForward.
%
% Input:
%   - bearingForward, bearing
%     We will treat bearingForward as the reference direction, and decide
%     whether the angle specified by bearing is the corresponding
%     "opposite" / "backward" direction. They should be angles from (0,
%     360] in degree.
%
% Outputs:
%   - decision
%     True if the vehicle is moving to the opposite direction; false if the
%     vehicle is moving towards the same direction.
%
% Yaguang Zhang, Purdue, 05/17/2017

decision = false;
bDiff = bearingDiff(bearingForward, bearing, true);
if (bDiff>90 || bDiff<-90)
    decision = true;
end

end
% EOF