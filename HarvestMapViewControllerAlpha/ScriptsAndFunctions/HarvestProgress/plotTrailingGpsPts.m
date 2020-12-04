function [handle] = plotTrailingGpsPts(allGpstimeLonLats, ...
    curGpsTimeInMs, NUM_OF_TRAILING_GPS_PTS, ...
    TRAILING_GPS_PTS_SIZE_RANGE, COLOR, FLAG_VARING_OPACITY)
%PLOTTRAILINGGPSPTS Plot the trailing GPS points.
%
% We will gradually reduce the size (and opacity if FLAG_VARING_OPACITY is
% true) of the points at past. Note: the AlphaData feature for scatter
% plots was tested in Matlab 2020b.
%
% Inputs:
%   - allGpstimeLonLats
%     The GPS records of interest in the format of [GPS time (ms), lons,
%     lats].
%   - curGpsTimeInMs
%     The simulated current time in millisecond.
%   - NUM_OF_TRAILING_GPS_PTS
%     Number of history GPS points to show, including the present one.
%   - TRAILING_GPS_PTS_SIZE_RANGE
%     The [minSize, maxSize] for the marker to be used for the GPS points.
%   - COLOR
%     The color for the markers representing the GPS points.
%
% Yaguang Zhang, Purdue, 11/03/2020

if ~exist('FLAG_VARING_OPACITY', 'var')
    FLAG_VARING_OPACITY = true;
end

% Find the markers to show.
indicesPtsToShow = find(allGpstimeLonLats(:,1)<=curGpsTimeInMs, ...
    NUM_OF_TRAILING_GPS_PTS, 'last');

ptsToShowLonLat = allGpstimeLonLats(indicesPtsToShow, 2:3);
numPtsAvailable = length(indicesPtsToShow);
indicesPtsAvailabe = (NUM_OF_TRAILING_GPS_PTS-numPtsAvailable+1 ...
    ):NUM_OF_TRAILING_GPS_PTS;

ptsSize = linspace(TRAILING_GPS_PTS_SIZE_RANGE(1), ...
    TRAILING_GPS_PTS_SIZE_RANGE(2), NUM_OF_TRAILING_GPS_PTS);

handle = scatter(ptsToShowLonLat(:, 1), ptsToShowLonLat(:, 2), ...
    ptsSize(indicesPtsAvailabe), COLOR, 'filled');

if FLAG_VARING_OPACITY
    ptsAlpha = linspace(0, 1, NUM_OF_TRAILING_GPS_PTS+1);
    ptsAlpha = ptsAlpha(2:end);
    handle.AlphaData = ptsAlpha(indicesPtsAvailabe);
    handle.MarkerFaceAlpha = 'flat';
end
end
% EOF