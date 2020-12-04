function [outputPolyshapeLonLat] = ...
    removeSmallSegsInPolyshapeLonLat( ...
    inputPolyshapeLonLat, minAreaAllowed)
%REMOVESMALLSEGSINPOLYSHAPELONLAT Remove segments that are too small
%compared with minAreaAllowed (in m^2) from the input polyshape in the UTM
%system.
%
% Yaguang Zhang, Purdue, 11/02/2020

[xs, ys, curZone] = deg2utmForceOneZone( ...
    inputPolyshapeLonLat.Vertices(:,2),...
    inputPolyshapeLonLat.Vertices(:,1));

inputPolyshapeUtm = polyshape(xs, ys);
inputPolyshapeUtmRegs = regions(inputPolyshapeUtm);
outputPolyshapeUtm = union(inputPolyshapeUtmRegs( ...
    arrayfun(@(r) area(r)>=minAreaAllowed, inputPolyshapeUtmRegs)));

[lats, lons] = utm2deg(outputPolyshapeUtm.Vertices(:,1), ...
    outputPolyshapeUtm.Vertices(:,2), ...
    repmat(curZone, size(outputPolyshapeUtm.Vertices(:,1),1), 1));

outputPolyshapeLonLat = polyshape(lons, lats);
end
% EOF