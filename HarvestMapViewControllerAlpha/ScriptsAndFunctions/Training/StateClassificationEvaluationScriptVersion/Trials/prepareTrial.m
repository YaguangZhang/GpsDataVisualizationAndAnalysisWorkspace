% PREPARETRIAL Load the dataset and set Matlab path for the trials.
%
% Yaguang Zhang, Purdue, 05/15/2017

% Changed folder to "ScriptsAndFunctions" first.
cd(fileparts(mfilename('fullpath')));
cd(fullfile('..', '..', '..'));

% Load data.
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
% EOF