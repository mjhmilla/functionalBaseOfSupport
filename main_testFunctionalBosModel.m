clc;
close all;
clear all;

%This only needs to be done once. If you have the 
%csv files normBosModelPigBare.csv and normBosModelPigShod.csv in the 
%data folder you do not need to do this.
flag_createPigBosFromIorBos=0;
modelType = 'Bare'; %'Bare' or 'Shod'

bosColorIor = [0,0,1];
bosColorPig = [1,0,1];

mainDir = pwd;
codeDir = fullfile(mainDir,'code');
dataDir = fullfile(mainDir,'data');

addpath('code');
%%
% Inputs
%%

%%
% Load the bos models and the marker data
%%

normBosModelIor=readmatrix(...
    fullfile(dataDir,'normBosModel',...
             sprintf('normBosModelIor%s.csv',modelType)));

if(flag_createPigBosFromIorBos==0)
    normBosModelPig=readmatrix(...
        fullfile(dataDir,'normBosModel',...
                 sprintf('normBosModelPig%s.csv',modelType)));
end




switch modelType
    case 'Bare'
        mkrPos = readCsvConvertToStruct(...
                    fullfile(dataDir,'staticMarkerData',...
                        'footMarkersIorPig_Bare.csv'));
    case 'Shod'
        mkrPos = readCsvConvertToStruct(...
                    fullfile(dataDir,'staticMarkerData',...
                      'footMarkersIorPig_Shod.csv'));
        
    otherwise
        assert(0,'Error: modelType must be either Bare or Shod');
end


%%
% Plot configuration
%%
maxPlotRows          = 1;
maxPlotCols          = 1;
plotWidthCm          = 29.7; 
plotHeightCm         = 21;
plotHorizMarginCm    = 1.5;
plotVertMarginCm     = 1.5;

[subPlotPanel, ...
 pageWidthCm, ...
 pageHeightCm]= ...
      plotConfigGeneric(  maxPlotCols,...
                          maxPlotRows,...
                          plotWidthCm,...
                          plotHeightCm,...
                          plotHorizMarginCm,...
                          plotVertMarginCm);


%%
% Plot the markers
%%

figFoot     =figure;

plotColor                       = [1,0,0];
seriesLabel                     ='Barefoot';
seriesLabelPositionNormCoord    = [1,1,1].*0.9;
subPlotPosition                 =reshape(subPlotPanel(1,1,:),1,4);
figFoot=plotMarkerPositions(figFoot,mkrPos,plotColor,...
            seriesLabel,seriesLabelPositionNormCoord,...
            subPlotPosition);


%%
% Plot the IOR foot frames
%%
rowIndex=1; 

[frameLeftOffsetIor, frameRightOffsetIor]=...
        getIorFootOffsetFrames(rowIndex, mkrPos);

[frameLeftIor, frameRightIor]= getIorFootFrames(...
                            rowIndex, ...
                            mkrPos, ...
                            frameLeftOffsetIor, ...
                            frameRightOffsetIor);

plotAxisScale=0.1;
figFoot = plotFrame(figFoot,frameLeftIor,plotAxisScale,...
                    '--',subPlotPosition);
figFoot = plotFrame(figFoot,frameRightIor,plotAxisScale,...
                    '--',subPlotPosition);


[footLengthIor, midFootLengthIor, footWidthIor] =...
    getIorFootSize(rowIndex, frameLeftIor, frameRightIor, mkrPos);

bosScaledLeftIor = normBosModelIor;
bosScaledLeftIor(:,1)=bosScaledLeftIor(:,1).*footWidthIor;
bosScaledLeftIor(:,2)=bosScaledLeftIor(:,2).*footLengthIor;

bosScaledRightIor = [bosScaledLeftIor(:,1).*-1, bosScaledLeftIor(:,2)];



bosTransformedLeftIor = transformBosModel(bosScaledLeftIor,frameLeftIor);
bosTransformedRightIor= transformBosModel(bosScaledRightIor,frameRightIor);

figFoot = plotFunctionalBos(figFoot,bosTransformedLeftIor,...
                                bosColorIor,'--',subPlotPosition);
figFoot = plotFunctionalBos(figFoot,bosTransformedRightIor,...
                                bosColorIor,'--',subPlotPosition);


%%
% Plot the PIG foot frames
%%

