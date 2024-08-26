%%
% SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>
%
% SPDX-License-Identifier: MIT
%
%%

clc;
close all;
clear all;

distanceTolerance = 0.0001; %Points that are closer than this distance
                            %are treated as identical

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
%       data/pilotData/trial_07
%       data/pilotData/trial_08
%       data/pilotData/trial_09
%
%       data/configPilot1
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
flag_writeFbosModelToFile=1;

m2cm=100;


mainDir = pwd;
codeDir = fullfile(mainDir,'code');
dataDir = fullfile(mainDir,'data','pilotData');
outputDir= fullfile(mainDir,'output');

forceThreshold = 0.4; %Minimum foot load for a point to count towards the
                      %fbos model

trialFolders = [{'trial_01'},{'trial_02'},{'trial_03'},...
                {'trial_07'},{'trial_08'},{'trial_09'}];

metaData(6)     = struct('data',[]);
markerData(6)   = struct('data',[]);
forceData(6)    = struct('data',[]);

frameData(6)    = struct('left',[],'right',[]);
fbosData(6)     = struct('left',[],'right',[],'combined',[]);


assert(length(trialFolders)==length(metaData));
assert(length(trialFolders)==length(markerData));
assert(length(trialFolders)==length(forceData));
assert(length(trialFolders)==length(frameData));
assert(length(trialFolders)==length(fbosData));


figFbos = figure;
if(flag_plotFbos==1)

    numberOfPlots = length(trialFolders)*2 + 2;

    numberOfVerticalPlotRows = 4;    
    numberOfHorizontalPlotColumns = length(trialFolders);

    plotWidth           = 4*0.5;
    plotHeight          = 18*0.5;
    plotHorizMarginCm   = 2;
    plotVertMarginCm    = 2;

    [subPlotPanel,pageWidth,pageHeight]  = ...
        plotConfigGeneric(numberOfHorizontalPlotColumns, ...
                          numberOfVerticalPlotRows,...
                          plotWidth,...
                          plotHeight,...
                          plotHorizMarginCm,...
                          plotVertMarginCm);
end
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
%
% Extract the Fbos from each trial
%
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
        %
        %Extract the convex hull for this foot print
        %
        idxValid = find(fbosData(indexTrial).(foot).isValid==1);
        xy = [fbosData(indexTrial).(foot).rPFP(idxValid,1),...
             fbosData(indexTrial).(foot).rPFP(idxValid,2)];
        idxCH = convhull(xy(:,1),xy(:,2));

        fbosData(indexTrial).(foot).fbos = xy(idxCH,:);

        %
        %Order the points beginning from the heel point
        %
        [yHeel,idxH] = min(fbosData(indexTrial).(foot).fbos(:,2));
        nPtsCH = length(fbosData(indexTrial).(foot).fbos(:,2));
        idxOrderA = [idxH:nPtsCH];
        idxOrderB = [1:(idxH-1)];
        idxOrder = [idxOrderA,idxOrderB];
        fbosData(indexTrial).(foot).fbos = ...
            fbosData(indexTrial).(foot).fbos(idxOrder,:);



        if(flag_plotFbos==1)
            plotRow = 0;
            plotColumn = indexTrial;
            switch foot
                case 'left'
                    plotRow=1;
                case 'right'
                    plotRow=2;
                otherwise
                    assert(0);
            end
            figure(figFbos);
            subplot('Position',reshape(subPlotPanel(plotRow,plotColumn,:),1,4));
            idxValid = find(fbosData(indexTrial).(foot).isValid==1);
            plot(fbosData(indexTrial).(foot).rPFP(idxValid,1).*m2cm,...
                 fbosData(indexTrial).(foot).rPFP(idxValid,2).*m2cm,...
                 'Color',[1,1,1].*0.75);
            hold on;
            plot(fbosData(indexTrial).(foot).fbos(:,1).*m2cm,...
                 fbosData(indexTrial).(foot).fbos(:,2).*m2cm,'Color',[0,0,0]);
            hold on;
            plot(fbosData(indexTrial).(foot).fbos(1,1).*m2cm,...
                 fbosData(indexTrial).(foot).fbos(1,2).*m2cm,'ok',...
                 'MarkerSize',5,'MarkerFaceColor',[0,0,0]);
            hold on;

            xTickValues = ...
                [min(fbosData(indexTrial).(foot).rPFP(idxValid,1)),...
                 0,...
                 max(fbosData(indexTrial).(foot).rPFP(idxValid,1))].*m2cm;
            xTickValues = sort(round(xTickValues,1));

            yTickValues = ...
                [min(fbosData(indexTrial).(foot).rPFP(idxValid,2)),...
                 0,...
                 max(fbosData(indexTrial).(foot).rPFP(idxValid,2))].*m2cm;
            yTickValues = sort(round(yTickValues,1));

            xticks(xTickValues);
            yticks(yTickValues);

            xlim([xTickValues(1,1)-0.5,xTickValues(1,3)+0.5]);
            ylim([yTickValues(1,1)-0.5,yTickValues(1,3)+0.5]);  

            xlabel('X (cm)');
            ylabel('Y (cm)');
            titleStr = [trialFolders{indexTrial},' (',foot,')'];
            idx = strfind(titleStr,'_');
            titleStr(1,idx)=' ';
            title(titleStr);
            box off;
            %grid on;
            %hold on;
        end        
    end


