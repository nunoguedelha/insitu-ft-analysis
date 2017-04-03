% minimal test for iCubVizAndForcesSynchronized
addpath /external/quadfit
addpath /utils 
experimentName='icub-insitu-ft-analysis-big-datasets/2017_01_18/GreenRobotTests/Left_leg';

scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=true;%true
scriptOptions.raw=false;
scriptOptions.saveData=true;
% Script of the mat file used for save the intermediate results 
scriptOptions.matFileName='dataEllipsoidAnalysis'; %newName
%scriptOptions.matFileName='datasetEllipsoidAnalys';
% [dataset]=read_estimate_experimentData2(experimentName,scriptOptions);
% % % load the script of parameters relative 
  load(strcat('data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset')
  
  
  sensorsToAnalize = {'left_leg'};
  
  robotName='iCubGenova05';
  
   iCubVizAndForcesSynchronized(dataset,robotName,sensorsToAnalize,'root_link');