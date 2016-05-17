% obtain data from all listed experiments
experimentNames={
       'icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';...% Name of the experiment;
'icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';...% Name of the experiment;
'icub-insitu-ft-analysis-big-datasets/2016_05_06';...% Name of the experiment;
'icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';...% Name of the experiment;
'icub-insitu-ft-analysis-big-datasets/2016_05_12/LeftLegTsensor'% Name of the experiment;
};
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=true;%true
scriptOptions.saveData=true;%true
scriptOptions.raw=true;
% Script of the mat file used for save the intermediate results 
scriptOptions.matFileName='ftDataset';

  
for i=1:length(experimentNames)
    
    [data.(strcat('e',num2str(i)))]=read_estimate_experimentData(experimentNames{i},scriptOptions);
    
end