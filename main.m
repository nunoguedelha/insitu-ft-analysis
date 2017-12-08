%% Comparing FT data vs estimated data
% %create input parameter is done through params.m for each experiment

%% add required folders for use of functions
addpath external/quadfit
addpath utils

%% general configuration options 
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=false;%true
scriptOptions.saveData=true;%true
scriptOptions.raw=true;% to calculate the raw data, for recalibration always true
scriptOptions.firstTime=true;%when there is no previous calibration matrix
% Script of the mat file used for save the intermediate results
%scriptOptions.saveDataAll=true;
scriptOptions.matFileName='ftDataset';

%% name and paths of the experiment files
%  experimentName='icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45';% Name of the experiment;
experimentName='green-iCub-Insitu-Datasets/2017_12_5_Strain2_3';% 
%experimentName='green-iCub-Insitu-Datasets/2017_12_5_Strain2_rightYoga';%
%experimentName='2017_08_29_2';% 

%% We carry the analysis just for a subset of the sensors
% the names are associated to the location of the sensor in the
% in the iCub

%sensorsToAnalize = {'left_leg','right_leg'};
sensorsToAnalize = {'right_leg'};
%sensorsToAnalize = {'left_leg','right_leg','right_foot','left_foot'};

%% Calibration options
%Regularization parameter
lambda=0;
lambdaName='';

%script options
calibOptions.saveMat=false;
calibOptions.usingInsitu=true;
calibOptions.plot=true;
calibOptions.onlyWSpace=true;
%% Start 
%Read data
[dataset,extraSample]=read_estimate_experimentData2(experimentName,scriptOptions);

%Plot for inspection of data
if( scriptOptions.printPlots )
    run('plottinScript.m')
end

%Calibrate
%temp until change is correctly handled in read experiment data
if(scriptOptions.firstTime)
    dataset.rawData=dataset.filteredFtData;
    extraSample.right.rawData=extraSample.right.filteredFtData;
end
run('CalibMatCorrection.m')

