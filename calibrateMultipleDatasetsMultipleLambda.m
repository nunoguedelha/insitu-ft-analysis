clear all
close all
clc

%%

%add required folders for use of functions
addpath external/quadfit
addpath utils

% obtain data from all listed experiments
experimentNames={
 'icub-insitu-ft-analysis-big-datasets/iCubGenova04/exp_1/poleLeftRight';% Name of the experiment;
 '/green-iCub-Insitu-Datasets/2018_04_09_Grid_2';% Name of the experiment;
    };
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=false;%true
scriptOptions.saveData=true;%true
scriptOptions.raw=true;
% Script of the mat file used for save the intermediate results
scriptOptions.matFileName='ftDataset';
lambdas=[0;
    10
    50;
    1000;
    10000;
    50000;
    100000;
    500000;
    1000000;
    5000000;
    10000000];

% Create appropiate names for the lambda variables
for namingIndex=1:length(lambdas)
    if (lambdas(namingIndex)==0)
        lambdasNames{namingIndex}='';
    else
    lambdasNames{namingIndex}=strcat('_l',num2str(lambdas(namingIndex)));
    end
end
lambdasNames=lambdasNames';

calculate=true;
%%
%calibration options
calibOptions.saveMat=true;
calibOptions.usingInsitu=true;
calibOptions.plot=true;
calibOptions.onlyWSpace=true;
%%
for i=1:length(experimentNames)    
    [data.(strcat('e',num2str(i))),~,~,data.(strcat('extra',num2str(i)))]=readExperiment(experimentNames{i},scriptOptions);
    
    if(calculate)
        dataset=data.(strcat('e',num2str(i)));
        extraSample=data.(strcat('extra',num2str(i)));
        experimentName=experimentNames{i};
        % We carry the analysis just for a subset of the sensors
         sensorsToAnalize = {'left_leg','right_leg'};% {'right_leg','right_foot'};
        %sensorsToAnalize = {'right_leg'};
        if( scriptOptions.printPlots )
            run('plottinScript.m')
        end
        for in=1:length(lambdas)
            lambda=lambdas(in);
            lambdaName=lambdasNames{in};
            run('CalibMatCorrection.m')
            
        end
        clear dataset;
        clear reCalibData;
        clear extraSample;
    end
end