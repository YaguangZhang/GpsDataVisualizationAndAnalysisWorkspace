function [ inLefthandHalfPlane ] = angleInLefthandHalfPlaneOfHeading( angles, headings )
%ANGLEINLEFTHANDHALFPLANEOFHEADING Check whether the input angles are in
%the left-hand-side half plane of the corresponding heading.
%
% Input:
%   - angles
%     Matrix with elements from (0, 360] in degree.
%   - headings
%     Matrix with elements from (0, 360] in degree. Each element will be
%     used for the angle with the same index in angles.
%
% Output:
%   - inLefthandHalfPlane
%     Booleans of the result.
%
% Yaguang Zhang, Purdue, 07/05/2017

assert(length(angles)==length(headings));

lefthandHalfPlaneAngRanges = arrayfun(...
    @(x) lefthandHalfPlaneHeadingRange(x), headings, ...
    'UniformOutput', false);
inLefthandHalfPlane = arrayfun(@(idx) ...
    (angles(idx)>lefthandHalfPlaneAngRanges{idx}(1,1) ...
    && angles(idx)<lefthandHalfPlaneAngRanges{idx}(2,1)) ...
    || (angles(idx)>lefthandHalfPlaneAngRanges{idx}(1,2) ...
    && angles(idx)<lefthandHalfPlaneAngRanges{idx}(2,2)), ...
    1:length(headings));

end
% EOF