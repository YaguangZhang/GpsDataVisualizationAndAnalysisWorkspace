hWbTemp = webmap;

pause;
for i = 1:10
hLineTemp = wmline(webmap,[0,-1,1],[0,2,2],'Width', 10, 'Color', 'Yellow','FeatureName', ' ');
wmremove(hLineTemp);
end

pause;

wmclose;