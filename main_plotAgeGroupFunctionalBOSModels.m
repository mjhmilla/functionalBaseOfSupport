%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

clc;
close all;
clear all;

fbosFolder ='normBosModelsYoungMidageOlderAdults';

lineSpecs.footwear=[1,0,0; ...
                    0.66,0,0;
                    0.33,0,0];
lineSpecs.barefoot=[0,0,1;... 
                    0,0,0.66;...
                    0,0,0.33];
lineSpecs.twofeet='-';
lineSpecs.onefoot='--';

%%
% Set up directories
%%
mainDir = pwd;
codeDir = fullfile(mainDir,'code');
dataDir = fullfile(mainDir,'data');
outputDir= fullfile(mainDir,'output');


addpath('code');

%%
% Plot configuration
%%

numberOfPlots = 1;

numberOfVerticalPlotRows = 1;    
numberOfHorizontalPlotColumns = 1.;

plotWidth           = 5;
plotHeight          = 2.82*plotWidth; %2.82 is approx footlength/footwidth

plotHorizMarginCm   = 3;
plotVertMarginCm    = 3;

[subPlotPanel,pageWidth,pageHeight]  = ...
    plotConfigGeneric(numberOfHorizontalPlotColumns, ...
                      numberOfVerticalPlotRows,...
                      plotWidth,...
                      plotHeight,...
                      plotHorizMarginCm,...
                      plotVertMarginCm);

%%
% Fetch the list of files
%%
fbosDataDir = fullfile(dataDir,fbosFolder);

fbosDataDirFileList = dir(fbosDataDir);
fbosFiles = [];

for idxFile=1:1:length(fbosDataDirFileList)
    if(contains(fbosDataDirFileList(idxFile).name,'.csv'))
        fbosFiles = [fbosFiles,{fbosDataDirFileList(idxFile).name}];
    end
end

figH =figure;


fbosModels(length(fbosFiles)) = struct('data',[],'n',0,...
    'ageGroup','','footwear','','stance','','markerSet','','study','');

%%
% Read the data in
%%
idx=1;
for idxFile=1:1:length(fbosFiles)
    if(contains(fbosFiles{idxFile},'.csv'))
        fname = fbosFiles{idxFile};
        fileWords = strsplit(fname(1,1:(end-4)),'_');
        fbosModels(idx).data = ...
            readmatrix(fullfile(fbosDataDir, fbosFiles{idxFile}));
        fbosModels(idx).n           = str2double(fileWords{2}(1,1:2));
        fbosModels(idx).ageGroup    = fileWords{2}(1,3:end);
        fbosModels(idx).footwear    = fileWords{3};
        fbosModels(idx).stance      = fileWords{4};
        fbosModels(idx).markerSet   = fileWords{5};
        fbosModels(idx).study       = fileWords{6};
        idx=idx+1;
    end
end

%%
% Plot the data
%%
idxYA = 0;
xTickList = [];
yTickList = [];
for idx=1:1:length(fbosModels)
    if(   contains(fbosModels(idx).footwear,'Footwear') ...
       && contains(fbosModels(idx).stance,'2Feet') ...
       && contains(fbosModels(idx).study,'Sloot2025') )

        lineColor = [];
        switch fbosModels(idx).ageGroup
            case 'YoungAdults'
                lineColor = [0,0,0];
            case 'MidageAdults'
                lineColor = [1,1,1].*0.75;                
            case 'OlderAdults'
                lineColor = [68,119,170]./255;
            otherwise
                assert(0,'Error: Unrecognized age group');
        end

        idxAdult = strfind(fbosModels(idx).ageGroup,'Adults');
        ageStr = fbosModels(idx).ageGroup(1,1:(idxAdult-1));
        displayName = [ageStr, '(n=',num2str(fbosModels(idx).n),')'];
        displayName = [displayName, '-',fbosModels(idx).study];

        subplot('Position',reshape(subPlotPanel(1,1,:),1,4));        
        plot(fbosModels(idx).data(:,1),...
             fbosModels(idx).data(:,2),'-',...
             'Color',lineColor,...
             'DisplayName',displayName,...
             'LineWidth',2);
        hold on;

        xTickList = [xTickList,min(fbosModels(idx).data(:,1)),...
                               max(fbosModels(idx).data(:,1))];
        yTickList = [yTickList,min(fbosModels(idx).data(:,2)),...
                               max(fbosModels(idx).data(:,2))];
        
    end

    xTickList = unique(round(sort(xTickList),2));
    yTickList = unique(round(sort(yTickList),2));

%     if(contains(fbosModels(idx).ageGroup,'YoungAdults'))
%         idxYAN = idxYA/3;
%         lineColor = [1,0,0].*idxYAN + [0,0,1].*(1-idxYAN);
%         displayName = [fbosModels(idx).footwear,' ',...
%             fbosModels(idx).stance,' (n=',num2str(fbosModels(idx).n),')'];
%         displayName = [displayName, '-',fbosModels(idx).study];
% 
%         subplot('Position',reshape(subPlotPanel(1,2,:),1,4));        
%         plot(fbosModels(idx).data(:,1),...
%              fbosModels(idx).data(:,2),'-',...
%              'Color',lineColor,...
%              'DisplayName',displayName,...
%              'LineWidth',2);
%         hold on;
% 
%         idxYA=idxYA+1;
%     end
    
end

subplot('Position',reshape(subPlotPanel(1,1,:),1,4));        
    box off;
    legend('Location','northwest');
    legend box off;
    axis tight;
    xyLim = axis;

    xMid    = 0.5*(xyLim(1,1)+xyLim(1,2)); 
    xHWidth = 0.5*(xyLim(1,2)-xyLim(1,1));
    xExt = [(xMid-xHWidth*1.1),(xMid+xHWidth*1.1)];

    yMid    = 0.5*(xyLim(1,3)+xyLim(1,4)); 
    yHWidth = 0.5*(xyLim(1,4)-xyLim(1,3));
    yExt = [(yMid-yHWidth),(yMid+yHWidth*1.2)];

    xlim(xExt);
    ylim(yExt);

    xticks(xTickList);
    xtickangle(90);
    yticks(yTickList);
    
    xlabel('Norm. X (x/foot-width)');
    ylabel('Norm. Y (y/foot-length)');
    title({'A. Comparison of 2-foot shod fBOS profiles of',...
        'younger, middle-aged, and older adults'});

% subplot('Position',reshape(subPlotPanel(1,2,:),1,4));        
%     box off;
%     legend;
%     legend box off;
%     xlim([-0.26,0.15]);
%     ylim([-0.55,0.25]);
%     xlabel('Norm. X (x/foot-width)');
%     ylabel('Norm. Y (y/foot-length)');
%     title({'B. Comparison of Young fBOS profiles when',...
%         'barefoot/shod, and 1-foot/2-feet'});


figH=plotExportConfig(figH,pageWidth,pageHeight);

fileName =  fullfile( outputDir,'fig_fbos_YoungerMiddleAgedOlderAdults.pdf');
print('-dpdf', fileName);    
