% INLINEPROFORINLINEPROWITHVALIDITYCHECK
%
% This script checks whether the sequence represented by the variable
% "indicesExtendedRoadSequence" is valid (i.e. not likely to be in a field)
% for inlineProForInlinePro by Rule 5 using device independent sample
% density defined in testOnRoadClassification.m. If the sequence passes
% this validity check, it will be labeled as "on the road" and the script
% inlineProForInlinePro will be carried out for it.
%
% Variable used for the validity check: indicesExtendedRoadSequence,
% location and dens.
%
% Yaguang Zhang, Purdue, 03/08/2015

% The sequence should be far away from already determined on-the-road
% points. Here we only label this sequence if it doesn't overlap with any
% other points on the road.
if isempty(intersect(...
        indicesExtendedRoadSequence, ...
        find(location~=0)...
        ))
    if min(dens(indicesExtendedRoadSequence)) >= ...
            mean(dens(location == -100)) ...
        || ...
        max(dens(indicesExtendedRoadSequence)) <= ...
            mean(dens(location == -100))
        % The varialbe devIndSampleDensity is usually higher if the sample
        % point is in the field. So in this case the sequence is probably
        % closer to the field set, and thus more likely to be in the field.
        
        % Clear the squence.
        indicesExtendedRoadSequence = [];
    end
    
    location(indicesExtendedRoadSequence) = -50;
    
    % Inline propagation for inline propagation.
    inlineProForInlinePro;
end

% EOF