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
numberOfHorizontalPlotColumns = 3.;

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

ageKeywords = [{'YoungAdults'},{'MidageAdults'},{'OlderAdults'}];

ageTitleKeywords = ...  
    [{'Younger Adults'},{'Middle-aged Adults'},{'Older Adults'}];

shodKeywords = [{'Footwear'},{'Barefoot'}];

testKeywords = [{'2Feet'},{'1Foot'}];

mkrKeywords  = [{'Ior'},{'Pig'}];

for idxFile=1:1:length(fbosFiles)
    
    %Extract meta data from the name
    ageId = 0;
    n = 0;
    for i=1:1:length(ageKeywords)
        if(contains(fbosFiles{idxFile},ageKeywords{i}))
            ageId=i;
            
            j = min(strfind(fbosFiles{idxFile},'_'))+1;
            k = strfind(fbosFiles{idxFile},ageKeywords{i})-1;
            tmpStr=fbosFiles{idxFile};
            n = str2double(tmpStr(j:k));
            break;
        end
    end
    shodId = 0;
    for i=1:1:length(shodKeywords)
        if(contains(fbosFiles{idxFile},shodKeywords{i}))
            shodId=i;
            break;
        end
    end
    testId = 0;
    for i=1:1:length(testKeywords)
        if(contains(fbosFiles{idxFile},testKeywords{i}))
            testId=i;
            break;
        end
    end
    mkrId = 0;
    for i=1:1:length(mkrKeywords)
        if(contains(fbosFiles{idxFile},mkrKeywords{i}))
            mkrId=i;
            break;
        end
    end
    
    %Since there are multiple barefoot and shod trials, figure out if this
    %which repeat this is
    iter=0;
    repNumber=0;
    for i=1:1:length(fbosFiles)
        ageFlag = contains(fbosFiles{i},ageKeywords{ageId});
        shodFlag = contains(fbosFiles{i},shodKeywords{shodId});
        testFlag = contains(fbosFiles{i},testKeywords{testId});
        mkrFlag = contains(fbosFiles{i},mkrKeywords{mkrId});
        
        if(ageFlag && shodFlag && testFlag && mkrFlag)
            iter=iter+1;
            if(i==idxFile)
                if(iter >3)
                    here=1;
                end
                repNumber=iter;
            end
        end
    end

    lineColor =[0,0,0];
    shodStr = '';
    switch shodId
        case 1
            lineColor = lineSpecs.footwear(repNumber,:);
            shodStr = 'Shod';
        case 2
            lineColor = lineSpecs.barefoot(repNumber,:);            
            shodStr = 'Bare';
        otherwise assert(0,'Error: unrecognized footware keyword');
    end

    testStr='';
    lineType = '';
    switch testId
        case 1
            lineType = lineSpecs.twofeet;
            testStr = '2 feet';
        case 2
            lineType = lineSpecs.onefoot;            
            testStr = '1 feet';            
        otherwise assert(0,'Error: unrecognized test type');
    end

    normBosModel=readmatrix(fullfile(fbosDataDir, fbosFiles{idxFile}));
    
    figure(figH);
    subplot('Position',reshape(subPlotPanel(1,ageId,:),1,4));
    plot(normBosModel(:,1),normBosModel(:,2),lineType,'Color',lineColor,...
         'DisplayName',[shodStr,' ',testStr,'(',num2str(n),')']);
    hold on;


end

for idx=1:1:3
    figure(figH);
    subplot('Position',reshape(subPlotPanel(1,idx,:),1,4));
    xlabel('Norm. X (m/m)');
    ylabel('Norm. Y (m/m)');
    legend('Location','northeast');
    legend box off;
    xlim([-0.26,0.15]);
    ylim([-0.55,0.25]);
    box off;
    title({'Normalized fBOS Profiles: ',ageTitleKeywords{idx}});
end

figH=plotExportConfig(figH,pageWidth,pageHeight);

fileName =  fullfile( outputDir,'fig_fbos_YoungerMiddleAgedOlderAdults.pdf');
print('-dpdf', fileName);    
