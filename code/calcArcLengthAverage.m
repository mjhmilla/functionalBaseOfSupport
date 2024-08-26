%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

function xyAvg = calcArcLengthAverage(xyA, xyB)


%Order the points to begin from the heel and proceed counter clockwise
%This only works if the input the (prior) output of a call to convhull
[yHeelA,idxHeelA] = min(xyA(:,2));
idxA1 = [idxHeelA:1:size(xyA,1)]';
idxA2 = [1:(idxHeelA-1)]';
idxA = [idxA1;idxA2];

xyAUpd = xyA(idxA,:);

%Get the normalized cumulative arc length
sA = calcPolygonArcLength(xyAUpd);
[sA,idxAU] = unique(sA);
xyAUpd=xyAUpd(idxAU,:);
sA = sA./sA(end);

%Order the points to begin from the heel and proceed counter clockwise
[yHeelB,idxHeelB] = min(xyB(:,2));
idxB1 = [idxHeelB:1:size(xyB,1)]';
idxB2 = [1:(idxHeelB-1)]';
idxB = [idxB1;idxB2];

%Get the normalized cumulative arc length
xyBUpd = xyB(idxB,:);
sB = calcPolygonArcLength(xyBUpd);
[sB,idxBU]=unique(sB);
xyBUpd=xyBUpd(idxBU,:);

sB = sB./sB(end);


%Form the locations s 
s = unique(sort([sA;sB]));

xyAvg = zeros(length(s),2);

%Take the average
for i=1:1:length(s)
    for j=1:1:2
        cA = interp1(sA,xyAUpd(:,j),s(i),'linear');
        cB = interp1(sB,xyBUpd(:,j),s(i),'linear');
        xyAvg(i,j)= 0.5*(cA+cB);
    end
end


flag_debug=0;
if(flag_debug==1)
    dxBig=0.0;
    numberOfHorizontalPlotColumns = 3;
    numberOfVerticalPlotRows = 1;
    plotWidth = 3.5;
    plotHeight = 11;
    plotHorizMarginCm = 1;
    plotVertMarginCm = 1;

    m2cm=100;

    [subPlotPanel,pageWidth,pageHeight]  = ...
        plotConfigGeneric(numberOfHorizontalPlotColumns, ...
                          numberOfVerticalPlotRows,...
                          plotWidth,...
                          plotHeight,...
                          plotHorizMarginCm,...
                          plotVertMarginCm);    

    figDebug=figure;
    subplot('Position',[reshape(subPlotPanel(1,1,:),1,4)]);

    plot(xyAUpd(:,1).*m2cm,xyAUpd(:,2).*m2cm,'-','Color',[1,0.5,0.5],'LineWidth',1);
    hold on;
    plot(xyAUpd(:,1).*m2cm,xyAUpd(:,2).*m2cm,'o','Color',[0,0,0],'LineWidth',1,...
        'MarkerFaceColor',[0,0,0],'MarkerSize',2);
    hold on;
    for i=1:1:length(xyAUpd)
        hAlign ='left';
        if(sA(i)>0.5)
            hAlign='right';
        end

        text(xyAUpd(i,1).*m2cm,xyAUpd(i,2).*m2cm,...
            sprintf('%d. s=%1.2f',i,sA(i)),...
            'FontSize',6,'HorizontalAlignment',hAlign,'VerticalAlignment','bottom',...
            'Color',[0,0,0]);
        hold on;
    end

    xlabel('X (cm)');
    ylabel('Y (cm)') 
    title('A. fBOS \#1');
    xlim([-5.5,3.5]);    
    ylim([-3.5,16]);    
    %axis equal;
    grid off
    box off;

    subplot('Position',[reshape(subPlotPanel(1,2,:),1,4)]);
    plot(xyBUpd(:,1).*m2cm,xyBUpd(:,2).*m2cm,'-','Color',[0.5,0.5,1],'LineWidth',1);
    hold on;
    plot(xyBUpd(:,1).*m2cm,xyBUpd(:,2).*m2cm,'o','Color',[0,0,0],'LineWidth',1,...
        'MarkerFaceColor',[0,0,0],'MarkerSize',2);
    hold on;
    for i=1:1:length(xyBUpd)
        hAlign ='left';
        if(sB(i)>0.5)
            hAlign='right';
        end

        text(xyBUpd(i,1).*m2cm,xyBUpd(i,2).*m2cm,...
            sprintf('%d. s=%1.2f',i,sB(i)),...
            'FontSize',6,...
            'HorizontalAlignment',hAlign,'VerticalAlignment','bottom',...
            'Color',[0,0,0]);
        hold on;
    end

    xlabel('X (cm)');
    ylabel('Y (cm)') ;
    xlim([-5.5,3.5]);
    ylim([-3.5,16]);    
    %axis equal;
    title('B. fBOS \#2');
    
    grid off
    box off;
    
    subplot('Position',[reshape(subPlotPanel(1,3,:),1,4)]);
    plot(xyAvg(:,1).*m2cm,xyAvg(:,2).*m2cm,'-','Color',[1,1,1].*0.5,'LineWidth',1);
    hold on;
    plot(xyAvg(:,1).*m2cm,xyAvg(:,2).*m2cm,'o','Color',[0,0,0],'LineWidth',1,...
        'MarkerFaceColor',[0,0,0],'MarkerSize',2);
    hold on;
    for i=1:1:length(xyAvg)
        hAlign ='left';
        if(s(i)>0.5)
            hAlign='right';
        end        
        text(xyAvg(i,1).*m2cm,xyAvg(i,2).*m2cm,...
            sprintf('%d. s=%1.2f',i,s(i)),...
            'FontSize',6,...
            'HorizontalAlignment',hAlign,'VerticalAlignment','bottom',...
            'Color',[0,0,0]);
        hold on;
    end

    xlabel('X (cm)');
    ylabel('Y (cm)')
    xlim([-5.5,3.5]);
    ylim([-3.5,16]);
    %axis equal;
    
    grid off
    box off;
    title('C. The average of fBOS \#1 \& \#2');

    here=1;
    
    figDebug=plotExportConfig(figDebug,pageWidth,pageHeight);
    filePath = 'fig_fBosAverage.pdf';
    print('-dpdf', filePath);     


end
