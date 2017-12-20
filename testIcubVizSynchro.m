% minimal test for iCubVizAndForcesSynchronized
addpath utils
addpath external/quadfit
%experimentName='2017_10_30';
%experimentName='/green-iCub-Insitu-Datasets/2017_12_7_testYogaWithSensorLeft';% first sample with cable corrected ;
%experimentName='dataSamples/First_Time_Sensor';% 
experimentName='dataSamples/TestYogaExtendedRIght';% 

%% options when loading experiment dataset
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=true;%true
scriptOptions.raw=true;
scriptOptions.saveData=false;
scriptOptions.testDir=false;% to calculate the raw data, for recalibration always true
scriptOptions.filterData=true;
scriptOptions.estimateWrenches=true;
scriptOptions.useInertial=false;    

% Script of the mat file used for save the intermediate results 
%scriptOptions.matFileName='dataEllipsoidAnalysis'; %newName
scriptOptions.matFileName='ftDataset';
%scriptOptions.matFileName='iCubDataset';
 %[dataset]=read_estimate_experimentData(experimentName,scriptOptions);
   [dataset,estimator,input]=readExperiment (experimentName,scriptOptions);
   %withEstim=estimateDynamicsUsingIntervals(dataset,estimator,input,true);
%   mask=dataset.time>dataset.time(1)+input.intervals.rightLeg.initTime & dataset.time<dataset.time(1)+input.intervals.rightLeg.endTime;
%   dataset=applyMask(dataset,mask);
 %  figure,plot(dataset.rawData.right_leg); hold on;
 %  plot(dataset.time-dataset.time(1));
 %  legend 4 5 6 1 2 3 time % the channels are inverted since true channels are like this
   %the saturation message considers the F T notation when calibration is
   %true
% % % load the script of parameters relative 
%  load(strcat('data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset')
  %getRawData(dataset.ftData,pathFile,serialNumbers)
  
  %sensorsToAnalize = {'right_leg'};
  sensorsToAnalize = {'left_leg'};
  
  robotName='iCubGenova04';
  input.robotName='model';
  onTestDir=false;
  visualizeExperiment(dataset,input,sensorsToAnalize,'contactFrame','r_sole')
%  iCubVizWithSlider(dataset,robotName,sensorsToAnalize,'l_sole',onTestDir);
  % iCubVizAndForcesSynchronized(dataset,robotName,sensorsToAnalize,'root_link',100);
  