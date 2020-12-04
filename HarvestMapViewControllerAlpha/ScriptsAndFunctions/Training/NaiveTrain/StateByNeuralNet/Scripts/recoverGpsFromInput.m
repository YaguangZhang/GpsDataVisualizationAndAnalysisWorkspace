function [ gpsInfo ] = recoverGpsFromInput( inputs )
%RECOVERGPSFROMINPUT Recovers the GPS information from inputs extracted for
%the alpha version of neural network.
%
% This function can be very handy for debugging.
%
% Yaguang Zhang, Purdue, 07/23/2018

NUM_PAST_SAMPS = 30;
NUM_FUTURE_SAMPS = 30;

NUM_VEHS = 5;

gpsInfo = struct('lat', {}, 'lon', {}, 'speed', {});

for idxVeh = 1:NUM_VEHS
    % We have lat, lon and speed.
    numSampsPerCluster = NUM_PAST_SAMPS+1+NUM_FUTURE_SAMPS;
    columnOffSet = (idxVeh-1).*numSampsPerCluster.*3;
    
    % First cluster of past samples.
    lat = inputs((1:NUM_PAST_SAMPS)+columnOffSet,1);
    lon = inputs((1:NUM_PAST_SAMPS)+columnOffSet+numSampsPerCluster,1);
    speed = inputs((1:NUM_PAST_SAMPS) ...
        +columnOffSet+numSampsPerCluster.*2,1);
    
    % Append all "current" samples to the results.
    lat = [lat; inputs(NUM_PAST_SAMPS+1+columnOffSet,:)'];
    lon = [lon; ...
        inputs(NUM_PAST_SAMPS+1+columnOffSet+numSampsPerCluster,:)'];
    speed = [speed; ...
        inputs(NUM_PAST_SAMPS+1+columnOffSet+numSampsPerCluster.*2,:)'];
    
    % Get rid of invalid GPS samples.
    boolsInvalid = (lat==0 | lon==0);
    lat(boolsInvalid) = nan;
    lon(boolsInvalid) = nan;
    speed(boolsInvalid) = nan;
    
    % Save results for current vehicle.
    gpsInfo(end+1) = struct('lat', lat, 'lon', lon, 'speed', speed);
end

end
% EOF