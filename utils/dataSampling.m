function [data,mask]= dataSampling(dataset,N)
temp=dataset.time;
temp(1:N:end)=-999;
mask=temp==-999;
data=applyMask(dataset,mask);