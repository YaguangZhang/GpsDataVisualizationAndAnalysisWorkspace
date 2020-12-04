function [l] = cm32l(cm3)
% Convert volume from cubic centimeters to liters. 
% Chad Greene 2012
% 
% In August 2014, Maximilian Tsocherchner caught a typo in this function.  
% It previously reada as follows: 
% 
% l = cm3*001;
% 
% This means that conversions were off by a factor of 1000.  Sorry about
% that.  Thanks for bringing this to my attention, Maximilian.  

l = cm3*.001;