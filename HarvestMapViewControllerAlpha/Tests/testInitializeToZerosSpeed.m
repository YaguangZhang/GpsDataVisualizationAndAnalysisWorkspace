tic
for iii = 1:1:100
    aaa = zeros(length(filesToShow), 1);
end
toc

tic
for iii = 1:1:100
    bbb = aaa;
end
toc

% Result: the second method is much faster.
