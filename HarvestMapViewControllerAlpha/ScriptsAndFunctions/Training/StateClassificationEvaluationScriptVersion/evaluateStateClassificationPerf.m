%EVALUATESTATEDCLASSIFICATIONPERF Evaluates the state classification
%performance.
%
% This script will compute the error rates for the state classification
% algorithms we developed. 
%
% Please run naiveTrain (to get classifcation
% results, e.g. statesByDist) and collectorForStates (to get manually
% labeled results as targets, e.g. statesRef) for the data set of interest
% before running this performance evaluation script.
%
% Note: tested using Matlab R2015a.
%
% Yaguang Zhang, Purdue, 12/06/2016

%% Predefined Parameters

% Changed folder to "ScriptsAndFunctions" first.
cd(fileparts(mfilename('fullpath')));
cd(fullfile('..', '..'));
% Set path.
setMatlabPath;
addpath(fullfile(fileparts(which(mfilename)),'Scripts'));

% The data set of insterest.

% fileFolderSet = fullfile('..', '..', '..',  'Harvest_Ballet_2015');
fileFolderSet = fullfile('..', '..', '..',  'Harvest_Ballet_2015_ManuallyLabeled');

% filesLoadedHistory.mat
FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
FULLPATH_FILES_LOADED_HISTORY = fullfile(...
    FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
    'filesLoadedHistory.mat'...
    );

% filesLoadedStatesByDist.mat
pathStatesByDistFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathStatesByDistFile = fullfile(...
    pathStatesByDistFilefolder, ...
    strcat('filesLoadedStatesByDist','.mat')...
    );

% filesLoadedStatesByDist.mat
pathStateClassificationFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathStateClassificationFile = fullfile(...
    pathStateClassificationFilefolder, ...
    strcat('filesLoadedStates_ref','.mat')...
    );

%% Load the Data

if ~exist('files', 'var')
    load(FULLPATH_FILES_LOADED_HISTORY);
end

if ~exist('statesByDist', 'var')
    load(pathStatesByDistFile);
end

if ~exist('statesRef', 'var')
    load(pathStateClassificationFile);
end

%% Evaluation

handles = evalStates(statesByDist, statesRef, files);

% EOF