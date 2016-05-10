%test calibration matrices obtained from different datasets
%use from test directory
%load calibration matrices to compare
%original
% clear all;
addpath ../utils
addpath ../external/quadfit
serialNumber='SN026';
e=1; %one for doing comparison on experiment1 data, 2 for experiment
[calibMat1,fullscale] = readCalibMat(strcat('../data/sensorCalibMatrices/matrix_',serialNumber,'.txt'));

% experiment 1
experiment1='icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';
%experiment1='icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';
% experiment1='icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';
[calibMat2,fullscale2] = readCalibMat(strcat('../data/',experiment1,'/calibrationMatrices/',serialNumber));

% experiment 2
% experiment2='icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';
% experiment2='icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';
experiment2='icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';
[calibMat3,fullscale3] = readCalibMat(strcat('../data/',experiment2,'/calibrationMatrices/',serialNumber));

% % experiment 3
experiment3='icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';
% experiment3='icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';
 [calibMat4,fullscale4] = readCalibMat(strcat('../data/',experiment3,'/calibrationMatrices/',serialNumber));


%simple comparison among matrices (some similarity index)
% diff=calibMat1-calibMat2;
% totalDiff=sum(sum(diff))
% diagDif=diag(diff)
% 
% diff=calibMat1-calibMat3;
% totalDiff=sum(sum(diff))
% diagDif=diag(diff)
% 
% diff=calibMat2-calibMat3;
% totalDiff=sum(sum(diff))
% diagDif=diag(diff)
% load dataset in which the 3 calibration matrices will be tested
if (exist(strcat('../data/',experiment1,'/dataset2.mat'),'file')==2)
    %% Load from workspace
    %     %load meaninful data, estimated data, meaninful data no offset
    e1=load(strcat('../data/',experiment1,'/dataset2.mat'),'dataset2');
end 

if (exist(strcat('../data/',experiment2,'/dataset2.mat'),'file')==2)
    %% Load from workspace
    %     %load meaninful data, estimated data, meaninful data no offset
   e2= load(strcat('../data/',experiment2,'/dataset2.mat'),'dataset2');
end 

if (exist(strcat('../data/',experiment3,'/dataset2.mat'),'file')==2)
    %% Load from workspace
    %     %load meaninful data, estimated data, meaninful data no offset
   e3= load(strcat('../data/',experiment3,'/dataset2.mat'),'dataset2');
end 
%get raw data or directly load raw data
ftNames=fieldnames(e1.dataset2.ftData);


% (rande1(1:e1size/n1),:)
% 
% (rande2(1:e2size/n2),:)

%insitu

