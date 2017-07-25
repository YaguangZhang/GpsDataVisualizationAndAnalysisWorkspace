tic

save('/Users/Zyglabs/Desktop/testFilesSaveAndLoadSpeed', ...
            'files', 'fileIndicesCombines', 'fileIndicesTrucks', ...
            'fileIndicesGrainKarts', ...
            'fileIndicesSortedByStartRecordingGpsTime', ...
            'fileIndicesSortedByEndRecordingGpsTime');
        
toc

tic 

load('/Users/Zyglabs/Desktop/testFilesSaveAndLoadSpeed');

toc

pause;

tic

savefast('/Users/Zyglabs/Desktop/testFilesSaveAndLoadSpeed', ...
            'files', 'fileIndicesCombines', 'fileIndicesTrucks', ...
            'fileIndicesGrainKarts', ...
            'fileIndicesSortedByStartRecordingGpsTime', ...
            'fileIndicesSortedByEndRecordingGpsTime');
        
toc
     
tic 

load('/Users/Zyglabs/Desktop/testFilesSaveAndLoadSpeed');

toc

% Use normal save please...
% Fastsave generates file with HUGE size... And not fast at all for this
% case.
