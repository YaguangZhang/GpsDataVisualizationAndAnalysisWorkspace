% TRIAL5_3_SNIPPETTODRAWDIFFFIELDSHAPES Trial 5.3 - The snippet to draw the
% field boundries from the farmer and the corresponding alpha shape boundry
% from 5.3. One can copy the snippet they want to a temp .m file to run it.
%
% Need to load the data manually first. Especially, files,
% enhancedFieldShapes and harvestedPts are required.
%
% Yaguang Zhang, Purdue, 06/08/2017


%% 1. Output Shape Comparison for Full and Partial Statistical Harv

% After run both trial 5 and trial 5.1 for the same field.
colorOrg = [255, 150, 0]/255;
colorBlu = [0, 150, 255]/255;
alphaExFactor = 1;

hFig = figure;
hold on; axis off;
boolsToPlotF = harvProsF>0.5;
harvFieldF = alphaShape(lonsF(boolsToPlotF), latsF(boolsToPlotF));
harvFieldF.Alpha = harvFieldF.Alpha*alphaExFactor;
harvShapeF = plot(harvFieldF, ...
    'FaceColor', 'red','FaceAlpha',0.5, 'EdgeAlpha', 0);
boolsToPlot = inShape(extendedEnhancedFieldShapeUtm, xsF, ysF);
harvField = alphaShape(lonsF(boolsToPlot), latsF(boolsToPlot));
harvField.Alpha = harvField.Alpha*alphaExFactor;
harvShape = plot(harvField, ...
    'FaceColor', 'blue','FaceAlpha',0.5, 'EdgeAlpha', 0);
daspect auto; plot_google_map('MapType', 'satellite');
hold off;
%% Then zoom in to area of interest, adjust the figure window size, and add
% the legend.
legend('Ha','Ex'); % legend({'Ha','Ex'}, 'FontSize', 14, 'Location', 'southeast');

%% 2. Enhanced Field Shape vs Extended Field Shape vs Owner's Boundary

%% Cheatsheet: [Lat, Lon]
centersOwnerBound = [40.5749, -102.3453;
    40.7706, -102.1216;
    40.8753, -102.3487;
    40.8037, -102.2818;
    40.7892, -102.318;
    40.6747, -102.1298;
    40.7584, -102.3487;
    40.7749, -102.2892;
    40.8482, -102.4351;
    40.7146, -102.3474];
indicesOwnerBound2014 = [1;2;  3; 4; 5; 6; 7; 8];
indicesEnShapes2014 =   [1;19;16;14;13;26;28;29];

indicesOwnerBound2016 = [3; 4;5;9;10];
indicesEnShapes2016 =  [15;17;8;9; 7];

%% Load Owner's Boundaries
REL_DIR_SHAPE_FILEFOLDER = ...
    fullfile('..', '..', '..', '..', '..', '..', ...
    'Harvest_Ballet_FieldBoundries', 'JIM BOUNDARIES');
OwnerBounds = cell(10,1);
for idxOwnerB = 1:10
    fileName = ['ITEM ',num2str(idxOwnerB)];
    shapeFilePath = fullfile(REL_DIR_SHAPE_FILEFOLDER, fileName);
    [OwnerBounds{idxOwnerB}, Area] = shaperead(shapeFilePath);
end

%% Find which field is for which owner's boundary.
for idxB = indicesOwnerBound2014'
    center = centersOwnerBound(idxB, :);
    center = center(end:-1:1);
    disp('------------------------------');
    disp(['Item ', num2str(idxB)]);
    disp('------------------------------');
    for idxS = 1:length(enhancedFieldShapes)
        if (inShape(enhancedFieldShapes{idxS},center))
            disp(num2str(idxS));
        end
    end
end

%% Plot
for idx = 1:length(indicesEnShapes2014)
    
    idxEnShape = indicesEnShapes2014(idx);
    idxOwnerB = indicesOwnerBound2014(idx);
    
    idxField = idxEnShape;
    doNotAssignIdxField = true;
    skipGeneratingFigures = true;
    Trial5_1_StatisticalHarvestForBoundary;
    clear doNotAssignIdxField skipGeneratingFigures;
    
