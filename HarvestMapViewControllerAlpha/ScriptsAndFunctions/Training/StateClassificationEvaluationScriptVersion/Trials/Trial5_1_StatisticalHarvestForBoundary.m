% TRIAL5_1_STATISTICALHARVESTFORBOUNDARY Trial 5.1 - Plot the statistical
% result for some fields with only the boundary harvested.
%
% Yaguang Zhang, Purdue, 05/23/2017

% Load data and set the current Matlab directory.
if(~exist('allDataLoaded', 'var') || allDataLoaded == false)
    cd(fileparts(mfilename('fullpath')));
    prepareTrial;
    cd(fileparts(mfilename('fullpath')));
    if(~exist('enhancedFieldShapes', 'var'))
        load(fullfile(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
            'enhancedFieldShapes.mat'));
    end
    if(~exist('enhancedFieldShapesUtm', 'var'))
        load(fullfile(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
            'enhancedFieldShapesUtm.mat'));
    end
    if(~exist('fieldShapesRef', 'var'))
        load(fullfile(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
            'filesLoadedFieldShapes_ref.mat'));
    end
end

% Use default settings. E.g. 30 feet header width (~= 9.144 m)
gridWidth = 1;
if(~exist('doNotAssignIdxField', 'var') || doNotAssignIdxField == false)
    idxField = 1;%1;%29;
end
optimalAlphaUtm = 11.38;

fieldShape = enhancedFieldShapes{idxField};
fieldShapeUtm = enhancedFieldShapesUtm{idxField};
fieldShapeUtm.Alpha = optimalAlphaUtm;

boudnaryFieldShape = extractBoundaryFieldShape(fieldShape);
% Find relavant GPS tracks in the data set.
indicesFilesToUse = findRelatedFiles(files, fieldShape);
% ---------------------------- Production version.
% ----------------------------
[ harvestedPts, boudnaryFieldShapeUtm ] = statisticalHarvestTruc( ...
    files(indicesFilesToUse), ...
    indicesFilesToUse, ...
    statesByDist, boudnaryFieldShape, gridWidth );
% ----------------------------

%% Save the result.
fileName = ['Trial5_1_Results_gridWidth_', num2str(gridWidth), ...
    '_idxField_', num2str(idxField)];
save([fileName, '.mat'], 'harvestedPts');

% Figures.
numHarvPts = length(harvestedPts);
[xs, ys, lats, lons, harvPros, idsMostLikelyCom] = deal(nan(numHarvPts,1));
for idxHarvPt = 1:numHarvPts
    xs(idxHarvPt) = harvestedPts(idxHarvPt).x;
    ys(idxHarvPt) = harvestedPts(idxHarvPt).y;
    lats(idxHarvPt) = harvestedPts(idxHarvPt).lat;
    lons(idxHarvPt) = harvestedPts(idxHarvPt).lon;
    harvPros(idxHarvPt) = harvestedPts(idxHarvPt).probOfHarvested;
    
    harvLogProbs = harvestedPts(idxHarvPt).harvLogProbs;
    harvLogFileIds = harvestedPts(idxHarvPt).harvLogFileIds;
    idxMostLikelyVeh = find(harvLogProbs==max(harvLogProbs),1);
    if(~isempty(idxMostLikelyVeh))
        idsMostLikelyCom(idxHarvPt) = harvLogFileIds(idxMostLikelyVeh);
    end
end

if(~exist('skipGeneratingFigures', 'var') || skipGeneratingFigures == false)
    hFigHarvProb = figure;
    plot3k([xs, ys, harvPros]);
    daspectOld = daspect;
    daspectxy = min(daspectOld(1:2));
    daspect([daspectxy,daspectxy,daspectOld(3)]);
    title('Harvest Probability for Statistical Harvest (Trucated version)');
    xlabel('x'); ylabel('y'); zlabel('Prob. of being Harvested');
    saveas(hFigHarvProb, [fileName, '_harvProb.png']);
    saveas(hFigHarvProb, [fileName, '_harvProb.fig']);
    
    hFigHarvProbWithTrack = figure; hold on;
    plot3k([lons, lats, harvPros],'ColorBar',false);
    plot3(boudnaryFieldShape.Points(:,1), boudnaryFieldShape.Points(:,2), ...
        ones(length(boudnaryFieldShape.Points(:,1)),1), 'r-', 'LineWidth',0.1);
    daspect auto; plot_google_map; hold off;
    title('Harvest Probability with Track for Statistical Harvest (Trucated version)');
    xlabel('Lon'); ylabel('Lat'); view(2);
    saveas(hFigHarvProbWithTrack, [fileName, '_harvProbOnTrack.png']);
    saveas(hFigHarvProbWithTrack, [fileName, '_harvProbOnTrack.fig']);
    
    hFigMostLikelyCom = figure; hold on;
    uniqIdsMostLikelyCom = unique(idsMostLikelyCom);
    boolsNanUniqIdsMostLikelyCom = isnan(uniqIdsMostLikelyCom);
    uniqIdsMostLikelyCom(boolsNanUniqIdsMostLikelyCom) = [];
    for idxCom = 1:length(uniqIdsMostLikelyCom)
        boolsToPlot = idsMostLikelyCom==uniqIdsMostLikelyCom(idxCom);
        plot(lons(boolsToPlot), lats(boolsToPlot),'.');
    end
    hold off; plot_google_map('MapType', 'satellite');
    title('Most Likely Combines for Statistical Harvest (Trucated version)');
    saveas(hFigMostLikelyCom, [fileName, '_mostLikelyCom.png']);
    saveas(hFigMostLikelyCom, [fileName, '_mostLikelyCom.fig']);
