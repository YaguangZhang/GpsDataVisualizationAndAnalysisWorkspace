function [ vehHeading, isForwarding, x, y, utmZones, refBearing, ...
    hFigArrOnTrack, hFigDiffHist, hFigMap] ...
    = estimateVehicleHeading( file, DEBUG )
%ESTIMATEVEHICLEHEADING Estimate the heading of the vehicle according to
%its GPS log file.
%
% Inputs:
%   - file
%     A struct representing the GPS log file. It contains fields like
%     gpsTime, lat, lon, speed, bearing, etc. Please refer to
%     processGpsDataFiles.m for more details.
%   - DEBUG
%     Enable debug mode and generate plots.
%
% Outputs:
%   - vehHeading
%     A vector containing the estimated direction of the vehicle's heading.
%     The elements should be numbers from (0, 360] in degrees, representing
%     the clockwise angles from north to the direction to which the vehicle
%     is heading. Each element corresponds to one GPS sample in the input
%     file (will be NaN if not able to get an estimation for that GPS
%     sample).
%   - isForwarding
%     The labels for whether the samples are considered as moving forward.
%   - x, y, utmZones
%     Column vectors representing the UTM coordinates and UTM Zones
%     (strings) for the GPS coordinates specified by the input file.
%   - refBearing
%     As a comparison, the bearing of the GPS samples will be stored in
%     this column vector variable. For our dataset, the GPS samples were
%     gotten via an Android app. In this case, the elements in this vector
%     should be from (0, 360] (Note that we replace 0, which represents
%     bearing not available in Android, with NaN, to make this vector
%     structured the same as vehHeading).
%   - hFigArrOnTrack, hFigDiffHist, hFigMap
%     For debugging: hFigs contains the figures generated if the input
%     DEBUG flag is set to be true.
%
% Requires the external Matlab function deg2utm.m (available online).
%
% Yaguang Zhang, Purdue, 05/17/2017

if (nargin < 2)
    DEBUG = false;
    hFigArrOnTrack = nan;
    hFigDiffHist = nan;
end

MIN_NUM_SAMPLES_EXPECTED = 60; % 1 sample corresponds to ~ 1 second.
MAX_TIME_BACKING = 60000; % In miliseconds.

if length(file.lat)<MIN_NUM_SAMPLES_EXPECTED
    warning(['The GPS track specified by file may be too short to ',...
        'generate reasonable estimations for the vehicle heading.']);
end

vehHeading = nan(length(file.lat),1);
[x, y, utmZones] = deg2utm(file.lat, file.lon);
refBearing = file.bearing;
refBearing(refBearing==0) = nan;

%% Initial estimation of vehHeading according to (x, y).
% Note that we can use the UTM coordinates for different points only if
% they are in the same UTM zone.
utmZonesCell = mat2cell(utmZones, ones(1, length(x)));
utmZonesInvolved = utmZonesCell(1);

for idxZone = 2:length(utmZonesCell)
    zone = utmZonesCell(idxZone);
    if(~ismember(zone,utmZonesInvolved))
        utmZonesInvolved(end+1) = zone; %#ok<AGROW>
    end
end
[~, zoneIds] = ismember(utmZonesCell,utmZonesInvolved);
[indicesStarts, indicesEnds, ~] = findConsecutiveSubSeqs(zoneIds);
for idxConZone = 1:length(indicesStarts)
    % Use (x,y) of the sample and that for the next sample to get the
    % initial heading angle.
    for idxSample = indicesStarts(idxConZone):(indicesEnds(idxConZone)-1)
        % Discard the vehHeading for samples with speed 0 or is going to
        % stop for the next sample. The second condition will avoid
        % disturbance by not-very-trustworthy zero-speed end sample for
        % estimating the instant heading.
        if(all(file.speed(idxSample:(idxSample+1))~=0))
            % Also map the angle to True-North East angles.
            deltaX = x(idxSample+1)-x(idxSample);
            deltaY = y(idxSample+1)-y(idxSample);
            % Flip the x & y for easier mapping later.
            vehHeading(idxSample) = rad2deg(atan2(deltaX, deltaY));
        end
    end
