clear all
close all
clc
% add required folders for use of functions
addpath external/quadfit
addpath utils

%% read experiment related variables
% obtain data from all listed experiments
experimentNames={
    'icub-insitu-ft-analysis-big-datasets/iCubGenova04/exp_1/poleLeftRight';% Name of the experiment;
    '/green-iCub-Insitu-Datasets/2018_04_09_Grid_2';% Name of the experiment;
    };
% read experiment options
readOptions = {};
readOptions.forceCalculation=false;%false;
readOptions.raw=true;
readOptions.saveData=true;
readOptions.multiSens=true;
readOptions.matFileName='ftDataset'; % name of the mat file used for save the experiment data

readOptions.visualizeExp=false;
readOptions.printPlots=true;%true
%% Calibration related variables options
% Select sensors to calibrate the names are associated to the location of
% the sensor in the robot
% on iCub  {'left_arm','right_arm','left_leg','right_leg','right_foot','left_foot'};
sensorsToAnalize = {'left_leg','right_leg'};
% lambdas=[0;
%     10
%     50;
%     1000;
%     10000;
%     50000;
%     100000;
%     500000;
%     1000000;
%     5000000;
%     10000000];
lambdas=0;
% Create appropiate names for the lambda variables
for namingIndex=1:length(lambdas)
    if (lambdas(namingIndex)==0)
        lambdasNames{namingIndex}='';
    else
        lambdasNames{namingIndex}=strcat('_l',num2str(lambdas(namingIndex)));
    end
end
lambdasNames=lambdasNames';
%calibration options
calculate=true;
calibOptions.saveMat=true;
calibOptions.estimateType=1;%0 only insitu offset, 1 is insitu, 2 is offset on main dataset, 3 is oneshot offset on main dataset, 4 is full oneshot
calibOptions.useTemperature=true;
calibOptions.plotForceSpace=true;
calibOptions.plotForceVsTime=false;
calibOptions.secMatrixFormat=false;
calibOptions.resultEvaluation=false;
%%
for i=1:length(experimentNames)
    [data.(strcat('e',num2str(i))),~,~,data.(strcat('extra',num2str(i)))]=readExperiment(experimentNames{i},readOptions);
    
    if(calculate)
        dataset=data.(strcat('e',num2str(i)));
        extraSample=data.(strcat('extra',num2str(i)));
        experimentName=experimentNames{i};
        
        if( readOptions.printPlots )
            run('plottinScript.m')
        end
        for in=1:length(lambdas)
            lambda=lambdas(in);
            lambdaName=lambdasNames{in};
            calibrateAndCheck
        end
        clear dataset;
        clear reCalibData;
        clear extraSample;
    end
end