end

%% Filter the grid with a probability threshold and combine the result with
% the previous alpha shape for the field.
minProbHarvested = 0.5;
boolsNewHarvested = harvPros>=minProbHarvested ...
    & (~inShape(fieldShape,lons, lats));
extendedEnhancedFieldShape = alphaShape([fieldShape.Points; ...
    lons(boolsNewHarvested) lats(boolsNewHarvested)]);
% A little smaller than the maximum recommended alpha to avoid filling too
% much of the hole parts. 5.6519 * (1,2] meters in the paper.
extendedEnhancedFieldShapeUtm = alphaShape([fieldShapeUtm.Points; ...
    xs(boolsNewHarvested) ys(boolsNewHarvested)]);
extendedEnhancedFieldShapeUtm.Alpha = optimalAlphaUtm;
save([fileName, '_extEnhFieldShape.mat'], 'extendedEnhancedFieldShape');
save([fileName, '_extEnhFieldShapeUtm.mat'], 'extendedEnhancedFieldShapeUtm');


if(~exist('skipGeneratingFigures', 'var') || skipGeneratingFigures == false)
    % % Plot the resulted field shapes on a map. hFigExtenedEnhField =
    % figure; hold on; % The extended field shape.
    % plot(extendedEnhancedFieldShape,'FaceColor','blue',...
    %     'FaceAlpha',0.5, 'EdgeAlpha', 0)
    % % The old field shape.
    % plot(fieldShape,'FaceColor','green','FaceAlpha',0.5, 'EdgeAlpha', 0)
    % % The boundary track(s). plot(boudnaryFieldShape.Points(:,1),
    % boudnaryFieldShape.Points(:,2), ...
    %     'r.', 'LineWidth',1);
    % % The reference boundary. plot(fieldShapesRef{idxField}(:,1),
    % fieldShapesRef{idxField}(:,2), ...
    %     'k.-', 'LineWidth',1);
    % daspect auto; plot_google_map('MapType', 'satellite'); hold off;
    % title('Enhanced Field Shape Extended by Statistical Harvest (Trucated
    % version)'); xlabel('Lon'); ylabel('Lat'); view(2);
    % saveas(hFigExtenedEnhField, [fileName,
    % '_extEnhFieldWithBoundTrack.png']); saveas(hFigExtenedEnhField,
    % [fileName, '_extEnhFieldWithBoundTrack.fig']);
    
    % Plot the reference field boundaries on a map if they are available
    % for this field.
    if(~isempty(fieldShapesRef{idxField}))
        hFigFieldShapeRef = figure; hold on;
        % The reference boundary.
        plot(fieldShapesRef{idxField}(:,1), fieldShapesRef{idxField}(:,2), ...
            'k.-', 'LineWidth',1);
        daspect auto; plot_google_map('MapType', 'satellite'); hold off;
        title('Reference Field Boundaries');
        xlabel('Lon'); ylabel('Lat'); view(2);
        saveas(hFigFieldShapeRef, [fileName, '_referenceFieldBoudnary.png']);
        saveas(hFigFieldShapeRef, [fileName, '_referenceFieldBoudnary.fig']);
    end
    
    % Plot the resulted field shapes in UTM coordinates.
    if(~isempty(fieldShapesRef{idxField}))
        [ fieldShapeRefUtm, ~] ...
            = genFieldShapeUtm( alphaShape(fieldShapesRef{idxField}), 0);
        fieldShapeRefUtmPoints = fieldShapeRefUtm.Points;
        fieldShapeRefUtmPoints(end+1,:) = fieldShapeRefUtmPoints(1,:);
    end
    
    hFigExtenedEnhFieldUtm = figure; hold on;
    % The extended UTM field shape.
    plot(extendedEnhancedFieldShapeUtm,...
        'FaceColor','blue','FaceAlpha',0.5, 'EdgeAlpha', 0)
    % The old UTM field shape.
    plot(fieldShapeUtm,'FaceColor','green','FaceAlpha',0.5, 'EdgeAlpha', 0)
    % The boundary track(s).
    plot(boudnaryFieldShapeUtm.Points(:,1), ...
        boudnaryFieldShapeUtm.Points(:,2), ...
        'r.', 'LineWidth',1);
    if(~isempty(fieldShapesRef{idxField}))
        % The reference boundary.
        plot(fieldShapeRefUtmPoints(:,1), fieldShapeRefUtmPoints(:,2), ...
            'k.-', 'LineWidth',1);
    end
    hold off;
    title('Enhanced Field Shape Extended by Statistical Harvest (Trucated version)');
    xlabel('x'); ylabel('y'); view(2);
    saveas(hFigExtenedEnhFieldUtm, ...
        [fileName, '_extEnhFieldUtmWithBoundTrack.png']);
    saveas(hFigExtenedEnhFieldUtm, ...
        [fileName, '_extEnhFieldUtmWithBoundTrack.fig']);
end

% EOF