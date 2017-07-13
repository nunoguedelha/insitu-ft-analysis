
function  [calibMatrices,offset,fullscale]=estimateMatricesAndOffset(rawData,estimatedFtData,cMat,lambda,sensorsToAnalize)
%Does the estimation of the calibration matrix on the centered data. This
%is done by substracting the mean value to all samples. The offset is then
%calculated on the means with the new calculated calibration matrix

for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
    meanFt=mean(rawData.(ft));
     meanEst=mean(estimatedFtData.(ft));
    rawNoMean=rawData.(ft)-repmat(meanFt,size(rawData.(ft),1),1);
    estNoMean=estimatedFtData.(ft)-repmat(meanEst,size(estimatedFtData.(ft),1),1);
%[calibMatrices.(ft),fullscale.(ft)]=estimateCalibMatrix(rawNoMean,estNoMean.(ft));
[calibMatrices.(ft),fullscale.(ft)]=estimateCalibMatrixWithReg(rawNoMean,estNoMean,cMat.(ft),lambda);

offset.(ft)=meanEst'-calibMatrices.(ft)*meanFt'; %should I change it so that offset needs to be substracted?
end