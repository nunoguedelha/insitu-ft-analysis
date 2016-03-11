function [ dataset ] = findOffsetInFTdata( dataset )
%findOffsetInFTdata find offset in FT data 
% Remove the mean from the FT signal: given that we need to compute the
% offset anyway, let's remove the mean from the FT signal for numerical
% reasons 
dataset.offset = estimateOffsetUsingInSitu(dataset.ft,dataset.acc(:,1:3));
dataset.ft = dataset.ft-repmat(offset,size(dataset.ft,1),1);


dataset.forceNorm = sqrt(sum(abs(dataset.ft(:,1:3)).^2,2));
dataset.forceCADNorm = sqrt(sum(abs(dataset.ftCAD(:,1:3)).^2,2));
dataset.accNorm = sqrt(sum(abs(dataset.acc(:,1:3)).^2,2));



end

