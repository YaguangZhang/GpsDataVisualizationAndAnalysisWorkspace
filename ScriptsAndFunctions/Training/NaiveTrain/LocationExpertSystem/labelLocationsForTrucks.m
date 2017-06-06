%LABELLOCATIONSFORCOMBINES Carry out the infield classificaiton test for
%combines.
%
% This script encapsulates the algorithm developed in
% testInFieldClassificaiton.m. It will classify the GPS points in the
% combine routes into "in the field" or "on the road".
%
% Yaguang Zhang, Purdue, 03/19/2015

type = 'Truck';

for indexFile = 1:1:length(files)
    % During this loop, we will mark sample points of trucks only.
    if strcmp(files(indexFile).type, type)
        % This vehicle hasn't been marked yet.
        if isempty(locations{indexFile})
            % Load data.
            lengthLat = length(files(indexFile).lat);
            lengthSpeed = length(files(indexFile).speed);
            
            % Label the corresponding locations as on the road (-100).
            % Discard the last sample if it's not complete.
            locations{indexFile} = -100*ones(min(lengthLat,lengthSpeed),1);
        end
    end
end

% EOF