function d = fieldDiameter(lat,lon)
% FIELDDIAMETER Get the size of the field in meters.
%
% This function will find the furthest 2-point pair in the coordiniate data
% set and compute the distance between them in meters.
%
% Yaguang Zhang, Purdue, 03/14/2015

% Treat longitude as x and latitude as y.
cHull = convhull(lon,lat);
xPair = lon(cHull);
yPair = lat(cHull);

sizeDist = size(xPair,1);
d = 0;
for i = 1:sizeDist-1
    for j = i+1:sizeDist
        distTemp = 1000*lldistkm([yPair(i) xPair(i)], [yPair(j) xPair(j)]);
        d = max(d,distTemp);
    end
end

end

% EOF