end
vehHeadingNeg = vehHeading<0;
vehHeading(vehHeadingNeg) = vehHeading(vehHeadingNeg) + 360;

% Make sure we have labeled the data set with some valid headings.
if (all(isnan(vehHeading)))
    warning('Unable to mark the data because no valid heading is generated!');
end

%% Mark the moving direction as F(orwarding) / B(ackwarding).

% Labels for isForwarding
%   1: forwarding by long enough subsequence with estimated headings; 1.5:
%   forwarding by (no 1 but) longest subsequence with estimated headings;
%   0: undtermined; 2/-2: forwarding / backing up and extended according to
%   adjacent past forwarding (1) samples; 3/-3: backing up and extended
%   according to adjacent future forwarding (1) samples; 4/-4: Forwarding /
%   Backing up in the start part; 5/-5: Forwarding / Backing up in
%   remaining gaps. 6/-6: Forwarding / Backing up in for remaining
%   unlabeled samples.
% Priority (or confidence of label correctness)
%   1 > 1.5 > 2 = -2 > 3 = -3 > 4 = -4 > 5 = -5 > 6 = -6
isForwarding = zeros(length(vehHeading), 1);
vehHeadingValid = ones(length(vehHeading), 1);
vehHeadingValid(isnan(vehHeading)) = 0;

% Mark long enough consecutive subsequences with valid angles as
% forwarding.
[indicesStarts, indicesEnds, valuesVehHeadingValid] = ...
    findConsecutiveSubSeqs(vehHeadingValid);

% Make sure we have some subsequences to start with.
if (isempty(indicesStarts))
    warning('Unable to mark the data! There may be too few moving samples.');
end

for idxConMov = 1:length(indicesStarts)
    if (valuesVehHeadingValid(idxConMov) ...
            && (file.gpsTime(indicesEnds(idxConMov)) ...
            - file.gpsTime(indicesStarts(idxConMov)))>MAX_TIME_BACKING )
        isForwarding(...
            indicesStarts(idxConMov):indicesEnds(idxConMov)...
            ) = 1; % Forwarding.
    end
end

% Treat the longest subsequence as forwarding if there is no long enough
% sequence at all.
if (all(isForwarding==0))
    indicesSubSeqWithHeading = find(valuesVehHeadingValid == 1);
    if (isempty(indicesSubSeqWithHeading))
        indicesSubSeqWithHeading = 1:length(valuesVehHeadingValid);
    end
    [~, idxLongestSubseq] = max(indicesEnds(indicesSubSeqWithHeading) ...
        -indicesStarts(indicesSubSeqWithHeading));
    idxTheChosenSubSeq = indicesSubSeqWithHeading(idxLongestSubseq);
    isForwarding(indicesStarts(idxTheChosenSubSeq)...
        :indicesEnds(idxTheChosenSubSeq)) = 1.5;
end

