function [data_noOffset,offset]=removeOffset(ftData,estData)
% REMOTEOFFSET Remote the offset from an FT data using estimated data 
%   This function compute the offset (and returned the ft data without
%   offset) assuming that an estimated of the FT data without offset 
%   is available

diff=ftData-estData;
%offset= mean(diff);
offset=mean(diff(not(isnan(diff(:,1))),:));% ignore the possible NaN in the data
data_noOffset=ftData-repmat(offset,size(estData,1),1);