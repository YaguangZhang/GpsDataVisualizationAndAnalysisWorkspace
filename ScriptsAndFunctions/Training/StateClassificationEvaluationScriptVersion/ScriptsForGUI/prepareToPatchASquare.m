%PREPARETOPATCHASQUARE Generate f and v according to yTop, yBottom,
%timeStart and timeEnd.
%
% Yaguang Zhang, Purdue, 05/19/2016

v = [timeStart yBottom; ...
    timeStart yTop; ...
    timeEnd yTop; ...
    timeEnd yBottom];
f = [1, 2, 3, 4];

% EOF