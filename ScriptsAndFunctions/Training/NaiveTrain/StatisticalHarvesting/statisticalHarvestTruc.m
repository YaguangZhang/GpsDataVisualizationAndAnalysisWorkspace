function [ harvestedPts, fieldShapeUtm, fieldShapeUtmZone ] ...
    = statisticalHarvestTruc( files, filesNumIds, ...
    states, fieldShape, gridWidth, headerWidth, harvDistribution)
%STATISTICALHARVESTTRUC Carry out the truncated version of the statistical
%harvesting using vehicles specified by files for the field specified by
%fieldShape.
%
% Inputs:
%   - files
%     A struct array representing the GPS log files. Each element contains
%     fields like gpsTime, lat, lon, speed, bearing, etc. Please refer to
%     processGpsDataFiles.m for more details.
%   - filesNumIds
%     The indices used to distinguish the vehicles that generated files
%     outside of this function.
%   - states
%     The states (harvesting / loading / unloading) for the vehicles.
%     Vehicle #n in files will have states specified by
%     states(filesNumIds(n)). It is harvesting if the first column is 0 in
%     its state matrix (loading from the field). For more details about
%     states, please refer to labelStatesByDist.m.
%   - fieldShape
%     An alpha shape representing the inner side of the field to be
%     harvested. inShape() will be used for determining the GPS points that
%     are relavant.
%   - headerWidth
%     We will truncate harvDistribution by ignoring grid points outside of
%     the distance range (-trucDist, trucDist), where trucDist will be
%     computed for each GPS point according to the GPS accuracy. Currently,
%     trucDist will be the 3 standard dev + half of the header width.
%   - gridWidth
%     The width of each cell in the grid which represents a quantitized
%     version of the field.
%   - harvDistribution
%     A function for the probability of being harvested over distance (in
%     meter) to the GPS track. By default, the model with 1D Gussian for
%     GPS and fixed header width introduced in our paper "Dynamic
%     High-Precision Field Shape Generation via Combine GPS Tracks" will be
%     used to compute a dynamic harvDistribution for each point. If a
%     function is provided, that function will be used without any
%     modification for each point.
%
% Outputs:
%   - harvestedPts
%     A struct array representing the harvested results. Each element is a
%     point in the field and it has fields:
%       - x, y
%         Scalars. The UTM coordinates of the point.
%       - utmZone
%         1x4 char vector specifying the UTM zone for this point.
%       - lat, lon
%         Scalars. Geomatric coordinates of this point.
%       - probOfHarvested
%         A scalar from [0, 1]. The overall probability of this point being
%         harvested.
%       - harvLogFileIds
%         A vector of file number IDs cooresponding to the order of
%         vehicles that have statistically harvested this point. The
%         earlier the vehicle harvested the point, the earlier it shows up
%         in this vector.
%       - harvLogProbs
%         A vector of probabilities that this point being harvested by each
%         vehicle listed in harvLogFileIds.
%   - fieldShapeUtm
%     The equivalent alpha shape with UTM coordinates for fieldShape.
%   - fieldShapeUtmZone
%     The UTM zone for fieldShapeUtm.
%
% Requires the external Matlab function deg2utm.m (available online).
%
% Yaguang Zhang, Purdue, 05/17/2017

disp(' => Preprocessing ... ');
tic;

if nargin<7
    USE_DEFAULT_DIST = true;
    harvDistribution = nan;
    if nargin<6
        headerWidth = 9.144; % In meter; ~30 feet.
    end
end

%% Get Harvesting Samples

% For replying using the GPS time, only consider samples that are from
% combines, in the field and are harvesting.
filesHarv =struct('type', {}, 'id', {}, ...
    'time', {}, 'gpsTime', {}, ...
    'lat', {}, 'lon', {}, 'altitude', {},...
    'speed', {}, 'bearing', {}, 'accuracy', {});
