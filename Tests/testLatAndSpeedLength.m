% By this test, file gps_2014_07_20_14_33_12.txt in Everything_Else/p and e
% 6130 is incomplete. One speed sample is missing. And only this file is
% so.

for i = 1:length(files)
if length(files(i).lat)~=length(files(i).speed)
disp(i);
end
end