% Extend the labels for the forwarding subsequences forward and backward
% (only) once. First, for forwarding. TODO: restructure this and the next
% procedures to better (e.g. get rid of the subsequences without valid
% estimated headings first).
for idxConMov = 1:length(indicesStarts)
    if (isForwarding(indicesStarts(idxConMov))==1)
        % A marked forwarding subsequence. Extend the last history angle of
        % a forwarding consecutive subsequence to the future when possible.
        idxConMovRef = idxConMov;
        idxNextConMov = idxConMov+1;
        if idxNextConMov <= length(indicesStarts)
            % Always extend the last history label (1) to the samples
            % between these two subsequences.
            isForwarding((indicesEnds(idxConMovRef)+1) ...
                :(indicesStarts(idxNextConMov)-1)) = 2;
            vehHeading((indicesEnds(idxConMovRef)+1) ...
                :(indicesStarts(idxNextConMov)-1)) = ...
                vehHeading(indicesEnds(idxConMovRef));
            % Only need to label NextConMov if it is not labeled yet.
            if (isForwarding(indicesStarts(idxNextConMov))==0)
                if (~valuesVehHeadingValid(idxNextConMov))
                    % No valid heading available for this subsquece. Label
                    % relavant samples according to the last history label
                    % (1), too.
                    isForwarding(indicesStarts(idxNextConMov) ...
                        :indicesEnds(idxNextConMov)) = 2;
                    vehHeading(indicesStarts(idxNextConMov) ...
                        :indicesEnds(idxNextConMov)) = ...
                        vehHeading(indicesEnds(idxConMovRef));
                else
                    % A subsequence not labeled yet, but with esimated
                    % headings available. Compare the samples to determine
                    % whether a back-up movement is happening. Note that we
                    % use 2 samples because at least 2 samples are
                    % available for any consecutive subsequence.
                    if (isVehMovOpp( mean([ ...
                            vehHeading(indicesEnds(idxConMovRef)), ...
                            vehHeading(indicesEnds(idxConMovRef)-1) ...
                            ]), mean([ ...
                            vehHeading(indicesStarts(idxNextConMov)), ...
                            vehHeading(indicesStarts(idxNextConMov)+1) ...
                            ])))
                        % The vehicle is backing up.
                        isForwarding(indicesStarts(idxNextConMov) ...
                            :indicesEnds(idxNextConMov)) = -2;
                    else
                        % The vehicle is still moving forward.
                        isForwarding(indicesStarts(idxNextConMov) ...
                            :indicesEnds(idxNextConMov)) = 2;
                    end
                end
            end
        end
    end
end

% Then, similarly for the past. Note that to determine whether a sample has
% been considered already, valuesVehHeadingValid is not appropriate
% anymore. We will use isForwarding instead.
for idxConMov = 1:length(indicesStarts)
    if (isForwarding(indicesStarts(idxConMov))==1)
        % A marked forwarding subsequence. Extend the first angle of this
        % forwarding consecutive subsequence to the past when possible.
        idxConMovRef = idxConMov;
        idxPreConMov = idxConMov-1;
        if (idxPreConMov>0)
            % Only need to label PreConMov if it is not labeled yet.
            if(isForwarding(indicesEnds(idxPreConMov))==0)
                if (~valuesVehHeadingValid(idxPreConMov))
                    % No valid heading available for this subsquece and it
                    % is not labeled yet. Label relavant samples using the
                    % first label for the subsequence #idxConMovRef, too.
                    isForwarding(indicesStarts(idxPreConMov) ...
                        :indicesEnds(idxPreConMov)) = 3;
                    vehHeading(indicesStarts(idxPreConMov) ...
                        :indicesEnds(idxPreConMov)) = ...
                        vehHeading(indicesStarts(idxConMovRef));
                else
                    % Estimated heading available and it is a subsequence
                    % not labeled yet. Compare the samples to determine
                    % whether a back-up movement is happening. Note that we
                    % use 2 samples because at least 2 samples are
                    % available for any consecutive subsequence.
                    if (isVehMovOpp( mean([ ...
                            vehHeading(indicesEnds(idxPreConMov)), ...
                            vehHeading(indicesEnds(idxPreConMov)-1) ...
                            ]), mean([ ...
                            vehHeading(indicesStarts(idxConMovRef)), ...
                            vehHeading(indicesStarts(idxConMovRef)+1) ...
                            ])))
                        % The vehicle is backing up.
                        isForwarding(indicesStarts(idxPreConMov) ...
                            :indicesEnds(idxPreConMov)) = -3;
                    else
                        % The vehicle is still moving forward.
                        isForwarding(indicesStarts(idxPreConMov) ...
                            :indicesEnds(idxPreConMov)) = 3;
                    end
                end
            end
            % Only extend the last label of PreConMov to the samples
            % between PreConMov and the forwarding subsequence if they are
            % not labeled yet.
            indicesToLabel = (indicesEnds(idxPreConMov)+1) ...
                :(indicesStarts(idxConMovRef)-1);
            mask = find(isForwarding(indicesToLabel) == 0) ...
                +indicesEnds(idxPreConMov);
            indicesToSet = intersect(indicesToLabel, mask);
            isForwarding(indicesToSet) = 3 ...
                *sign(isForwarding(indicesEnds(idxPreConMov)));
            vehHeading(indicesToSet) = ...
                vehHeading(indicesEnds(idxPreConMov));
        end
    end
