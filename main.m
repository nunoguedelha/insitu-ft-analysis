%% Comparing FT data vs estimated data
% %create input parameter is done through params.m for each experiment

%add required folders for use of functions
addpath external/quadfit
addpath utils
% name and paths of the data files
%     experimentName='icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';% Name of the experiment;
%      experimentName='icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';% Name of the experiment;
  experimentName='icub-insitu-ft-analysis-big-datasets/2016_06_08/extendedYoga';% Name of the experiment;
    experimentName='icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
%   experimentName='icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';% Name of the experiment;
%experimentName='icub-insitu-ft-analysis-big-datasets/2016_05_19/blackBothLegs';% Name of the experiment;
%experimentName='icub-insitu-ft-analysis-big-datasets/2016_04_19/blackUsingOldSensor';% Name of the experiment;
scriptOptions = {};
scriptOptions.forceCalculation=true;%false;
scriptOptions.printPlots=true;%true
scriptOptions.saveData=true;%true
scriptOptions.raw=true;
% Script of the mat file used for save the intermediate results 
scriptOptions.matFileName='ftDataset';

  [dataset]=read_estimate_experimentData(experimentName,scriptOptions);
 % We carry the analysis just for a subset of the sensors
sensorsToAnalize = {'left_leg','right_leg'};

if( scriptOptions.printPlots )
run('plottinScript.m')
end


run('CalibMatCorrection.m')

%