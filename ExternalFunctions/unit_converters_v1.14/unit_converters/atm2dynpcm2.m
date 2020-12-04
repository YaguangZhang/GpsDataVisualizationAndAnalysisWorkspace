function [dynpcm2] = atm2dynpcm2(atm)
% Convert pressure from atmospheres to dynes per square centimeter.
% 
% Chad A. Greene
dynpcm2 = atm*1.01325e+6;