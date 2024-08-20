%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

function figH = plotMarkerPositions( ...
                    figH,c3dMarkers, ...
                    plotColor,seriesLabel,seriesLocationNormCoord,...
                    subPlotPosition)


figure(figH);

markerNames = fields(c3dMarkers);

if(isempty(subPlotPosition)==0)
    subplot('Position',subPlotPosition);
end


for indexMarker=1:1:length(markerNames)
    plot3(c3dMarkers.(markerNames{indexMarker})(1,1),... 
         c3dMarkers.(markerNames{indexMarker})(1,2),...
         c3dMarkers.(markerNames{indexMarker})(1,3),...
         'o','MarkerFaceColor',plotColor);
    hold on;

    markerLabel = markerNames{indexMarker};
    idx = strfind(markerLabel,'_');
    markerLabel(1,idx)=' ';

%     if(indexMarker > 1 && strcmp(markerLabel(1,1),lastMarkerName(1,1)))
%         plot3([c3dMarkers.(markerNames{indexMarker})(1,1),lastMarker(1,1)],...
%               [c3dMarkers.(markerNames{indexMarker})(1,2),lastMarker(1,2)],...
%               [c3dMarkers.(markerNames{indexMarker})(1,3),lastMarker(1,3)],...
%               'Color',[1,1,1].*0.5);
%         hold on;
%     end



    text(c3dMarkers.(markerNames{indexMarker})(1,1),... 
         c3dMarkers.(markerNames{indexMarker})(1,2),...
         c3dMarkers.(markerNames{indexMarker})(1,3),...
         markerLabel,...
         'HorizontalAlignment','left',...
         'VerticalAlignment','bottom');
    hold on;  

    lastMarker = c3dMarkers.(markerNames{indexMarker})(1,:);
    lastMarkerName = markerLabel;
end

text('Units','normalized','Position',seriesLocationNormCoord,... 
     'String',seriesLabel,...
     'FontSize',12,'Color',plotColor);

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

box off;

axis equal;