end


%%
% Build the trial bos model by:
% 1. Taking the average of the left and right feet (for trials that
%    include both feet)
% 2. Computing the average fbos of all trials
%%
for indexTrial=1:1:length(frameData)

    if(  frameData(indexTrial).left.hasData==1 ...
      && frameData(indexTrial).right.hasData==1)
        
        %Note the negative sign: the combined model will be a left foot
        xyLeft=fbosData(indexTrial).('left').fbos;
        xyRightFlipped = fbosData(indexTrial).('right').fbos;        
        xyRightFlipped(:,1)=xyRightFlipped(:,1).*-1;

        %convhull is taken to order the points counter-clockwise (it
        %seems to this this for free, which is nice)
        idxCH = convhull(xyRightFlipped(:,1),xyRightFlipped(:,2));
        xyRightFlipped=xyRightFlipped(idxCH,:);


        fbosData(indexTrial).combined.fbos = ...
            calcArcLengthAverage(xyLeft, xyRightFlipped);

    elseif(frameData(indexTrial).left.hasData==1)
        fbosData(indexTrial).combined.fbos = ...
            fbosData(indexTrial).('left').fbos;
    elseif(frameData(indexTrial).right.hasData==1)
        fbosData(indexTrial).combined.fbos = ...
            fbosData(indexTrial).('right').fbos;
    else
        assert(0,'Error: Invalid trial: no data for either the left or right feet');
    end

    %
    %Order the points beginning from the heel point
    %
    [yHeel,idxH] = min(fbosData(indexTrial).combined.fbos(:,2));
    nPtsCH = length(fbosData(indexTrial).combined.fbos(:,2));
    idxOrderA = [idxH:nPtsCH];
    idxOrderB = [1:(idxH-1)];
    idxOrder = [idxOrderA,idxOrderB];
    fbosData(indexTrial).combined.fbos = ...
        fbosData(indexTrial).combined.fbos(idxOrder,:);

    legendText = [];
    legendColor = [];
    if(flag_plotFbos==1)

        plotRow = 3;
        plotColumn = indexTrial;
        figure(figFbos);
        subplot('Position',reshape(subPlotPanel(plotRow,plotColumn,:),1,4));


        if(    frameData(indexTrial).left.hasData==1 ...
            && frameData(indexTrial).right.hasData==1)

            plot(fbosData(indexTrial).left.fbos(:,1).*m2cm,...
                 fbosData(indexTrial).left.fbos(:,2).*m2cm,...
                 'Color',[0.5,0.5,1],'DisplayName','Left');        
            hold on;  

            plot(-fbosData(indexTrial).right.fbos(:,1).*m2cm,...
                  fbosData(indexTrial).right.fbos(:,2).*m2cm,...
                 'Color',[1,0.5,0.5],'DisplayName','Right');        
            hold on; 
            legendText=[{'Left'},{'Right'}];
            legendColor=[0.5,0.5,1; 1,0.5,0.5];
        end

        plot(fbosData(indexTrial).combined.fbos(:,1).*m2cm,...
             fbosData(indexTrial).combined.fbos(:,2).*m2cm,...
             'Color',[0,0,0],'DisplayName','Combined');        
        hold on;        

        plot(fbosData(indexTrial).combined.fbos(1,1).*m2cm,...
             fbosData(indexTrial).combined.fbos(1,2).*m2cm,...
             'o','Color',[0,0,0],'MarkerSize',4,...
             'MarkerFaceColor',[0,0,0],'HandleVisibility','off');        
        hold on; 

        legendText = [legendText,{'Combined'}];
        legendColor =[legendColor; 0,0,0];



       xTickValues = ...
            [min(fbosData(indexTrial).combined.fbos(:,1)),...
             0,...
             max(fbosData(indexTrial).combined.fbos(:,1))].*m2cm;
        xTickValues = sort(round(xTickValues,1));

        yTickValues = ...
            [min(fbosData(indexTrial).combined.fbos(:,2)),...
             0,...
             max(fbosData(indexTrial).combined.fbos(:,2))].*m2cm;
        yTickValues = sort(round(yTickValues,1));

        xticks(xTickValues);
        yticks(yTickValues);

        for i=1:1:length(legendText)
            xTxt = xTickValues(1,1);
            yTxt = yTickValues(1,3)-(i-1)*0.75;
            text(xTxt,yTxt,legendText{i},'Color',legendColor(i,:));
            hold on;
        end

        xlim([xTickValues(1,1)-0.5,xTickValues(1,3)+0.5]);
        ylim([yTickValues(1,1)-0.5,yTickValues(1,3)+0.5]);  

        xlabel('X (cm)');
        ylabel('Y (cm)');
        titleStr = [trialFolders{indexTrial},' (combined)'];
        idx = strfind(titleStr,'_');
        titleStr(1,idx)=' ';
        title(titleStr);
        box off;
    end
