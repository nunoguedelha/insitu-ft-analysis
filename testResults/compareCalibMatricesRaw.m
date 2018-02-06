%test calibration matrices obtained from different datasets
%use from test directory
%load calibration matrices to compare
%original, consider mainly grid datasets
% clear all;
addpath ../utils
addpath ../external/quadfit
serialNumber='SN163';
sensorsToAnalize = {'left_leg'};

e=1; %one for doing comparison on experiment1 data, 2 for experiment
[workbench,fullscale] = readCalibMat(strcat('../data/sensorCalibMatrices/matrix_',serialNumber,'.txt'));

% experiment 1
compareExp='icub-insitu-ft-analysis-big-datasets/2017_12_20_Green_iCub_leftLegFoot/validatePoleGridLeftLeg'; % Name of the experiment;

toCompare='icub-insitu-ft-analysis-big-datasets/2017_12_20_Green_iCub_leftLegFoot/poleGridLeftLeg';
[calibMat,fullscale] = readCalibMat(strcat('../data/',toCompare,'/calibrationMatrices/',serialNumber));



%simple comparison among matrices (some similarity index)
diff=workbench-calibMat;
totalDiff=sum(sum(diff))
diagDif=diag(diff)

% load dataset in which the 3 calibration matrices will be tested
if (exist(strcat('../data/',compareExp,'/ftDataset.mat'),'file')==2)
    %% Load from workspace
    %     %load meaninful data, estimated data, meaninful data no offset
    e1=load(strcat('../data/',compareExp,'/ftDataset.mat'),'dataset');
end

%get raw data or directly load raw data
ftNames=fieldnames(e1.dataset.ftData);

%obtain offset in the rawdata
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    offset.(ft)=estimateOffsetUsingInSitu(e1.dataset.rawData.(ft), e1.dataset.estimatedFtData.(ft)(:,1:3));
end
%recalibrate with matrix 1 experiment1


for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    for j=1:size(e1.dataset.rawData.(ft),1)
        ftDataNoOffset1(j,:)=workbench*(e1.dataset.ftData.(ft)(j,:)'-offset.(ft)');
    end
end

%remove offset
% ftDataNoOffset1=removeOffset(reCalibData1,e1.dataset.estimatedFtData.(ftNames{i}));

% recalibrate with matrix 2
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    for j=1:size(e1.dataset.rawData.( ft),1)
        ftDataNoOffset2(j,:)=calibMat*(e1.dataset.rawData.(ft)(j,:)'-offset.( ft)');
    end
end
% ftDataNoOffset2=removeOffset(reCalibData2,e1.dataset.estimatedFtData.(ftNames{i}));


figure,plot3_matrix(ftDataNoOffset1(:,1:3));hold on;
plot3_matrix(e1.dataset.estimatedFtData.(ft)(:,1:3)); grid on;
legend('measuredDataNoOffset','estimatedData','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

figure,plot3_matrix(ftDataNoOffset2(:,1:3));hold on;
plot3_matrix(e1.dataset.estimatedFtData.(ft)(:,1:3)); grid on;
legend('reCalDataE1','estimatedData','Location','west');

title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

figure,plot3_matrix(ftDataNoOffset1(:,1:3));hold on;
plot3_matrix(e1.dataset.estimatedFtData.(ft)(:,1:3)); grid on;  hold on;
plot3_matrix(ftDataNoOffset2(:,1:3));hold on;


legend('measuredDataNoOffset','estimatedData','reCalDataE1','Location','west');
title('Wrench space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

%error calculation

dif1=e1.dataset.estimatedFtData.(ft)(:,1:3)-ftDataNoOffset1(:,1:3);
dif2=e1.dataset.estimatedFtData.(ft)(:,1:3)-ftDataNoOffset2(:,1:3);


figure, plot(dif1);
figure, plot(dif2);


sum(sum(abs(dif1)))
sum(sum(abs(dif2)))


sum(abs(dif1))
sum(abs(dif2))
