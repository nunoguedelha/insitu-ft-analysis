% function [rawData,calibMatrices]=getRawData(ftData,pathFile,serialNumbers)
% ftNames=fieldnames(ftData);
% if (size(serialNumbers,1)~=size(ftNames,1))
%     disp('error number of serial numbers does not match number of sensors')
%     rawData=0;
% else
%     for i=1:size(serialNumbers,1)
%            calibMatrices.(ftNames{i})=getWorkbenchCalibMat(pathFile,serialNumbers{i});
%             for j=1:size(ftData.(ftNames{i}))
%                 rawData.(ftNames{i})(j,:)=calibMatrices.(ftNames{i})\ftData.(ftNames{i})(j,:)';
%             end
%     end
% end
function [rawData,calibMatrices]=getRawData(ftData,varargin)
ftNames=fieldnames(ftData);
if (length(varargin)==1)
    calibMatrices=varargin{1}; 
    for i=1:size(ftNames,1)
        for j=1:size(ftData.(ftNames{i}))
            rawData.(ftNames{i})(j,:)=calibMatrices.(ftNames{i})\ftData.(ftNames{i})(j,:)';
        end
    end
else
    if (length(varargin)<4)
        pathFile=varargin{1};
        serialNumbers=varargin{2};
        
        if (length(varargin)==3)
            calibFlag=varargin{3};
        else
            calibFlag=true;
        end
        
        if (size(serialNumbers,1)~=size(ftNames,1))
            disp('error number of serial numbers does not match number of sensors')
            rawData=0;
        else
            for i=1:size(serialNumbers,1)
                if calibFlag
                    % since the channels in raw imput are swaped with respect to the yarp ports it is necesary to sawp the matrix and fullscale properly
                    tempCalibMat=getWorkbenchCalibMat(pathFile,serialNumbers{i});
                    calibMatrices.(ftNames{i})=swapCMat(tempCalibMat);
                    
                    for j=1:size(ftData.(ftNames{i}))
                        rawData.(ftNames{i})(j,:)=calibMatrices.(ftNames{i})\ftData.(ftNames{i})(j,:)';
                    end
                else
                    rawData=swapFT(ftData);
                    calibMatrices.(ftNames{i})=eye(6);
                   
                end
            end
        end
    else
        disp( 'error in number of arguments, to many')
    end
end