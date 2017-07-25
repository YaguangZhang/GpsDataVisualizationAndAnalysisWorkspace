function [latSampled,lonSampled] = sampleCoordinates(filesToSample, SAMPLE_RATE_FOR_WEB_MAP)
%SAMPLECOORDINATES Get sampled coordinates from file structure.
%   SAMPLECOORDINATES samples the coordinates stored in the file structure
%   "filesToShow" by uniformly getting one pair of lat and lon from every
%   SAMPLE_RATE_FOR_WEB_MAP sample sets.
% Yaguang Zhang, Purdue, 02/12/2015

% In order to render the map faster, we separate the data computation and
% mark addition.
latSampled = cell(length(filesToSample),1);
lonSampled = latSampled;

% Data computing.
for indexRoute = 1:1:length(filesToSample)
    file = filesToSample(indexRoute);
    % Sampling.
    numSamples = floor(length(file.lat)/SAMPLE_RATE_FOR_WEB_MAP);
    [latSampled{indexRoute},lonSampled{indexRoute}] = reducem(...
        file.lat(1:SAMPLE_RATE_FOR_WEB_MAP:SAMPLE_RATE_FOR_WEB_MAP*numSamples),...
        file.lon(1:SAMPLE_RATE_FOR_WEB_MAP:SAMPLE_RATE_FOR_WEB_MAP*numSamples));
end

% EOF