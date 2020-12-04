function [roadAlphaShapeUtm ] ...
    = genRoadAlphaShapeUtmFromTruckXYSpeeds( ...
    truckXYSpeeds, maxSpeedInField, extraXysOnRoad, ...
    roadTileDistDelta, maxSpeedOnRoad, sampleRateInHz)
%GENROADALPHASHAPEUTMFROMTRUCKXYSPEEDS Generate an alpha shape for the
%roads based on the truck GPS tracks in UTM.
%
% We will locate the truck GPS points with a speed higher than
% maxSpeedInField (i.e., for sure on the road) and include a small area
% around it as on the road.
%
% Inputs:
%   - truckXYSpeeds
%     GPS record [xs, ys, speeds] for trucks. Note that all the data should
%     be in the same UTM zone.
%   - maxSpeedInField
%     The max speed a truck can run in a field in m/s.
%   - extraXysOnRoad
%     Optional. Kown on-road GPS data [xs, ys] in the same UTM zone.
%   - roadTileDistDelta
%     Optional. For each point, we will include eight more points (up,
%     upper right, right, lower right, down, ...) to the orignal one, with
%     the distance roadTileDistDelta in meter.
%   - maxSpeedOnRoad
%     Optional. The max speed a truck can run on the road in m/s. This
%     value will be used as alpha in creating the road shape.
%   - sampleRateInHz
%     Optional. Used to convert sample number to time. Default to 1
%     sample/s.
%
% Outputs:
%   - roadAlphaShapeUtm
%     The output alpha shape in the UTM (x,y) system for the roads.
%
% Yaguang Zhang, Purdue, 11/01/2020

%% Parameters

% Gaps between on-road samples with element numbers smaller than this will
% be filled.
MAX_GAP_TIME_LENGTH_TO_FILL_IN_S = 120;

if ~exist('roadTileDistDelta', 'var')
    roadTileDistDelta = 3; % In meters.
end

if ~exist('maxSpeedOnRoad', 'var')
    maxSpeedOnRoad = 30; % In m/s. Used as alpha.
end

if ~exist('sampleRate', 'var')
    sampleRateInHz = 1; % In samples/s.
end

%% Locate On-Road Samples

boolsOnRoad = truckXYSpeeds(:, 3)>maxSpeedInField;
% We will also fill in small gaps.
maxSampNumForGapsToFill = MAX_GAP_TIME_LENGTH_TO_FILL_IN_S*sampleRateInHz;
[indicesGapStarts, indicesGapEnds] = findConsecutiveSubSeq(boolsOnRoad, 0);
for idxGap = 1:length(indicesGapStarts)
    curIdxGapStart = indicesGapStarts(idxGap);
    curIdxGapEnd = indicesGapEnds(idxGap);
    if (curIdxGapEnd-curIdxGapStart+1)<=maxSampNumForGapsToFill
        boolsOnRoad(curIdxGapEnd:curIdxGapStart) = true;
    end
end

xs = truckXYSpeeds(boolsOnRoad, 1);
ys = truckXYSpeeds(boolsOnRoad, 2);

if exist('extraXysOnRoad', 'var')
    if ~isempty(extraXysOnRoad)
        xs = [xs; extraXysOnRoad(:,1)];
        ys = [ys; extraXysOnRoad(:,2)];
    end
end

%% Construct the Alpha Shape in UTM

[xs, ys] = duplicatePtsInEightDirs(xs, ys, roadTileDistDelta);
roadAlphaShapeUtm = alphaShape(xs, ys, maxSpeedOnRoad);

end
% EOF