function  [calibMatrices,offset,fullscale]=estimateMatrices(rawData,estimatedFtData,sensorsToAnalize)

 for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
    offset.(ft)=estimateOffsetUsingInSitu(rawData.(ft), estimatedFtData.(ft)(:,1:3));
    rawNoOffset=rawData.(ft)-repmat(offset.(ft),size(rawData.(ft),1),1);
[calibMatrices.(ft),fullscale.(ft)]=estimateCalibMatrix(rawNoOffset,estimatedFtData.(ft));
end