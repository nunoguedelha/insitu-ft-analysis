function  [s,offset,A]=checkSVD(rawData,estimatedFtData,cMat,lambda)

 
    offset=estimateOffsetUsingInSitu(rawData, estimatedFtData(:,1:3));
    rawNoOffset=rawData-repmat(offset,size(rawData,1),1);
    [u,s,v]=svd(rawNoOffset,'econ');
    A=rawNoOffset;
%C_w=cMat'; 
% kIA = kron(eye(6), rawNoOffset);
% [u,s,v]=svd(kIA);
% A=kIA;
% n=size(kIA,1);
% A=(kIA'*kIA)/n+lambda*eye(36);
% [u,s,v]=svd(pinv(A));


