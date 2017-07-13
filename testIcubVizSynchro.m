% minimal test for iCubVizAndForcesSynchronized
addpath /external/quadfit
addpath /utils 
experimentName='icub-insitu-ft-analysis-big-datasets/2017_06_14';% Name of the experiment;

scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=true;%true
scriptOptions.raw=false;
scriptOptions.saveData=true;
% Script of the mat file used for save the intermediate results 
%scriptOptions.matFileName='dataEllipsoidAnalysis'; %newName
scriptOptions.matFileName='datasetEllipsoidAnalys';
% [dataset]=read_estimate_experimentData2(experimentName,scriptOptions);
% % % load the script of parameters relative 
  load(strcat('data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset')
  
  
  sensorsToAnalize = {'left_arm'};
  
  robotName='iCubGenova05';
  
   iCubVizAndForcesSynchronized(dataset,robotName,sensorsToAnalize,'root_link');
   
%    for i=1:length(view2)
%        view(-37.5,view2(i));
%        drawnow;
%        pause(.01);
%     end