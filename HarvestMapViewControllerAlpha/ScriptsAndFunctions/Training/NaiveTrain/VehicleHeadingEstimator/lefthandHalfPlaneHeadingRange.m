function [ lefthandAngRange ] = lefthandHalfPlaneHeadingRange( heading )
%LEFTHANDHALFPLANEHEADINGRANGE Compute the angle range of the left hand
%side half plane of the input heading in true-north east manner.
%
% Input:
%   - heading
%     A scalar from (0, 360] in degree.
%
% Output:
%   - lefthandAngRange
%     One 2x2 Matrix with elements from (0, 360] in degree. Each colomn
%     cooresponds to an angle range (min, max) within which all the angles
%     are considered as in the left-hand half plane.
%
% Note: one should check whether an angle is in either range (column) using
% login OR.
%
% Yaguang Zhang, Purdue, 07/05/2017

lefthandAngRange = [inf, inf; -inf -inf];
if heading>180 && heading <=360
    lefthandAngRange(:,1) = [heading-180, heading];
else
    lefthandAngRange = [heading+180, 0;360, heading];
end

end
% EOF