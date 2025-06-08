%%
% SPDX-FileCopyrightText: 2025 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

%%
%
% This function generates a figure using two hypothetical 
%
%
%%

clc;
close all;
clear all;

addpath('code');

mainDir = pwd;
dataDir = fullfile(mainDir,'data');
codeDir = fullfile(mainDir,'code');
outputDir= fullfile(mainDir,'output');




%%
% Load the example polygons
%   These polygons are from trials 8 and 9 which you can see by running
%   main_bosModelConstructionExample.m. These fbos polygons are normalized
%   and the points are ordered to begin at the most negative point in the 
%   y direction (the heel) and proceed counter-clockwise until the final
%   point is reached just to the left of the starting point.
%%

fbosMetaData = readCsvConvertToStruct( ...
                    fullfile(dataDir,'exampleNormalizedFbos',...
                    'participant01_metadata.csv'));

fbosA = load(fullfile(dataDir,'exampleNormalizedFbos',...
        'participant01_fbosNormExample_trial_08_left.csv'));

fbosB = load(fullfile(dataDir,'exampleNormalizedFbos',...
        'participant01_fbosNormExample_trial_09_left.csv'));

fbosAvg = calcArcLengthAverage(fbosA,fbosB);


%%
% Plot configuration
%%

numberOfPlots = 1;

numberOfVerticalPlotRows = 1;    
numberOfHorizontalPlotColumns = 1.;

plotWidth           = 5;
plotHeight          = plotWidth*(fbosMetaData.footLength/fbosMetaData.footWidth);

plotHorizMarginCm   = 5;
plotVertMarginCm    = 5;

[subPlotPanel,pageWidth,pageHeight]  = ...
    plotConfigGeneric(numberOfHorizontalPlotColumns, ...
                      numberOfVerticalPlotRows,...
                      plotWidth,...
                      plotHeight,...
                      plotHorizMarginCm,...
                      plotVertMarginCm);

%
% Calculate a bunch of additional data to illustrate the inner workkings
% of the calcArcLengthAverage method
%

% Calculate the normalized cumulative arc-length vector of each polygon
sA = zeros(length(fbosA),1);
sB = zeros(length(fbosB),1);

for i=2:1:length(fbosA)
    xy1 = fbosA(i,:);
    xy0 = fbosA(i-1,:);    
    sA(i,1) = sA(i-1,1) + sqrt(sum((xy1-xy0).^2));
end

sA = sA ./ sA(end,1);

for i=2:1:length(fbosB)
    xy1 = fbosB(i,:);
    xy0 = fbosB(i-1,:);    
    sB(i,1) = sB(i-1,1) + sqrt(sum((xy1-xy0).^2));
end
sB = sB ./ sB(end,1);


s = unique(sort([sA;sB]));



plotColors = zeros(3,3);
plotColors(1,:) = [0,0,0];
plotColors(2,:) = [0,119,187]./255;
plotColors(3,:) = [51,187,238]./255;

