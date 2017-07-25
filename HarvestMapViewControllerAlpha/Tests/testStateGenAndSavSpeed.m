tic

% States initialization.
states= cell(1,length(files));

for indexStates = 1:1:length(files)
    states{indexStates} = zeros(length(files(indexStates).lat),1);
end

toc

tic

% Normal save.
save(FULLPATH_FILES_LOADED_STATES, 'states');

toc

tic

% Fast save.
savefast(FULLPATH_FILES_LOADED_STATES, 'states');

toc

% Results:
% Elapsed time is 0.044082 seconds.
% Elapsed time is 0.253992 seconds.
% Elapsed time is 0.303625 seconds.

% normal save is better even when we change the order.