end

%%
% Build the final bos model by taking the average of all of the 
% combined foot models. This is a two stage process:
%
% A. For combined foot model
% 1. Evaluate the normalized cumulative arc length each trial: this
%    defines the node locations of the foot as a function of arc length
%
% 2. Combine all the vector of all normalized cumlative arc lengths
%    into one vector, sort it, and eliminate duplicates.
%
% B. For each point in arcLengthNodes
% 1. Compute the value of each combined model at this arc length
% 2. Compute the average across all points
%%
normArcLength = [];
for indexTrial=1:1:length(frameData)

    fbosData(indexTrial).combined.normArcLength = ...
        calcPolygonArcLength(fbosData(indexTrial).combined.fbos);

    fbosData(indexTrial).combined.normArcLength = ...
        fbosData(indexTrial).combined.normArcLength ...
        ./fbosData(indexTrial).combined.normArcLength(end,1);

    %Eliminate duplicates
    [fbosData(indexTrial).combined.normArcLength, idxU] ...
        = unique(fbosData(indexTrial).combined.normArcLength);
    fbosData(indexTrial).combined.fbos ...
        = fbosData(indexTrial).combined.fbos(idxU,:);

    normArcLength = [normArcLength;...
        fbosData(indexTrial).combined.normArcLength];
end

normArcLength = sort(normArcLength);
normArcLength = unique(normArcLength);

fbosModel = zeros(length(normArcLength),2);

