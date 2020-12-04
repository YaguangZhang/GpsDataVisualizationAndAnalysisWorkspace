function [hHistGps] = plotHistGps( ...
    lons, lats, color, markerSize, alpha)
%PLOTHISTGPS Plot history GPS data (lons, lats) for the progress monitoring
%plot with specified color, markerSize, and transparency alpha.
%
% Yaguang Zhang, Purdue, 11/04/2020
if ~isempty(lons)
    hHistGps = plot(lons, lats, ...
        '.', 'Color', color, 'MarkerSize', markerSize);
    hHistGps.Color(4) = alpha;
else
    hHistGps = [];
end
end
% EOF