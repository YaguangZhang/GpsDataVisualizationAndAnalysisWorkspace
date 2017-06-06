% LABELLOCATIONSFORGRAINKARTSANDTRUCKSUSINGCOMBINEFIELDBOUNDS Mark infield
% samples according to the field boundaries gotten from combines.
%
% Yaguang Zhang, Purdue, 07/10/2015

% Now the field shapes should be available. And we will use them to label
% all other kinds of vehicles except combines.
typeExcept = 'Combine';

% For hint display. Count the number of other vehicles that have been
% processed and the total number of other vehicels that need to be
% processed.
counterExceptCombine = 0;
totalNumCombines = length(fileIndicesGrainKarts) ...
    + length(fileIndicesTrucks);

for indexFile = 1:1:length(files)
    % During this loop, we will mark sample points of all vehicles which
    % are not combines.
    if ~strcmp(files(indexFile).type, typeExcept)    
        counterExceptCombine = counterExceptCombine + 1;
        if isempty(locations{indexFile})
            % This vehicle hasn't been marked yet.
            disp(strcat(num2str(counterExceptCombine),'/',...
                num2str(totalNumCombines), 23, 23, ...
            '(Counter for other vehicles / Total Number of other vehicles)'));
        
            % Load data.
            lengthLat = length(files(indexFile).lat);
            lengthSpeed = length(files(indexFile).speed);
            
            % Label the corresponding locations as in the field according
            % to the field shapes.
            
            % First all on the road.
            location = -100*ones(min(lengthLat,lengthSpeed),1);
            % Then in the field test.
            for idxFieldShape = 1:length(fieldShapes)
                % Mark all points in the field shapes as in the field.
                location(inShape(fieldShapes{idxFieldShape}, ...
                    files(indexFile).lon,files(indexFile).lat)) = 0;
            end
            
            % Finally record the result.
            locations{indexFile} = location;
        end
    end
end

% EOF