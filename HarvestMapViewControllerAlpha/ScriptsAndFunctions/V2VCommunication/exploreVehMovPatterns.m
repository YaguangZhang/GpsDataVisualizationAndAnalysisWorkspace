% EXPLOREVEHMOVEPATTERNS We will load all the wheat harvesting GPS data we
% have and explore the movement patterns that could be beneficial for V2V
% communications.
%
% Yaguang Zhang, Purdue, 10/17/2018

%% User Specified Parameters
HIDE_FIGS = true;

RELATIVE_PATH_TO_DATA_SETS = fullfile('..', '..', '..', '..');
RELATIVE_PATH_TO_SAVE_RESULTS = fullfile(RELATIVE_PATH_TO_DATA_SETS, ...
    '_AUTOGEN_V2VCOMM');

% A cell matrix with each row being {'data set name', 'folder name'}.
INFO_FOR_DATA_TO_LOAD = { ...
    '2015', 'Harvest_Ballet_2015'; ...
    '2016_synched', ...
    fullfile('Harvest_Ballet_2016', ...
    'harvests_synchronized'); ...
    '2017', 'Harvest_Ballet_2017'; ...
    '2018', 'Harvest_Ballet_2018'; ...
    '2018_rateTest', 'Harvest_Ballet_2018_Wifi_Test'; ...
    '2019', 'Harvest_Ballet_2019'
    };

%% Automatic Settings

close all;

curFileName = mfilename;
curParentDir = fileparts(which(curFileName));

fileNameHintRuler = [' ', repmat('-', 1, length(curFileName)+2), ' '];
disp(fileNameHintRuler);
disp(['  ', curFileName, '  ']);
disp(fileNameHintRuler);

disp(' ')
disp('Pre-processing ...');

fullPathToDataSets = fullfile(curParentDir, ...
    RELATIVE_PATH_TO_DATA_SETS);
fullPathToSaveResults = fullfile(curParentDir, ...
    RELATIVE_PATH_TO_SAVE_RESULTS);

% Create dir if necessary.
if ~exist(fullPathToSaveResults, 'file')
    mkdir(fullPathToSaveResults);
end

disp(' ')
disp('    Setting matlab path ...')

% Load useful functions.
cd(fullfile(curParentDir,'..'));
setMatlabPath;

disp('    Done!')

% Load all GPS data.
disp(' ')
disp('    Loading GPS data sets ...')

[numDataSets, ~] = size(INFO_FOR_DATA_TO_LOAD);

if exist('gpsRecordsCell', 'var') && exist('estimatedHeadingsCell', 'var')
    disp('        GPS data found in current workspace.')
else
    [gpsRecordsCell, estimatedHeadingsCell] = deal(cell(numDataSets, 1));
    for idxDataSet = 1:numDataSets
        disp(['        ', num2str(idxDataSet), ...
            '/', num2str(numDataSets), ...
            ': (', INFO_FOR_DATA_TO_LOAD{idxDataSet, 1}, ')']);
        
        curFullPathToHistoryFiles = fullfile(fullPathToDataSets, ...
            INFO_FOR_DATA_TO_LOAD{idxDataSet, 2}, ...
            '_AUTOGEN_IMPORTANT', 'filesLoadedHistory.mat'); %#ok<PFBNS>
        try
            gpsRecordsCell{idxDataSet} = load(curFullPathToHistoryFiles);
        catch
            error(['Error loading GPS file! ', ...
                'Please makes sure naiveTrain has been run for ', ...
                INFO_FOR_DATA_TO_LOAD{idxDataSet, 2}, '!']);
        end
        
        % We will use our version of estimated headings for the vehicles,
        % which do not have gaps for zero-speed GPS points.
        curFullPathToVehHeadings = fullfile(fullPathToDataSets, ...
            INFO_FOR_DATA_TO_LOAD{idxDataSet, 2}, ...
            '_AUTOGEN_IMPORTANT', 'naiveTrain', 'Headings.mat'); %#ok<PFBNS>
        try
            estimatedHeadingsCell{idxDataSet} ...
                = load(curFullPathToVehHeadings);
        catch
            error(['Error loading estimated headings! ', ...
                'Please makes sure naiveTrain has been run for ', ...
                INFO_FOR_DATA_TO_LOAD{idxDataSet, 2}, '!']);
        end
    end
