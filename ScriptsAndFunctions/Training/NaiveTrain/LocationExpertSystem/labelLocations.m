%LABELLOCATIONS Label locaitons for all vehicles using naive infield
%classification.
%
% About the values for location: -100 (on road for sure) to 0 (in-field for
% sure).
%
% Update 04/10/2015: Use field boundaries from combines to classify trucks
% and grain carts Yaguang Zhang, Purdue, 04/02/2015

% For combines, use the infield expert system.
disp(' ');
disp('naiveTrain: Labeling combines...');
tic;
% By default, this script will only label combines if type is not
% specified.
clear type;
labelLocationsForCombines; 
toc;
disp('naiveTrain: Done!');

% For grain carts and trucks, label infield points according to the field
% boundaries gotten from combines.
disp(' ');
disp('naiveTrain: Labeling grain carts and trucks using our field boundaries...');
tic;
labelLocationsForGrainKartsAndTrucksUsingCombineFieldBounds;
toc;
disp('naiveTrain: Done!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Old version backup just in case things don't work well.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(' ');
% disp('naiveTrain: Labeling trucks...');
% tic;
% 
% % In this case the accuracy is around 0.5. 
% %
% % For trucks, all sample points will be labeled as "on the road".
% labelLocationsForTrucks;
% 
% % % Also try using the infield expert system. Now the accuracy is even
% % % lower, at around 0.454.
% % type = 'Truck';
% % labelLocationsForCombines;
% 
% toc;
% disp('naiveTrain: Done!');
% 
% % For combines, use the infield expert system.
% disp(' ');
% disp('naiveTrain: Labeling combines...');
% tic;
% % By default, this script will only label combines if type is not
% % specified.
% clear type;
% labelLocationsForCombines; 
% toc;
% disp('naiveTrain: Done!');
% 
% % For grain carts, not implemented yet. For now, we will use the same algorithm
% % for combines.
% disp(' ');
% disp('naiveTrain: Labeling grain carts...');
% disp('            For now, we will treat them as combines...');
% tic;
% type = 'Grain Kart';
% labelLocationsForCombines;
% toc;
% disp('naiveTrain: Done!');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% EOF