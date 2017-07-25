% INLINEPROFLOWDENSUBSEQCONFIRMONROAD Confirm the inline propagation low
% density subsequence to be on the raod.
%
% Yaguang Zhang, Purdue, 04/04/2015

% Check whether the sequence is roughly along the meridians/parallels. We
% will compare the ranges of latitude and longtude for the sequence.
indicesPossibleRoadSeq = [indicesLowDenSubSeq; ...
    indicesBackwardInlineSubSeq; ...
    indicesForwardInlineSubSeq];

rangLati = max(lati(indicesPossibleRoadSeq)) ...
    - min(lati(indicesPossibleRoadSeq));
rangeLong = max(long(indicesPossibleRoadSeq)) ...
    - min(long(indicesPossibleRoadSeq));

if rangLati/rangeLong > 10 || rangeLong/rangLati > 10
    % The sequence is in a really narrow area. We will treat it as valid
    % road.
    location(location==-60.5) = -60;
    location([indicesBackwardInlineSubSeq;indicesForwardInlineSubSeq]) = -55;
else
    % This sequence fails the test. Change the -60.5 labels in this
    % sequence back to 0.
    location(location==-60.5) = 0;
end

% EOF