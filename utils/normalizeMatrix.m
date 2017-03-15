function  [normalized]=normalizeMatrix(data)

 mxData=max(data);
 mnData=min(data);
 diff=mxData-mnData;
    dataNoMin=data-repmat(mnData,size(data,1),1);
    normalized=dataNoMin./repmat(diff,size(data,1),1);
    
