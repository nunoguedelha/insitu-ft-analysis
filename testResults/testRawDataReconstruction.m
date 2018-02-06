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

toCompare='/green-iCub-Insitu-Datasets/2017_10_31_4';
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=true;%true
scriptOptions.raw=false;
scriptOptions.saveData=true;
scriptOptions.testDir=true;% to calculate the raw data, for recalibration always true
scriptOptions.filterData=true;
scriptOptions.estimateWrenches=false;
scriptOptions.useInertial=false;    
% Script of the mat file used for save the intermediate results
%scriptOptions.matFileName='dataEllipsoidAnalysis'; %newName
scriptOptions.matFileName='rawDataset';
%[dataset,~,~]=read_estimate_experimentData(experimentName,scriptOptions);
[dataset,~,~]=readExperiment (toCompare,scriptOptions);

compareExp='icub-insitu-ft-analysis-big-datasets/2017_12_20_Green_iCub_leftLegFoot/validatePoleGridLeftLeg'; % Name of the experiment;

scriptOptions.matFileName='ftDataset';
% load dataset to use as reference
[refDataset,~,~]=readExperiment (compareExp,scriptOptions);

%get raw data or directly load raw data
ftNames=fieldnames(refDataset.ftData);

%obtain offset in the rawdata
% for ftIdx =1:length(sensorsToAnalize)
%     ft = sensorsToAnalize{ftIdx};
%     offset.(ft)=estimateOffsetUsingInSitu(e1.dataset.rawData.(ft), e1.dataset.estimatedFtData.(ft)(:,1:3));
% end
%recalibrate with matrix 1 experiment1

for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    for j=1:size(dataset.ftData.(ft),1)
        rawCalculated.(ft)(j,:)=(workbench)\(dataset.ftData.(ft)(j,:)');%-offset.(ft)([4,5,6,1,2,3])');
    end
end

%remove offset
% ftDataNoOffset1=removeOffset(reCalibData1,e1.dataset.estimatedFtData.(ftNames{i}));



FTplots(rawCalculated,dataset.time,'raw');


FTplots(refDataset.ftData,refDataset.time,'raw');

figure,plot3_matrix(rawCalculated.(ft)(:,1:3));hold on;
plot3_matrix(refDataset.rawData.(ft)(:,1:3)); grid on;  hold on;


legend('normal','reference','Location','west');
title('Force 3D space');
xlabel('F_{x}');
ylabel('F_{y}');
zlabel('F_{z}');

