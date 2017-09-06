%add required folders for use of functions
addpath external/quadfit
addpath utils

% name and paths of the data files
%experimentName='skinTest20170903';% 
experimentName='ihmc2';% 





scriptOptions = {};
scriptOptions.forceCalculation=true;%false;
scriptOptions.printPlots=false;%true
scriptOptions.saveData=true;%true
scriptOptions.raw=true;% to calculate the raw data, for recalibration always true
% Script of the mat file used for save the intermediate results 
%scriptOptions.saveDataAll=true;
scriptOptions.matFileName='iCubDataset';

% read experiment data
[dataset,estimator,input]=readExperiment(experimentName,scriptOptions);
% [dataset]=readExperiment(experimentName,scriptOptions)

% filtered ft data for easy reading 
%         [filteredFtData,mask]=filterFtData(dataset.ftData);
%         
%         dataset=applyMask(dataset,mask);
%         filterd=applyMask(filteredFtData,mask);
%         dataset.filteredFtData=filterd;
        
% estimate external forces