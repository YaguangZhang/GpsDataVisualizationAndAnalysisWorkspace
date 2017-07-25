function [ fieldBoundaryShape ] = extractBoundaryFieldShape( fieldShape )
%EXTRACTBOUNDARYFIELDSHAPE Extract the boundary of the alpha input
%alpha shape and generate a new one accordingly.
%
% Input:
%   - fieldShape
%     The input alpha shape representing the field.
%
% Output:
%   - fieldBoundaryShape
%     The resulted new alpha shape only containing the boudary points.
%
% Yaguang Zhang, Purdue, 05/23/2017

[~, boudaryPts] = boundaryFacets(fieldShape);
fieldBoundaryShape = alphaShape(boudaryPts);
% We will set the alpha to be 0 to indicate that this is a boudary.
fieldBoundaryShape.Alpha = 0;

end
% EOF