% obtain data from all listed experiments
experimentNames={
%    'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
%  'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45'% Name of the experiment;
% 'icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
% 'icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';% Name of the experiment;
% 'icub-insitu-ft-analysis-big-datasets/2016_06_17/fast';% Name of the experiment;
% 
% 'icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
% 'icub-insitu-ft-analysis-big-datasets/2016_07_04/fast';% Name of the experiment;
'green-iCub-Insitu-Datasets/2017_08_29_3';% Name of the experiment;
  'green-iCub-Insitu-Datasets/2017_08_29_2';
 
    };
   
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=false;%true
scriptOptions.saveData=true;%
scriptOptions.raw=true;
% Script of the mat file used for save the intermediate results
scriptOptions.saveDataAll=true;
scriptOptions.matFileName='ftDataset';

calculate=false;
%%
%calibration options
calibOptions.saveMat=false;
calibOptions.usingInsitu=true;
calibOptions.plot=true;
calibOptions.onlyWSpace=true;
%%
for i=1:length(experimentNames)
    
    %[data.(strcat('e',num2str(i))),data.(strcat('extra',num2str(i)))]=read_estimate_experimentData(experimentNames{i},scriptOptions);
    [data.(strcat('e',num2str(i))),~,~,data.(strcat('extra',num2str(i)))]=readExperiment(experimentNames{i},scriptOptions);
    
    if(calculate)
        dataset=data.(strcat('e',num2str(i)));
        extraSample=data.(strcat('extra',num2str(i)));
        experimentName=experimentNames{i};
        % We carry the analysis just for a subset of the sensors
        sensorsToAnalize = {'left_leg','right_leg'};
        
        if( scriptOptions.printPlots )
            run('plottinScript.m')
        end
        
        lambda=0;
        lambdaName='';
        
        run('CalibMatCorrection.m')
        clear dataset;
        clear reCalibData;
        clear extraSample;
    end
end