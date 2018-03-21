function  [calibMatrices,fullscale]=estimateMatricesWthRegExtraSamples(dataset,sensorsToAnalize,cMat,lambda,extraSample,offset,preCalibMat)
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
%

rawData=dataset.rawData;
estimatedFtData=dataset.estimatedFtData;
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx}; 
    if (~strcmp(ft,'right_arm') && ~strcmp(ft,'left_arm')) %new samples work mainly on legs
        
        if (strcmp(ft,'right_leg') || strcmp(ft,'right_foot' )) % if calibrating right side use samples specific for the right
            if (isstruct(extraSample.right)) %check if there is extra samples on this side
                rawData2=extraSample.right.rawData;
                estimatedFtData2=extraSample.right.estimatedFtData;
            else %no data use previous calibration matrix
                calibMatrices.(ft)=preCalibMat.(ft);
            end
        end
        
        if (strcmp(ft,'left_leg') || strcmp(ft,'left_foot') ) % if calibrating left side use samples specific for the left
            if (isstruct(extraSample.left)) %check if there is extra samples on this side
                rawData2=extraSample.left.rawData;
                estimatedFtData2=extraSample.left.estimatedFtData;
            else %no data use previous calibration matrix
                calibMatrices.(ft)=preCalibMat.(ft);
            end
        end
        
        rawNoOffset=[rawData.(ft);rawData2.(ft)]-repmat(offset.(ft),size(rawData.(ft),1)+size(rawData2.(ft),1),1);
        [calibMatrices.(ft),fullscale.(ft)]=estimateCalibMatrixWithReg(rawNoOffset,[estimatedFtData.(ft);estimatedFtData2.(ft)],cMat.(ft),lambda);
    else %no data use previous calibration matrix
        calibMatrices.(ft)=preCalibMat.(ft);
    end
end