% for i=3:6
% generate random vectors for mixed training
% n1=5; n2=3;
% 
% e1size=size(e1.dataset2.rawData.( ftNames{i}),1);
% rande1=randperm(e1size);
% e2size=size(e2.dataset2.rawData.( ftNames{i}),1);
% rande2=randperm(e2size);
%      offset.(ftNames{i})=estimateOffsetUsingInSitu(e1.dataset2.rawData.(ftNames{i}), e1.dataset2.estimatedFtData.(ftNames{i})(:,1:3));
%     rawNoOffset1=e1.dataset2.rawData.(ftNames{i})-repmat(offset.(ftNames{i}),size(e1.dataset2.rawData.(ftNames{i}),1),1);
%     
%       offset.(ftNames{i})=estimateOffsetUsingInSitu(e2.dataset2.rawData.(ftNames{i}), e2.dataset2.estimatedFtData.(ftNames{i})(:,1:3));
%     rawNoOffset2=e2.dataset2.rawData.(ftNames{i})-repmat(offset.(ftNames{i}),size(e2.dataset2.rawData.(ftNames{i}),1),1);
% 
%     
%      moreData.rawData.( ftNames{i})=[e1.dataset2.rawData.( ftNames{i})(1:(size(e1.dataset2.rawData.( ftNames{i}),1)/n1),:);e2.dataset2.rawData.( ftNames{i})(rande2(1:e2size/n2),:)];
%    moreData.rawNoOffset.( ftNames{i})=[rawNoOffset1(1:(size(e1.dataset2.rawData.( ftNames{i}),1)/n1),:);rawNoOffset2((size(e2.dataset2.rawData.( ftNames{i}),1)/n2):end,:)];
%     moreData.estimatedFtData.( ftNames{i})=[e1.dataset2.estimatedFtData.( ftNames{i})(1:(size(e1.dataset2.estimatedFtData.( ftNames{i}),1)/n1),:);e2.dataset2.estimatedFtData.( ftNames{i})((size(e2.dataset2.estimatedFtData.( ftNames{i}),1)/n2):end,:)];
% 
%     [calibMatrices.(ftNames{i}),fullscale.(ftNames{i})]=estimateCalibMatrix(moreData.rawNoOffset.(ftNames{i}),moreData.estimatedFtData.(ftNames{i}));
% 
% end
%not insitu
% for i=4:4
%      % generate random vectors for mixed training
% n1=1; n2=1;
% 
% e1size=size(e1.dataset2.rawData.( ftNames{i}),1);
% rande1=randperm(e1size);
% e2size=size(e2.dataset2.rawData.( ftNames{i}),1);
% rande2=randperm(e2size);
% 
%      moreData.rawData.( ftNames{i})=[e1.dataset2.rawData.( ftNames{i})(rande1(1:e1size/n1),:);...
%          e2.dataset2.rawData.( ftNames{i})(rande2(1:e2size/n2),:)];
%    moreData.estimatedFtData.( ftNames{i})=[e1.dataset2.estimatedFtData.( ftNames{i})(rande1(1:e1size/n1),:);...
%        e2.dataset2.estimatedFtData.( ftNames{i})(rande2(1:e2size/n2),:)];
% 
%     [calibMatrices.(ftNames{i}),fullscale.(ftNames{i}),offset.(ftNames{i})]=...
%         estimateCalibMatrixWithRegAndOff(...
%              moreData.rawData.(ftNames{i}),...
%              moreData.estimatedFtData.(ftNames{i}),...
%              calibMat1,...
%              .5,...
%              [0;0;0;0;0;0]);
% 
% end
% 
% 
% 
% for i=4:4
%     for j=1:size(moreData.rawData.( ftNames{i}),1)
%         reCalibData.( ftNames{i})(j,:)=calibMatrices.( ftNames{i})*(moreData.rawData.( ftNames{i})(j,:)'-offset.( ftNames{i}));
%     end
% end

% for i=4:4
%    
%     figure,plot3_matrix(reCalibData.( ftNames{i})(:,1:3));hold on;
%     plot3_matrix(moreData.estimatedFtData.( ftNames{i})(:,1:3)); grid on;
% end

%recalibrate with matrix 1 experiment1

if(e==1)
    
    for i=4:4
        for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
            reCalibData1(j,:)=calibMat1*(e1.dataset2.rawData.( ftNames{i})(j,:)');%-e1.dataset2.offset.( ftNames{i})');
        end
    end

%remove offset 
 ftDataNoOffset1=removeOffset(reCalibData1,e1.dataset2.estimatedFtData.(ftNames{i}));

% recalibrate with matrix 2
for i=4:4
    for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
        reCalibData2(j,:)=calibMat2*(e1.dataset2.rawData.( ftNames{i})(j,:)');%-e1.dataset2.offset.( ftNames{i})');
    end
end
 ftDataNoOffset2=removeOffset(reCalibData2,e1.dataset2.estimatedFtData.(ftNames{i}));

%recalibrate with matrix 3
for i=4:4
    for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
        reCalibData3(j,:)=calibMat3*(e1.dataset2.rawData.( ftNames{i})(j,:)');%-e1.dataset2.offset.( ftNames{i})');
    end
end
 ftDataNoOffset3=removeOffset(reCalibData3,e1.dataset2.estimatedFtData.(ftNames{i}));
 
 %recalibrate with matrix 3
for i=4:4
    for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
        reCalibData4(j,:)=calibMat4*(e1.dataset2.rawData.( ftNames{i})(j,:)');%-e1.dataset2.offset.( ftNames{i})');
    end
end
 ftDataNoOffset4=removeOffset(reCalibData4,e1.dataset2.estimatedFtData.(ftNames{i}));
%  for i=4:4
%      for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
%         reCalibData4(j,:)=calibMatrices.( ftNames{i})*(e1.dataset2.rawData.( ftNames{i})(j,:)');%-e1.dataset2.oofset.( ftNames{i})');
%     end
% end
%   ftDataNoOffset4=removeOffset(reCalibData4,e1.dataset2.estimatedFtData.(ftNames{i}));
  
    figure,plot3_matrix(ftDataNoOffset1(:,1:3));hold on;
    plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    legend('measuredDataNoOffset','estimatedData','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');
    
     figure,plot3_matrix(ftDataNoOffset2(:,1:3));hold on;
    plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
     legend('reCalDataE1','estimatedData','Location','west');
    
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');
    
     figure,plot3_matrix(ftDataNoOffset3(:,1:3));hold on;
    plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
   legend('reCalDataE2','estimatedData','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');
    
      figure,plot3_matrix(ftDataNoOffset4(:,1:3));hold on;
     plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
      legend('reCalDataMixed','estimatedData','Location','west');
       legend('reCalDataE3','estimatedData','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

     figure,
      plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;  hold on; 
      plot3_matrix(ftDataNoOffset1(:,1:3));hold on; 
      plot3_matrix(ftDataNoOffset2(:,1:3));hold on;
      plot3_matrix(ftDataNoOffset3(:,1:3));hold on;
      plot3_matrix(ftDataNoOffset4(:,1:3));hold on;
      legend('estimatedData','measuredDataNoOffset','reCalDataE1','reCalDataE2','reCalDataMixed','Location','west');
      legend('estimatedData','measuredDataNoOffset','reCalDataE1','reCalDataE2','reCalDataE3','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');
    
%recalibrate with matrix 1 experiment1
% for i=4:4
%     for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
%         reCalibData1(j,:)=calibMat1*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.oofset.( ftNames{i})');
%     end
% end
% % recalibrate with matrix 2
% for i=4:4
%     for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
%         reCalibData2(j,:)=calibMat2*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.oofset.( ftNames{i})');
%     end
% end
% %recalibrate with matrix 3
% for i=4:4
%     for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
%         reCalibData3(j,:)=calibMat3*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.oofset.( ftNames{i})');
%     end
% end
% 
% 
% for i=4:4
%      for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
%         reCalibData4(j,:)=calibMatrices.( ftNames{i})*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.oofset.( ftNames{i})');
%     end
% end
% 
%     figure,plot3_matrix(reCalibData1(:,1:3));hold on;
%     plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
%     
%      figure,plot3_matrix(reCalibData2(:,1:3));hold on;
%     plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
%     
%      figure,plot3_matrix(reCalibData3(:,1:3));hold on;
%     plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
%   
%     figure,plot3_matrix(reCalibData4(:,1:3));hold on;
%      plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;

%error calculation

    dif1=e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset1(:,1:3);
     dif2=e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset2(:,1:3);
      dif3=e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset3(:,1:3);
  dif4=e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset4(:,1:3);
  
  figure, plot(dif1);
  figure, plot(dif2);
  figure, plot(dif3);
  figure, plot(dif4);
  
  sum(sum(abs(dif1)))
  sum(sum(abs(dif2)))
  sum(sum(abs(dif3)))
  sum(sum(abs(dif4)))
  
 sum(abs(dif1))
 sum(abs(dif2))
 sum(abs(dif3))
 sum(abs(dif4))

end
if(e==2)
    %recalibrate with matrix 1 experiment2
for i=4:4
    for j=1:size(e2.dataset2.rawData.( ftNames{i}),1)
        reCalibData1(j,:)=calibMat1*(e2.dataset2.rawData.( ftNames{i})(j,:)');%-e1.dataset2.offset.( ftNames{i})');
     end
end

%remove offset 
 ftDataNoOffset1=removeOffset(reCalibData1,e2.dataset2.estimatedFtData.(ftNames{i}));

% recalibrate with matrix 2
for i=4:4
    for j=1:size(e2.dataset2.rawData.( ftNames{i}),1)
        reCalibData2(j,:)=calibMat2*(e2.dataset2.rawData.( ftNames{i})(j,:)');%-e1.dataset2.offset.( ftNames{i})');
    end
end
 ftDataNoOffset2=removeOffset(reCalibData2,e2.dataset2.estimatedFtData.(ftNames{i}));

%recalibrate with matrix 3
for i=4:4
    for j=1:size(e2.dataset2.rawData.( ftNames{i}),1)
        reCalibData3(j,:)=calibMat3*(e2.dataset2.rawData.( ftNames{i})(j,:)');%-e1.dataset2.offset.( ftNames{i})');
    end
end
 ftDataNoOffset3=removeOffset(reCalibData3,e2.dataset2.estimatedFtData.(ftNames{i}));
 
 for i=4:4
     for j=1:size(e2.dataset2.rawData.( ftNames{i}),1)
        reCalibData4(j,:)=calibMatrices.( ftNames{i})*(e2.dataset2.rawData.( ftNames{i})(j,:)');%-e2.dataset2.oofset.( ftNames{i})');
    end
 end
 
 ftDataNoOffset4=removeOffset(reCalibData4,e2.dataset2.estimatedFtData.(ftNames{i}));
 
    figure,plot3_matrix(ftDataNoOffset1(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    legend('measuredDataNoOffset','estimatedData','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

     figure,plot3_matrix(ftDataNoOffset2(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    legend('reCalDataE1','estimatedData','Location','west');
    
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

     figure,plot3_matrix(ftDataNoOffset3(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    legend('reCalDataE2','estimatedData','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

     figure,plot3_matrix(ftDataNoOffset4(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
     legend('reCalDataMixed','estimatedData','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');    
    
      figure,
      plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;  hold on; 
      plot3_matrix(ftDataNoOffset1(:,1:3));hold on; 
      plot3_matrix(ftDataNoOffset2(:,1:3));hold on;
      plot3_matrix(ftDataNoOffset3(:,1:3));hold on;
      plot3_matrix(ftDataNoOffset4(:,1:3));hold on;
      legend('estimatedData','measuredDataNoOffset','reCalDataE1','reCalDataE2','reCalDataMixed','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');
% 
% for i=4:4
%     for j=1:size(e2.dataset2.rawData.( ftNames{i}),1)
%         reCalibData1(j,:)=calibMat1*(e2.dataset2.rawData.( ftNames{i})(j,:)'-e2.dataset2.oofset.( ftNames{i})');
%     end
% end
% % recalibrate with matrix 2
% for i=4:4
%     for j=1:size(e2.dataset2.rawData.( ftNames{i}),1)
%         reCalibData2(j,:)=calibMat2*(e2.dataset2.rawData.( ftNames{i})(j,:)'-e2.dataset2.oofset.( ftNames{i})');
%     end
% end
% %recalibrate with matrix 3
% for i=4:4
%     for j=1:size(e2.dataset2.rawData.( ftNames{i}),1)
%         reCalibData3(j,:)=calibMat3*(e2.dataset2.rawData.( ftNames{i})(j,:)'-e2.dataset2.oofset.( ftNames{i})');
%     end
% end
% 
% for i=4:4
%      for j=1:size(e2.dataset2.rawData.( ftNames{i}),1)
%         reCalibData4(j,:)=calibMatrices.( ftNames{i})*(e2.dataset2.rawData.( ftNames{i})(j,:)'-e2.dataset2.oofset.( ftNames{i})');
%     end
% end
% 
% 
%     figure,plot3_matrix(reCalibData1(:,1:3));hold on;
%     plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
%     
%      figure,plot3_matrix(reCalibData2(:,1:3));hold on;
%     plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
%     
%      figure,plot3_matrix(reCalibData3(:,1:3));hold on;
%     plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
%     
%     figure,plot3_matrix(reCalibData4(:,1:3));hold on;
%      plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;

%error calculation

    dif1=e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset1(:,1:3);
     dif2=e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset2(:,1:3);
      dif3=e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset3(:,1:3);
  dif4=e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)-ftDataNoOffset4(:,1:3);
  
  figure, plot(dif1);
  figure, plot(dif2);
  figure, plot(dif3);
  figure, plot(dif4);
  
  sum(sum(abs(dif1)))
  sum(sum(abs(dif2)))
  sum(sum(abs(dif3)))
  sum(sum(abs(dif4)))
  
 sum(abs(dif1))
 sum(abs(dif2))
 sum(abs(dif3))
 sum(abs(dif4))
end

