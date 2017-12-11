%% This script is aimed to be useful for inspecting the data.
%  It will be divided into different parts for the different parts :
% Saturation-> look at raw data, possibly comparing with reference data
% No external force perturbation in grid-> plot wrench space and look for
%    forces out of the ellipsoid expected shape. Only for grid datasets
% Visualize forces vs time -> FTplots, it can help select the intervals

addpath utils
addpath external/quadfit

experimentName='dataSamples/First_Time_Sensor';% 


%Desired inspection sections
checkSaturation=true;
sphereReference=true;
Force3Dspace=true;
ForceVsTime=true;
PromptForIntervals=true;

%Experiment conditions to know to what compare
%options:
% right_leg_yoga
% left_leg_yoga
% grid
% random
% contactSwitching
% standUp
% walking
type='grid';
%% set references
useReference=true;
refOptions = {};
refOptions.forceCalculation=false;%false;
refOptions.saveData=false;
refOptions.testDir=false;% to calculate the raw data, for recalibration always true
refOptions.filterData=true;
refOptions.estimateWrenches=true;
refOptions.useInertial=false;  
refOptions.matFileName='ftDataset';   

% Datasets to be used as reference mainly the estimated part.
referenceExp= {};
referenceExp.right_leg='dataSamples/First_Time_Sensor';% Grid experiment with identity calibration matrix
referenceExp.right_leg_yoga='dataSamples/TestYogaExtendedRight';% Run without feedback
referenceExp.left_leg_yoga='dataSamples/TestYogaExtendedLeft';% Run without feedback
referenceExp.grid='dataSamples/TestGrid';% Should replace this one with a grid on bothlegs
refNames=fieldnames(referenceExp);

%% Read data
scriptOptions = {};
scriptOptions.forceCalculation=false;%false;
if(checkSaturation)
scriptOptions.raw=true;
end
scriptOptions.saveData=false;
scriptOptions.testDir=false;% to calculate the raw data, for recalibration always true
scriptOptions.filterData=true;
if(strcmp(type,'random'))
scriptOptions.estimateWrenches=true;
end
scriptOptions.useInertial=false;    
% Script of the mat file used for save the intermediate results 
scriptOptions.matFileName='iCubDataset';
 [dataset,estimator,input,extraSample]=readExperiment (experimentName,scriptOptions);
 

%%
if(checkSaturation)
    names=fieldnames(dataset.ftData);
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        if (any(strcmp(ft, refNames)) && strcmp(type,'grid'))
            [reference,estimator,input,extraSample]=readExperiment (referenceExp.(ft),refOptions);
            FTplots(dataset.rawData,dataset.time,reference.filteredFtData,'raw','referenceRaw')
        else
            FTplots(dataset.rawData,dataset.time,'raw')
        end
        
    end
end
%%
if(Force3Dspace)
%% TODO consider to test if the reference type exist and what to do in case it dont
[reference,estimator,input,extraSample]=readExperiment (referenceExp.(type),refOptions);
names=fieldnames(dataset.ftData);
for ftIdx =1:length(sensorsToAnalize)
    ft = sensorsToAnalize{ftIdx};
    names={'filtered','estimated'};
    wrenchSpacePlots(names,ft,dataset.ftData.(ft), reference.estimatedFtData.(ft))    
    
    if (sphereReference)
    else
        
        
    end
end
end
%%
if(ForceVsTime)
    
    %%
    if(PromptForIntervals)
    end
end