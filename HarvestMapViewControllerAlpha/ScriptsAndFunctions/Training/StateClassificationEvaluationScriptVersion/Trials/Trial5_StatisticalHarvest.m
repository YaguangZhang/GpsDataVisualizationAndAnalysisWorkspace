% TRIAL5_STATISTICALHARVEST Trial 5 - Plot the statistical result for some
% fields.
%
% Yaguang Zhang, Purdue, 05/19/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));
if(~exist('enhancedFieldShapes', 'var'))
    load(fullfile(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
        'enhancedFieldShapes.mat'));
end

% The file indices for the first field in the data set.
indicesFilesToUse = 1:length(files); % 1:5;
% Use default settings. E.g. 30 feet header width (~= 9.144 m)
gridWidth = 1;
idxField = 29; %1;

fieldShape = enhancedFieldShapes{idxField};
% ----------------------------
% Production version.
% ----------------------------
[ harvestedPts ] = statisticalHarvestTruc( files(indicesFilesToUse), ...
    indicesFilesToUse, ...
    statesRef, fieldShape, gridWidth );
% ----------------------------
% For debugging: Run and Time to improve code performance.
% 
% This won't work. Just run the other version using "Run and Time" and
% press ctrl+c after a while. ---------------------------- trucFiles =
% files; trucStates = statesRef; maxNumSamplesPerFile = 2000; for idxFile =
% indicesFilesToUse
%     idxEnd = min(length(files(idxFile).gpsTime), maxNumSamplesPerFile);
%     trucFiles(idxFile) = subFile(files(idxFile), ...
%         1, idxEnd);
%     trucStates{idxFile} = trucStates{idxFile}(1:idxEnd,:);
% end
% [ harvestedPts ] = statisticalHarvestTruc( trucFiles(indicesFilesToUse), ...
%     indicesFilesToUse, ...
%     trucStates, fieldShape, gridWidth );
% ----------------------------

% Save the result.
fileName = ['Trial5_Results_gridWidth_', num2str(gridWidth), ...
    '_idxField_', num2str(idxField)];
save([fileName, '.mat'], 'harvestedPts');

% Figures.
numHarvPts = length(harvestedPts);
[ xs, ys, lats, lons, harvPros, idsMostLikelyCom ] = deal(nan(numHarvPts,1));
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
plot3(fieldShape.Points(:,1), fieldShape.Points(:,2), ...
    ones(length(fieldShape.Points(:,1)),1), 'r-', 'LineWidth',0.1);
plot_google_map; hold off;
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

% EOF