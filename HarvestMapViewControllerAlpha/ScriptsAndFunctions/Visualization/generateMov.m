%GENERATEMOV
% Callback function for the "Generate movie now" button in the animation
% figure.
%
% Yaguang Zhang, Purdue, 01/28/2015

% Save the animation as an AVI file.
animationFilename = strcat(fileName,'.avi');

% % Get rid of wrong frames.
% originalSize = size(F(1).cdata);
% for frameInd = 2:length(F)
%     if size(F(frameInd).cdata) ~= originalSize
%         F(frameInd) = [];
%     end
% end

movie2avi(F, animationFilename,'quality', 100, ...
    'compression', COMPRESSION, ...
    'fps',FRAMES_PER_SECOND);

disp('          Movie generated.');

% EOF