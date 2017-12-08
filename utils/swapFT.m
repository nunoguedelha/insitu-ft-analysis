function [swapedInfo]=swapFT(ftInfo)
names=fieldnames(ftInfo);
 for i=1:length(names)
        swapedInfo.(names{i})=[ftInfo.(names{i})(:,4:6),ftInfo.(names{i})(:,1:3)];
 end