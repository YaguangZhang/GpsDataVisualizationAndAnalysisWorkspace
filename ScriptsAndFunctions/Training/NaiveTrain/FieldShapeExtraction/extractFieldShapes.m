%EXTRACTFIELDSHAPES Extract field shapes from GPS tracks from combines
%during harvesting.
%
% Key ideas:
%
%   1) Use alpha shapes, with alpha choosen by estimated combine header
%   width and harvesting speed range.
%
%   2) Generate "statistical"  edges for the whole field and holes inside,
%   via simulating harvesting with a predefined harvested-probability vs
%   distance-to-middle-line function.
%
% Yaguang Zhang, Purdue, 12/16/2015

%% Set Matlab path.

% Add current folder.
cd(fullfile(fileparts(mfilename('fullpath'))));
addpath(fullfile(pwd));

% Changed folder to "ScriptsAndFunctions".
cd(fullfile(fileparts(which(mfilename)),'..', '..', '..'));
% Set path.
setMatlabPath;

%% Load data needed.
% We only need files and locations.

% Relative path to the data set.
% fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2016', 'harvests_synchronized');
fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015');

try
    pathNaiveTrainResultsFilefolder = fullfile(pwd, fileFolder, ...
        '_AUTOGEN_IMPORTANT');
    
    if(exist('files', 'var'))
        disp('GPS tracks found in current workspace. We will reuse them for convenience.');
    else
        disp('Loading GPS tracks...')
        load(fullfile(pathNaiveTrainResultsFilefolder, 'filesLoadedHistory.mat'));
        disp('  Done!')
    end
    if(exist('locations', 'var'))
        disp('Location labels for the GPS tracks found in current workspace. We will reuse them for convenience.');
    else
        disp('Loading location labels for the GPS tracks...')
        load(fullfile(pathNaiveTrainResultsFilefolder, 'filesLoadedLocations.mat'));
        disp('  Done!')
    end
catch
    disp('Full path for fileFolder:');
    disp(fullfile(pwd, fileFolder));
    error('Unable to load the data required for the data set specified! Please make sure naiveTrain.m has been run for this dataset before.');
end

%% Predefined parameters.

% Estimated combine header width in meters.
HEADER_WIDTH = 9.1; % 30 feet is around 9.144 meters. Denoted by W in the document.

% Updated according to the ASABE paper. Harvesting speed range for
% combines. [0.044704, 6.7056] m/s (i.e. ~[0.1, 15] MPH).
%MIN_HARVEST_SPE = 0.044704;
MAX_HARVEST_SPE = 4; % 6.7056;

% GPS sample period in second.
GPS_SAMPLE_PERIOD = 1;

% Generate and save field shape (for both the lat & lon and the UTM
% version) plots.
FLAG_GEN_AND_SAVE_FIELD_SHAPES = true;
FIGURE_EXT = 'jpg';

%% Compute alpha.

% Updated according to the ASABE paper.
d_Max = MAX_HARVEST_SPE*GPS_SAMPLE_PERIOD;
alpha = 11.38; % ALPHA_RELAX_RATIO* sqrt((d_Max/2)^2 + HEADER_WIDTH^2) / ( 2*cos(atan(d_Max/(2*HEADER_WIDTH))) );

%% Construct alpha shapes accordingly.

% The minimum diameter of a valid field at the end.
MIN_FIELD_DIAMETER = 100; % In meters. Ref: before 200 was used.
FORCE_CREATE_NEW = true;

if(exist('enhancedFieldShapes', 'var'))
    disp('Field shapes found in current workspace. We will reuse them for convenience.');