%     optimalAlpha = 11.38;
%     preliminaryFieldShapeUtm = enhancedFieldShapesUtm{idxEnShape};
%     preliminaryFieldShapeUtm.Alpha = optimalAlpha;
%     boolsInPreShape = inShape(preliminaryFieldShapeUtm, xs, ys);
%     PreFieldShapeLons = lons(boolsInPreShape);
%     PreFieldShapeLats = lats(boolsInPreShape);
    
    PreFieldShape = enhancedFieldShapes{idxEnShape};

    ExEnhFieldShapeUtm = extendedEnhancedFieldShapeUtm;
    boolsInExShape = inShape(ExEnhFieldShapeUtm, xs, ys);
    ExEnhFieldShapeLons = lons(boolsInExShape);
    ExEnhFieldShapeLats = lats(boolsInExShape);
    
    if idxOwnerB==2
        % This field boundary do not have the same number of points for X &
        % Y. Manually fix it.
        [x1,ownerBoundLons]=OwnerBounds{idxOwnerB}.X;
        [y1,ownerBoundLats]=OwnerBounds{idxOwnerB}.Y;
    else
        ownerBoundLons = OwnerBounds{idxOwnerB}.X(1:(end-1));
        ownerBoundLats = OwnerBounds{idxOwnerB}.Y(1:(end-1));
    end
    figFileName = ['Trial5_3_SnippetToDrawDiffFieldShapes_2014_idx_', num2str(idx),'_idxBoud_', num2str(idxOwnerB), '_idxEnS_', num2str(idxEnShape)];
    hFig = figure('Position', [0,0,400,400]); axis off; hold on;
    % Extended field shape points.
    hE = plot(ExEnhFieldShapeLons, ExEnhFieldShapeLats, 'o', ...
        'MarkerSize',1,'Color', [255,200,0]/255);
    % Preliminary field shape
    hP = plot(PreFieldShape, ...
        'FaceColor','blue','FaceAlpha',0.5, 'EdgeAlpha', 0);
%     hP = plot(alphaShape(PreFieldShapeLons, PreFieldShapeLats), ...
%         'FaceColor','blue','FaceAlpha',0.6, 'EdgeAlpha', 0);
    % Owner's boundary.
    hO = plot(ownerBoundLons, ownerBoundLats, 'r-.', 'LineWidth',1.5);
    % Relevant tracks.
    for idxFile = indicesFilesToUse
        if strcmp(files(idxFile).type, 'Combine')
            hT = plot(files(idxFile).lon, files(idxFile).lat, 'Color', [1 1 1]*0,'LineWidth', 0.5);
        end
    end
    % Fake the legend for the extended field shape.
    hF = plot(alphaShape(ExEnhFieldShapeLons(1:5),ExEnhFieldShapeLats(1:5)), ...
        'FaceColor',[255,200,0]/255,'FaceAlpha',0.5, 'EdgeAlpha', 0);
    daspect auto; plot_google_map('MapType', 'satellite'); hold off;
    hL = legend([hT, hP, hF, hO, ],'Combine Tracks Involved', 'Preliminary Field Shape', 'Extended by Statistical Harvesting','Reference Boundary from Field Owner');
    tightfig; % set(hF, 'Visible', false);
    legendPos = get(hL,'Position');
    set(hL,'Position',[1-legendPos(3)-0.01,1-legendPos(4)-0.01, legendPos(3:4)]);
    % We have captured the legend.
    saveas(hFig, [figFileName, '.png']);
    saveas(hFig, [figFileName, '.fig']);
    close all;
end

%% For 2016 data

% Load data from the trials folder.
dataFolderPath2016 = fullfile('..','..','..','..','..','..', ...
    'Harvest_Ballet_2016','harvests_synchronized','_AUTOGEN_IMPORTANT');
if(~exist('files', 'var'))
    load(fullfile(dataFolderPath2016, ...
        'filesLoadedHistory.mat'));
end
if(~exist('statesByDist', 'var'))
    load(fullfile(dataFolderPath2016, ...
        'filesLoadedStatesByDist.mat'));
end
if(~exist('enhancedFieldShapes', 'var'))
    load(fullfile(dataFolderPath2016, ...
        'enhancedFieldShapes.mat'));
end
if(~exist('enhancedFieldShapesUtm', 'var'))
    load(fullfile(dataFolderPath2016, ...
        'enhancedFieldShapesUtm.mat'));
end

%% Find which field is for which owner's boundary.
for idxB = indicesOwnerBound2016'
    center = centersOwnerBound(idxB, :);
    center = center(end:-1:1);
    disp('------------------------------');
    disp(['Item ', num2str(idxB)]);
    disp('------------------------------');
    for idxS = 1:length(enhancedFieldShapes)
        if (inShape(enhancedFieldShapes{idxS},center))
    legend off;
    
    load gong.mat;
    soundsc(y, 2*Fs);
    disp('Please adjust the figure before saving...');
    pause;
    disp('Saving figure...')
            disp(num2str(idxS));
        end
    end
