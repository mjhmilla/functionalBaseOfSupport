clc;
close all;
clear all;

addpath('code');

%%
% M.Millard
% 4 April 2023
%
% 1. Prerequisites:
%   For this function to work you must have the following files:
%
%     data/normBosModelPigShod.csv
%     data/normBosModelPigBare.csv
%
%   If you do not have these files, you can generate them by running
%  
%     main_testFunctionalBosModel.m 
%
%   with the appropriate flags set.
%
% 2. Highlights
%  See the code block titled 'PIG Bos Example Code' for an example of how
%  to use the functions needed to scale and place the PIG BOS model to 
%  fit the marker data.
%
%%
modelType = 'Bare'; %'Bare' or 'Shod'

bosColorPig = [1,0,1];

mainDir = pwd;
codeDir = fullfile(mainDir,'code');
dataDir = fullfile(mainDir,'data');

%%
% PIG Bos Example Code
%%

%1. 
% Load the c3d data and put it into a standardized struct
load(fullfile(dataDir,'Data_PiG_IOR_Static.mat'));

%Put the c3d data into a standardized struct that contains the 
%conventional names for PiG foot markers
mkrPosPig = struct('RTOE',[],'RHEE',[],'RANK',[],...
                   'LTOE',[],'LHEE',[],'LANK',[]);

switch modelType
    case 'Bare'
        mkrPosPig.RTOE = Data_PiG_IOR.Sub(1).Bar_static.c3dMarkers.R_FM2_top;
        mkrPosPig.RHEE = Data_PiG_IOR.Sub(1).Bar_static.c3dMarkers.R_FCC;
        mkrPosPig.RANK = Data_PiG_IOR.Sub(1).Bar_static.c3dMarkers.R_FAL;
        
        mkrPosPig.LTOE = Data_PiG_IOR.Sub(1).Bar_static.c3dMarkers.L_FM2_top;
        mkrPosPig.LHEE = Data_PiG_IOR.Sub(1).Bar_static.c3dMarkers.L_FCC;
        mkrPosPig.LANK = Data_PiG_IOR.Sub(1).Bar_static.c3dMarkers.L_FAL;
    case 'Shod'
        mkrPosPig.RTOE = Data_PiG_IOR.Sub(1).Run_static.c3dMarkers.R_FM2_top;
        mkrPosPig.RHEE = Data_PiG_IOR.Sub(1).Run_static.c3dMarkers.R_FCC;
        mkrPosPig.RANK = Data_PiG_IOR.Sub(1).Run_static.c3dMarkers.R_FAL;
        
        mkrPosPig.LTOE = Data_PiG_IOR.Sub(1).Run_static.c3dMarkers.L_FM2_top;
        mkrPosPig.LHEE = Data_PiG_IOR.Sub(1).Run_static.c3dMarkers.L_FCC;
        mkrPosPig.LANK = Data_PiG_IOR.Sub(1).Run_static.c3dMarkers.L_FAL;
    otherwise
        assert(0,'Error: modelType must be either Bare or Shod');
end




%2. 
% Load the normalized Pig Bos model.
%       Note: this normalized foot is a normalized left foot
normBosModelPig=readmatrix(...
    fullfile(dataDir,sprintf('normBosModelPig%s.csv',modelType)));




%3.
%Create the vector and orientation frame offsets align the PIG foot
%frame with the sole of the foot for the data at rowIndex
rowIndex=1;
[frameLeftOffsetPig, frameRightOffsetPig]=...
        getPigFootOffsetFrames(rowIndex, mkrPosPig);

%4.
%Calculate the location of the foot print frame using the PIG marker set
[frameLeftPig, frameRightPig]= getPigFootFrames(...
                            rowIndex, ...
                            mkrPosPig, ...
                            frameLeftOffsetPig, ...
                            frameRightOffsetPig);

%5.
%Evaluate the length of the foot using the Pig marker set
footLengthPig =(norm(mkrPosPig.('RTOE')-mkrPosPig.('RHEE')) ...
              + norm(mkrPosPig.('LTOE')-mkrPosPig.('LHEE'))).*0.5;

%6.
%Scale the normalized Pig foot model to this participant
bosScaledLeftPig = normBosModelPig.*footLengthPig;

bosScaledRightPig = normBosModelPig.*footLengthPig;
bosScaledRightPig(:,1)=bosScaledRightPig(:,1).*-1;

%7. 
%Transform the scaled left and right foot models to align with the
%participant's foot prints.
bosTransformedLeftPig = transformBosModel(bosScaledLeftPig,frameLeftPig);
bosTransformedRightPig= transformBosModel(bosScaledRightPig,frameRightPig);


%%
% Plotting
%%

%Plot configuration
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


% Plot the markers
figFoot     =figure;

plotColor                       = [1,0,0];
seriesLabel                     = modelType;
seriesLabelPositionNormCoord    = [1,1,1].*0.9;
subPlotPosition                 =reshape(subPlotPanel(1,1,:),1,4);
figFoot=plotMarkerPositions(figFoot,mkrPosPig,plotColor,...
            seriesLabel,seriesLabelPositionNormCoord,...
            subPlotPosition);

% Plot the foot frames
plotAxisScale=0.1;
figFoot = plotFrame(figFoot,frameLeftPig,plotAxisScale,...
                    '--',subPlotPosition);
figFoot = plotFrame(figFoot,frameRightPig,plotAxisScale,...
                    '--',subPlotPosition);

% Plot the Bos model
figFoot = plotFunctionalBos(figFoot,bosTransformedLeftPig,...
                                bosColorPig,'--',subPlotPosition);
figFoot = plotFunctionalBos(figFoot,bosTransformedRightPig,...
                                bosColorPig,'--',subPlotPosition);