figH=figure;
    subplot('Position',reshape(subPlotPanel(1,1,:),1,4));

    fill(fbosAvg(:,1),fbosAvg(:,2),[1,1,1].*0.85,...
         'EdgeColor','none', 'DisplayName','Avg. of A \& B');
    hold on;



  

    %Plot the line segments between A and B where an average is taken
    for i=1:1:length(s)
        xy = zeros(2,2);
        for j=1:1:2
            xy(1,j) = interp1(sA,fbosA(:,j),s(i));
            xy(2,j) = interp1(sB,fbosB(:,j),s(i));            
        end
        plot(xy(:,1),xy(:,2),'-','Color',plotColors(1,:),...
            'LineWidth',0.25,'HandleVisibility','off');
        hold on;
    end

    xy0 = [0,0.35];
    mOff = 0.05;


    for i=1:1:length(sA)

        xy = fbosA(i,:);

        hAlign = 'right';
        vAlign = 'bottom';

        if(i <= 4)
            vAlign = 'top';
        elseif(i > 4 && i <= 11)
            vAlign='bottom';
        else
            vAlign='top';
        end

        if(i < 13)
            hAlign='left';
        else
            hAlign='right';
        end


        text(xy(1,1),xy(1,2),['$$','A_{',num2str(i),'}$$'],...
             'Color',plotColors(2,:),'FontSize',6,...
             'HorizontalAlignment',hAlign,...
             'VerticalAlignment',vAlign);
        hold on;
    end

    for i=1:1:length(sB)

        xy = fbosB(i,:);
        hAlign = 'left';
        vAlign = 'bottom';

        if(i < 5)
            vAlign = 'bottom';
        elseif(i >= 5 && i <= 12)
            vAlign='top';
        else
            vAlign='bottom';
        end

        if(i < 13)
            hAlign='right';
        else
            hAlign='left';
        end        


        text(xy(1,1),xy(1,2),['$$','B_{',num2str(i),'}$$'],...
             'Color',plotColors(3,:),'FontSize',6,...
             'HorizontalAlignment',hAlign,...
             'VerticalAlignment',vAlign);
        hold on;
    end
    

    plot(fbosA(:,1),fbosA(:,2),'-','Color',plotColors(2,:),...
         'LineWidth',1,'DisplayName','A');
    hold on;

    plot(fbosA(:,1),fbosA(:,2),'o','Color',plotColors(2,:),...
         'MarkerFaceColor',[1,1,1],'MarkerSize',4,....
         'HandleVisibility','off');

    plot(fbosB(:,1),fbosB(:,2),'-','Color',plotColors(3,:),...
         'LineWidth',1,'DisplayName','B');
    hold on;

    plot(fbosB(:,1),fbosB(:,2),'o','Color',plotColors(3,:),...
        'MarkerFaceColor',[1,1,1],'MarkerSize',3,...
        'HandleVisibility','off');
    

        
    plot(fbosAvg(:,1),fbosAvg(:,2),'.',...
         'Color',plotColors(1,:),...
         'LineWidth',1,...
         'HandleVisibility','off');


    plot(fbosA(1,1),fbosA(1,2),'s','Color',[1,1,1],...
         'MarkerFaceColor',plotColors(2,:),...
         'MarkerSize',6,....
         'HandleVisibility','off');

    plot(fbosB(1,1),fbosB(1,2),'s','Color',[1,1,1],...
        'MarkerFaceColor',plotColors(3,:),...
        'MarkerSize',6,...
        'HandleVisibility','off');    

    plot(fbosAvg(1,1),fbosAvg(1,2),'s',...
         'Color',[1,1,1],...
         'MarkerFaceColor',plotColors(1,:),...
         'MarkerSize',6,...
         'LineWidth',1,...
         'HandleVisibility','off');

    xylim = axis();

    dx = (xylim(1,4)-xylim(1,3))/15;    
    dy = (xylim(1,4)-xylim(1,3))/50;

    xA = xylim(1,2);
    yA = xylim(1,4);

    xTxt=xA+dx;
    yTxt=yA;
    text(xTxt,yTxt,'$$\underbar{s}_A$$','HorizontalAlignment','left');
    yTxt=yTxt-dy;
    for i=1:1:length(fbosA)
        yTxt=yTxt-dy;
        text(xTxt,yTxt,sprintf('%1.2f',sA(i,1)),...
            'HorizontalAlignment','left',...
            'FontSize',6);     
        hold on;
    end

    xTxt=xA+2*dx;
    yTxt=yA;
    text(xTxt,yTxt,'$$\underbar{s}_B$$','HorizontalAlignment','left');
    yTxt=yTxt-dy;
    for i=1:1:length(fbosB)
        yTxt=yTxt-dy;
        text(xTxt,yTxt,sprintf('%1.2f',sB(i,1)),...
            'HorizontalAlignment','left',...
            'FontSize',6); 
        hold on;
    end

    xTxt=xA+3*dx;
    yTxt=yA;
    text(xTxt,yTxt,'$$\underbar{s}$$','HorizontalAlignment','left');
    yTxt=yTxt-dy;
    for i=1:1:length(fbosAvg)
        yTxt=yTxt-dy;
        text(xTxt,yTxt,sprintf('%1.2f',s(i,1)),...
            'HorizontalAlignment','left',...
            'FontSize',6); 
        hold on;
    end    

    hold on;  

    axis tight;
    axis padded;

    box off;

    legend('Location','northoutside');
    legend boxoff;


    xlabel('Norm. X ($$x/$$W)');
    ylabel('Norm. Y ($$y/$$L)');
    title({'Arc-length indexed average',' of fBOS polygons A \& B'});

    hold on;


%%
% 
%%
figH=plotExportConfig(figH,pageWidth,pageHeight);

fileName =  fullfile( outputDir,'fig_fbos_arcLengthAverage.pdf');
print('-dpdf', fileName);    
