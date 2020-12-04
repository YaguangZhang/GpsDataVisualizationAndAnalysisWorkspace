function [polyshpDecimated] = decimatePolyshapeByNumOfPts(polyshp, ...
    numOfPtsForDecPolyshape)
%DECIMATEPOLYSHAPEBYNUMOFPTS Decimate the number of points for each
%boundary in the polygon to the number specified.
%
% Yaguang Zhang, Purdue, 12/02/2020

% A variation of decimatePolyshape.m.
numOfBs = numboundaries(polyshp);
if numOfBs>=1
    newBs = cell(numOfBs, 1);
    for idxB = 1:numOfBs
        [curBXs, curBYs] = boundary(polyshp, idxB);
        curNumOfPt = length(curBXs);
        if curNumOfPt>numOfPtsForDecPolyshape
            % Estimate the decimation factor.
            decimationFactor = max(1, ...
                curNumOfPt/numOfPtsForDecPolyshape);
            fractionToRetain = 1/decimationFactor;
            
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