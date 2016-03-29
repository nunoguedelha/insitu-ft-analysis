function  [calibMatrices,offset]=estimateMatrices(rawData,estimatedFtData)
ftNames=fieldnames(estimatedFtData);
%add offset removal here? estimateOffsetusingInsitu(rawData(:,1:3), estimatedFtData(:.1:3))
for i=3:size(ftNames,1)
    offset.(ftNames{i})=estimateOffsetUsingInSitu(rawData.(ftNames{i}), estimatedFtData.(ftNames{i})(:,1:3));
    rawNoOffset=rawData.(ftNames{i})-repmat(offset.(ftNames{i}),size(rawData.(ftNames{i}),1),1);
calibMatrices.(ftNames{i})=estimateCalibMatrix(rawNoOffset,estimatedFtData.(ftNames{i}));
end