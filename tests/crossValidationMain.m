% serialNumber='SN192';%from iCubGenova05
% sensorName='r_leg_ft_sensor';
serialNumber='SN191';%from iCubGenova05
sensorName='r_foot_ft_sensor';
%Use only datasets where the same sensor is used
% experimentNames={
%     'icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';...% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';...% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';...% Name of the experiment;
%     }; %this set is from iCubGenova02
experimentNames={
  %  'icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_06_17/fast';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_07_04/fast';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45'% Name of the experiment;
    };%this set is form iCubGenova05
names2use={'Workbench';
 %   'Yoga';
    'Yogapp1st';
    'fastYogapp';
    'Yogapp2nd';
    'fastYogapp2';
    'gridMin30';
    'gridMin45'};% except for the first one all others are short names for the expermients in experimentNames
%toCompareWith='Yogapp2nd'; %choose in which experiment will comparison be made

comparisonList={%'Yoga';
    'Yogapp1st';
    'fastYogapp';
    'Yogapp2nd';
    'fastYogapp2';
    'gridMin30';
    'gridMin45'
 };% except for the first one all others are short names for the expermients in experimentNames
%toCompareWith='Yogapp2nd'; %choose in which experiment will comparison be made

crossValidation(serialNumber,sensorName,experimentNames,names2use,comparisonList)

