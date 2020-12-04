function [ mergedFieldShape ] ...
    = mergeGpsAndUtmFieldShapes(fieldShape, ...
    fieldShapeUtm, fieldShapeUtmZone)
%MERGEGPSANDUTMFIELDSHAPES Merge two alphas shapes representing fields
%shapes, one with (lat, lon) as the point elements, the other with UTM (x,
%y) as the point elements.
%
% Inputs:
%   - fieldShape
%     The field shape with (lat, lon) as the point elements.
%   - fieldShapeUtm, fieldShapeUtmZone
%     The field shape with UTM (x, y) as the point elements, and its UTM
%     zone.
%
% Output:
%   - mergedFieldShape
%     The merged field shape with (lat, lon) as the point elements.
%
% Yaguang Zhang, Purdue, 06/04/2019

[numfieldShapeUtmPts, ~] = size(fieldShapeUtm.Points);
[fsUtmLat, fsUtmLon] = utm2deg( ...
    fieldShapeUtm.Points(:,1), fieldShapeUtm.Points(:,2),...
    repmat(fieldShapeUtmZone, numfieldShapeUtmPts, 1));
gpsPts = [fieldShape.Points; fsUtmLon fsUtmLat];

mergedFieldShape = alphaShape(gpsPts);

if fieldShape.Alpha == 0 || fieldShapeUtm.Alpha == 0
    % Boundary only.
    mergedFieldShape.Alpha = 0;
end

end
% EOF