end

disp('    Done!')

%% Investigate the Accuracy for All Data

disp(' ')
disp('Investigating GPS accuracy for all datasets ...')

num2strPre = 2;

gpsAccusCell = cell(numDataSets, 1);
for idxDataSet = 1:numDataSets
    gpsAccusCell{idxDataSet} ...
        = gpsRecordsCell{idxDataSet}.files.accuracy;
end
allGpsAccus = vertcat(gpsAccusCell{:});

% Empirical CDF for each dataset in one figure.

% Empirical CDF for all data.
hEcdfForAllGpsAccus = figure;
ecdf(allGpsAccus);
set(gca, 'XScale', 'log');
title({'Empirical CDF for GPS accuracy values';
    ['(mean = ', num2str(mean(allGpsAccus), num2strPre), ...
    ', std = ', num2str(std(allGpsAccus), num2strPre), ')']});
insertXTicks([min(allGpsAccus), max(allGpsAccus)]);
xlabel('GPS Accuracy (m) with Logarithmic Scale');
ylabel('Empirical CDF');
grid on; grid minor;
saveas(hEcdfForAllGpsAccus, ...
    fullfile(fullPathToSaveResults, ...
    'ecdfForAllGpsAccus.png'));

%% Convert GPS Data to the Fixed-Grain-Cart Polar System
% We will only consider the GPS logs here, i.e. no rate test is required.

% We will look at point within 500 m range instead for plotting. Here, we
% just safely remove points too far away for that.
MAX_DIST_TO_K_OF_INTEREST_IN_M = 1000;

disp(' ')
disp('Exploring ehicle movement pattern ...')

disp(' ')
disp('    Converting GPS to angular patterns ...');

% We will store all the results into a cell vector, coorsXYWrtFixedKsCell,
% with each element being a struct array for one data set. The fields for
% the struct are: CenterGrainFileIdx, ClientVehFileIdx, xs, ys.
fullPathToResultMatFile =fullfile(fullPathToSaveResults, ...
    'coorsXYWrtFixedKsCell.mat');
if(exist('coorsXYWrtFixedKsCell', 'var'))
    disp('        Variable coorsXYWrtFixedKsCell found in current workspace.');
    disp('    Done!');
    
    flagConversionNeeded = false;
else
    if(exist(fullPathToResultMatFile, 'file'))
        cachedInfoForLoadedData = load(fullPathToResultMatFile, ...
            'INFO_FOR_DATA_TO_LOAD');
        
        % Check whether the cached results match INFO_FOR_DATA_TO_LOAD.
        if isequal(cachedInfoForLoadedData.INFO_FOR_DATA_TO_LOAD, ...
                INFO_FOR_DATA_TO_LOAD)
            disp('        History results found for specified data sets.');
            disp('        Loading history results ...');
            
            flagConversionNeeded = false;
            
            cachedResults = load(fullPathToResultMatFile, ...
                'coorsXYWrtFixedKsCell');
            coorsXYWrtFixedKsCell = cachedResults.coorsXYWrtFixedKsCell;
            
            disp('    Done!');
        else
            flagConversionNeeded = true;
        end
    else
        flagConversionNeeded = true;
    end
end

