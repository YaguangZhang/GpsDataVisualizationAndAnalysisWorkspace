% TRIAL5_2_CHOOSEGOODFIELDS Trial 5.2 - Plot the specified field pairs /
% plot all fields on the map.
%
% Yaguang Zhang, Purdue, 05/25/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));
if(~exist('fields2014', 'var'))
    fields2014 = load(fullfile(...
        'C:\Users\Zyglabs\Google Drive\2014_Harvest\GpsDataVisualizationAndAnalysis\Harvest_Ballet_2015\_AUTOGEN_IMPORTANT', ...
        'enhancedFieldShapes.mat'));
end
if(~exist('fields2016', 'var'))
    fields2016 = load(fullfile(...
        'C:\Users\Zyglabs\Google Drive\2014_Harvest\GpsDataVisualizationAndAnalysis\Harvest_Ballet_2016\harvests_synchronized\_AUTOGEN_IMPORTANT', ...
        'enhancedFieldShapes.mat'));
end

%% Indices for the field pairs to show
indicesField2014 = []; % [1]
indicesField2016 = []; % [1]

for idxFieldPair = 1:length(indicesField2014)
    idxField2014 = indicesField2014(idxFieldPair);
    idxField2016 = indicesField2016(idxFieldPair);
    
    figure; hold on;
    plot(fields2014.enhancedFieldShapes{idxField2014}, ...
        'FaceColor','green','FaceAlpha',0.5, 'EdgeAlpha', 0);
    plot(fields2016.enhancedFieldShapes{idxField2016}, ...
        'FaceColor','blue','FaceAlpha',0.5, 'EdgeAlpha', 0);
    daspect auto; plot_google_map('MapType', 'satellite'); hold off;
    title(['2014 field #', num2str(idxField2014), ...
        ' (green) & 2016 field #', num2str(idxField2016), ' (blue)']);
end

%% Show all fields
figure; hold on;
for idxField2014 = 1:length(fields2014.enhancedFieldShapes)
    plot(fields2014.enhancedFieldShapes{idxField2014}, ...
        'FaceColor','red','FaceAlpha',0.5, 'EdgeAlpha', 0);
end
for idxField2016 = 1:length(fields2016.enhancedFieldShapes)
    plot(fields2016.enhancedFieldShapes{idxField2016}, ...
        'FaceColor','yellow','FaceAlpha',0.5, 'EdgeAlpha', 0);
end
daspect auto; plot_google_map('MapType', 'satellite'); hold off;
title(['2014 fields (red) & 2016 fields (yellow)']);
% EOF