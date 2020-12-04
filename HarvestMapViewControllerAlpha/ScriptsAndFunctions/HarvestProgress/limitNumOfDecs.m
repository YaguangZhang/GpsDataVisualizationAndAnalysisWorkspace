function [newNumbers] = limitNumOfDecs(numbers, ...
    numOfDigitsAfterDecPt)
%LIMITNUMOFDECS Round the input numbers to the desired precision.
%
% Yaguang Zhang, Purdue, 12/02/2020

factor = 10^numOfDigitsAfterDecPt;
newNumbers = round(numbers.*factor)./factor;

end
% EOF