if flagConversionNeeded
    coorsXYWrtFixedKsCell = cell(numDataSets, 1);
    
    for idxDataSet = 1:numDataSets
        curCoorsXYWrtFixedKs = struct('CenterGrainFileIdx', {}, ...
            'ClientVehFileIdx', {}, 'xs', {}, 'ys', {});
        
        disp(['        ', num2str(idxDataSet), '/', ...
            num2str(numDataSets), ...
            ': (', INFO_FOR_DATA_TO_LOAD{idxDataSet, 1}, ')']);
        
        curDataSetLabel = INFO_FOR_DATA_TO_LOAD{idxDataSet, 1};
        curFiles = gpsRecordsCell{idxDataSet}.files;
        curIndicesK = gpsRecordsCell{idxDataSet}.fileIndicesGrainKarts;
        curNumKs = length(curIndicesK);
        curIndicesNonK = [ ...
            gpsRecordsCell{idxDataSet}.fileIndicesCombines; ...
            gpsRecordsCell{idxDataSet}.fileIndicesTrucks];
        
        for cntK = 1:curNumKs
            
            curIdxK = curIndicesK(cntK);
            
            serverGpsTime = gpsRecordsCell{idxDataSet}.files(...
                curIdxK).gpsTime;
            serverLat = gpsRecordsCell{idxDataSet}.files(curIdxK).lat;
            serverLon = gpsRecordsCell{idxDataSet}.files(curIdxK).lon;
            
            % Make sure the server bearing is in [0, 360).
            serverBearing ...
                = mod( ...
                estimatedHeadingsCell{idxDataSet}.vehsHeading{curIdxK}, ...
                360);
            
            % Find non-grain-cart files that have overlaps in time with the
            % server.
            curNumIndicesNonK = length(curIndicesNonK);
            
            textprogressbar(['            Cart ', num2str(cntK), ...
                '/', num2str(curNumKs), ': ']);
            for cntClient = 1:curNumIndicesNonK
                textprogressbar(cntClient/curNumIndicesNonK*100);
                
                curIdxClient = curIndicesNonK(cntClient);
                
                % disp(['                Client ', num2str(cntClient), ...
                %     '/', num2str(curNumIndicesNonK)]);
                
                curClientGpsTime ...
                    = gpsRecordsCell{idxDataSet}.files(...
                    curIdxClient).gpsTime;
                % We allow 1 second offset.
                boolsWithinServerGpsTimeRange ...
                    = (curClientGpsTime>(serverGpsTime(1)-1000)) ...
                    & (curClientGpsTime<(serverGpsTime(end)+1000));
                
                clientGpsTime = gpsRecordsCell{idxDataSet}.files( ...
                    curIdxClient).gpsTime(boolsWithinServerGpsTimeRange);
                clientLat = gpsRecordsCell{idxDataSet}.files( ...
                    curIdxClient).lat(boolsWithinServerGpsTimeRange);
                clientLon = gpsRecordsCell{idxDataSet}.files( ...
                    curIdxClient).lon(boolsWithinServerGpsTimeRange);
                
                % Ignore warnings temporarily.
                warning('off','all');
                [ coorsXY, ~ ] = planeTransFixedServerWithHeading(...
                    serverGpsTime, serverLat, serverLon, ...
                    serverBearing, ...
                    clientGpsTime, clientLat, clientLon);
                warning('on','all');
                
                % Remove nan results.
                coorsXY(isnan(coorsXY(:,1))|isnan(coorsXY(:,2)), :) = [];
                
                % Remove dots that are too far away.
                coorsXY( ...
                    vecnorm(coorsXY,2,2) ...
                    >MAX_DIST_TO_K_OF_INTEREST_IN_M, ...
                    :) = [];
                
                if ~isempty(coorsXY)
                    [ numPtsFound, ~ ] = size(coorsXY);
                    newcoorsXYWrtFixedKsCell = struct( ...
                        'CenterGrainFileIdx', curIdxK, ...
                        'ClientVehFileIdx', curIdxClient, ...
                        'xs', coorsXY(:,1), 'ys', coorsXY(:,2));
                    
                    curCoorsXYWrtFixedKs(end+1, 1) ...
                        = newcoorsXYWrtFixedKsCell; %#ok<SAGROW>
                end
            end
            textprogressbar(' Done!');
        end
        coorsXYWrtFixedKsCell{idxDataSet} = curCoorsXYWrtFixedKs;
    end
    
    disp('    Done!')
    
    disp(' ')
    disp('    Caching the results ...');
    
    save(fullPathToResultMatFile, ...
        'coorsXYWrtFixedKsCell', 'INFO_FOR_DATA_TO_LOAD');
    
    disp('    Done!')
end

%% Plot the Vehicle PMF Around Grain Carts

if HIDE_FIGS
    % We will save figures without showing them.
    set(0, 'DefaultFigureVisible', 'off');
end

% For all the data sets together.
allXs = arrayfun(@(idxDataSet) ...
    vertcat(coorsXYWrtFixedKsCell{idxDataSet}.xs), ...
    1:numDataSets, 'UniformOutput', false);
