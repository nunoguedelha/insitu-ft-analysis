%test calibration matrices obtained from different datasets
%use from test directory
%load calibration matrices to compare
%original, consider mainly grid datasets
% clear all;
addpath ../utils
addpath ../external/quadfit
serialNumber='SN282';
sensorsToAnalize = {'right_leg'};

e=1; %one for doing comparison on experiment1 data, 2 for experiment
[workbench,fullscale] = readCalibMat(strcat('../data/sensorCalibMatrices/matrix_',serialNumber,'.txt'));

% experiment 1

toCompare='/green-iCub-Insitu-Datasets/2018_04_09_Grid';
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
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

compareExp='/green-iCub-Insitu-Datasets/2018_04_09_Grid_Raw'; % Name of the experiment;

scriptOptions.matFileName='rawDataset';
% load dataset to use as reference
[refDataset,~,~]=readExperiment (compareExp,scriptOptions);

%get raw data or directly load raw data
ftNames=fieldnames(refDataset.ftData);

%obtain offset in the rawdata
% for ftIdx =1:length(sensorsToAnalize)
%     ft = sensorsToAnalize{ftIdx};
%     offset.(ft)=estimateOffsetUsingInSitu(e1.dataset.rawData.(ft), e1.dataset.estimatedFtData.(ft)(:,1:3));
% end

%% compare raw data
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    for j=1:size(dataset.ftData.(ft),1)
        rawCalculated.(ft)(j,:)=(workbench)\(dataset.ftData.(ft)(j,:)');%-offset.(ft)([4,5,6,1,2,3])');
         rawCalculatedFiltered.(ft)(j,:)=(workbench)\(dataset.filteredFtData.(ft)(j,:)');%-offset.(ft)([4,5,6,1,2,3])');
    end
end


reference.(ft)=refDataset.ftData.(ft);

FTplots(rawCalculated,dataset.time,reference,refDataset.time,'byChannel','raw');
FTplots(rawCalculated,dataset.time,reference,refDataset.time,'raw');

    names={'calculatedRawData','referenceRawData'};
force3DPlots(names,(ft),rawCalculated.(ft), refDataset.ftData.(ft)) ;

referenceFiltered.(ft)=refDataset.filteredFtData.(ft);

FTplots(rawCalculatedFiltered,dataset.time,referenceFiltered,refDataset.time,'byChannel','raw');
FTplots(rawCalculatedFiltered,dataset.time,referenceFiltered,refDataset.time,'raw');

ft = 'right_leg';
    names={'calculatedRawData','referenceRawData'};
force3DPlots(names,ft,rawCalculatedFiltered.(ft), referenceFiltered.(ft)) ;

l=min([length(rawCalculatedFiltered.(ft));length(referenceFiltered.(ft))]);
rawDiff=rawCalculatedFiltered.(ft)(1:l,:)-referenceFiltered.(ft)(1:l,:);
rawMeanDiff=mean(abs(rawDiff));
rawMaxDiff=max(abs(rawDiff));

%% compare ft data
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    for j=1:size(refDataset.ftData.(ft),1)
        ftCalculated.(ft)(j,:)=(workbench)*(refDataset.ftData.(ft)(j,:)');%-offset.(ft)([4,5,6,1,2,3])');
        ftCalculatedFiltered.(ft)(j,:)=(workbench)*(refDataset.filteredFtData.(ft)(j,:)');%-offset.(ft)([4,5,6,1,2,3])');
    end
end

ftReference.(ft)=dataset.ftData.(ft);

FTplots(ftCalculated,refDataset.time,ftReference,dataset.time,'bychannel');
FTplots(ftCalculated,refDataset.time,ftReference,dataset.time);

ft = 'right_leg';
    names={'ftCalculated','referenceFtData'};
force3DPlots(names,ft,ftCalculated.(ft), dataset.ftData.(ft)) 

ftReferenceFiltered.(ft)=dataset.filteredFtData.(ft);

FTplots(ftCalculatedFiltered,refDataset.time,ftReferenceFiltered,dataset.time,'bychannel');
FTplots(ftCalculatedFiltered,refDataset.time,ftReferenceFiltered,dataset.time);

ft = 'right_leg';
    names={'ftCalculated','referenceFtData'};
force3DPlots(names,ft,ftCalculatedFiltered.(ft), ftReferenceFiltered.(ft)) 

l=min([length(ftCalculatedFiltered.(ft));length(ftReferenceFiltered.(ft))]);
diff=ftCalculatedFiltered.(ft)(1:l,:)-ftReferenceFiltered.(ft)(1:l,:);
meanDiff=mean(abs(diff));
maxDiff=max(abs(diff));
