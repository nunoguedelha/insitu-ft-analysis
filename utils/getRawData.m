function [rawData,calibMatrices]=getRawData(ftData,pathFile,serialNumbers)
ftNames=fieldnames(ftData);
if (size(serialNumbers,1)~=size(ftNames,1))
    disp('error number of serial numbers does not match number of sensors')
    rawData=0;
else
    
    for i=1:size(serialNumbers,1)
        
        if (exist(strcat(pathFile,'matrix_',serialNumbers{i},'.txt'),'file')==2)
            calibMat=readCalibMat(strcat(pathFile,'matrix_',serialNumbers{i},'.txt'));
            calibMatrices.(ftNames{i})=calibMat;
            for j=1:size(ftData.(ftNames{i}))
                rawData.(ftNames{i})(j,:)=calibMat\ftData.(ftNames{i})(j,:)';
            end
        else
            rawData=0;
        end
    end
end