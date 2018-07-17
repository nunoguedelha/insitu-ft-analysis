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
scriptOptions.filterData=true;
scriptOptions.estimateWrenches=true;
scriptOptions.useInertial=false;
scriptOptions.multiSens=true;

% Script of the mat file used for save the intermediate results
scriptOptions.matFileName='ftDataset';

%% name and paths of the experiment files
% change name to desired experiment folder
%experimentName='icub-insitu-ft-analysis-big-datasets/iCubGenova04/exp_1/poleLeftRight';
% experimentName='/green-iCub-Insitu-Datasets/2018_07_05_Grid';
experimentName='/green-iCub-Insitu-Datasets/2018_07_10_Grid';
% experimentName='/green-iCub-Insitu-Datasets/2018_07_10_Grid_warm';


%% We carry the calibration for just a subset of the sensors
% the names are associated to the location of the sensor in the
% in the iCub options are {'left_arm','right_arm','left_leg','right_leg','right_foot','left_foot'};

sensorsToAnalize = {'left_leg','left_foot','right_leg','right_foot'};
%sensorsToAnalize = {'right_leg','left_leg'};

%% Start
%Read data
%[dataset,extraSample]=read_estimate_experimentData(experimentName,scriptOptions);
[dataset,~,input,extraSample]=readExperiment(experimentName,scriptOptions);

% stack extrasamples
[~,~,augmentedDataset,~]=estimateMatricesWthRegExtraSamples2(dataset,sensorsToAnalize,dataset.cMat,0,extraSample);
% create csv folder
if ~exist(strcat('data/',experimentName,'/csvFiles'),'dir')
    mkdir(strcat('data/',experimentName,'/csvFiles'));
end

% create csv files
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    toTable=[augmentedDataset.ftData.(ft),augmentedDataset.temperature.(ft),augmentedDataset.estimatedFtData.(ft)];
    toCSV=array2table(toTable,...
        'VariableNames',{'fx','fy','fz','tx','ty','tz','temperature','ref_fx','ref_fy','ref_fz','ref_tx','ref_ty','ref_tz'});
    writetable(toCSV,strcat('data/',experimentName,'/csvFiles/',ft,'.txt'),'Delimiter',',');
    %csvwrite(strcat('data/',experimentName,'/csvFiles/',ft,'.txt'),toCsv);
    toTable=[augmentedDataset.rawData.(ft),augmentedDataset.temperature.(ft),augmentedDataset.estimatedFtData.(ft)];
    toCSV=array2table(toTable,...
        'VariableNames',{'ch1','ch2','ch3','ch4','ch5','ch6','temperature','ref_fx','ref_fy','ref_fz','ref_tx','ref_ty','ref_tz'});
    writetable(toCSV,strcat('data/',experimentName,'/csvFiles/',ft,'_raw.txt'),'Delimiter',',');
    %csvwrite(strcat('data/',experimentName,'/csvFiles/',ft,'_raw.txt'),toCsv);
end


