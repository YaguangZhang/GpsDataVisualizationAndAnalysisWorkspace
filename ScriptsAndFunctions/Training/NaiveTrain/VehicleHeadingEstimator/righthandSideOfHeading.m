function [ righthandDir ] = righthandSideOfHeading( heading )
%RIGHTHANDSIDEOFHEADING Compute the right hand side direction of heading in true-north east manner.
%
% Input:
%   - heading
%     Matrix with elements from (0, 360] in degree.
%
% Output:
%   - righthandDir
%     Matrix with elements from (0, 360] in degree. They coorespond to the
%     right hand side directions specified by the elements of heading.
%
% Yaguang Zhang, Purdue, 05/22/2017

righthandDir = heading + 90;
boolsInvalid = righthandDir>360;
righthandDir(boolsInvalid) = righthandDir(boolsInvalid)-360;

end
% EOF