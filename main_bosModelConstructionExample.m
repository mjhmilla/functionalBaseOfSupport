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
%
%       data/pilotData/trial_01
%       data/pilotData/trial_02
%       data/pilotData/trial_03
%       data/pilotData/trial_08
%       data/pilotData/trial_09
%       data/pilotData/trial_10
%
%   Trials 8-10 are data from single foot FBOS trials while trials 1-3 are
%   from two foot FBOS trials. These contain marker data and force plate 
%   data from a single foot functional base of support experiment. Please 
%   note that this is just an example. Only a very small subset of our 
%   experimental data has been included here to keep the size of the data 
%   folder small.
%
%%
modelType = 'Bare'; 

flag_plotFbos = 1;

mainDir = pwd;
codeDir = fullfile(mainDir,'code');
dataDir = fullfile(mainDir,'data','pilotData');

forceThreshold = 0.4; %Minimum foot load for a point to count towards the
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

    numberOfRows = 0;
    if(isfield(markerData(indexTrial).data,'L_FAL'))
        numberOfRows = size(markerData(indexTrial).data.L_FAL,1);
    end
    if(numberOfRows == 0 && isfield(markerData(indexTrial).data,'R_FAL'))
        numberOfRows = size(markerData(indexTrial).data.R_FAL,1);
    end

    for indexRow = 1:1:numberOfRows
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
% Resolve the CoP data into the foot frame and check whether the 
% data meets the requirements of being within the foot orientation and 
% minimum force limits.
%%
for indexTrial=1:1:length(frameData)
    footSet = [];
    if(frameData(indexTrial).left.hasData==1)
        footSet = [footSet,{'left'}];
    end
    if(frameData(indexTrial).right.hasData==1)
        footSet = [footSet,{'right'}];
    end
    
    numberOfRows = size(frameData(indexTrial).(footSet{1}).r,1);

    for indexFoot = 1:1:length(footSet)

        foot = footSet{indexFoot};     
        switch foot
            case 'left'
                copField = 'L_r0F0';
                forceField='L_f0';
            case 'right'
                copField = 'R_r0F0';
                forceField='R_f0';                
            otherwise 
                assert(0,'Error: foot must either be left or right');
        end
        
        assert(size(forceData(indexTrial).data.(copField),1)==numberOfRows);

        fbosData(indexTrial).(foot).rPFP = zeros(numberOfRows,3);
        fbosData(indexTrial).(foot).fP   = zeros(numberOfRows,3);
        fbosData(indexTrial).(foot).isValid = zeros(numberOfRows,1);
        

        for indexRow=1:1:numberOfRows
            %Note the name convention for this kinematic vector
            %
            % r: position vector
            % 0: from point 0 (the lab frame)
            % C: to the center of pressure
            % 0: resolved in the coordinates of the lab frame
            %
            r0F0 = forceData(indexTrial).data.(copField)(indexRow,:)';

            %Note the name convention for this force vector
            %
            % f: force vector  
            % 0: resolved in the coordinates of the lab frame
            %
            f0 = forceData(indexTrial).data.(forceField)(indexRow,:)';
            
            % P : the origin of the foot print frame
            r0P0 = frameData(indexTrial).(foot).r(indexRow,:)';

            %Note the name convention for this rotation matrix
            %
            % E: rotation matrix
            % P: rotates coordinates from the foot print frame P
            % 0: to the inertial frame           
            ea321 = frameData(indexTrial).(foot).ea321(indexRow,:);
            EP0  = calcEfromEA321(ea321);
            
            rPFP = EP0'*(r0F0 - r0P0);
            fP   = EP0'*f0;
            fbosData(indexTrial).(foot).rPFP(indexRow,:)=rPFP';
            fbosData(indexTrial).(foot).fP(indexRow,:)=fP';

            %
            % Only accept data points for the fbos when:
            % - the foot is on the ground to within footCompressionMax
            % - the foot is flat to within angleXUB and angleYUB
            % - the foot is loaded by at least bodyWeight*forceThreshold
            %
            isValid =1;
            if(   abs(ea321(1,3)) > metaData(indexTrial).data.angleXUB ...
               || abs(ea321(1,2)) > metaData(indexTrial).data.angleYUB)
                isValid=0;
            end
            if(f0(3) < bodyWeight*forceThreshold )
                isValid=0;
            end
            fbosData(indexTrial).(foot).isValid(indexRow,1)=isValid;
        end
    end
end


%%
% Build the trial bos model by taking the convex hull of the CoP data
% resolved into the foot frame.
%%

%%
% Build the final bos model by taking the average of the left and
% right foot data.
%%
