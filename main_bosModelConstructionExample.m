clc;
close all;
clear all;

addpath('code');

%%
% M.Millard
% 5 August 2024
%
% Prerequisites:
%   For this function to work you must have the following files:
%       data/pilotData/trial_08
%       data/pilotData/trial_09
%       data/pilotData/trial_10
%
%   These contain marker data and force plate data from a single foot
%   functional base of support experiment. Please note that this is
%   just an example. Only a very small subset of our experimental data
%   has been included here to keep the size of the data folder small.
%
%%
modelType = 'Bare'; 

bosColorPig = [1,0,1];

mainDir = pwd;
codeDir = fullfile(mainDir,'code');
dataDir = fullfile(mainDir,'data','pilotData');

forceThreshold = 0.75; %

trialFolders = [{'trial_08'},{'trial_09'},{'trial_10'}];

metaData(3)  = struct('data',[]);
markerData(3)= struct('data',[]);
forceData(3) = struct('data',[]);

%%
% Load the trial meta data, marker data, and force plate data
%%

cd(dataDir);
configPilot1;
cd(mainDir);

for indexTrial=1:1:length(trialFolders)

    idx = strfind(trialFolders{indexTrial},'_');
    trialSuffix = trialFolders{indexTrial}((idx+1):end);
    here=1;
    fileNameMetaData    = ['metadata_',trialSuffix,'.csv'];
    fileNameMarkerData  = ['markerdata_',trialSuffix,'.csv']; 
    fileNameForceData   = ['forcedata_',trialSuffix,'.csv']; 
    
    metaData(indexTrial).data = ...
       readCsvConvertToStruct( fullfile(dataDir,...
                            trialFolders{indexTrial},fileNameMetaData));

    markerData(indexTrial).data = ...
        readCsvConvertToStruct( fullfile(dataDir,...
                            trialFolders{indexTrial},fileNameMarkerData));

    forceData(indexTrial).data = ...
        readCsvConvertToStruct( fullfile(dataDir,...
                            trialFolders{indexTrial},fileNameForceData));  
end

%%
% Calculate the location and orientation of the foot frame from the markers
%%

%%
% Resolve the CoP data into the foot frame
%%

%%
% Build the trial bos model by taking the convex hull of the CoP data
% resolved into the foot frame.
%%

%%
% Build the final bos model by taking the average of the left and
% right foot data.
%%
