%% Testing filter function
ftData.test1=ones(600,3);
ftData.test2=ones(600,3)*2;

[filteredFtData,mask]=filterFtData(ftData);
withoutzero=sum(mask);
ftData.test1=[ones(300,3);zeros(300,3)];
ftData.test2=ones(600,3)*2;

[filteredFtData,mask]=filterFtData(ftData);
withzero=sum(mask);
if (withoutzero==withzero)
    disp('success')
end