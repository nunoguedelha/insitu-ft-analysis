% minimal test for iCubVizAndForcesSynchronized
addpath /external/quadfit
addpath /utils 
%experimentName='2017_10_30';
experimentName='leftYoga';

scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=true;%true
scriptOptions.raw=false;
scriptOptions.saveData=true;
% Script of the mat file used for save the intermediate results 
%scriptOptions.matFileName='dataEllipsoidAnalysis'; %newName
%scriptOptions.matFileName='ftDataset';
scriptOptions.matFileName='iCubDataset';
% [dataset]=read_estimate_experimentData2(experimentName,scriptOptions);
% % % load the script of parameters relative 
  load(strcat('data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset')
  
  
  sensorsToAnalize = {'left_leg'};
  
  robotName='iCubGenova04';
  onTestDir=false;
  iCubVizWithSlider(dataset,robotName,sensorsToAnalize,'l_sole',onTestDir);
  % iCubVizAndForcesSynchronized(dataset,robotName,sensorsToAnalize,'root_link',100);
   
%    for i=1:length(view2)
%        view(-37.5,view2(i));
%        drawnow;
%        pause(.01);
%     end

%Think of a function that uses the slider to get the time sample that wants
%to be evaulated send this to a one time position and plot of forces
%example slider. Consider rounding the value of the slider to get only
%integers or find an alternate solution
%b = uicontrol('Parent',f,'Style','slider','Position',[81,54,419,23],...
%              'value',1, 'min',1, 'max',dataset.time(end)-dataset.time(1);