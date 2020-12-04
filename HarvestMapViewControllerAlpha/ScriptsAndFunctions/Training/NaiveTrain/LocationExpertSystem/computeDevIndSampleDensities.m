% COMPUTEDEVINDSAMPLEDENSITIES Computes the device independent sample
% densities for all routes.
%
% This script encapsulates the algorithm developed in
% testInFieldClassificaiton.m. It will classify the GPS points in the
% combine routes into "in the field" or "on the road".
%
% Yaguang Zhang, Purdue, 03/19/2015

% The estimated radius of earth in meter.
radius=6371000;

% Estimate the required differences of latitude and longitude in degree for
% SQUARE_SIDE_LENGTH according to the Haversine formula.
deltaLatiHalf = SQUARE_SIDE_LENGTH/radius*90/pi; % Sample independent.

% Used to store the results.
devIndSampleDensities = cell(length(files),1);

% All combine samples.
latC = vertcat(files(fileIndicesCombines).lat);
lonC = vertcat(files(fileIndicesCombines).lon);

disp(['                Start at ', datestr(now, 'yyyy/mm/dd HH:MM:ss')]);
for indexFile = 1:length(files)
    
    % Display the process by file index and total file number.
    disp(['                ',datestr(now, 'yyyy/mm/dd HH:MM:ss'), ...
        ' File ', num2str(indexFile),'/',num2str(length(files)),'.']);
    
    % Load data.
    lati = files(indexFile).lat;
    long = files(indexFile).lon;
    time = files(indexFile).gpsTime;
    spee = files(indexFile).speed;
    
    % Compute device sample rate in kHz.
    deviceSampleRateInKHz = (length(time)-1)/(time(end)-time(1));
    % Then we can compute the denominator part for computer the sample
    % density.
    denominatorForSampleDensity = ...
        deviceSampleRateInKHz*(SQUARE_SIDE_LENGTH^2);
    
    % For each sample, compute and record how many Combine sample points
    % are in its square area.
    numSamplesInSquare = -ones(length(lati),1);
    % Device independent sample density to be computed.
    devIndSampleDensity = numSamplesInSquare;
    
    for indexSample = 1:length(devIndSampleDensity)
        
        % Delta longitude is depending on the latitude of the sample.
        % Vecotorization is not OK since Matlab will give us zeros because
        % the vaule is really small.
        deltaLongHalf = abs(asind(sin(SQUARE_SIDE_LENGTH/2/radius)/cos(lati(indexSample))));
        
        % Compute the coordinates of the square sides.
        currentSquareSouthSideLati = lati(indexSample)-deltaLatiHalf;
        currentSquareNorthSideLati = lati(indexSample)+deltaLatiHalf;
        currentSquareWestSideLong = long(indexSample)-deltaLongHalf;
        currentSquareEastSideLong = long(indexSample)+deltaLongHalf;
        
        % Find the number of samples of the same route which are in the
        % square.
        numSamplesInSquare(indexSample) = sum(...
            latC<=currentSquareNorthSideLati ...
            & latC>=currentSquareSouthSideLati ...
            & lonC<=currentSquareEastSideLong ...
            & lonC>=currentSquareWestSideLong);
    end
    
    % Compute the device independent sample density.
    devIndSampleDensity = numSamplesInSquare./denominatorForSampleDensity;
    devIndSampleDensities{indexFile} = devIndSampleDensity;
    
end
disp(['                Finish at ', datestr(now, 'yyyy/mm/dd HH:MM:ss')]);
% EOF