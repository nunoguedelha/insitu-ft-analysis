estNorm=B;
rawNorm=A;
obTemp=99999999;
counter=0;
Obs=zeros(24,1);
obsRec=[];
newIndex= randperm(24);
num=24;
sample=[17,19,21,23,18,20];
for n=1:num
%     not_done = true;
%   while not_done
%     newIndex= randperm(length(dataset.time),1);
%     if (
%     not_done = condition;
%   end

   
  
   temprawSet=rawNorm([sample,newIndex(n)],:);
   temprefSet=estNorm([sample,newIndex(n)],:);
         % [calibMatrices,offset,fullscale]=estimateMatrices(dataset.rawData,dataset.estimatedFtData,sensorsToAnalize);

 [~,s,~]=svd(temprawSet,'econ');
 eigMax(n)=max(diag(s));
 eigMin(n)=min(diag(s));
  Obs(n)=eigMax(n)/eigMin(n);
 if ( Obs(n)<=obTemp)
     counter=counter+1;
    sample= [sample,newIndex(n)];
    obsRec(counter)=Obs(n);
    obTemp=Obs(n);
 end
end
figure,
%for i=1:6
 plot(Obs); hold on;
%plot(eigMax(1:num,i)); hold on;
% plot(eigMin(1:num,i)); hold on;
%end
figure,
plot(obsRec);

figure,
%for i=1:6
% plot(Obs(1:500,i)); hold on;
 plot(eigMax(1:num)); hold on;
plot(eigMin(1:num)); hold on;
%end


 [~,st,~]= svd(rawNorm(sample,:));
 eigMaxt=max(diag(st));
 eigMint=min(diag(st));
  Obst=eigMaxt/eigMint;
  
  sample
  size(sample)