allXs = vertcat(allXs{:});
allYs = arrayfun(@(idxDataSet) ...
    vertcat(coorsXYWrtFixedKsCell{idxDataSet}.ys), ...
    1:numDataSets, 'UniformOutput', false);
allYs = vertcat(allYs{:});

% Also save another set of copies with a different colormap.
newColormap = 'gray';
fctChangeColormap = @(cm) eval(['colormap ', cm]);

maxDistMOfInterest = 500;

boolsCloseEnough = (vecnorm([allXs'; allYs']) <= maxDistMOfInterest)';
gridsize = 5;

[hCurPmfMap, hFigTrack] = gen2dPmfMap( ...
    allXs(boolsCloseEnough), allYs(boolsCloseEnough), gridsize);
hideInvalidCircleArea(hCurPmfMap, maxDistMOfInterest);
title({'Combines and Trucks around Grain Carts'; ...
    ['(', num2str(maxDistMOfInterest), ' m Distance Range with ', ...
    num2str(gridsize),' m Grid Size)']});
curFigFileDir = fullfile(fullPathToSaveResults, ...
    ['2dPmfMapForAllData_distRange_', num2str(maxDistMOfInterest), ...
    '_gridSize_', num2str(gridsize)]);
saveas(hCurPmfMap, [curFigFileDir, '.png']);
fctChangeColormap(newColormap);
saveas(hCurPmfMap, [curFigFileDir, '_', newColormap, '.png']);
saveas(hFigTrack, [curFigFileDir, '_track.png']);

% For a zoomed in version.
maxDistMOfInterest = 125;

boolsCloseEnough = (vecnorm([allXs'; allYs']) <= maxDistMOfInterest)';
gridsize = 2;

[hCurPmfMap, hFigTrack] = gen2dPmfMap( ...
    allXs(boolsCloseEnough), allYs(boolsCloseEnough), gridsize);
hideInvalidCircleArea(hCurPmfMap, maxDistMOfInterest);
title({'Combines and Trucks around Grain Carts'; ...
    ['(', num2str(maxDistMOfInterest), ' m Distance Range with ', ...
    num2str(gridsize),' m Grid Size)']});
curFigFileDir = fullfile(fullPathToSaveResults, ...
    ['2dPmfMapForAllData_distRange_', num2str(maxDistMOfInterest), ...
    '_gridSize_', num2str(gridsize)]);
saveas(hCurPmfMap, [curFigFileDir, '.png']);
fctChangeColormap(newColormap);
saveas(hCurPmfMap, [curFigFileDir, '_', newColormap, '.png']);
saveas(hFigTrack, [curFigFileDir, '_track.png']);

% For trucks and combines separately.

VEH_TYPES = {'Combine', 'Grain Kart', 'Truck'};

numPts = length(allXs);

allClientVehType = nan(numPts, 1);
cntDeterminedCliVeh = 0;
for idxDataSet = 1:numDataSets
    curCoorsSets = coorsXYWrtFixedKsCell{idxDataSet};
    curNumCoorsSets = length(coorsXYWrtFixedKsCell{idxDataSet});
    for idxCoorsSet = 1:curNumCoorsSets
        curCoorsStruct = curCoorsSets(idxCoorsSet);
        
        curNumPts = length(curCoorsStruct.xs);
        
        allClientVehType((1:curNumPts)+cntDeterminedCliVeh) ...
            = find(strcmp(VEH_TYPES, ...
            gpsRecordsCell{idxDataSet}.files( ...
            curCoorsStruct.ClientVehFileIdx).type));
        cntDeterminedCliVeh = cntDeterminedCliVeh+curNumPts;
    end
end
boolsIsC = allClientVehType==find(strcmp(VEH_TYPES, 'Combine'));
boolsIsT = allClientVehType==find(strcmp(VEH_TYPES, 'Truck'));

[hCurPmfMap, hFigTrack] = gen2dPmfMap( ...
    allXs(boolsCloseEnough&boolsIsC), ...
    allYs(boolsCloseEnough&boolsIsC), gridsize);
hideInvalidCircleArea(hCurPmfMap, maxDistMOfInterest);
title({'Combines around Grain Carts'; ...
    ['(', num2str(maxDistMOfInterest), ' m Distance Range with ', ...
    num2str(gridsize),' m Grid Size)']});
