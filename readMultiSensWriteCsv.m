%% script to prepare data for non linear fitting
% Here we will read joint enconders, the ft sensors and the temperature values
% then we will generate the reference ft measurements and lastly export to
% csv

addpath external/walkingDatasetScripts
addpath utils

%% general reading configuration options
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.raw=true;
scriptOptions.saveData=true;
scriptOptions.testDir=false;% to calculate the raw data, for recalibration always true
scriptOptions.filterData=false;
scriptOptions.estimateWrenches=true;
scriptOptions.useInertial=false;
scriptOptions.multiSens=true;

% Script of the mat file used for save the intermediate results
scriptOptions.matFileName='ftDataset';

%% name and paths of the experiment files
% change name to desired experiment folder
%experimentName='icub-insitu-ft-analysis-big-datasets/iCubGenova04/exp_1/poleLeftRight';
experimentName='/green-iCub-Insitu-Datasets/dumper_yoga_cold_1';

%% We carry the calibration for just a subset of the sensors
% the names are associated to the location of the sensor in the
% in the iCub options are {'left_arm','right_arm','left_leg','right_leg','right_foot','left_foot'};

%sensorsToAnalize = {'left_leg','left_foot','right_leg','right_foot'};
sensorsToAnalize = {'right_leg','left_leg'};

%% Start
%Read data
%[dataset,extraSample]=read_estimate_experimentData(experimentName,scriptOptions);
[dataset,~,input,extraSample]=readExperiment(experimentName,scriptOptions);
if ~exist(strcat('data/',experimentName,'/csvFiles'),'dir')
    mkdir(strcat('data/',experimentName,'/csvFiles'));
end
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    toCsv=[dataset.ftData.(ft),dataset.temperature.(ft),dataset.estimatedFtData.(ft)];
    csvwrite(strcat('data/',experimentName,'/csvFiles/',ft,'.txt'),toCsv);
end