filesHarvIndices = [];
filesHarvSamplesIndices = cell(0);
% Aslo estimate the combine headings for future use.
[vehHeadings, isForwardings, xs, ys, utmZones] = ...
    deal(cell(length(files),1));
for idxFile = 1:length(files)
    % Make sure all fields of each file are of the same length.
    numSamplesExpected = length(files(idxFile).accuracy);
    if(length(files(idxFile).gpsTime) ~= numSamplesExpected)
        files(idxFile) = subFile(files(idxFile),1,numSamplesExpected);
        states{idxFile} = states{idxFile}(1:numSamplesExpected,:);
    end
    
    if(strcmp(files(idxFile).type, 'Combine'))
        comFile = files(idxFile);
        comState = states(filesNumIds(idxFile));
        if (fieldShape.Alpha>0)
        boolsSamplesToUse = ...
            inShape(fieldShape, comFile.lon, comFile.lat) ...
            & (comState{:,1} == 0);
        else
            boolsSamplesToUse = ...
                ismember([comFile.lon comFile.lat],...
                fieldShape.Points, 'rows') ...
                & (comState{:,1} == 0);
        end
        newFileHarv = subFile(comFile, boolsSamplesToUse);
        if (~isempty(newFileHarv.gpsTime))
            filesHarv(end+1) = newFileHarv; %#ok<AGROW>
            filesHarvIndices(end+1) = idxFile; %#ok<AGROW>
            filesHarvSamplesIndices{end+1} = find(boolsSamplesToUse); %#ok<AGROW>
        end
        
        % [ vehHeading, isForwarding, x, y, utmZones, refBearing, ...
        %    hFigArrOnTrack, hFigDiffHist ] ... = estimateVehicleHeading(
        %    file, DEBUG )
        [ vehHeadings{idxFile}, isForwardings{idxFile}, ...
            xs{idxFile}, ys{idxFile}, utmZones{idxFile} ] ...
            = estimateVehicleHeading( files(idxFile) );
    end
end

% Get a matrix of GPS times, sample indices, and file indices in files for
% filesHarv. This will be used to reply the harvesting and decide the order
% of the samples for relavant GPS tracks.
numSamplesHarv = sum(arrayfun(@(f) length(f.gpsTime),filesHarv));
% Also get a copy of some other information of these points for future use.
% Summary for columns:
%    1 - gpsTime
%     2 - Sample index
%    3 - File index in files
%     4 & 5 - UTM coordinates 6 - heading 7 - gpsAccuracy
gpsTimesHarv = nan(numSamplesHarv,7);
idxToSetStart = 1;
for idxFileHarv = 1:length(filesHarv)
    idxToSetEnd = idxToSetStart+length(filesHarv(idxFileHarv).gpsTime)-1;
    indicesToSet = idxToSetStart:idxToSetEnd;
    % File indices in files.
    idxInFiles = filesHarvIndices(idxFileHarv);
    gpsTimesHarv(indicesToSet,3) = idxInFiles;
    % Sample indices.
    indicesHarvSamples = filesHarvSamplesIndices{idxFileHarv};
    gpsTimesHarv(indicesToSet,2) = indicesHarvSamples;
    % GPS times for these samples.
    gpsTimesHarv(indicesToSet,1) = filesHarv(idxFileHarv).gpsTime;
    
    % Other info.
    gpsTimesHarv(indicesToSet,4:5) ...
        = [xs{idxInFiles}(indicesHarvSamples), ...
        ys{idxInFiles}(indicesHarvSamples)];
    gpsTimesHarv(indicesToSet,6) ...
        = vehHeadings{idxInFiles}(indicesHarvSamples);
    gpsTimesHarv(indicesToSet,7) = ...
        files(idxInFiles).accuracy(indicesHarvSamples);
    
    idxToSetStart = idxToSetEnd+1;
end

% Sort according to GPS time.
gpsTimesHarv = sortrows(gpsTimesHarv,1);

%% Generate the Grid in the UTM Coordinate

