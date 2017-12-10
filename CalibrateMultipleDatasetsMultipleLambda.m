%add required folders for use of functions
addpath external/quadfit
addpath utils

% obtain data from all listed experiments
experimentNames={
 'green-iCub-Insitu-Datasets/2017_08_29_2';
 'green-iCub-Insitu-Datasets/2017_08_29_3';% Name of the experiment;
    };
scriptOptions = {};
scriptOptions.forceCalculation=true;%false;
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
lambdasNames=lambdasNames'

calculate=true;
%%
%calibration options
calibOptions.saveMat=false;
calibOptions.usingInsitu=true;
calibOptions.plot=true;
calibOptions.onlyWSpace=true;
calibOptions.IITfirmwareFriendly=true; % in case a calibration matrix that will not be used by iit firmware is estimated

%%
for i=1:length(experimentNames)
    %TODO: create a variable for having extrasample variable for each
    %expermient
    [data.(strcat('e',num2str(i))),data.(strcat('extra',num2str(i)))]=read_estimate_experimentData(experimentNames{i},scriptOptions);
    
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