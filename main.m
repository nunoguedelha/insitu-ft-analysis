%% Comparing FT data vs estimated data
% %create input parameter is done through params.m for each experiment

%add required folders for use of functions
addpath external/quadfit
addpath utils
% name and paths of the data files
%   experimentName='icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';% Name of the experiment;
%     experimentName='icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';% Name of the experiment;
%  experimentName='icub-insitu-ft-analysis-big-datasets/2016_05_06';% Name of the experiment;
%   experimentName='icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';% Name of the experiment;
 experimentName='icub-insitu-ft-analysis-big-datasets/2016_05_12/LeftLegTsensor';% Name of the experiment;

scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
scriptOptions.printPlots=true;%true
scriptOptions.saveData=true;%true
scriptOptions.raw=true;
% Script of the mat file used for save the intermediate results 
scriptOptions.matFileName='ftDataset';

  [dataset]=read_estimate_experimentData(experimentName,scriptOptions);
  
  
    ftNames=fieldnames(dataset.ftData);
 
    % compute the offset that minimizes the difference with 
    % the estimated F/T (so if the estimates are wrong, the offset
    % estimated in this way will be totally wrong) 
    
  
%     ftNames=fieldnames(dataset.ftData);
    for i=1:size(ftNames,1)
        [ftDataNoOffset.(ftNames{i}),offset.(ftNames{i})]=removeOffset(dataset.ftData.(ftNames{i}),dataset.estimatedFtData.(ftNames{i}));
    end
    dataset.ftDataNoOffset=ftDataNoOffset;

for i=1:size(ftNames,1)
    [filteredNoOffset.(ftNames{i}),filteredOffset.(ftNames{i})]=removeOffset(dataset.filteredFtData.(ftNames{i}),dataset.estimatedFtData.(ftNames{i}));
end
dataset.filteredNoOffset=filteredNoOffset;
dataset.filteredOffset=filteredOffset;

if( scriptOptions.printPlots )
run('plottinScript.m')
end

run('CalibMatCorrection.m')

%