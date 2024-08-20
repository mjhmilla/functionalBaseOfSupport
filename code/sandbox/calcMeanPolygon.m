%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

function meanPolygon = calcMeanPolygon(listOfPolygons)
%%
%
%
% @param listOfPolygons
%   A structure that contains:
%       xy: n x 2 array of xy coordinates
%        s: vector of the arclength of the polygon
%       sN: vector of the arclength of the polygon normalized to 0-1
%
%   For the function calcMeanPolygon to function the points xy must have
%   a specific ordering:
%
%   1. The point that corresponds to an arc length of zero must all be 
%      consistent
%   2. The points should all be labelled in order, and all going in a
%      consistent clock-wise, or counter-clockwise direction
%%

sNSet = [];

for i=1:1:length(listOfPolygons)
    sNSet = [sNSet;listOfPolygons(i).sN];
end

sNSet = unique(sNSet,"rows");
sNSet = sort(sNSet);

meanPolygon = struct( 'xy',zeros(size(sNSet,1),2),...
                       's',zeros(size(sNSet,1),1),...
                      'sN',zeros(size(sNSet,1),1) );
for i=1:1:size(sNSet)
    for j=1:1:length(listOfPolygons)
        for k=1:1:2
            val = interp1(listOfPolygons(j).sN,...
                          listOfPolygons(j).xy(:,k),...
                          sNSet(i,1)); 
            meanPolygon.xy(i,k) = meanPolygon.xy(i,k)+val; 
        end
    end
    meanPolygon.xy(i,:) = meanPolygon.xy(i,:)./length(listOfPolygons);
end

meanPolygon.s = calcPolygonArcLength(meanPolygon.xy);
meanPolygon.sN = meanPolygon.s ./ meanPolygon.s(end,1); 