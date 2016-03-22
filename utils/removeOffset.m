function [data_noOffset,offset]=removeOffset(ftData,estData)
% remove the mean of the difference between the data from force-torque
% sensor and estimated wrenches 
diff=ftData-estData;
%offset= mean(diff);
offset=mean(diff(not(isnan(diff(:,1))),:));% ignore the possible NaN in the data
data_noOffset=ftData-repmat(offset,size(estData,1),1);