% First convert the fieldShape into a UTM one, using alpha that is slightly
% larger than that computed in our paper "Dynamic High-Precision Field
% Shape Generation via Combine GPS Tracks" to make sure everything in the
% field is covered.
alpha = 15; % 5.6519 * (1,2] meters in the paper.
fieldExtendedLen = 100; % In meter.
% [ fieldShapeUtm, utmZone] ...
%     = genFieldShapeUtm( fieldShape, newAlpha)
[ fieldShapeUtm, fieldShapeUtmZone] ...
    = genFieldShapeUtm( fieldShape, alpha);
minX = min(fieldShapeUtm.Points(:,1))-fieldExtendedLen;
maxX = max(fieldShapeUtm.Points(:,1))+fieldExtendedLen;
minY = min(fieldShapeUtm.Points(:,2))-fieldExtendedLen;
maxY = max(fieldShapeUtm.Points(:,2))+fieldExtendedLen;
[gridXs, gridYs] = meshgrid(minX:gridWidth:maxX, minY:gridWidth:maxY);
% Resize to column vectors.
gridXs = gridXs(:);
gridYs = gridYs(:);
% % Get rid of the grid points that are outside of the field.
% boolsGridNotInField = ~inShape(fieldShapeUtm, gridXs, gridYs);
% gridXs(boolsGridNotInField) = [];
% gridYs(boolsGridNotInField) = [];

% Initialize harvestedPts for the grid.
harvestedPts(length(gridXs)) = struct();
for idxGridPt = 1:length(gridXs)
    harvestedPts(idxGridPt).x = gridXs(idxGridPt);
    harvestedPts(idxGridPt).y = gridYs(idxGridPt);
    harvestedPts(idxGridPt).utmZone = fieldShapeUtmZone;
    [harvestedPts(idxGridPt).lat, harvestedPts(idxGridPt).lon] ...
        = utm2deg(harvestedPts(idxGridPt).x, ...
        harvestedPts(idxGridPt).y, fieldShapeUtmZone);
    harvestedPts(idxGridPt).probOfHarvested = 0;
    harvestedPts(idxGridPt).harvLogFileIds = [];
    harvestedPts(idxGridPt).harvLogProbs = [];
end

toc;

%% Statistical Harvesting

disp(' => Statistical Harvesting ... ');
tic;

% Compute the edge (one line segment perpendicular to the heading) for each
% harv GPS point to form the polygon in which all the grid points will be
% harvested. The end points will be organized as [x,y] in harvPlyEdgeStaPts
% and harvPlyEdgeEndPts, with each row of them corresponding to the sample
% specified by the same row in gpsTimesHarv.
[harvPolyEdgeStaPts, harvPolyEdgeEndPts] = extractHarvPolyEdge( ...
    gpsTimesHarv(:,4), ... % x
    gpsTimesHarv(:,5), ... % y
    gpsTimesHarv(:,6), ... % heading
    gpsTimesHarv(:,7), ... % gpsAccuracy
    headerWidth);

% Replay the harvesting activity according to the sorted GPS time.
infoEveryNumOfSample = ...
    floor(numSamplesHarv/10);
