% serialNumber='SN192';%from iCubGenova05
% sensorName='r_leg_ft_sensor';
serialNumber='SN269';%from iCubGenova05
sensorName='r_foot_ft_sensor';
%Use only datasets where the same sensor is used

% experimentNames={
%   %  'icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_06_17/fast';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_07_04/fast';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45'% Name of the experiment;
%     };%this set is form iCubGenova05
% names2use={'Workbench';
%  %   'Yoga';
%     'Yogapp1st';
%     'fastYogapp';
%     'Yogapp2nd';
%     'fastYogapp2';
%     'gridMin30';
%     'gridMin45'};% except for the first one all others are short names for the expermients in experimentNames
% %toCompareWith='Yogapp2nd'; %choose in which experiment will comparison be made
% 
% comparisonList={%'Yoga';
%     'Yogapp1st';
%     'fastYogapp';
%     'Yogapp2nd';
%     'fastYogapp2';
%     'gridMin30';
%     'gridMin45'
%  };% except for the first one all others are short names for the expermients in experimentNames
% %toCompareWith='Yogapp2nd'; %choose in which experiment will comparison be made
experimentNames={
  %  'icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
    'green-iCub-Insitu-Datasets/2017_08_29_2';% Name of the experiment;
    'green-iCub-Insitu-Datasets/2017_08_29_3';% Name of the experiment;
       };%this set is form iCubGenova05
names2use={'Workbench';
 %   'Yoga';
    'first';
    'second';
    };% except for the first one all others are short names for the expermients in experimentNames
%toCompareWith='Yogapp2nd'; %choose in which experiment will comparison be made

comparisonList={%'Yoga';
    'first';
    'second';
 };% except for the first one all others are short names for the expermients in experimentNames
%toCompareWith='Yogapp2nd'; %choose in which experiment will comparison be made

crossValidation(serialNumber,sensorName,experimentNames,names2use,comparisonList)

