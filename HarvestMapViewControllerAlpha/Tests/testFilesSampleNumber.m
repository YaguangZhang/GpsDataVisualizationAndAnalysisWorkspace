y = -ones(length(files),1);
for i=1:1:length(files)
    y(i) = length(files(i).lat);
end
figure;bar(1:length(files), y);