%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

clc;
close all;
clear all;

startPointExtrema = [0;-1];

flag_typeOfTestCase = 0;
%0: offset diamonds

%These points must be ordered clockwise or counter-clockwise and have the
%same first and last point as is returned by convhull
diamond1 = [0,-1;  1, 0;  0, 1; -1, 0; 0,-1];
diamond2 = [1, 0;  0, 1; -1, 0;  0,-1; 1, 0].*1 + [0,0.5];
diamond3 = [0, 1; -1, 0;  0,-1;  1, 0; 0, 1].*1 + [0.5,0];

listOfPolygons(2) = struct('xy',[],'s',[],'sN',[],'angle',[],'centroid',[]);

switch flag_typeOfTestCase
    case 0
        listOfPolygons(1).xy = diamond1;
        listOfPolygons(2).xy = diamond2;
        listOfPolygons(3).xy = diamond3;
    case 1
        assert(0,'Error: flag_typeOfTestCase set to a value that does not exist');
end

for i=1:1:length(listOfPolygons)

    %Order the points in the polygon so that they all start at a point
    %that is the furthest away in a specific direction
    nPts    = size(listOfPolygons(i).xy,1);
    xyDist  = zeros(size(listOfPolygons(i).xy,1),1);

    for j=1:1:size(listOfPolygons(i).xy,1)
        xyDist(j,1) = listOfPolygons(i).xy(j,:)*startPointExtrema;
    end

    [maxDist,indexStart] = max(xyDist);
    
    indexSorted = [indexStart:1:(indexStart+nPts-1)]';
    indexSorted = mod(indexSorted,nPts);

    %This will strip off the last point, which is repeated in the polygon
    %that is returned by convhull
    indexSorted = indexSorted( indexSorted ~= 0);

    listOfPolygons(i).xy = [listOfPolygons(i).xy(indexSorted,:);...
                            listOfPolygons(i).xy(indexSorted(1,1),:)];

    listOfPolygons(i).s  = calcPolygonArcLength(listOfPolygons(i).xy);
    listOfPolygons(i).sN = listOfPolygons(i).s./listOfPolygons(i).s(end,1);
end

meanPolygon = calcMeanPolygon(listOfPolygons);

fig = figure;
lineColorA = [  1, 0, 0];
lineColorB = [0.1, 0, 0];

for i=1:1:length(listOfPolygons)
    n = (i-1)./(length(listOfPolygons)-1);
    lineColor = lineColorA.*n + lineColorB.*(1-n);

    plot(listOfPolygons(i).xy(:,1),listOfPolygons(i).xy(:,2),...
         'Color',lineColor);    
    hold on;
    plot(listOfPolygons(i).xy(:,1),listOfPolygons(i).xy(:,2),...
         'o','Color',lineColor,...
         'MarkerFaceColor',lineColor,...
         'MarkerSize',5);    
    hold on;
end

meanColor = [0,0,1];
plot(meanPolygon.xy(:,1),meanPolygon.xy(:,2),'Color',meanColor);
hold on;
plot(meanPolygon.xy(:,1),meanPolygon.xy(:,2),...
     'o','Color',meanColor,...
     'MarkerFaceColor',[1,1,1],...
     'MarkerSize',5);    
hold on;
box off;
xlabel('X');
ylabel('Y');