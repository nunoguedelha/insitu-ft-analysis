function [calibMatrices,fullscale,augmentedDataset,varargout]=estimateMatricesWthRegExtraSamples(dataset,sensorsToAnalize,cMat,lambda,extraSample,varargin)
%% Inputs
% dataset: is the main data from de experiment.
% sensorsToAnalize: are the sensors which are required to be recalibrated
% cMat: the calibration matrix currently used in the sensor
% lambda: regularization parameter to tune between cMat and new calibration matrix
% extraSample: data coming from another experiment composed of some extra positions to be considered for calibration
% offset: offset in the raw data calculated previously on the main data contained in dataset
% preCalibMat: calibration matrix obtained without considering the extra samples
%% Outputs
% calibMatrices: calibration matrices of the sensors to be analized

% initialize some values
extraSampleNames=fieldnames(extraSample);
augmentedDataset=dataset;
useFiltered=false;
useTemperature=false;
%% deal with varargin
offset=[];
preCalibMat=[];
offsetAvailable=false;
calibrationDimension=size(dataset.rawData.(sensorsToAnalize{1}),2);
for v=1:length(varargin)
    
if (isstruct(varargin{v}))
   vnames= fieldnames(varargin{v});
   if (~strcmp((vnames{1}),(sensorsToAnalize{1})) && length(vnames)>=length(sensorsToAnalize))
       error('estimateMatricesWthRegExtraSamples:Not matching field names between structures');
   end
   tempV=varargin{v};
    if (isvector(tempV.(vnames{1})))
        if (sum(size(tempV.(vnames{1}))) ==(calibrationDimension+1) && (size(tempV.(vnames{1}),1)==calibrationDimension || size(tempV.(vnames{1}),2)==calibrationDimension) )
            offset=tempV;
            offsetAvailable=true;
        else
            warning('estimateMatricesWthRegExtraSamples: this vector is not an offset of the right dimensions, ignoring vector');
        end
     
        else
        if (ismatrix(tempV.(vnames{1})))
            if (size(tempV.(vnames{1}),1)==calibrationDimension && size(tempV.(vnames{1}),2)==calibrationDimension) % check if this is true when including temperature
                preCalibMat=tempV;
            else
                warning('estimateMatricesWthRegExtraSamples: matrix inerted is not 6 by 6 so not a calibration matrix');
            end
        end
    end
else
    warning('estimateMatricesWthRegExtraSamples: no struct in varargin, variable will not be used');
end
end
if ismember('temperatureEstimationOn',varargin)
useTemperature=true;
end

if isempty(preCalibMat)
   preCalibMat= cMat;
   info('estimateMatricesWthRegExtraSamples: no other calibration matrix available so if required workbench matrix will be used');
end


%% start estimating
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    % initialize stacking variables for the sensor in turn
    stackedRaw=dataset.rawData.(ft);
    stackedEstimated=dataset.estimatedFtData.(ft);
    stackedRawFiltered=dataset.rawDataFiltered.(ft);
    calibrationRequired=false;
    
    % go through all possible extra samples
    for eSampleIDNum =1:length(extraSampleNames)
        eSampleID = extraSampleNames{eSampleIDNum};
        rawData2=[];
        rawDataFiltered2=[];
        estimatedFtData2=[];
        if (~strcmp(ft,'right_arm') && ~strcmp(ft,'left_arm')) %new samples work mainly on legs
            if (strcmp(eSampleID,'right') || strcmp(eSampleID,'left' )) % if calibrating right side use samples specific for the right
                if (strcmp(ft,'right_leg') || strcmp(ft,'right_foot' )) % if calibrating right side use samples specific for the right
                    if (isstruct(extraSample.right) && strcmp(eSampleID,'right' )) %check if there is extra samples on this side
                        rawData2=extraSample.right.rawData;
                        rawDataFiltered2=extraSample.right.rawDataFiltered;
                        estimatedFtData2=extraSample.right.estimatedFtData;
                        calibrationRequired=true;
                    end
                end
                
                if (strcmp(ft,'left_leg') || strcmp(ft,'left_foot') ) % if calibrating left side use samples specific for the left
                    if (isstruct(extraSample.left)&& strcmp(eSampleID,'left' )) %check if there is extra samples on this side
                        rawData2=extraSample.left.rawData;
                        rawDataFiltered2=extraSample.left.rawDataFiltered;
                        estimatedFtData2=extraSample.left.estimatedFtData;
                        calibrationRequired=true;
                    end
                end
            else % if is not the right or left extra sample is should be Tz or general. Tz only to be considered in the legs
                if (isstruct(extraSample.(eSampleID))) %check if there is extra samples on this side
                    rawData2=extraSample.(eSampleID).rawData;
                    rawDataFiltered2=extraSample.(eSampleID).rawDataFiltered;
                    estimatedFtData2=extraSample.(eSampleID).estimatedFtData;
                    calibrationRequired=true;
                end
            end
            
        else % Only general extra sample can be considered for adding info to the arms since in theory it could affect all sensors
            if (isstruct(extraSample.(eSampleID)) && strcmp(eSampleID,'general' ))
                rawData2=extraSample.(eSampleID).rawData;
                rawDataFiltered2=extraSample.(eSampleID).rawDataFiltered;
                estimatedFtData2=extraSample.(eSampleID).estimatedFtData;
                calibrationRequired=true;
            end
        end
        %% stack them
        if(isstruct(rawData2))
        stackedRaw=[stackedRaw;rawData2.(ft)];
        stackedEstimated=[stackedEstimated;estimatedFtData2.(ft)];
        stackedRawFiltered=[stackedRawFiltered;rawDataFiltered2.(ft)];
        end
        
        % augment dataset only once for each extra sample, regardless if
        % the extra sample will be used to calibrate or not, so we do it
        % only in the first loop of sensors
        if (ftIdx==1 && isstruct(extraSample.(eSampleID)))
            augmentedDataset=addDatasets(augmentedDataset,extraSample.(eSampleID));
        end
    end
    
    if calibrationRequired
        if offsetAvailable
            %% check correct dimensions of the offset
            [rows,columns]=size(offset.(ft));
            if rows==6 && columns==1
                offset.(ft)=offset.(ft)';
            end
            
            if useFiltered
                rawNoOffset=stackedRawFiltered-repmat(offset.(ft),size(stackedRaw,1),1);
            else
                rawNoOffset = stackedRaw-repmat(offset.(ft),size(stackedRaw,1),1);
            end
            [calibMatrices.(ft),fullscale.(ft)]=estimateCalibMatrixWithReg(rawNoOffset,stackedEstimated,cMat.(ft),lambda);
        else
            %% no offset provided so we attempt the one shot.
            if useFiltered
                [calibMatrices.(ft),fullscale.(ft),offset]=estimateCalibMatrixWithRegAndOff(stackedRawFiltered,stackedEstimated,cMat.(ft),lambda);
            else
                [calibMatrices.(ft),fullscale.(ft),offset.(ft)]=estimateCalibMatrixWithRegAndOff(stackedRaw,stackedEstimated,cMat.(ft),lambda);
            end
            %% put offset correctly just in case
            [rows,columns]=size(offset.(ft));
            if rows==6 && columns==1
                offset.(ft)=offset.(ft)';
            end
        end
    else
        calibMatrices.(ft)=preCalibMat.(ft);
        
    end
   
end
 varargout{1}=offset;