%EXTENDFIELDSHAPES Extend the enhancedFieldShapes via the statistical
%harvesting algorithm.
%
% This script depends on results from extractFieldShapes and the state by
% distance.
%
% Yaguang Zhang, Purdue, 06/03/2019

% Use default settings. E.g. 30 feet header width (~= 9.144 m)
gridWidth = 1;
minProbHarvested = 0.5;

% Generate field shapes via statistical harvesting. We will generate a new
% copy of the alphaShapes cell and store the results there. Based on
% script:
%       GpsDataVisualizationAndAnalysis\MatlabWorkspace
%           \HarvestMapViewControllerAlpha\ScriptsAndFunctions\Training
%               \StateClassificationEvaluationScriptVersion\Trials
%                   Trial5_1_StatisticalHarvestForBoundary.m

if(exist('extendedEnhancedFieldShapes', 'var'))
    disp(['Field shapes extended by statistical harvesting found ', ...
        'in current workspace. We will reuse them for convenience.']);
else
    [extendedEnhancedFieldShapes, extendedEnhancedFieldShapesUtm] ...
        = deal(cell(1, length(enhancedFieldShapes)));
    
    numEnhancedFieldShapes = length(enhancedFieldShapes);
    for curIdxField = 1:numEnhancedFieldShapes
        
        disp('');
        disp(['    Enhanced field shape #', num2str(curIdxField), ...
            '/', num2str(numEnhancedFieldShapes)]);
        
        curFieldShape = enhancedFieldShapes{curIdxField};
        curFieldShapeUtm = enhancedFieldShapesUtm{curIdxField};
        
        curFieldShapeUtmZone = enhancedFieldShapesUtmZones{curIdxField};
        
        boundaryFieldShape = extractBoundaryFieldShape(curFieldShape);
        
        % boundaryFieldShapeUtm ...
        %     = extractBoundaryFieldShape(curFieldShapeUtm);
        %
        % boundaryFieldShapeAll ...
        %      = mergeGpsAndUtmFieldShapes(boundaryFieldShape, ...
        %      boundaryFieldShapeUtm, curFieldShapeUtmZone);
        boundaryFieldShapeAll = boundaryFieldShape;
        
        % Find relavant GPS tracks in the data set.
        indicesFilesToUse = findRelatedFiles(files, curFieldShape);
        % ----------------------------
        %  Production version.
        % ----------------------------
        [ harvestedPts, ~, ~, curFieldGrid ] = statisticalHarvestTruc( ...
            files(indicesFilesToUse), ...
            indicesFilesToUse, ...
            statesByDist, boundaryFieldShapeAll, gridWidth );
        % ----------------------------
        
        numHarvPts = length(harvestedPts);
        [curXs, curYs, curLats, curLons, curHarvPros] ...
            = deal(nan(numHarvPts,1));
        for idxHarvPt = 1:numHarvPts
            curXs(idxHarvPt) = harvestedPts(idxHarvPt).x;
            curYs(idxHarvPt) = harvestedPts(idxHarvPt).y;
            curLats(idxHarvPt) = harvestedPts(idxHarvPt).lat;
            curLons(idxHarvPt) = harvestedPts(idxHarvPt).lon;
            curHarvPros(idxHarvPt) ...
                = harvestedPts(idxHarvPt).probOfHarvested;
        end
        
        % We will use the grid to construct the field shape to maintain a
        % consistant alpha in the field and on the edge of the field.
        boolsGridPtsInField = inShape(curFieldShapeUtm, curFieldGrid);
        curFieldGrid = curFieldGrid(boolsGridPtsInField, :);
        
        % Filter the grid with a probability threshold and combine the
        % result with the previous field shape and grid points.
        curBoolsNewHarvested = curHarvPros>=minProbHarvested ...
            & ( ...
            (~inShape(curFieldShapeUtm, curXs, curYs)) ...
            | (~inShape(curFieldShape, curLons, curLats)));
        extendedEnhancedFieldShape = alphaShape([curFieldShape.Points; ...
            curLons(curBoolsNewHarvested) curLats(curBoolsNewHarvested)]);
        
        curFieldGrid = unique([curFieldShapeUtm.Points; curFieldGrid; ...
            curXs(curBoolsNewHarvested) curYs(curBoolsNewHarvested)], ...
            'rows');
        
        % Set the tightest alpha to maintain the field shape.
        extendedEnhancedFieldShapeUtm ...
            = alphaShape(curFieldGrid);
        extendedEnhancedFieldShapeUtm.Alpha = gridWidth*sqrt(2)/2;
        
        extendedEnhancedFieldShapes{curIdxField} ...
            = extendedEnhancedFieldShape;
        extendedEnhancedFieldShapesUtm{curIdxField} ...
            = extendedEnhancedFieldShapeUtm;
        
        % Plot.
        if(~exist('skipGeneratingFigures', 'var') ...
                || skipGeneratingFigures == false)
            fileName = fullfile(pathFolderToSaveFieldShapes, ...
                ['extendedEnhancedFieldShapesUtm_', ...
                num2str(curIdxField), '_alpha_', ...
                num2str(floor(optimalAlphaUtm))]);
            if(~exist([fileName,'.',FIGURE_EXT], 'file'))
                % hFigExtenedEnhFieldUtm = figure;
                hFigExtenedEnhFieldUtm ...
                    = figure('units', 'normalized', ...
                    'outerposition', [0 0 1 1]);
                hold on;
                % The old UTM field shape.
                hEnhField = plot(curFieldShapeUtm,'FaceColor','k', ...
                    'FaceAlpha',0.5, 'EdgeAlpha', 0);
                % The extended UTM field shape.
                hExtEnhField = plot(extendedEnhancedFieldShapeUtm,...
                    'FaceColor','g','FaceAlpha',0.5, 'EdgeAlpha', 0);
                % The relavant combine GPS points.
                for idxCom = 1:length(fileIndicesCombines)
                    curFileCom = files(fileIndicesCombines(idxCom));
                    [curRelXs, curRelYs] ...
                        = deg2utm(curFileCom.lat, curFileCom.lon);
                    
                    curBoolsInfield ...
                        = inShape(extendedEnhancedFieldShapeUtm, ...
                        curRelXs, curRelYs);
                    
                    curRelXs(~curBoolsInfield) = nan;
                    curRelYs(~curBoolsInfield) = nan;
                    
                    hRelaventGpsPts = plot(curRelXs, curRelYs, '.', ...
                        'Color', ones(1,3).*0.9, 'MarkerSize', 1);
                end
                hold off; legend([hEnhField, hExtEnhField, ...
                    hRelaventGpsPts], ...
                    'Enhanced Field', 'Extended Enhanced Eield', ...
                    'Combine GPS Pts');
                title({'Enhanced Field Shape Extended by Statistical Harvest'; ...
                    '(Trucated version)'});
                xlabel('x'); ylabel('y'); view(2);
                saveas(hFigExtenedEnhFieldUtm, ...
                    [fileName, '_extEnhFieldUtmWithBoundTrack.jpg']);
            end
        end
    end
end

% EOF