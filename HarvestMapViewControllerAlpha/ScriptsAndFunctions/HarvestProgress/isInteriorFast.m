function [boolsIn] = isInteriorFast(ployin, xs, ys)
%ISINTERIORFAST A (hopefully) faster implementation of isinterior when the
%number of points to check is large. 
%
% We will also limit the number of points to feed into isinterior to avoid
% "out of memory" errors.
%
% Yaguang Zhang, Purdue, 11/02/2020

MAX_NUM_OF_PTS_TO_FEED_INTO_ISINTERIOR = 10000;

numOfInputPts = length(xs);
boolsIn = nan(numOfInputPts, 1);

% Prune input points by a boundary box.
minX = min(ployin.Vertices(:,1));
maxX = max(ployin.Vertices(:,1));
minY = min(ployin.Vertices(:,2));
maxY = max(ployin.Vertices(:,2));

boolsOutOfBoundBox = (xs<minX)|(xs>maxX)|(ys<minY)|(ys>maxY);
boolsIn(boolsOutOfBoundBox) = false;

if ~all(boolsOutOfBoundBox)
    indicesInBoundBox = find(~boolsOutOfBoundBox);
    numOfPtsToCheck = length(indicesInBoundBox);
    numOfPtsChecked = 0;
    while numOfPtsChecked<numOfPtsToCheck
        numOfPtsToCheckRem = numOfPtsToCheck-numOfPtsChecked;
        if numOfPtsToCheckRem>=MAX_NUM_OF_PTS_TO_FEED_INTO_ISINTERIOR
            curNumOfPtsToCheck = MAX_NUM_OF_PTS_TO_FEED_INTO_ISINTERIOR;
        else
            curNumOfPtsToCheck = numOfPtsToCheckRem;
        end
        
        boolsMask = false(numOfInputPts,1);
        boolsMask(indicesInBoundBox((numOfPtsChecked+1) ...
            :(numOfPtsChecked+curNumOfPtsToCheck))) = true;
        if sum(boolsMask)>0
            boolsIn(boolsMask) = isinterior(ployin, ...
                xs(boolsMask), ys(boolsMask));
        end
        
        numOfPtsChecked = numOfPtsChecked + curNumOfPtsToCheck;
    end
end

% Convert results to logical.
boolsIn = logical(boolsIn);
end
% EOF