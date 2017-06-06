function [ cornerLabels ] = detectCorners( file, windowSize )
%DETECTCONERS Detect corners for a GPS track.
%
% Inputs:
%   - file
%     A struct representing the GPS log file. It contains fields like
%     gpsTime, lat, lon, speed, bearing, etc. Please refer to
%     processGpsDataFiles.m for more details.
%   - windowSize
%     An integer to determine how many consecutive samples to inspect in
%     the window.
% Output:
%   - cornerLabels
%     A column vector whose elements are 0 (not a corner), 1 (a normal
%     turn), and 2 (a U / large turn).
%
% Yaguang Zhang, Purdue, 05/22/2017

disp(' => Preprocessing ... ');
tic;

cornerLabels = zeros(length(file.gpsTime),1);

if (nargin<2)
    % The number of consecutive (moving) sample points we look at to find a
    % corner.
    lengthSegToInspect = 30; % 1 sample ~= 1 second.
else
    lengthSegToInspect = windowSize;
end

% Used to test how much angle has been covered by each segment that is
% under inspection.
covRangeProbes = (1:360)';
% Used to determine whether a turn happens and if so, what label should be
% assigned.
minCovRangeForATurn = 70;
minCovRangeForAUTurn = 120;

% If the heading changes too dramatically, we will treat that as noise.
maxValidStepAngle = 45; % In degree.

[ vehHeading, isForwarding, x, y, utmZones, refBearing] ...
    = estimateVehicleHeading( file );

% Get rid of the samples we do not need.
indicesSamplesToInsp = find( ...
    file.speed>0 ...
    & [0;abs(diff(vehHeading))<=maxValidStepAngle] ... todo: Fix this!
    );
vehHeadingToInsp = vehHeading(indicesSamplesToInsp);

% Initialize the storage for the angle ranges covered by the inspected
% samples.
angleRanges = cell(lengthSegToInspect,1);
idxLastSampleToInsp = length(indicesSamplesToInsp)-1;
if (idxLastSampleToInsp<lengthSegToInspect)
    error('Unable to process this GPS track! It may not have enough GPS samples.');
end
for idxSample = 1:(lengthSegToInspect-1)
    angleRanges{idxSample+1} ...
        = genClockwiseHeadingCovRange(vehHeadingToInsp(idxSample), ...
        vehHeadingToInsp(idxSample+1));
end

disp(' => Searching corners ... ');
tic;

infoEveryNumOfSample = ...
    floor(idxLastSampleToInsp/100);
for idxSample = lengthSegToInspect:idxLastSampleToInsp
    if(mod(idxSample,infoEveryNumOfSample) == 0)
        toc;
        disp(['    Progress: ', ...
            num2str(idxSample/idxLastSampleToInsp*100,'%0.2f'),'% (', ...
            num2str(idxSample), '/', ...
            num2str(idxLastSampleToInsp),' samples)']);
        tic;
    end
    angleRanges{mod(idxSample, lengthSegToInspect)+1} ...
        = genClockwiseHeadingCovRange(vehHeadingToInsp(idxSample), ...
        vehHeadingToInsp(idxSample+1));
    % All the angle ranges have been computed. We only need to check
    % whether all the ranges have covered enough to be called a turn.
    totalRangeCovered = sum(arrayfun(@(heading) ...
        any(cellfun(@(x) ...
        headingCoveredByClockwiseRange(heading, x(1), x(2)), ...
        angleRanges)), covRangeProbes));
    if (totalRangeCovered>minCovRangeForATurn)
        indicesToLabel = indicesSamplesToInsp(...
            (idxSample-lengthSegToInspect+1):idxSample);
        if (totalRangeCovered>minCovRangeForAUTurn)
            % A U turn: label 2.
            cornerLabels(indicesToLabel) = 2;
        else
            % A turn: label 1 if it has not been labeled yet.
            boolsNotOkToLabel = cornerLabels(indicesToLabel) > 0;
            
            indicesToLabel(boolsNotOkToLabel) = [];
            cornerLabels(indicesToLabel) = 1;
        end
    end
end
toc; disp('Done!')
% EOF