%Error check: I can average across the FBOS here in units of cm because
%  all of the data comes from the same pariticpant: the foot size is
%  the same. If you are using data from different participants you 
%  should normalize the fbos (by footwidth and footlength) and then
%  compute the average. This code is not configured to do this, so
%  I'm adding this error check to make sure the script is not 
%  incorrectly used.
for i=2:1:length(metaData)
    assert(abs(metaData(i).data.footLength...
            -metaData(i-1).data.footLength) < sqrt(eps));
    assert(abs(metaData(i).data.footWidth...
            -metaData(i-1).data.footWidth) < sqrt(eps));
end


for i=1:1:length(normArcLength)
    xy = zeros(length(frameData),2);
    for indexTrial=1:1:length(frameData)

        xTrial = interp1(fbosData(indexTrial).combined.normArcLength,...
                         fbosData(indexTrial).combined.fbos(:,1),...
                         normArcLength(i,1));
        yTrial = interp1(fbosData(indexTrial).combined.normArcLength,...
                         fbosData(indexTrial).combined.fbos(:,2),...
                         normArcLength(i,1));
        xy(indexTrial,:) = [xTrial,yTrial];
    end
    fbosModel(i,1) = mean(xy(:,1)); 
    fbosModel(i,2) = mean(xy(:,2));     
end

%Since this is all from the same participant the foot width and
%length is the same across all trials. 

footWidth  = metaData(1).data.footWidth;
footLength = metaData(1).data.footLength;

normFbosModel  = [fbosModel(:,1)./footWidth, fbosModel(:,2)./footLength];

%
%
% Write the normalized FBOS to file
%
%
if(flag_writeFbosModelToFile==1)
    dlmwrite(fullfile(outputDir,'participant01_fbosInMeters.csv'),fbosModel);
    dlmwrite(fullfile(outputDir,'participant01_fbosNormalized.csv'),fbosModel);
    
end


%
% 
% Plotting
%
%
if(flag_plotFbos==1)
    for i=1:1:2
        plotRow = 4;
        plotColumn = 1+(i-1);
        figure(figFbos);
        subplot('Position',reshape(subPlotPanel(plotRow,plotColumn,:),1,4));    

        dataToPlot = [];
        switch i
            case 1
                dataToPlot=fbosModel.*m2cm;
                xLbl = 'X (cm)';
                yLbl = 'Y (cm)';
                titleStr = 'Avg. Fbos Model';
                dx = 0.1;
                dy = 0.1;
            case 2
                dataToPlot=normFbosModel;
                xLbl = 'Norm. X';
                yLbl = 'Norm. Y';
                titleStr = 'Norm. Avg. Fbos Model';
                dx = 0.01;
                dy = 0.01;
        end

        plot(dataToPlot(:,1),dataToPlot(:,2),'-b');
        hold on;
        plot(dataToPlot(1,1),dataToPlot(1,2),'ob','MarkerSize',4,...
             'MarkerFaceColor',[0,0,1]);
        hold on;
    
       xTickValues = ...
            [min(dataToPlot(:,1)),...
             0,...
             max(dataToPlot(:,1))];
        xTickValues = sort(round(xTickValues,2));
    
        yTickValues = ...
            [min(dataToPlot(:,2)),...
             0,...
             max(dataToPlot(:,2))];
        yTickValues = sort(round(yTickValues,2));
    
        xticks(xTickValues);
        yticks(yTickValues);
    
        for i=1:1:length(legendText)
            xTxt = xTickValues(1,1);
            yTxt = yTickValues(1,3)-(i-1)*0.75;
            text(xTxt,yTxt,legendText{i},'Color',legendColor(i,:));
            hold on;
        end
    
        xlim([xTickValues(1,1)-dx,xTickValues(1,3)+dx]);
        ylim([yTickValues(1,1)-dy,yTickValues(1,3)+dy]);  
    
        xlabel(xLbl);
        ylabel(yLbl);
        title(titleStr);
        box off;
    end

end



if(flag_plotFbos==1)
    figFbos=plotExportConfig(figFbos,pageWidth,pageHeight);

    fileName =  fullfile( outputDir,'fig_fbos.pdf');
    print('-dpdf', fileName);    
end
