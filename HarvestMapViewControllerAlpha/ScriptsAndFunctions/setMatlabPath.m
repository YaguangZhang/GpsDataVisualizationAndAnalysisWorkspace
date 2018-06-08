%SETMATLABPATH
% This script will add all the paths needed for the program
% mapViewController to run successfully.
%
% When run this script, please make sure Matlab has changed folder to
% "ScriptsAndFunctions".
%
% Update: added the state classification evaluation folder, 11/16/2015
%
% Yaguang Zhang, Purdue, 02/23/2015

% Setup path.
addpath(fullfile(pwd, '..'));
addpath(genpath(fullfile(pwd, '..', '..', 'ExternalFunctions')));
addpath(fullfile(pwd, '..', '..', 'PlotsAndMovies', 'Scripts'));

% Instead, manually list all the script filefolders to avoid adding
% automatically generated plots. addpath(genpath(fullfile(pwd, '..', '..',
% ...
%     'MapViewControllerAlpha', 'ScriptsAndFunctions')));

% ScriptsAndFunctions
addpath(fullfile(pwd));
% ScriptsAndFunctions/Visualization
addpath(fullfile(pwd, 'Visualization'));
% ScriptsAndFunctions/Training
addpath(fullfile(pwd, 'Training'));
addpath(fullfile(pwd, 'Training', 'NaiveTrain'));
addpath(fullfile(pwd, 'Training', 'NaiveTrain', 'LocationExpertSystem'));
addpath(fullfile(pwd, 'Training', 'NaiveTrain', 'StateByDistExpertSystem'));
addpath(fullfile(pwd, 'Training', 'NaiveTrain', 'StateByDistExpertSystem', 'generateAnimations'));
% For manual labeling and performance evaluation.
addpath(fullfile(pwd, 'Training', 'InFieldClassificationEvaluationScriptVersion'));
addpath(fullfile(pwd, 'Training', 'StateClassificationEvaluationScriptVersion'));
addpath(fullfile(pwd, 'Training', 'FieldShapeExtractionEvaluationScriptVersion'));
% For neural networks.
addpath(fullfile(pwd, 'Training', 'NaiveTrain', 'StateByNeuralNet', 'Scripts'));
% For field shape generateion.
addpath(fullfile(pwd, 'Training', 'NaiveTrain', 'FieldShapeExtraction'));
% For vehicle heading estimator.
addpath(fullfile(pwd, 'Training', 'NaiveTrain', 'VehicleHeadingEstimator'));
% For statistical harvesting.
addpath(fullfile(pwd, 'Training', 'NaiveTrain', 'StatisticalHarvesting'));
% For corner detection.
addpath(fullfile(pwd, 'Training', 'NaiveTrain', 'CornerDetector'));
% For product traceability.
addpath(fullfile(pwd, 'Training', 'NaiveTrain', 'ProductTraceability'));

% ScriptsAndFunctions/DataProcessing
addpath(fullfile(pwd, 'DataProcessing'));

% EOF