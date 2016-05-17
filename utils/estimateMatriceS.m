
function  [calibMatrices,offset,fullscale]=estimateMatriceS(rawData,estimatedFtData,cMat,lambda)
ftNames=fieldnames(estimatedFtData);
n=3; %n=3 usually start from 3rd, start from first
%add offset removal here? estimateOffsetusingInsitu(rawData(:,1:3), estimatedFtData(:.1:3))
for i=n:size(ftNames,1)
    meanFt=mean(rawData.(ftNames{i}));
     meanEst=mean(estimatedFtData.(ftNames{i}));
    rawNoMean=rawData.(ftNames{i})-repmat(meanFt,size(rawData.(ftNames{i}),1),1);
    estNoMean=estimatedFtData.(ftNames{i})-repmat(meanEst,size(estimatedFtData.(ftNames{i}),1),1);
%[calibMatrices.(ftNames{i}),fullscale.(ftNames{i})]=estimateCalibMatrix(rawNoMean,estNoMean.(ftNames{i}));
[calibMatrices.(ftNames{i}),fullscale.(ftNames{i})]=estimateCalibMatrixWithReg(rawNoMean,estNoMean,cMat.(ftNames{i}),lambda);

offset.(ftNames{i})=meanEst'-calibMatrices.(ftNames{i})*meanFt';
end