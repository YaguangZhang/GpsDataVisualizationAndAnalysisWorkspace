%PLOTGPSTIMEVERLINES Plot / update the vertical lines for GPS times set.
%and 
%
% Yaguang Zhang, Purdue, 05/20/2016

% Plot the line for GpsTimeStart and GpsTimeEnd.
vline2('clear');
axis tight;
validateTimes;
vline2(timeStart,'b--','Start');
vline2(timeEnd,'r-.','End');

% EOF