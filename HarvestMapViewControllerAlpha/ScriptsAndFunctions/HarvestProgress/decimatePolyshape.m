function [polyshpDecimated] = decimatePolyshape(polyshp, ...
    decimationFactor, minNumOfPtsToDecPolyshape)
%DECIMATEPOLYSHAPE Decimate the number of points in the polygon based on
%the specified decimation factor.
%
% We will decimate the boundaries with minNumOfPtsToDecPolyshape or more
% points one by one.
%
% Yaguang Zhang, Purdue, 11/23/2020
fractionToRetain = 1/decimationFactor;
numOfBs = numboundaries(polyshp);
if numOfBs>=1
    newBs = cell(numOfBs, 1);
    for idxB = 1:numOfBs
        [curBXs, curBYs] = boundary(polyshp, idxB);
        if length(curBXs)>=minNumOfPtsToDecPolyshape
            newBs{idxB} = DecimatePoly([curBXs, curBYs], ...
                [fractionToRetain, 2], false);
        else
            newBs{idxB} = [curBXs, curBYs];
        end
    end
    polyshpDecimated = polyshape(newBs{1});
    for idxB = 2:numOfBs
        polyshpDecimated = addboundary(polyshpDecimated, newBs{idxB});
    end
else
    polyshpDecimated = polyshape();
end
end
% EOF