end

%% If not found... Ref:
figure;hold on;
for idxFile=1:length(files)
    plot(files(idxFile).lon, files(idxFile).lat);
end
daspect auto; plot_google_map('MapType', 'satellite');
center = centersOwnerBound(4, :);
plot(center(2), center(1), 'r*')

%% Plot
for idx = 1:length(indicesEnShapes2016)
    
    idxEnShape = indicesEnShapes2016(idx);
    idxOwnerB = indicesOwnerBound2016(idx);
    
    idxField = idxEnShape;
    doNotAssignIdxField = true;
    skipGeneratingFigures = true;
    allDataLoaded = true;
    Trial5_1_StatisticalHarvestForBoundary;
    clear doNotAssignIdxField skipGeneratingFigures allDataLoaded;
    
%     optimalAlpha = 11.38;
%     preliminaryFieldShapeUtm = enhancedFieldShapesUtm{idxEnShape};
%     preliminaryFieldShapeUtm.Alpha = optimalAlpha;
%     boolsInPreShape = inShape(preliminaryFieldShapeUtm, xs, ys);
%     PreFieldShapeLons = lons(boolsInPreShape);
%     PreFieldShapeLats = lats(boolsInPreShape);
    
    PreFieldShape = enhancedFieldShapes{idxEnShape};
    
    ExEnhFieldShapeUtm = extendedEnhancedFieldShapeUtm;
    boolsInExShape = inShape(ExEnhFieldShapeUtm, xs, ys);
    ExEnhFieldShapeLons = lons(boolsInExShape);
    ExEnhFieldShapeLats = lats(boolsInExShape);
    
    ownerBoundLons = OwnerBounds{idxOwnerB}.X(1:(end-1));
    ownerBoundLats = OwnerBounds{idxOwnerB}.Y(1:(end-1));
    
    figFileName = ['Trial5_3_SnippetToDrawDiffFieldShapes_2016_idx_', num2str(idx),'_idxBoud_', num2str(idxOwnerB), '_idxEnS_', num2str(idxEnShape)];
    hFig = figure('Position', [0,0,400,400]); axis off; hold on;
    % Extended field shape points.
    hE = plot(ExEnhFieldShapeLons, ExEnhFieldShapeLats, 'o', ...
        'MarkerSize',1,'Color', [255,200,0]/255);
    % Preliminary field shape
    hP = plot(PreFieldShape, ...
         'FaceColor','blue','FaceAlpha',0.5, 'EdgeAlpha', 0);
%     hP = plot(alphaShape(PreFieldShapeLons, PreFieldShapeLats), ...
%         'FaceColor','blue','FaceAlpha',0.6, 'EdgeAlpha', 0);
    % Owner's boundary.
    hO = plot(ownerBoundLons, ownerBoundLats, 'r-.', 'LineWidth',1.5);
    % Relevant tracks.
    for idxFile = indicesFilesToUse
        if strcmp(files(idxFile).type, 'Combine')
            hT = plot(files(idxFile).lon, files(idxFile).lat, 'Color', [1 1 1]*0,'LineWidth', 0.5);
        end
    end
    % Fake the legend for the extended field shape.
    hF = plot(alphaShape(ExEnhFieldShapeLons(1:5),ExEnhFieldShapeLats(1:5)), ...
        'FaceColor',[255,200,0]/255,'FaceAlpha',0.5, 'EdgeAlpha', 0);
    daspect auto; plot_google_map('MapType', 'satellite'); hold off;
    hL = legend([hT, hP, hF, hO, ],'Combine Tracks Involved', 'Preliminary Field Shape', 'Extended by Statistical Harvesting','Reference Boundary from Field Owner');
    tightfig; % set(hF, 'Visible', false);
    legendPos = get(hL,'Position');
    set(hL,'Position',[1-legendPos(3)-0.01,1-legendPos(4)-0.01, legendPos(3:4)]);
    % We have captured the legend.
    legend off;
    
    load gong.mat;
    soundsc(y, 2*Fs);
    disp('Please adjust the figure before saving...');
    pause;
    disp('Saving figure...')
    saveas(hFig, [figFileName, '.png']);
    saveas(hFig, [figFileName, '.fig']);
    close all;
end

% EOF