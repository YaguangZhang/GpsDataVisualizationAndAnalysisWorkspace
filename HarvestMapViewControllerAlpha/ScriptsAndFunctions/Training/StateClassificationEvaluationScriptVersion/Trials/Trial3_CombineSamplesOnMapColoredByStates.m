% TRIAL3_COMBINESAMPLESONMAPCOLOREDBYSTATES Trial 3 - Plot the combine
% samples on a map and color / mark them according to what the combine is
% doing (e.g. stopped, harvesting, corner, and running).
%
% Yaguang Zhang, Purdue, 05/17/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));

numOfCombineFilesToPlot = 1;
indicesToPlot = 1:numOfCombineFilesToPlot;
% Plot the combine samples and color them according to the vehicle
% activity.
hFig = figure('PaperPositionMode', 'auto'); hold on;
for idxFileC = fileIndicesCombines(indicesToPlot)'
    plot(files(idxFileC).lon, files(idxFileC).lat, '.b');
    
    boolsHarvesting = statesRef{idxFileC}(:,1)==0;
    plot(files(idxFileC).lon(boolsHarvesting), ...
        files(idxFileC).lat(boolsHarvesting), '.y')
    
    boolsStopped = files(idxFileC).speed==0;
    plot(files(idxFileC).lon(boolsStopped), ...
        files(idxFileC).lat(boolsStopped), '.r')
end

hold off; plot_google_map('MapType', 'satellite');
title('Combine Samples Colored by States');
figFileName = ['Trial3_Results_first_', ...
    num2str(numOfCombineFilesToPlot), '_combine_files'];
legend('Track', 'Harvesting', 'Stopped')
saveas(hFig, [figFileName, '.png']);
saveas(hFig, [figFileName, '.fig']);
% EOF