end

% Fill the start part if necessary.
if isForwarding(1)==0
    % Find the not labeled start part.
    idxLastToLabel = find(isForwarding~=0, 1)-1;
    % Find the subsequences with vehHeading in this range.
    [indicesStartsS, indicesEndsS, valuesVehHeadingValidS] = ...
        findConsecutiveSubSeqs(vehHeadingValid(1:idxLastToLabel));
    boolsInvalidHeading = valuesVehHeadingValidS ==0;
    indicesStartsS(boolsInvalidHeading) = [];
    indicesEndsS(boolsInvalidHeading) = [];
    % No subsequence found: label all.
    if isempty(indicesStartsS)
        isForwarding(1:idxLastToLabel) = 4* ...
            sign(isForwarding(idxLastToLabel+1));
        vehHeading(1:idxLastToLabel) = vehHeading(idxLastToLabel+1);
    else
        % Label the end of the start part if necessary.
        indicesToLabel = (indicesEndsS(end)+1):idxLastToLabel;
        isForwarding(indicesToLabel) = 4* ...
            sign(isForwarding(idxLastToLabel+1));
        vehHeading(indicesToLabel) = vehHeading(idxLastToLabel+1);
        % Label the subsequences one by one backwards.
        idxRefSample = idxLastToLabel+1;
        for idxSubSeqS = length(indicesStartsS):-1:1
            % Label this subsequence. In this case, we will only compare
            % one sample (instead of the mean of two) because we only want
            % to assume that the sample right after this subsequence is
            % labeled.
            if (isVehMovOpp(vehHeading(indicesEndsS(idxSubSeqS)), ...
                    vehHeading(idxRefSample)))
                % Label as the opposite.
                indicesToSet = indicesStartsS(idxSubSeqS)...
                    :indicesEndsS(idxSubSeqS);
                isForwarding(indicesToSet) ...
                    = -4*sign(isForwarding(indicesEndsS(idxSubSeqS)+1));
            else
                % Label as the same.
                isForwarding(indicesStartsS(idxSubSeqS)...
                    :indicesEndsS(idxSubSeqS)) ...
                    = 4*sign(isForwarding(indicesEndsS(idxSubSeqS)+1));
            end
            
            % Always label the samples between this subsequence and the
            % previous one if there are any.
            if idxSubSeqS ~= 1
                indicesToLabel = (indicesEndsS(idxSubSeqS-1)+1)...
                    :(indicesStartsS(idxSubSeqS)-1);
            else
                indicesToLabel = 1:(indicesStartsS(idxSubSeqS)-1);
            end
            isForwarding(indicesToLabel) ...
                = 4*sign(isForwarding(indicesStartsS(idxSubSeqS)));
            vehHeading(indicesToLabel) ...
                = vehHeading(indicesStartsS(idxSubSeqS));
            
            idxRefSample = indicesStartsS(idxSubSeqS);
        end
    end
end

% We should be done for normal situations. But just in case, fill the
% unlabeled gaps by keeping track of the heading in the gap. We first need
% to locate those gaps.
notSetYet = isForwarding == 0;
[indicesStartsG, indicesEndsG, valuesVehHeadingValidG] = ...
    findConsecutiveSubSeqs(notSetYet);