curFigFileDir = fullfile(fullPathToSaveResults, ...
    ['2dPmfMapForAllData_distRange_', num2str(maxDistMOfInterest), ...
    '_gridSize_', num2str(gridsize), '_combines']);
saveas(hCurPmfMap, [curFigFileDir, '.png']);
fctChangeColormap(newColormap);
saveas(hCurPmfMap, [curFigFileDir, '_', newColormap, '.png']);
saveas(hFigTrack, [curFigFileDir, '_track.png']);

[hCurPmfMap, hFigTrack] = gen2dPmfMap( ...
    allXs(boolsCloseEnough&boolsIsT), ...
    allYs(boolsCloseEnough&boolsIsT), gridsize);
hideInvalidCircleArea(hCurPmfMap, maxDistMOfInterest);
title({'Trucks around Grain Carts'; ...
    ['(', num2str(maxDistMOfInterest), ' m Distance Range with ', ...
    num2str(gridsize),' m Grid Size)']});
curFigFileDir = fullfile(fullPathToSaveResults, ...
    ['2dPmfMapForAllData_distRange_', num2str(maxDistMOfInterest), ...
    '_gridSize_', num2str(gridsize), '_trucks']);
saveas(hCurPmfMap, [curFigFileDir, '.png']);
fctChangeColormap(newColormap);
saveas(hCurPmfMap, [curFigFileDir, '_', newColormap, '.png']);
saveas(hFigTrack, [curFigFileDir, '_track.png']);

% For a zoomed in even more version.
maxDistMOfInterest = 50;
boolsCloseEnough = (vecnorm([allXs'; allYs']) <= maxDistMOfInterest)';

gridsize = 0.5;

[hCurPmfMap, hFigTrack] = gen2dPmfMap( ...
    allXs(boolsCloseEnough), allYs(boolsCloseEnough), gridsize);
hideInvalidCircleArea(hCurPmfMap, maxDistMOfInterest);
title({'Combines and Trucks around Grain Carts'; ...
    ['(', num2str(maxDistMOfInterest), ' m Distance Range with ', ...
    num2str(gridsize),' m Grid Size)']});
curFigFileDir = fullfile(fullPathToSaveResults, ...
    ['2dPmfMapForAllData_distRange_', num2str(maxDistMOfInterest), ...
    '_gridSize_', num2str(gridsize)]);
saveas(hCurPmfMap, [curFigFileDir, '.png']);
fctChangeColormap(newColormap);
saveas(hCurPmfMap, [curFigFileDir, '_', newColormap, '.png']);
saveas(hFigTrack, [curFigFileDir, '_track.png']);

[hCurPmfMap, hFigTrack] = gen2dPmfMap( ...
    allXs(boolsCloseEnough&boolsIsC), ...
    allYs(boolsCloseEnough&boolsIsC), gridsize);
hideInvalidCircleArea(hCurPmfMap, maxDistMOfInterest);
title({'Combines around Grain Carts'; ...
    ['(', num2str(maxDistMOfInterest), ' m Distance Range with ', ...
    num2str(gridsize),' m Grid Size)']});
curFigFileDir = fullfile(fullPathToSaveResults, ...
    ['2dPmfMapForAllData_distRange_', num2str(maxDistMOfInterest), ...
    '_gridSize_', num2str(gridsize), '_combines']);
saveas(hCurPmfMap, [curFigFileDir, '.png']);
fctChangeColormap(newColormap);
saveas(hCurPmfMap, [curFigFileDir, '_', newColormap, '.png']);
saveas(hFigTrack, [curFigFileDir, '_track.png']);

[hCurPmfMap, hFigTrack] = gen2dPmfMap( ...
    allXs(boolsCloseEnough&boolsIsT), ...
    allYs(boolsCloseEnough&boolsIsT), gridsize);
hideInvalidCircleArea(hCurPmfMap, maxDistMOfInterest);
title({'Trucks around Grain Carts'; ...
    ['(', num2str(maxDistMOfInterest), ' m Distance Range with ', ...
    num2str(gridsize),' m Grid Size)']});
curFigFileDir = fullfile(fullPathToSaveResults, ...
    ['2dPmfMapForAllData_distRange_', num2str(maxDistMOfInterest), ...
    '_gridSize_', num2str(gridsize), '_trucks']);
