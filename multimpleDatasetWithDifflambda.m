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
 '2017_08_29_2';% Name of the experiment;
    };
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=false;%true
scriptOptions.saveData=true;%true
scriptOptions.raw=true;
% Script of the mat file used for save the intermediate results
scriptOptions.matFileName='ftDataset';
lambdas=[0;
    90000000000;
    ];
lambdasNames={'';
    '_l100000';        
    };
% lambdas=[0;
%     0.5;
%     1;
%     2;
%     5;
%     10;
%     30;
%     50;
%     100;
%     1000];
% lambdasNames={'';
%     '_l_5';
%     '_l1';
%     '_l2';
%     '_l5';
%     '_l10';
%     '_l30';
%     '_l50';
%     '_l100';
%     '_l1000'};

calculate=true;
for i=1:length(experimentNames)
    
    [data.(strcat('e',num2str(i)))]=read_estimate_experimentData2(experimentNames{i},scriptOptions);
    
    if(calculate)
        dataset=data.(strcat('e',num2str(i)));
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