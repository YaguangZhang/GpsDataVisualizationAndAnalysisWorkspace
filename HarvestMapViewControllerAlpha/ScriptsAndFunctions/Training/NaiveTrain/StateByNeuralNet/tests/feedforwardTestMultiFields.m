%FEEDFORWARDTESTMULTIFIELDS Use a customized feedforward neural network to
%classify the vehicle states.
%
% We will use the data generated by extractTrainingSetForMultiFields.m.
%
% Yaguang Zhang, Purdue, 07/26/2017

PATH_PAR_DIR = fileparts(which(mfilename));
cd(PATH_PAR_DIR);
% Get the dataset.
extractTrainingSetForMultiFields;

% Randomize the start index for the dataset.
[~, maxSampleIndex] = size(inputs);
startIndex = randi([1,maxSampleIndex]);
inputs = [inputs(:,startIndex:end), inputs(:,1:startIndex)];
targets = [targets(:,startIndex:end), targets(:,1:startIndex)];

% % Adjustable parameters. hiddenSizes = 100;

disp('Press any key to continue...');
pause;

%% Test: All
% Haven't found a way to use the nnstart tool to do classification with a
% lot of classes.
cd(fullfile(PATH_PAR_DIR, 'MatlabGeneratedNNsDivideBlock'));

%% Test: C1 Harvesting
targetsC1H = [targets(1,:); ~targets(1,:)];

C1H;
disp('Press any key to continue...');
pause;

%% Test: C2 Harvesting
targetsC2H = [targets(5,:); ~targets(5,:)];

C2H;
disp('Press any key to continue...');
pause;

%% Test: C1 Unloading
targetsC1U = [targets(2:4,:); ~sum(targets(2:4,:))];

C1U;
disp('Press any key to continue...');
pause;

%% Test: C2 Unloading
targetsC2U = [targets(6:8,:); ~sum(targets(6:8,:))];

C2U;
disp('Press any key to continue...');
pause;

%% Test: K Unloading
targetsKU = [targets(9:10,:); ~sum(targets(9:10,:))];

KU;
disp('Press any key to continue...');
pause;

% EOF