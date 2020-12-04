function [areaInM2] = areaPolyshapeLonLat(polyshpLonLat)
%AREAPOLYSHAPELONLAT Compute the area of the input (lon, lat) polyshape in
%the UTM system.
%
% Yaguang Zhang, Purdue, 11/03/2020

if area(polyshpLonLat)==0
    areaInM2 = 0;
else
    [xs, ys, ~] = deg2utmForceOneZone( ...
        polyshpLonLat.Vertices(:,2),...
        polyshpLonLat.Vertices(:,1));
    
    areaInM2 = area(polyshape(xs, ys));
end

end
% EOF