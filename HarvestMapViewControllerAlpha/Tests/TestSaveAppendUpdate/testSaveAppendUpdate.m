a = 1;
b = 2;

save('temp.mat','a','b');
clear;
load temp.mat;

pause;

load temp.mat
pause


c = 3;
save('temp.mat','c','-append');
clear;
load temp.mat;

pause;
c = 4;
save('temp.mat','c','-append');
clear;
load temp.mat;

pause;
a = 100;
save('temp.mat','a','-append');
clear;
load temp.mat;
pause;