%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

function figH = plotFunctionalBos(figH,bosTransformed,plotColor,lineType,...
                                  subPlotPosition)

figure(figH);

if(isempty(subPlotPosition)==0)
    subplot('Position',subPlotPosition);
end

plot3(bosTransformed(:,1),bosTransformed(:,2),bosTransformed(:,3),...
      lineType,'Color',plotColor);
hold on;