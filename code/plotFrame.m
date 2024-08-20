%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

function figH = plotFrame(figH,frame, axisScale,lineType,subPlotPosition)

figure(figH);

if(isempty(subPlotPosition)==0)
    subplot('Position',subPlotPosition);
end

axisLabels = {'X','Y','Z'};

for i=1:1:3

    v1 = frame.r + frame.E(:,i).*axisScale;
    axisColor = zeros(1,3);
    axisColor(1,i)=1;
    plot3([frame.r(1,1),v1(1,1)],...
          [frame.r(2,1),v1(2,1)],...
          [frame.r(3,1),v1(3,1)],...
          lineType,'Color',axisColor);
    hold on;
%     text(v1(1,1),v1(2,1),v1(3,1),axisLabels{1,i});
%     hold on;

end