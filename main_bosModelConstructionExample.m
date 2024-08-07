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

forceThreshold = 0.5; %Minimum foot load for a point to count towards the
                      %fbos model

trialFolders = [{'trial_01'},{'trial_02'},{'trial_03'},...
                {'trial_07'},{'trial_08'},{'trial_09'}];

metaData(6)     = struct('data',[]);
markerData(6)   = struct('data',[]);
forceData(6)    = struct('data',[]);

frameData(6)    = struct('left',[],'right',[]);
fbosData(6)     = struct('left',[],'right',[]);

assert(length(trialFolders)==length(metaData));
assert(length(trialFolders)==length(markerData));
assert(length(trialFolders)==length(forceData));
assert(length(trialFolders)==length(frameData));
assert(length(trialFolders)==length(fbosData));

%%
% Load the trial meta data, marker data, and force plate data
%%

cd(dataDir);
configPilot1;
cd(mainDir);

for indexTrial=1:1:length(trialFolders)

    idx         = strfind(trialFolders{indexTrial},'_');
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

    if( strcmp( trialFolders{indexTrial}, quietStandingFolder ))
        fieldnames = fields(markerData(indexTrial).data);        
        for i=1:1:length(fieldnames)
          quietStandingData.data.(fieldnames{i}) = ...
              markerData(indexTrial).data.(fieldnames{i})(quietStandingIndices,:);
          here=1;
        end
        here=1;
    end
end

%%
% Calculate the location and orientation of the foot frame from the markers
%%
rowIndex=1;
[frameLeftOffset, frameRightOffset]=...
        getIorFootOffsetFrames(rowIndex, quietStandingData.data);


for indexTrial=1:1:length(frameData)

    frameData(indexTrial).left.r = ...
        zeros(size(markerData(indexTrial).data.L_FAL,1),3);
    frameData(indexTrial).left.ea321 = ...
        zeros(size(markerData(indexTrial).data.L_FAL,1),3);

    frameData(indexTrial).right.r = ...
        zeros(size(markerData(indexTrial).data.L_FAL,1),3);
    frameData(indexTrial).right.ea321 = ...
        zeros(size(markerData(indexTrial).data.L_FAL,1),3);

    for indexRow = 1:1:size(markerData(indexTrial).data.L_FAL,1)
        [frameLeft, frameRight] = ...
            getIorFootFrames(indexRow, ...
                             markerData(indexTrial).data, ...
                             frameLeftOffset, ...
                             frameRightOffset); 

        if(isfield(markerData(indexTrial).data,'L_FAL'))
            frameData(indexTrial).left.r(indexRow,:) = frameLeft.r';
            frameData(indexTrial).left.ea321(indexRow,:) = calcEA321(frameLeft.E);
            frameData(indexTrial).left.hasData=1;
        else
            frameData(indexTrial).left.hasData=0;
        end

        if(isfield(markerData(indexTrial).data,'R_FAL'))
            frameData(indexTrial).right.r(indexRow,:) = frameRight.r';
            frameData(indexTrial).right.ea321(indexRow,:) = calcEA321(frameRight.E);
            frameData(indexTrial).right.hasData=1;
        else
            frameData(indexTrial).right.hasData=0;
        end
    end
end

here=1;
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
