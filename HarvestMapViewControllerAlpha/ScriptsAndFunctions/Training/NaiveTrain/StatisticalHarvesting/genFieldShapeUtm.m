function [ fieldShapeUtm, utmZone] ...
    = genFieldShapeUtm( fieldShape, newAlpha)
%GENFIELDSHAPEUTM Transfer the alpha shape field shape to the UTM
%coordinate one.
%
% Inputs:
%   - fieldShape
%     The alpha shape specifying the shape of the field. Its Point field is
%     a matrix with each line being the geo-coordinate in the form of (lon,
%     lat).
%   - newAlpha
%     The alpha that will be used for fieldShapeUtm.
%
% Outputs:
%   - fieldShapeUtm
%     The resulted alpha shape with (x,y) recorded in its field Point.
%   - utmZone
%     A 1x4 char vector. The UTM zone for these points. Note that we expect
%     all the points to be in the same zone. Otherwise, the UTM conversion
%     will carried out in the zone where most of the points in
%     fieldShapeUtm are located.
%
% Yaguang Zhang, Purdue, 05/19/2017

fieldShapeUtm = fieldShape;
[xs, ys, zones] = deg2utm(...
    fieldShape.Points(:, 2), ...
    fieldShape.Points(:, 1) ...
    );
% Make sure all UTM coordinates in one field are within the same zone.
try
    if (all(cellfun(@(x) strcmp(zones(1,:),x), num2cell(zones, 2))))
        utmZone = zones(1, :);
    else
        error('Not all UTM coordinates in the field are within the same zone!')
    end
catch e
    disp(e);
    [xs, ys, utmZone] = deg2utmForceOneZone(...
        fieldShape.Points(:, 2), ...
        fieldShape.Points(:, 1) ...
        );
end
fieldShapeUtm.Points = [xs, ys];
fieldShapeUtm.Alpha = newAlpha;

end
% EOF