saveas(hCurPmfMap, [curFigFileDir, '.png']);
fctChangeColormap(newColormap);
saveas(hCurPmfMap, [curFigFileDir, '_', newColormap, '.png']);
saveas(hFigTrack, [curFigFileDir, '_track.png']);

if HIDE_FIGS
    close all;
end

%% Plot the Vehicle Movement Pattern Around Grain Carts

SCATTER_MARKER_AREA = 1;
SCATTER_MARKER_COLOR_C = 'b';
SCATTER_MARKER_COLOR_T = 'r';
SCATTER_MARKER_ALPHA = 0.1/(length(allXs)/MAX_DIST_TO_K_OF_INTEREST_IN_M^2);

hMovePatternMap = figure; hold on;
scatter(allXs(boolsIsC), allYs(boolsIsC), SCATTER_MARKER_AREA, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', SCATTER_MARKER_COLOR_C, ...
    'MarkerFaceAlpha', SCATTER_MARKER_ALPHA);
scatter(allXs(boolsIsT), allYs(boolsIsT), SCATTER_MARKER_AREA, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', SCATTER_MARKER_COLOR_T, ...
    'MarkerFaceAlpha', SCATTER_MARKER_ALPHA);
hLocsAroundCs = scatter([], [], SCATTER_MARKER_AREA, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', SCATTER_MARKER_COLOR_C, ...
    'MarkerFaceAlpha', 1);
hLocsAroundTs = scatter([], [], SCATTER_MARKER_AREA, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', SCATTER_MARKER_COLOR_T, ...
    'MarkerFaceAlpha', 1);
legend([hLocsAroundCs, hLocsAroundTs], 'Combine', 'Truck');
xlabel('x (m)');
ylabel('y (m)');
pbaspect([1 1 1]); axis tight;
grid on;

halfSideLengthSquareOfInterest = 500;
axis([-halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest, ...
    -halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest]);

sideLengthSquareOfInterest = halfSideLengthSquareOfInterest.*2;
title({'Combine and Truck Locations around Grain Carts'; ...
    ['(Within a ', num2str(sideLengthSquareOfInterest), ...
    'm-Side-Length Square Area)']});
saveas(hMovePatternMap, ...
    fullfile(fullPathToSaveResults, ...
    ['vehLocsAroundKsForAllData_sideLength_', ...
    num2str(sideLengthSquareOfInterest), '.png']));

halfSideLengthSquareOfInterest = 125;
axis([-halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest, ...
    -halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest]);

sideLengthSquareOfInterest = halfSideLengthSquareOfInterest.*2;
title({'Combine and Truck Locations around Grain Carts'; ...
    ['(Within a ', num2str(sideLengthSquareOfInterest), ...
    'm-Side-Length Square Area)']});
saveas(hMovePatternMap, ...
    fullfile(fullPathToSaveResults, ...
    ['vehLocsAroundKsForAllData_sideLength_', ...
    num2str(sideLengthSquareOfInterest), '.png']));

halfSideLengthSquareOfInterest = 50;
axis([-halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest, ...
    -halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest]);

sideLengthSquareOfInterest = halfSideLengthSquareOfInterest.*2;
title({'Combine and Truck Locations around Grain Carts'; ...
    ['(Within a ', num2str(sideLengthSquareOfInterest), ...
    'm-Side-Length Square Area)']});
saveas(hMovePatternMap, ...
    fullfile(fullPathToSaveResults, ...
    ['vehLocsAroundKsForAllData_sideLength_', ...
    num2str(sideLengthSquareOfInterest), '.png']));

if HIDE_FIGS
    close all;
end

%% Plot the Combine Movement Pattern Around Grain Carts

hMovePatternMapC = figure;
scatter(allXs(boolsIsC), allYs(boolsIsC), ...
    SCATTER_MARKER_AREA, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', SCATTER_MARKER_COLOR_C, ...
    'MarkerFaceAlpha', SCATTER_MARKER_ALPHA);

xlabel('x (m)');
ylabel('y (m)');
pbaspect([1 1 1]); axis tight;
grid on;

