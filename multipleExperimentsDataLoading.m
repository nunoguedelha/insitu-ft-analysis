% obtain data from all listed experiments
experimentNames={
%    'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
%  'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45'% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
'icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';% Name of the experiment;
'icub-insitu-ft-analysis-big-datasets/2016_06_17/fast';% Name of the experiment;

 'icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
 'icub-insitu-ft-analysis-big-datasets/2016_07_04/fast';% Name of the experiment;
    };
scriptOptions = {};
scriptOptions.forceCalculation=true;%false;
scriptOptions.printPlots=false;%true
scriptOptions.saveData=true;%
scriptOptions.raw=true;
% Script of the mat file used for save the intermediate results
scriptOptions.saveDataAll=true;
scriptOptions.matFileName='ftDataset';

calculate=false;
for i=1:length(experimentNames)
    
    [data.(strcat('e',num2str(i)))]=read_estimate_experimentData(experimentNames{i},scriptOptions);
    
    if(calculate)
        dataset=data.(strcat('e',num2str(i)));
        experimentName=experimentNames{i};
        % We carry the analysis just for a subset of the sensors
        sensorsToAnalize = {'right_leg','right_foot'};
        
        if( scriptOptions.printPlots )
            run('plottinScript.m')
        end
        
        lambda=10;
        lambdaName='';
        
        run('CalibMatCorrection.m')
        clear dataset;
        clear reCalibData;
    end
end