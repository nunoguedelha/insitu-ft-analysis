%test calibration matrices obtained from different datasets
%use from test directory
%load calibration matrices to compare
%original, consider mainly grid datasets
% clear all;
addpath ../utils
addpath ../external/quadfit
serialNumber='SN163';
e=1; %one for doing comparison on experiment1 data, 2 for experiment
[calibMat1,fullscale] = readCalibMat(strcat('../data/sensorCalibMatrices/matrix_',serialNumber,'.txt'));

% experiment 1
trainingData='calibLeftLegFootFT/poleGridLeftLeg';
experiment1='calibLeftLegFootFT/validatePoleGridLeftLeg';
% experiment1='icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';
[calibMat2,fullscale2] = readCalibMat(strcat('../data/',trainingData,'/calibrationMatrices/',serialNumber));

% second Calibration matrix
%[calibMat3,fullscale3] = readCalibMat(strcat('../data/',experiment1,'/calibrationMatrices/',strcat(serialNumber,'_sampled')));


%simple comparison among matrices (some similarity index)
diff=calibMat1-calibMat2;
totalDiff=sum(sum(diff))
diagDif=diag(diff)

% diff=calibMat1-calibMat3;
% totalDiff=sum(sum(diff))
% diagDif=diag(diff)

% diff=calibMat2-calibMat3;
% totalDiff=sum(sum(diff))
% diagDif=diag(diff)
% load dataset in which the 3 calibration matrices will be tested
if (exist(strcat('../data/',experiment1,'/ftDataset.mat'),'file')==2)
    %% Load from workspace
    %     %load meaninful data, estimated data, meaninful data no offset
    e1=load(strcat('../data/',experiment1,'/ftDataset.mat'),'dataset');
end

%get raw data or directly load raw data
ftNames=fieldnames(e1.dataset.ftData);
sensorsToAnalize = {'left_leg'};

%obtain offset in the rawdata
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    offset.(ft)=estimateOffsetUsingInSitu(e1.dataset.rawData.(ft), e1.dataset.estimatedFtData.(ft)(:,1:3));
end
%recalibrate with matrix 1 experiment1


for i=1:1
    for j=1:size(e1.dataset.rawData.( ftNames{i}),1)
        ftDataNoOffset1(j,:)=calibMat1*(e1.dataset.rawData.( ftNames{i})(j,:)'-offset.( ftNames{i})');
    end
end

%remove offset
% ftDataNoOffset1=removeOffset(reCalibData1,e1.dataset.estimatedFtData.(ftNames{i}));

% recalibrate with matrix 2
for i=1:1
    for j=1:size(e1.dataset.rawData.( ftNames{i}),1)
        ftDataNoOffset2(j,:)=calibMat2*(e1.dataset.rawData.( ftNames{i})(j,:)'-offset.( ftNames{i})');
    end
end
% ftDataNoOffset2=removeOffset(reCalibData2,e1.dataset.estimatedFtData.(ftNames{i}));

% %recalibrate with matrix 3
% for i=4:4
%     for j=1:size(e1.dataset.rawData.( ftNames{i}),1)
%         ftDataNoOffset3(j,:)=calibMat3*(e1.dataset.rawData.( ftNames{i})(j,:)'-offset.( ftNames{i})');
%     end
% end
% % ftDataNoOffset3=removeOffset(reCalibData3,e1.dataset.estimatedFtData.(ftNames{i}));


figure,plot3_matrix(ftDataNoOffset1(:,1:3));hold on;
plot3_matrix(e1.dataset.estimatedFtData.(ftNames{1})(:,1:3)); grid on;
legend('measuredDataNoOffset','estimatedData','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

figure,plot3_matrix(ftDataNoOffset2(:,1:3));hold on;
plot3_matrix(e1.dataset.estimatedFtData.(ftNames{1})(:,1:3)); grid on;
legend('reCalDataE1','estimatedData','Location','west');

title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

% figure,plot3_matrix(ftDataNoOffset3(:,1:3));hold on;
% plot3_matrix(e1.dataset.estimatedFtData.(ftNames{1})(:,1:3)); grid on;
% legend('reCalDataE2','estimatedData','Location','west');
% title('Wrench space');
% xlabel('F_{x}');
% ylabel('F_{y}');
% zlabel('F_{z}');

figure,
plot3_matrix(e1.dataset.estimatedFtData.(ftNames{1})(:,1:3)); grid on;  hold on;
plot3_matrix(ftDataNoOffset1(:,1:3));hold on;
plot3_matrix(ftDataNoOffset2(:,1:3));hold on;
% plot3_matrix(ftDataNoOffset3(:,1:3));hold on;

legend('estimatedData','measuredDataNoOffset','reCalDataE1','reCalDataE2','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

%error calculation

dif1=e1.dataset.estimatedFtData.(ftNames{1})(:,1:3)-ftDataNoOffset1(:,1:3);
dif2=e1.dataset.estimatedFtData.(ftNames{1})(:,1:3)-ftDataNoOffset2(:,1:3);
% dif3=e1.dataset.estimatedFtData.(ftNames{1})(:,1:3)-ftDataNoOffset3(:,1:3);


figure, plot(dif1);
figure, plot(dif2);
% figure, plot(dif3);


sum(sum(abs(dif1)))
sum(sum(abs(dif2)))
% sum(sum(abs(dif3)))


sum(abs(dif1))
sum(abs(dif2))
% sum(abs(dif3))


