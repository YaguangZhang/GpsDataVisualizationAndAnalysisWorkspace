%UPDATECURRENTSAMPEIND
% Update the current samples to show "currentSampleInd" according to
% currentGpsTime. It stores samples which we should group into the
% catogory of samples to be shown.
%
% Please make sure the varialbe "currentGpsTime" is up-to-date before
% calling this script.
%
% Yaguang Zhang, Purdue, 02/13/2015

currentSampleInd = zeros(length(filesToShow), 1);
for fileIndex = 1:1:length(filesToShow)
    tempSampleInd = find(filesToShow(fileIndex).gpsTime > currentGpsTime,1,'first');
    
    if isempty(tempSampleInd)
        tempSampleInd = length(filesToShow(fileIndex).gpsTime);
    end
    
    currentSampleInd(fileIndex) = tempSampleInd;
end