%add required folders for use of functions
addpath external/quadfit
addpath utils
% obtain data from all listed experiments

experimentNames={
%     'icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
% 'icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';% Name of the experiment;
% 'icub-insitu-ft-analysis-big-datasets/2016_06_17/fast';% Name of the experiment;
% 'icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
% 'icub-insitu-ft-analysis-big-datasets/2016_07_04/fast';% Name of the experiment;
%   'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
% 'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45'% Name of the experiment;
 '2017_10_31_3';
 '2017_10_31_4';% Name of the experiment;
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
lambdasNames=lambdasNames'

% lambdas=[0;
%     0.5;
%     100;
%     200;
%     500;
%     1000;
%     3000;
%     5000;
%     10000;
%     15000;
%     30000;
%     50000;
%     100000];
% lambdasNames={'';
%     '_l_5';
%     '_l100';
%     '_l200';
%     '_l500';
%     '_l1000';
%     '_l3000';
%     '_l5000';
%     '_l10000';
%     '_l15000';
%     '_l30000';
%     '_l50000';
%     '_l100000';};

calculate=true;
for i=1:length(experimentNames)
    %TODO: create a variable for having extrasample variable for each
    %expermient
    [data.(strcat('e',num2str(i))),data.(strcat('extra',num2str(i)))]=read_estimate_experimentData2(experimentNames{i},scriptOptions);
    
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
    end
end