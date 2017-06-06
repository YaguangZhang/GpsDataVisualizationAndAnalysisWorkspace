function [ covRange ] ...
    = genClockwiseHeadingCovRange( curHeading, nextHeading )
%GENCLOCKWISEHEADINGCOVRANGE Generate clockwise heading coverage range. All
%variables should be true north east from (0, 360].
%
% Inputs:
%   - covRange
%     Essentially, this is a 2x1 vector with scalars curHeading and
%     nextHeading, the current heading and the next heading in time.
% Outputs:
%   - headingCovStart, headingCovEnd
%     Scalars. The start heading and the end heading of the coverage angle
%     range. Note that we always assume the range is from headingCovStart
%     to headingCovEnd clockwise.
%
% Yaguang Zhang, Purdue, 05/23/2017

[ headingCovStart, headingCovEnd ] = deal(nan);

curHeadingOpp = oppositeHeading(curHeading);
if headingCoveredByClockwiseRange(nextHeading, curHeading, curHeadingOpp)
    headingCovStart = curHeading;
    headingCovEnd = nextHeading;
elseif headingCoveredByClockwiseRange(nextHeading, curHeadingOpp, curHeading)
    headingCovStart = nextHeading;
    headingCovEnd = curHeading;
else
    warning('Unable to generate the clockwise heading coverage range!')
end

covRange = [headingCovStart; headingCovEnd];
% EOF