clc;
close all;
clear all;
%%
% M.Millard
% 4 April 2023
%
% 1. Prerequisites:
%   For this function to work you must have the following files:
%
%     data/normBosModelIorShod.csv
%     data/normBosModelIorBare.csv
%
%   If you do not have these files, you can generate them by running
%  
%     main_testFunctionalBosModel.m 
%
%   with the appropriate flags set.
%
% 2. Highlights
%  See the code block titled 'IOR Bos Example Code' for an example of how
%  to use the functions needed to scale and place the IOR BOS model to 
%  fit the marker data.
%
%%
modelType = 'Bare'; %'Bare' or 'Shod'

bosColorIor = [0,0,1];

mainDir = pwd;
codeDir = fullfile(mainDir,'code');
dataDir = fullfile(mainDir,'data');

%%
% IOR Bos Example Code
%%

%1. 
% Load the c3d data and put it into a standardized struct
load(fullfile(dataDir,'Data_PiG_IOR_Static.mat'));

%Put the c3d data into a standardized
switch modelType
    case 'Bare'
        mkrPos   = Data_PiG_IOR.Sub(1).Bar_static.c3dMarkers;
    case 'Shod'
        mkrPos   = Data_PiG_IOR.Sub(1).Run_static.c3dMarkers;        
    otherwise
        assert(0,'Error: modelType must be either Bare or Shod');
end

%2. 
% Load the normalized Ior Bos model.
%       Note: this normalized foot is a normalized left foot
normBosModelIor=readmatrix(...
    fullfile(dataDir,sprintf('normBosModelIor%s.csv',modelType)));




%3.
%Create the vector and orientation frame offsets align the IOR foot
%frame with the sole of the foot for the data at rowIndex
rowIndex=1;
[frameLeftOffsetIor, frameRightOffsetIor]=...
        getIorFootOffsetFrames(rowIndex, mkrPos);

%4.
%Calculate the location of the foot print frame using the IOR marker set
[frameLeftIor, frameRightIor]= getIorFootFrames(...
                            rowIndex, ...
                            mkrPos, ...
                            frameLeftOffsetIor, ...
                            frameRightOffsetIor);

%5.
%Evaluate the size of the foot using the Ior marker set
[footLengthIor, midFootLengthIor, footWidthIor] =...
    getIorFootSize(rowIndex, frameLeftIor, frameRightIor, mkrPos);

%6.
%Scale the normalized IOR foot model to this participant
bosScaledLeftIor = normBosModelIor;
bosScaledLeftIor(:,1) = bosScaledLeftIor(:,1).*footWidthIor;
bosScaledLeftIor(:,2) = bosScaledLeftIor(:,2).*footLengthIor;

bosScaledRightIor = [bosScaledLeftIor(:,1).*-1, bosScaledLeftIor(:,2)];

%7. 
%Transform the scaled left and right foot models to align with the
%participant's foot prints.
bosTransformedLeftIor = transformBosModel(bosScaledLeftIor,frameLeftIor);
bosTransformedRightIor= transformBosModel(bosScaledRightIor,frameRightIor);


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
figFoot=plotMarkerPositions(figFoot,mkrPos,plotColor,...
            seriesLabel,seriesLabelPositionNormCoord,...
            subPlotPosition);

% Plot the foot frames
plotAxisScale=0.1;
figFoot = plotFrame(figFoot,frameLeftIor,plotAxisScale,...
                    '--',subPlotPosition);
figFoot = plotFrame(figFoot,frameRightIor,plotAxisScale,...
                    '--',subPlotPosition);

% Plot the Bos model
figFoot = plotFunctionalBos(figFoot,bosTransformedLeftIor,...
                                bosColorIor,'--',subPlotPosition);
figFoot = plotFunctionalBos(figFoot,bosTransformedRightIor,...
                                bosColorIor,'--',subPlotPosition);



