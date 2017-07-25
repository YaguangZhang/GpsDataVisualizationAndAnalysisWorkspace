%INITIALIZETRAININGSTATES
% Initial training for the data collected. This routine slso includes
% creating the saving and backup files for the training results.
%
% We use labels -1, 1 and 0 to represent "unloading", "loading" and
% "everthing else".
%
% Yaguang Zhang, Purdue, 02/05/2015

% States initialization.
states= cell(1,length(files));

for indexStates = 1:1:length(files)
    states{indexStates} = zeros(length(files(indexStates).lat),1);
end

% Initialize the flags indicating the human "teaching" process. We use 1 to
% indicate that time point has been evalucated by us and 0 to indicated
% "not set by us". So after this initialization, these flags will indicate
% that no human setting has been done.
flagStatesManuallySet = states;

% First of all, run this method to hopefully reduce the training workload
% which involves actual humans. One can replace it with better method.
naiveTrain;

save(FULLPATH_FILES_LOADED_STATES, 'states','flagStatesManuallySet');

% No backup file is generated for this since no human work is yet involved.

% EOF