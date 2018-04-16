%% This script is aimed to be useful for inspecting the data.
%  It will be divided into different parts for the different parts :
% Saturation-> look at raw data, possibly comparing with reference data
% No external force perturbation in grid-> plot wrench space and look for
%    forces out of the ellipsoid expected shape. Only for grid datasets
% Visualize forces vs time -> FTplots, it can help select the intervals

addpath utils
addpath external/quadfit

%experimentName='dataSamples/First_Time_Sensor';%
experimentName='green-iCub-Insitu-Datasets/2018_04_09_left_leg';


%Desired inspection sections
checkSaturation=false;
sphereReference=false;
Force3Dspace=false;
ForceVsTime=true;
PromptForIntervals=true;

%Experiment conditions to know to what compare
%options:
% right_leg_yoga
% left_leg_yoga
% grid
% tz
% random
% contactSwitching
% standUp
% walking
type='right_leg_yoga';
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
%referenceExp.walking=% Collect a walking example
refNames=fieldnames(referenceExp);

%% Read data
scriptOptions = {};
scriptOptions.forceCalculation=true;%false;
if(checkSaturation)
    scriptOptions.raw=true;
end
scriptOptions.saveData=false;
scriptOptions.testDir=false;% to calculate the raw data, for recalibration always true
scriptOptions.filterData=true;
if(strcmp(type,'random'))
    scriptOptions.estimateWrenches=true;
else
    scriptOptions.estimateWrenches=false;
end
scriptOptions.useInertial=false;
% Script of the mat file used for save the intermediate results
scriptOptions.matFileName='iCubDataset';
[dataset,estimator,input,extraSample]=readExperiment (experimentName,scriptOptions);
names=fieldnames(dataset.ftData);
sensorsToAnalize={'right_leg','left_leg'};
%%
if(checkSaturation)
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        if (any(strcmp(ft, refNames)) && strcmp(type,'grid'))
            [reference,estimator,input,extraSample]=readExperiment (referenceExp.(ft),refOptions);
            FTplots(dataset.rawData,dataset.time,reference.ftData,'raw','referenceRaw',reference.time)
        else
            FTplots(dataset.rawData,dataset.time,'raw')
        end
    end
end
%%
if(Force3Dspace)
    %% TODO consider to test if the reference type exist and what to do in case it dont
    [reference,estimator,input,extraSample]=readExperiment (referenceExp.(type),refOptions);
    for ftIdx =1:length(sensorsToAnalize)
        ft = sensorsToAnalize{ftIdx};
        plotNames={'filtered','estimated'};
        force3DPlots(plotNames,ft,dataset.filteredFtData.(ft), reference.estimatedFtData.(ft))
        
        if (sphereReference)
        else
            
            
        end
    end
end
%%
if(ForceVsTime)
    if (length(names)>length(sensorsToAnalize))
        for ftIdx =1:length(sensorsToAnalize)
            ft = sensorsToAnalize{ftIdx};
            toPlot.(ft)=dataset.ftData.(ft);
            toPlotFiltered.(ft)=dataset.filteredFtData.(ft);
        end
    end
    FTplots(toPlot,dataset.time);
    FTplots(toPlotFiltered,dataset.time);
    %%
    if(PromptForIntervals)
        switch type
            case 'right_leg_yoga'
                oneLegSection=find(dataset.filteredFtData.right_leg(:,3)<-200);
                startTime=dataset.time(oneLegSection(1))+1-dataset.time(1);
                endOnelegSection=find(dataset.filteredFtData.right_leg(oneLegSection(1):end,3)>-200);
                endTime=dataset.time(endOnelegSection(1)+oneLegSection(1))-1-dataset.time(1);
                %fprintf('input.intervals.rightLeg=struct(''initTime'',%.4f,''endTime'',%.4f,''contactFrame'',''r_sole'');',startTime,endTime)
                intervalString=sprintf('input.intervals.leftLeg=struct(''initTime'',%.4f,''endTime'',%.4f,''contactFrame'',''l_sole'');',startTime,endTime);
                
            case 'left_leg_yoga'
                oneLegSection=find(dataset.filteredFtData.left_leg(:,3)<-200);
                startTime=dataset.time(oneLegSection(1))+1-dataset.time(1);
                endOnelegSection=find(dataset.filteredFtData.left_leg(oneLegSection(1):end,3)>-200);
                endTime=dataset.time(endOnelegSection(1)+oneLegSection(1))-1-dataset.time(1);
                %fprintf('input.intervals.leftLeg=struct(''initTime'',%.4f,''endTime'',%.4f,''contactFrame'',''l_sole'');',startTime,endTime)
                intervalString=sprintf('input.intervals.leftLeg=struct(''initTime'',%.4f,''endTime'',%.4f,''contactFrame'',''l_sole'');',startTime,endTime);
                
            case 'grid'
                %fprintf('input.intervals.fixed=struct(''initTime'',%.4f,''endTime'',%.4f,''contactFrame'',''r_sole'');',startTime,endTime)
                intervalString=sprintf('input.intervals.fixed=struct(''initTime'',%.4f,''endTime'',%.4f,''contactFrame'',''root_link'');',0,1500);
               
                
        end
        disp(intervalString);
    end
    
    if( checKJointValues)
      nonEmptyIndexes= find(~cellfun(@isempty,dataset.jointNames)) 
       dataset.jointNames.jointNames(nonEmptyIndexes)
        
    end
end