halfSideLengthSquareOfInterest = 500;
axis([-halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest, ...
    -halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest]);

sideLengthSquareOfInterest = halfSideLengthSquareOfInterest.*2;
title({'Combine Locations around Grain Carts'; ...
    ['(Within a ', num2str(sideLengthSquareOfInterest), ...
    'm-Side-Length Square Area)']});
saveas(hMovePatternMapC, ...
    fullfile(fullPathToSaveResults, ...
    ['vehLocsAroundKsForAllData_sideLength_', ...
    num2str(sideLengthSquareOfInterest), '_combines.png']));

halfSideLengthSquareOfInterest = 125;
axis([-halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest, ...
    -halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest]);

sideLengthSquareOfInterest = halfSideLengthSquareOfInterest.*2;
title({'Combine Locations around Grain Carts'; ...
    ['(Within a ', num2str(sideLengthSquareOfInterest), ...
    'm-Side-Length Square Area)']});
saveas(hMovePatternMapC, ...
    fullfile(fullPathToSaveResults, ...
    ['vehLocsAroundKsForAllData_sideLength_', ...
    num2str(sideLengthSquareOfInterest), '_combines.png']));

halfSideLengthSquareOfInterest = 50;
axis([-halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest, ...
    -halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest]);

sideLengthSquareOfInterest = halfSideLengthSquareOfInterest.*2;
title({'Combine Locations around Grain Carts'; ...
    ['(Within a ', num2str(sideLengthSquareOfInterest), ...
    'm-Side-Length Square Area)']});
saveas(hMovePatternMapC, ...
    fullfile(fullPathToSaveResults, ...
    ['vehLocsAroundKsForAllData_sideLength_', ...
    num2str(sideLengthSquareOfInterest), '_combines.png']));

if HIDE_FIGS
    close all;
end

%% Plot the Truck Movement Pattern Around Grain Carts

hMovePatternMapC = figure;
scatter(allXs(boolsIsT), allYs(boolsIsT), ...
    SCATTER_MARKER_AREA, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', SCATTER_MARKER_COLOR_T, ...
    'MarkerFaceAlpha', SCATTER_MARKER_ALPHA);

xlabel('x (m)');
ylabel('y (m)');
pbaspect([1 1 1]); axis tight;
grid on;

halfSideLengthSquareOfInterest = 500;
axis([-halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest, ...
    -halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest]);

sideLengthSquareOfInterest = halfSideLengthSquareOfInterest.*2;
title({'Truck Locations around Grain Carts'; ...
    ['(Within a ', num2str(sideLengthSquareOfInterest), ...
    'm-Side-Length Square Area)']});
saveas(hMovePatternMapC, ...
    fullfile(fullPathToSaveResults, ...
    ['vehLocsAroundKsForAllData_sideLength_', ...
    num2str(sideLengthSquareOfInterest), '_trucks.png']));

halfSideLengthSquareOfInterest = 125;
axis([-halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest, ...
    -halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest]);

sideLengthSquareOfInterest = halfSideLengthSquareOfInterest.*2;
title({'Truck Locations around Grain Carts'; ...
    ['(Within a ', num2str(sideLengthSquareOfInterest), ...
    'm-Side-Length Square Area)']});
saveas(hMovePatternMapC, ...
    fullfile(fullPathToSaveResults, ...
    ['vehLocsAroundKsForAllData_sideLength_', ...
    num2str(sideLengthSquareOfInterest), '_trucks.png']));

halfSideLengthSquareOfInterest = 50;
axis([-halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest, ...
    -halfSideLengthSquareOfInterest, halfSideLengthSquareOfInterest]);

sideLengthSquareOfInterest = halfSideLengthSquareOfInterest.*2;
title({'Truck Locations around Grain Carts'; ...
    ['(Within a ', num2str(sideLengthSquareOfInterest), ...
    'm-Side-Length Square Area)']});
saveas(hMovePatternMapC, ...
    fullfile(fullPathToSaveResults, ...
    ['vehLocsAroundKsForAllData_sideLength_', ...
    num2str(sideLengthSquareOfInterest), '_trucks.png']));

if HIDE_FIGS
    close all;
    set(0, 'DefaultFigureVisible', 'on');
end

% EOF