if(~isempty(indicesStartsG))
    % Get rid of the labeled subsequences so that we only need to worry
    % about the un-labeled gaps.
    indicesNotGaps = valuesVehHeadingValidG==0;
    indicesStartsG(indicesNotGaps) = [];
    indicesEndsG(indicesNotGaps) = [];
    for idxGap = 1:length(indicesStartsG)
        idxFirstToLabel = indicesStartsG(idxGap);
        % Note that a gap in the middle amd the gap at the very end (if
        % that part is a gap) can be treated exactly the same using our
        % algorithm.
        idxLastToLabel = indicesEndsG(idxGap);
        % Find all the consecutive subsequences with vehHeading in the gap.
        indicesToLabel = idxFirstToLabel:idxLastToLabel;
        [indicesStartsGS, indicesEndsGS, valuesVehHeadingValidGS] = ...
            findConsecutiveSubSeqs(...
            vehHeadingValid(indicesToLabel));
        boolsInvalidHeading = valuesVehHeadingValidGS ==0;
        indicesStartsGS(boolsInvalidHeading) = [];
        indicesEndsGS(boolsInvalidHeading) = [];
        if (isempty(indicesStartsGS))
            % No convincing estimated heading available for this gap. Just
            % mark all as the sample right before this gap.
            isForwarding(indicesToLabel) ...
                = 5*sign(isForwarding(idxFirstToLabel-1));
            vehHeading(indicesToLabel) ...
                = vehHeading(idxFirstToLabel-1);
        else
            % Mark these subsequences one by one. Because we have filled
            % the start part, the sample right before the gap should be
            % labeled already and we will use it as the reference point.
            idxRefSample = idxFirstToLabel-1;
            for idxSubSeqGS = 1:length(indicesStartsGS)
                subSeqGSStart = indicesToLabel(...
                    indicesStartsGS(idxSubSeqGS));
                subSeqGSEnd = indicesToLabel(...
                    indicesEndsGS(idxSubSeqGS));
                
                % Always label the samples between the reference sample and
                % this gap subsequence first.
                indicesToSet = (idxRefSample+1):(subSeqGSStart-1);
                isForwarding(indicesToSet) ...
                    = 5*sign(isForwarding(idxRefSample));
                vehHeading(indicesToSet) ...
                    = vehHeading(idxRefSample);
                
                % Determine the direction of this gap compared to the
                % sample right before it.
                indicesToSet = subSeqGSStart:subSeqGSEnd;
                if(isVehMovOpp(vehHeading(idxRefSample), ...
                        vehHeading(subSeqGSStart)))
                    % Opposite.
                    isForwarding(indicesToSet) ...
                        = -5*sign(isForwarding(idxRefSample));
                else
                    % The same.
                    isForwarding(indicesToSet) ...
                        = 5*sign(isForwarding(idxRefSample));
                end
                
                % Update idxRefSample.
                idxRefSample = subSeqGSEnd;
            end
        end
    end
end

% Also need to fill angles that are still invalid in vehHeading. This will
% happen occasionally because we process the whole dataset in terms of
% subsequences and each valid subsequnce has at least 2 sample points. In
% other words, single points that are not able to be grouped in any
% subsequences may be left unlabeled.
if(any(isForwarding == 0))
    boolsNotLabeled = isForwarding == 0;
    % warning(' => Not all samples are labeled after the algorithm!');
    for idxSampleToSet = find(boolsNotLabeled)
        % Simply set these point according to its adjacent past one.
        isForwarding(idxSampleToSet) = 6* ...
            sign(isForwarding(idxSampleToSet-1));
        if(isnan(vehHeading(idxSampleToSet)))
            vehHeading(idxSampleToSet) = vehHeading(idxSampleToSet-1);
        end
    end
end

