
function  [calibMatrices,offset,fullscale]=estimateMatricesAndOffset(rawData,estimatedFtData,cMat,lambda,sensorsToAnalize)
%Does the estimation of the calibration matrix on the centered data. This
%is done by substracting the mean value to all samples. The offset is then
%calculated on the means with the new calculated calibration matrix
oneshot=true;
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    if ~oneshot
        meanFt=mean(rawData.(ft));
        meanEst=mean(estimatedFtData.(ft));
        rawNoMean=rawData.(ft)-repmat(meanFt,size(rawData.(ft),1),1);
        estNoMean=estimatedFtData.(ft)-repmat(meanEst,size(estimatedFtData.(ft),1),1);
        
        [calibMatrices.(ft),fullscale.(ft)]=estimateCalibMatrixWithReg(rawNoMean,estNoMean,cMat.(ft),lambda);
        offset.(ft)=calibMatrices.(ft)*meanFt'-meanEst'; 
    else
        O_w=[0,0,0,0,0,0]';
        [calibMatrices.(ft),fullscale.(ft),offset.(ft)]=estimateCalibMatrixWithRegAndOff(rawData.(ft),estimatedFtData.(ft),cMat.(ft),lambda,O_w);
    
    end
  [rows,columns]=size(offset.(ft));
        if rows==6 && columns==1
           offset.(ft)=offset.(ft)';
        end
end