function [ dataset ] = removeOffsetInFTdata( dataset, offset )
%remoteOffsetInFTdata remove offset in FT data 

dataset.ft = dataset.ft-repmat(offset,size(dataset.ft,1),1);
dataset.forceNorm = sqrt(sum(abs(dataset.ft(:,1:3)).^2,2));
dataset.forceCADNorm = sqrt(sum(abs(dataset.ftCAD(:,1:3)).^2,2));
dataset.accNorm = sqrt(sum(abs(dataset.acc(:,1:3)).^2,2));

end