% if(any(isForwarding == 0))
%     boolsNotLabeled = isForwarding == 0; % warning(' => Not all samples
%     are labeled after the algorithm!'); for idxSampleToSet =
%     find(boolsNotLabeled)
%         % Simply set these point according to its closest labeled sample
%         in % the past. mask = true(length(isForwarding),1);
%         mask((idxSampleToSet+1):end) = false; find(isForwarding == 0 &
%         mask,'last'); isForwarding(idxSampleToSet) = 6* ...
%             sign(isForwarding(idxSampleToSet-1));
%         if(isnan(vehHeading(idxSampleToSet)))
%             vehHeading(idxSampleToSet) = vehHeading(idxSampleToSet-1);
%         end
%     end
% end

% At last, actually reverse when necessary (isForwarding < 0).
indicesToReverse = isForwarding<0;
if(DEBUG)
    veHeadingOri = vehHeading;
end
vehHeading(indicesToReverse) ...
    = oppositeHeading(vehHeading(indicesToReverse));


%% Plot the GPS track on a map if DEBUG == true.
if DEBUG
    hFigArrOnTrack = figure; hold on;
    arrowLength = 5; % In meter.
    
    % GPS track.
    h1 = plot(x, y, '.b');
    % End point.
    h2 = plot(x(end), y(end), '*b');
    text(x(end), y(end), 'End');
    % Zero-speed points.
    boolsZeroSpeed = file.speed==0;
    h2_1 = plot(x(boolsZeroSpeed), y(boolsZeroSpeed), '.r');
    
    % vehHeading. Change the plotting method for better performance.
    %   h3 = plot([x';x'+arrowLength.*sin(vehHeading'/180*pi)], ...
    %      [y';y'+arrowLength.*cos(vehHeading'/180*pi)], '-k');
    tempX = [x';x'+arrowLength.*sin(vehHeading'/180*pi);nan(1,length(x))];
    tempY = [y';y'+arrowLength.*cos(vehHeading'/180*pi);nan(1,length(y))];
    h3 = plot(tempX(:), tempY(:), '-k');
    % For debugging: mark vehHeading. text(x,y,num2str(vehHeading,'%.1f'),
    % 'FontSize', 13); For debugging: mark isForwarding.
    text(x,y,num2str(isForwarding), 'FontSize', 9);
    
    % Bearing. h4 = plot([x';x'+arrowLength.*sin(refBearing'/180*pi)], ...
    %     [y';y'+arrowLength.*cos(refBearing'/180*pi)], '-r');
    tempX = [x';x'+arrowLength.*sin(refBearing'/180*pi);nan(1,length(x))];
    tempY = [y';y'+arrowLength.*cos(refBearing'/180*pi);nan(1,length(y))];
    h4 = plot(tempX(:), tempY(:), '--r');
    
    % For debugging: show the samples that do not receive any labels after
    % our algorithm.
    if(exist('boolsNotLabeled', 'var'))
        plot(x(boolsNotLabeled), y(boolsNotLabeled), 'or', ...
            'LineWidth', 3);
    end
    
    legend([h1,h2,h2_1,h3,h4], ...
        {'Track','End Point','Zero Speed','vehHeading','refBearing'});
    title('Estimated Vehicle Heading (Black) and Bearing (Red)');
    hold off; axis equal;
    
    hFigDiffHist = figure;
    histogram(veHeadingOri-refBearing, 'BinWidth', 1);
    xlimCur = xlim;
    xlim([max([xlimCur(1), -360]), min([xlimCur(2), 360])]);
    xlabel('Bearing difference (Degree)'); ylabel('Number of samples');
    title('Histogram for veHeadingOri-refBearing');
    
    hFigMap = figure; hold on;
    boolsForwarding = isForwarding>0;
    hF = plot(file.lon(boolsForwarding),file.lat(boolsForwarding), '.b');
    boolsBackingUp = isForwarding<0;
    hB = plot(file.lon(boolsBackingUp),file.lat(boolsBackingUp), '.y');
    boolsNotLabeled = isForwarding == 0;
    plot(file.lon(boolsNotLabeled),file.lat(boolsNotLabeled), 'xr');
    plot_google_map('MapType','satellite');
    legend([hF, hB], {'Forwarding', 'Backing Up'});
    title('GPS Track on Map');
end

end
% EOF