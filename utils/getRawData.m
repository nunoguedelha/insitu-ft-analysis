function [rawData,calibMatrices]=getRawData(ftData,pathFile,serialNumbers)
ftNames=fieldnames(ftData);
if (size(serialNumbers,1)~=size(ftNames,1))
    disp('error number of serial numbers does not match number of sensors')
    rawData=0;
else
    for i=1:size(serialNumbers,1)
           calibMatrices.(ftNames{i})=getWorkbenchCalibMat(pathFile,serialNumbers{i});
            for j=1:size(ftData.(ftNames{i}))
                rawData.(ftNames{i})(j,:)=calibMatrices.(ftNames{i})\ftData.(ftNames{i})(j,:)';
            end
    end
end