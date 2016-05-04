function  [calibMatrices,offset,fullscale]=estimateMatricesReg(rawData,estimatedFtData,cMat)
lambda=.5;
ftNames=fieldnames(estimatedFtData);
n=1; %n=3 usually start from 3rd, start from first
%add offset removal here? estimateOffsetusingInsitu(rawData(:,1:3), estimatedFtData(:.1:3))
for i=n:size(ftNames,1)
    offset.(ftNames{i})=estimateOffsetUsingInSitu(rawData.(ftNames{i}), estimatedFtData.(ftNames{i})(:,1:3));
    rawNoOffset=rawData.(ftNames{i})-repmat(offset.(ftNames{i}),size(rawData.(ftNames{i}),1),1);
[calibMatrices.(ftNames{i}),fullscale.(ftNames{i})]=estimateCalibMatrixWithReg(rawNoOffset,estimatedFtData.(ftNames{i}),cMat.(ftNames{i}),lambda);
end