else
    pathEnhancedFieldShapes = fullfile(pathNaiveTrainResultsFilefolder, 'enhancedFieldShapes.mat');
    if(exist(pathEnhancedFieldShapes, 'file') && ~FORCE_CREATE_NEW)
        disp('Loading field shapes (with lat & lon)...')
        load(pathEnhancedFieldShapes);
        disp('  Done!');
    else
        disp('Extracting field shapes (with lat & lon)...')
        % We will find fields by long enough consecutive in-field GPS
        % sample sequences. We will also try to merge newly-found ones with
        % the shapes already constructed, if they overlap.
        try
            enhancedFieldShapes = {};
            % Minimum length for the subsequence to contribute to any field
            % shape. 60 samples ~= 60 seconds.This can make the computation
            % faster.
            minValidSubSeqLongth = 60;
            
            % We will only use the GPS data from combines.
            fileCounter = 0;
            for idxFile = fileIndicesCombines'
                fileCounter = fileCounter+1;
                disp(['  File ', num2str(fileCounter), '/', num2str(length(fileIndicesCombines)), '...']);
                
                % We assume the size for a field is normally so small that
                % even if we treat lon & lat as x & y on a 2D plane, the
                % corresponding alphaShapes for different GPS sample
                % sub-sequences for the same field will still overlap, thus
                % being merged here. This way, we don't need to deal with
                % possibly different zone's for one single GPS sample
                % subsquence in the UTM system.
                [indicesSta, indicesEnd] = findConsecutiveSubSeq(locations{idxFile}, 0);
                
                % Get rid of the subsequences that are too short.
                booleansInvalidSubSeq = (indicesEnd-indicesSta)<minValidSubSeqLongth;
                indicesSta = indicesSta(~booleansInvalidSubSeq);
                indicesEnd = indicesEnd(~booleansInvalidSubSeq);
                
                % Organize those subsequences into a cell.
                infieldSubSeqs = {};
                for idxInfieldSubSeq = 1:length(indicesSta)
                    indicesSamplesToExtract = indicesSta(idxInfieldSubSeq):indicesEnd(idxInfieldSubSeq);
                    consecutiveSubSeq.lat = files(idxFile).lat(indicesSamplesToExtract);
                    consecutiveSubSeq.lon = files(idxFile).lon(indicesSamplesToExtract);
                    infieldSubSeqs{end+1} = consecutiveSubSeq;
                end
                
                % Populate enhancedFieldShapes while taking care of
                % merging.
                for idxInfieldSubSeq = 1:length(infieldSubSeqs)
                    
                    % Test whether this subsequence overlaps with any of
                    % the enhanced field shapes we have constructed.
                    booleansFieldShapeOverlapped = cellfun(@(x) any(...
                        inShape(x, ...
                        infieldSubSeqs{idxInfieldSubSeq}.lon, ...
                        infieldSubSeqs{idxInfieldSubSeq}.lat)...
                        ), enhancedFieldShapes);
                    
                    if(~any(booleansFieldShapeOverlapped))
                        % No overlap. We need to add a new field just for
                        % this subsequence.
                        enhancedFieldShapes{end+1} = ...
                            alphaShape(...
                            infieldSubSeqs{idxInfieldSubSeq}.lon, ...
                            infieldSubSeqs{idxInfieldSubSeq}.lat);
                    else
                        % Merge all the fields overlapped with this
                        % subsequence, and add the data for this
                        % subsequence into the shape, too.
                        fieldShapesToMerge = enhancedFieldShapes(booleansFieldShapeOverlapped==1);
                        % Update enhancedFieldShapes.
                        enhancedFieldShapes = enhancedFieldShapes(booleansFieldShapeOverlapped==0);
                        enhancedFieldShapes{end+1} = ...
                            alphaShape(...
                            vertcat(cell2mat(cellfun(@(x) x.Points, fieldShapesToMerge', 'UniformOutput', false)), ...
                            [infieldSubSeqs{idxInfieldSubSeq}.lon, infieldSubSeqs{idxInfieldSubSeq}.lat]) ...
                            );
                    end
                end
            end
        catch e % For debugging.
            % Delete the invalide variable.
            clear('enhancedFieldShapes');
            rethrow(e);
        end
        
        % Check the sizes of the resulted field shapes.
        disp('  Removing field shapes that are too tiny...');
        enhancedFieldShapes = enhancedFieldShapes(...
            cellfun(@(x) fieldDiameter(x.Points(:,2),x.Points(:,1))< MIN_FIELD_DIAMETER, ...
            enhancedFieldShapes)...
            ==0);
        
        disp('  Done!');
        % Also, we will save the results for future usage.
        disp('Saving field shapes (with lat & lon)...')
        save(pathEnhancedFieldShapes, 'enhancedFieldShapes');
        disp('  Done!');
    end
    
end

%% Convert the geographic coordinates (lat & lon) to UTM.

enhancedFieldShapesUtmZones = cell(size(enhancedFieldShapes));
% We will generate a new copy of the alphaShapes cell and store the results
% there.
if(exist('enhancedFieldShapesUtm', 'var'))
    disp('Field shapes with UTM coordinates found in current workspace. We will reuse them for convenience.');
else
    pathEnhancedFieldShapesUtm = fullfile(pathNaiveTrainResultsFilefolder, 'enhancedFieldShapesUtm.mat');
    pathEnhancedFieldShapesUtmZones = fullfile(pathNaiveTrainResultsFilefolder, 'enhancedFieldShapesUtmZones.mat');
    if(exist(pathEnhancedFieldShapesUtm, 'file'))
        disp('Loading field shapes (with UTM coordinates)...')
        load(pathEnhancedFieldShapesUtm);
        disp('  Done!');
    else
        disp('Converting field shapes (from lat & lon to UTM)...')
        enhancedFieldShapesUtm = enhancedFieldShapes;
        for idxEnhancedFieldShapesUtm = 1:length(enhancedFieldShapesUtm)
            disp(['  Field shape ', num2str(idxEnhancedFieldShapesUtm), '/', num2str(length(enhancedFieldShapesUtm)), '...']);
            [easting, northing, zones] = deg2utm(...
                enhancedFieldShapesUtm{idxEnhancedFieldShapesUtm}.Points(:, 2), ...
                enhancedFieldShapesUtm{idxEnhancedFieldShapesUtm}.Points(:, 1) ...
                );
            % Make sure all UTM coordinates in one field are within the
            % same zone.
            try
                if (all(cellfun(@(x) strcmp(zones(1,:),x), num2cell(zones, 2))))
                    enhancedFieldShapesUtmZones{idxEnhancedFieldShapesUtm} = zones(1, :);
                else
                    error('Not all UTM coordinates in the field are within the same zone!')
                end
                
                enhancedFieldShapesUtm{idxEnhancedFieldShapesUtm}.Points = ...
                    [easting, northing];
                enhancedFieldShapesUtm{idxEnhancedFieldShapesUtm}.Alpha = alpha;
            catch e
                disp(e);
                % rethrow(e);
            end
        end
        
        disp('  Done!');
        % Also, we will save the results for future usage.
        disp('Saving field shapes (with UTM coordinates)...')
        save(pathEnhancedFieldShapesUtm, 'enhancedFieldShapesUtm');
        save(pathEnhancedFieldShapesUtmZones, 'pathEnhancedFieldShapesUtmZones');
        disp('  Done!');
    end
end

%% Plot and save the field shapes.

if FLAG_GEN_AND_SAVE_FIELD_SHAPES
    pathFolderToSaveFieldShapes = fullfile(pathNaiveTrainResultsFilefolder, 'AutoGenFieldShapes');
    if(~exist(pathFolderToSaveFieldShapes, 'dir'))
        mkdir(pathFolderToSaveFieldShapes);
    end
    
    for idx = 1:length(enhancedFieldShapes)
        fileName = fullfile(pathFolderToSaveFieldShapes, ['enhancedFieldShapes_', num2str(idx)]);
        if(~exist([fileName,'.',FIGURE_EXT], 'file'))
            hFieldShapeFig = figure;
            plot(enhancedFieldShapes{idx});
            axis normal;
            plot_google_map('MapType', 'satellite');
            saveas(hFieldShapeFig, fileName, 'jpg');
        end
    end
    
    for idx = 1:length(enhancedFieldShapesUtm)
        fileName = fullfile(pathFolderToSaveFieldShapes, ['enhancedFieldShapesUtm_', num2str(idx), '_alpha_', num2str(floor(alpha))]);
        if(~exist([fileName,'.',FIGURE_EXT], 'file'))
            hFieldShapeFig = figure;
            % Note that we don't add any map backgroud here because the
            % coordinates are in UTM.
            plot(enhancedFieldShapesUtm{idx});
            axis equal;
            saveas(hFieldShapeFig, fileName, FIGURE_EXT);
        end
    end
end

% EOF