%[frameLeftOffset, frameRightOffset]=...
%        getIorFootOffsetFrames(rowIndex, mkrPos, mkrNames);



mkrPosPig = struct('RTOE',[],'RHEE',[],'RANK',[],...
                   'LTOE',[],'LHEE',[],'LANK',[]);

frameLeftOffsetPig  = struct('r',zeros(3,1),'E',eye(3,3)); 
frameRightOffsetPig = struct('r',zeros(3,1),'E',eye(3,3));

mkrPosPig.RTOE = mkrPos.R_FM2_top;
mkrPosPig.RHEE = mkrPos.R_FCC;
mkrPosPig.RANK = mkrPos.R_FAL;

mkrPosPig.LTOE = mkrPos.L_FM2_top;
mkrPosPig.LHEE = mkrPos.L_FCC;
mkrPosPig.LANK = mkrPos.L_FAL;


[frameLeftOffsetPig, frameRightOffsetPig]=...
        getPigFootOffsetFrames(rowIndex, mkrPosPig);

[frameLeftPig, frameRightPig]= getPigFootFrames(...
                            rowIndex, ...
                            mkrPosPig, ...
                            frameLeftOffsetPig, ...
                            frameRightOffsetPig);


figFoot = plotFrame(figFoot,frameLeftPig,plotAxisScale,...
                    '-',subPlotPosition);
figFoot = plotFrame(figFoot,frameRightPig,plotAxisScale,...
                    '-',subPlotPosition);

%%
% Create the Pig BOS from the IOR data
%%

if(flag_createPigBosFromIorBos==1)
    % Project the correctly scaled and placed IOR bos into the PIG frame
    bosModelPigLeft = zeros(size(bosTransformedLeftIor,1),2);
    bosModelPigRight = zeros(size(bosTransformedLeftIor,1),2);
    
    for i=1:1:size(bosTransformedLeftIor,1)
        r010 = bosTransformedLeftIor(i,:)';
        rP1P = frameLeftPig.E'*(r010-frameLeftPig.r);
        bosModelPigLeft(i,:) = [rP1P(1,1),rP1P(2,1)];
        
        assert(abs(rP1P(3,1))<1e-6,...
            ['Error: Something went wrong rP1P is a point on the bos',...
             'in the foot frame: the z component should be 0 but is not']);

        r010 = bosTransformedRightIor(i,:)';
        rP1P = frameRightPig.E'*(r010-frameRightPig.r);
        bosModelPigRight(i,:) = [rP1P(1,1),rP1P(2,1)];

        assert(abs(rP1P(3,1))<1e-6,...
            ['Error: Something went wrong rP1P is a point on the bos',...
             'in the foot frame: the z component should be 0 but is not']);        
        
    end
    footLengthPig =(norm(mkrPosPig.('RTOE')-mkrPosPig.('RHEE')) ...
                  + norm(mkrPosPig.('LTOE')-mkrPosPig.('LHEE'))).*0.5;

    bosModelPigRightMappedLeft = bosModelPigRight;
    bosModelPigRightMappedLeft(:,1)=bosModelPigRightMappedLeft(:,1).*-1;

    bosModelPig = 0.5.*(bosModelPigLeft+bosModelPigRightMappedLeft);

    normBosModelPig = bosModelPig./footLengthPig;

    cd('data');
    writematrix(normBosModelPig,...
        fullfile(dataDir,sprintf('normBosModelPig%s.csv',modelType)));
    cd 
end


footLengthPig =(norm(mkrPosPig.('RTOE')-mkrPosPig.('RHEE')) ...
              + norm(mkrPosPig.('LTOE')-mkrPosPig.('LHEE'))).*0.5;


bosScaledLeftPig = normBosModelPig.*footLengthPig;

bosScaledRightPig = normBosModelPig.*footLengthPig;
bosScaledRightPig(:,1)=bosScaledRightPig(:,1).*-1;


bosTransformedLeftPig = transformBosModel(bosScaledLeftPig,frameLeftPig);
bosTransformedRightPig= transformBosModel(bosScaledRightPig,frameRightPig);

figFoot = plotFunctionalBos(figFoot,bosTransformedLeftPig,...
                                bosColorPig,'-',subPlotPosition);
figFoot = plotFunctionalBos(figFoot,bosTransformedRightPig,...
                                bosColorPig,'-',subPlotPosition);



here=1;