for idxSampleHarv = 1:numSamplesHarv
    if(mod(idxSampleHarv,infoEveryNumOfSample) == 0)
        toc;
        disp(['    Progress: ', ...
            num2str(idxSampleHarv/numSamplesHarv*100,'%0.2f'),'% (', ...
            num2str(idxSampleHarv), '/', ...
            num2str(numSamplesHarv),' samples)']);
        tic;
    end
    
    idxFileInFiles = gpsTimesHarv(idxSampleHarv,3);
    idxSample = gpsTimesHarv(idxSampleHarv,2);
    % The UTM coordinates for this GPS sample.
    x0 = gpsTimesHarv(idxSampleHarv,4);
    y0 = gpsTimesHarv(idxSampleHarv,5);
    % Heading.
    heading = gpsTimesHarv(idxSampleHarv,6);
    % We will create a polygon representing the area being harvested using
    % this sample and its next one, so we need to first make sure this
    % sample is not the last one in the track.
    if (idxSample <= length(files(idxFileInFiles).gpsTime))
        harvPolyEdgeStaPt1 = harvPolyEdgeStaPts(idxSampleHarv,:);
        harvPolyEdgeEndPt1 = harvPolyEdgeEndPts(idxSampleHarv,:);
        % Create the polygon to harvest according to the edges of current
        % sample and the next one in the same track.
        idxNextSample = find(gpsTimesHarv(:,3)== idxFileInFiles ...
            & gpsTimesHarv(:,2)== (idxSample+1));
        if (~isempty(idxNextSample))
            % The next sample is also a harvesting one, and the edge has
            % been computed and stored before.
            harvPolyEdgeStaPt2 = harvPolyEdgeStaPts(idxNextSample,:);
            harvPolyEdgeEndPt2 = harvPolyEdgeEndPts(idxNextSample,:);
        else
            idxNextSample = idxSample+1;
            % We do not have the edge stored. Compute it.
            [harvPolyEdgeStaPt2, harvPolyEdgeEndPt2] = extractHarvPolyEdge( ...
                xs{idxFileInFiles}(idxNextSample), ...
                ys{idxFileInFiles}(idxNextSample), ...
                vehHeadings{idxFileInFiles}(idxNextSample), ...
                files(idxFileInFiles).accuracy(idxNextSample), ...
                headerWidth);
        end
        
        % The polygon.
        verticesHarvPoly = [harvPolyEdgeStaPt1; harvPolyEdgeEndPt1; ...
            harvPolyEdgeEndPt2;harvPolyEdgeStaPt2;harvPolyEdgeStaPt1];
        % Find grid points that are harvested. To improve the performance,
        % we first fitler the points with a box before using inpolygon.
        harvBox = [min(verticesHarvPoly(:,1)), ... min x
            max(verticesHarvPoly(:,1)), ... max x
            min(verticesHarvPoly(:,2)), ... min y
            max(verticesHarvPoly(:,2))]; % max y
        indicesGridPtInHarvBox = find(gridXs >= harvBox(1) ...
            & gridXs <= harvBox(2) ...
            & gridYs >= harvBox(3) ...
            & gridYs <= harvBox(4));
        indicesGridPtHarv = indicesGridPtInHarvBox(...
            inpolygon(gridXs(indicesGridPtInHarvBox), ...
            gridYs(indicesGridPtInHarvBox), ...
            verticesHarvPoly(:,1),verticesHarvPoly(:,2)) ...
            );
        % Update harvestedPts for each point found.
        dists = distToCenterLine(gridXs(indicesGridPtHarv), ...
            gridYs(indicesGridPtHarv), x0, y0, heading);
        % Update harvDistribution if necessary.
        if (USE_DEFAULT_DIST)
            % Standard diviation.
            standDev = gpsTimesHarv(idxSampleHarv,7);
            harvDistribution = @(x) normcdf(x+headerWidth/2,0,standDev) ...
                - normcdf(x-headerWidth/2,0,standDev);
        end
        for idxIndicesGridPtHarv = 1:length(indicesGridPtHarv)
            idxGridPt = indicesGridPtHarv(idxIndicesGridPtHarv);
            dist = dists(idxIndicesGridPtHarv);
            
            probMargin = 1 - harvestedPts(idxGridPt).probOfHarvested;
            newProbHarv = probMargin*harvDistribution(dist);
            
            harvestedPts(idxGridPt).harvLogFileIds(end+1) ...
                = gpsTimesHarv(idxSampleHarv,3);
            harvestedPts(idxGridPt).harvLogProbs(end+1) = newProbHarv;
            harvestedPts(idxGridPt).probOfHarvested ...
                = sum(harvestedPts(idxGridPt).harvLogProbs);
        end
    end
end
toc; disp('Done!')

% EOF