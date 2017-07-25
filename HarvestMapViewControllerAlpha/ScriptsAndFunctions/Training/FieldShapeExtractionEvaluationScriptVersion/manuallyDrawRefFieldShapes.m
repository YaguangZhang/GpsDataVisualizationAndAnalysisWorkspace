% MANNUALLYDRAWREFFIELDSHAPES Manually draw the field shapes for evaluating
% the field shape extraction algorithm.
%
% Yaguang Zhang, Purdue, 05/24/2017

% Changed folder to "ScriptsAndFunctions" first.
cd(fileparts(mfilename('fullpath')));
cd(fullfile('..', '..'));
% Set path.
setMatlabPath;

%% Load Data
disp('-------------------------------------------------------------');
disp('Collector: Initializing...');

cd(fullfile('Training', 'NaiveTrain'));
if(~exist('files', 'var'))
    loadJvkData;
end
if(~exist('statesRef', 'var'))
    load(fullfile(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
        'filesLoadedStates_ref.mat'));
end
if(~exist('statesByDist', 'var'))
    load(fullfile(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
        'filesLoadedStatesByDist.mat'));
end
if(~exist('enhancedFieldShapes', 'var'))
    load(fullfile(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
        'enhancedFieldShapes.mat'));
end
if(~exist('enhancedFieldShapesUtm', 'var'))
    load(fullfile(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
        'enhancedFieldShapesUtm.mat'));
end

%% Log Files

% The folder where the classification results are saved. We will use the
% file filesLoadedStates_ref.mat to store the collected state information.
pathFieldShapesRefFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathFieldShapesRefFile = fullfile(...
    pathFieldShapesRefFilefolder, ...
    strcat('filesLoadedFieldShapes_ref','.mat')...
    );

% For backup files.
pathBackupFileFolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'Backup_for_Training');

% Create the directory if necessary.
if ~exist(pathFieldShapesRefFilefolder,'dir')
    mkdir(pathFieldShapesRefFilefolder);
end

if ~exist(pathBackupFileFolder,'dir')
    mkdir(pathBackupFileFolder);
end

% Try loading corresponding history record first.
if exist(pathFieldShapesRefFile,'file')
    disp(' ');
    disp('Collector: Loading history results of fieldShapesRef...');
    load(pathFieldShapesRefFile);
    disp('Collector: Done!');
else
    disp(' ');
    disp('Collector: Couldn''t find history results of fieldShapesRef.');
    disp('Collector: Creating fieldShapesRef...');
    
    % Create the variable states to store the results. We will use empty
    % fieldShapesRef.
    disp('           Use an empty cell array as the starting point.')
    
    % Use an empty state holder.
    fieldShapesRef = cell(length(files),1);
    % Save the results into the history file.
    save(pathFieldShapesRefFile, 'fieldShapesRef');
    
    disp('Collector: Done!');
end

%% Manually Run Commands Below
if false
    %% Section to Set and Run Manually to Draw the Boundary
    % Note that you will have to update newFieldShape manually, before
    % saving it to fieldShapesRef.
    
    % Which field to draw.
    idxField = 1;
    
    % Generate reference figure to draw the field on.
    hFig = figure;
    plot(enhancedFieldShapes{idxField},'FaceColor','blue', ...
        'FaceAlpha',0.3, 'EdgeAlpha', 0);
    plot_google_map('MapType', 'satellite');
    title('Please plot the field boundary on this figure');
    
    hPoly = impoly;
    
    %% Section to Update newFieldShape Manually
    newFieldShape = getPosition(hPoly);
    % Do adjustment now.
end

if false
    %% Section to Run Manually to Save the Result to File
    
    % Backup newFieldShape.
    pathBackupStatesRefFile = fullfile(...
        pathBackupFileFolder, ...
        ...
        strcat(...
        'filesLoadedFieldShapes_ref_', ...
        datestr(now,'mm_dd_yyyy_HH_MM_SS'), '.mat'...
        )...
        ...
        );
    save(pathBackupStatesRefFile, 'fieldShapesRef');
    
    % Update fieldShapesRef
    fieldShapesRef{idxField} = newFieldShape;
    % Save the results into the history file.
    save(pathFieldShapesRefFile, 'fieldShapesRef');
end
% EOF