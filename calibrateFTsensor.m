clear all
clear all
close all
clc


%% Calibrate a sensor
% This script allows to calibrate six axis force torque (F/T)
% sensors once they are mounted on the robot. This procedure
% takes advantage of the knowledge of the model of the robot
% to generate the expected wrenches of the sensors during
% some arbitrary motions. It then uses this information to train
% and validate new calibration matrices, taking into account
% the calibration matrix obtained with a classical Workbench
% calibration. For more on the theory behind this script, check [1].
% The data from an experiment is typically logged
% using yarpDataDumper directly form statesAndFtSensorsInertial.xml or
% using sensor-calib-inertial [2] and stored in [3] or [4].
% [1] : F. J. A. Chavez, S. Traversaro, D. Pucci and F. Nori,
%       "Model based in situ calibration of six axis force torque sensors,"
%       2016 IEEE-RAS 16th International Conference on Humanoid Robots (Humanoids), Cancun, 2016
% [2] : https://github.com/robotology-playground/sensors-calib-inertial/tree/feature/integrateFTSensors%
% [3] : https://gitlab.com/dynamic-interaction-control/green-iCub-Insitu-Datasets
% [4] : https://gitlab.com/dynamic-interaction-control/icub-insitu-ft-analysis-big-datasets

%% Instructions before running script
% -Log the experiment using statesAndFtSensorsInertial.xml or
% using sensor-calib-inertial
% -Edit a file params.m based on paramsTemplate.m to match the
% characteristics of the experiment and put it in the experiment folder
% -Verify there is a folder named calibrationMatrices inside the experiment
% folder to store resulting calibration matrices
%    ~ Remark: if nothing changed between experiments (logging method,
%    sensor replacement or use of another robot) params.m can be
%    directly copied for another experiment.
% -Select desired options for reading the experiment
% -Change experimentName to desired experiment folder
% -Select desired options of the calibration procedure
% -Run this script

%% adding required dependencies
addpath external/quadfit
addpath external/walkingDatasetScripts
addpath utils

%% general reading configuration options
scriptOptions = {};
scriptOptions.forceCalculation=true;%false;
scriptOptions.printPlots=true;%true
scriptOptions.raw=true;
scriptOptions.saveData=true;
scriptOptions.testDir=false;% to calculate the raw data, for recalibration always true
scriptOptions.filterData=true;
scriptOptions.estimateWrenches=true;
scriptOptions.useInertial=false;
scriptOptions.visualizeExp=true;

% Script of the mat file used for save the intermediate results
scriptOptions.matFileName='ftDataset';

%% name and paths of the experiment files
% change name to desired experiment folder
experimentName='green-iCub-Insitu-Datasets/2018_01_18_poleWalkingLeftRight/poleLeftRight_1';

%% We carry the calibration for just a subset of the sensors
% the names are associated to the location of the sensor in the
% in the iCub options are {'left_arm','right_arm','left_leg','right_leg','right_foot','left_foot'};

sensorsToAnalize = {'left_leg','left_foot','right_leg','right_foot'};
%sensorsToAnalize = {'right_leg'};

%% Calibration options
%Regularization parameter
lambda=0;
lambdaName='';

%calibration script options
calibOptions.saveMat=false;
calibOptions.usingInsitu=true;
calibOptions.plot=true;
calibOptions.onlyWSpace=true;
calibOptions.IITfirmwareFriendly=true; % in case a calibration matrix that will not be used by iit firmware is estimated
%% Start
%Read data
%[dataset,extraSample]=read_estimate_experimentData(experimentName,scriptOptions);
[dataset,~,input,extraSample]=readExperiment(experimentName,scriptOptions);
%Plot for inspection of data
if( scriptOptions.printPlots )
    run('plottinScript.m')
end

if( scriptOptions.visualizeExp )
    robotName='iCubGenova04';
    onTestDir=false;
    visualizeExperiment(dataset,input,sensorsToAnalize,'contactFrame','root_link');
%     iCubVizWithSlider(dataset,robotName,sensorsToAnalize,'l_sole',onTestDir);
%     iCubVizAndForcesSynchronized(dataset,robotName,sensorsToAnalize,'root_link',100);
end

%Calibrate
if ( scriptOptions.calibrate )
    run('CalibMatCorrection.m');
end
