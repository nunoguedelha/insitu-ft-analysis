function [offset,rawData]= calculateOffset(sensorsToAnalize,ftData,estimatedFtData,calibMat,calibMatrices)
%offset calculation assumes the offset is constant through the whole data
%set for which the difference of the means would give the offset for the
%whole dataset
%sensorsToAnalize = sensors that will be considered for offset calculation
%ftData= force torque data from the sensors
%estimatedFtData= estimated force torque data from the model 
%calibMat= original calibration matrix
%calibMatrices= recalibrated calibration matrix
if (iscell(sensorsToAnalize))
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        
        for j=1:size(ftData.(ft))
            rawData.(ft)(j,:)=calibMat.(ft)\ftData.(ft)(j,:)';
        end
        meanFt=mean(rawData.(ft));
        meanEst=mean(estimatedFtData.(ft));
        offset.(ft)=calibMatrices.(ft)*meanFt'-meanEst';
    end
    
else %it means there is only one matrix in the struct
    ft=sensorsToAnalize;
    for j=1:size(ftData.(ft))
        rawData.(ft)(j,:)=calibMat.(ft)\ftData.(ft)(j,:)';
    end
    meanFt=mean(rawData.(ft));
    meanEst=mean(estimatedFtData.(ft));
    offset.(ft)=calibMatrices.(ft)*meanFt'-meanEst';
end
