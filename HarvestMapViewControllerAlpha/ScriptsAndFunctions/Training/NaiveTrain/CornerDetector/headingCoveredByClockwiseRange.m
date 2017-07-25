function [ isCovered ] ...
    = headingCoveredByClockwiseRange(heading, headingCovStart, headingCovEnd)
%HEADINGCOVEREDBYRANGE Test whether the input heading is covered by the anlge range headingCovStart to headingCovEnd (all in true north east from (0,360] in degree).
%
% Inputs:
%   - heading
%     A scalar. The input heading to be tested.
%   - headingCovStart, headingCovEnd
%     A scalar. The start heading and the end heading of the coverage angle range. Note that we always assume the range is from headingCovStart to headingCovEnd clockwise.
% Output:
%   - isCovered
%     The boolean for whether the heading is covered.
%
% Yaguang Zhang, Purdue, 05/22/2017

if (headingCovEnd>=headingCovStart)
    isCovered = (heading<=headingCovEnd) && (heading>=headingCovStart);
else % headingCovEnd<=headingCovStart
    isCovered = ((heading>=headingCovStart) && (heading<=360)) ...
        || ((heading>0) && (heading<=headingCovEnd));
end
% EOF