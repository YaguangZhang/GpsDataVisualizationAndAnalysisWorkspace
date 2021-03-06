%LOADJVKDEVINDSAMPLEDENSITIES
% This script loads device independent sample densities generated by
% naiveTrain.m for the data set indicated by variable "fileFolderSet". It
% is mainly used for testing.
%
% Yaguang Zhang, Purdue, 03/08/2015

% The folder where the sample density results are saved.
pathDevIndSampleDensitiesFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', '20150522_Only for the test trip', 'naiveTrain');
pathDevIndSampleDensitiesFile = fullfile(...
    pathDevIndSampleDensitiesFilefolder, ...
    strcat('DevIndSampleDensities_SQUARE_SIDE_LENGTH_',num2str(SQUARE_SIDE_LENGTH),'.mat')...
    );

% Try loading corresponding history record first.
if exist(pathDevIndSampleDensitiesFile,'file')
    load(pathDevIndSampleDensitiesFile);
else
    error('Failed in loading devIndSampleDensities');
end

% EOF