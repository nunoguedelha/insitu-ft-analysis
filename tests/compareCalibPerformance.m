%test calibration matrices obtained from different datasets
%use from test directory
%load calibration matrices to compare
%original
% clear all;
serialNumber='SN026';
e=2; %one for doing comparison on experiment1 data, 2 for experiment2
[calibMat1,fullscale] = readCalibMat(strcat('../data/sensorCalibMatrices/matrix_',serialNumber,'.txt'));

% experiment 1
experiment1='icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';
[calibMat2,fullscale2] = readCalibMat(strcat('../data/',experiment1,'/calibrationMatrices/',serialNumber));

% experiment 2
experiment2='icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';
[calibMat3,fullscale3] = readCalibMat(strcat('../data/',experiment2,'/calibrationMatrices/',serialNumber));


%simple comparison among matrices (some similarity index)
diff=calibMat1-calibMat2;
totalDiff=sum(sum(diff))
diagDif=diag(diff)

diff=calibMat1-calibMat3;
totalDiff=sum(sum(diff))
diagDif=diag(diff)

diff=calibMat2-calibMat3;
totalDiff=sum(sum(diff))
diagDif=diag(diff)
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
%get raw data or directly load raw data
ftNames=fieldnames(e1.dataset2.ftData);
%recalibrate with matrix 1 experiment1


% for i=4:4
%     for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
%         reCalibData1(j,:)=calibMat1*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.offset.( ftNames{i})');
%     end
% end
% % recalibrate with matrix 2
% for i=4:4
%     for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
%         reCalibData2(j,:)=calibMat2*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.offset.( ftNames{i})');
%     end
% end
% %recalibrate with matrix 3
% for i=4:4
%     for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
%         reCalibData3(j,:)=calibMat3*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.offset.( ftNames{i})');
%     end
% end
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
 
    figure,plot3_matrix(ftDataNoOffset1(:,1:3));hold on;
    plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
     figure,plot3_matrix(ftDataNoOffset2(:,1:3));hold on;
    plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
     figure,plot3_matrix(ftDataNoOffset3(:,1:3));hold on;
    plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
    
%recalibrate with matrix 1 experiment1
for i=4:4
    for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
        reCalibData1(j,:)=calibMat1*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.oofset.( ftNames{i})');
    end
end
% recalibrate with matrix 2
for i=4:4
    for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
        reCalibData2(j,:)=calibMat2*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.oofset.( ftNames{i})');
    end
end
%recalibrate with matrix 3
for i=4:4
    for j=1:size(e1.dataset2.rawData.( ftNames{i}),1)
        reCalibData3(j,:)=calibMat3*(e1.dataset2.rawData.( ftNames{i})(j,:)'-e1.dataset2.oofset.( ftNames{i})');
    end
end


    figure,plot3_matrix(reCalibData1(:,1:3));hold on;
    plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
     figure,plot3_matrix(reCalibData2(:,1:3));hold on;
    plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
     figure,plot3_matrix(reCalibData3(:,1:3));hold on;
    plot3_matrix(e1.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
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
 
    figure,plot3_matrix(ftDataNoOffset1(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
     figure,plot3_matrix(ftDataNoOffset2(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
     figure,plot3_matrix(ftDataNoOffset3(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;

% for i=4:4
%     for j=1:size(e2.dataset2.rawData.( ftNames{i}),1)
%         reCalibData1(j,:)=calibMat1*(e2.dataset2.rawData.( ftNames{i})(j,:)');%-e2.dataset2.oofset.( ftNames{i})');
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


    figure,plot3_matrix(reCalibData1(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
     figure,plot3_matrix(reCalibData2(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
    
     figure,plot3_matrix(reCalibData3(:,1:3));hold on;
    plot3_matrix(e2.dataset2.estimatedFtData.(ftNames{4})(:,1:3)); grid on;
end
    
% compare 