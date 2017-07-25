function [ lefthandDir ] = lefthandSideOfHeading( heading )
%LEFTHANDSIDEOFHEADING Compute the left hand side direction of heading in true-north east manner.
%
% Input:
%   - heading
%     Matrix with elements from (0, 360] in degree.
%
% Output:
%   - lefthandDir
%     Matrix with elements from (0, 360] in degree. They coorespond to the
%     left hand side directions specified by the elements of heading.
%
% Yaguang Zhang, Purdue, 05/22/2017

lefthandDir = heading - 90;
boolsInvalid = lefthandDir<=0;
lefthandDir(boolsInvalid) = lefthandDir(boolsInvalid)+360;

end
% EOF