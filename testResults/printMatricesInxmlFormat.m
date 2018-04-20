scriptOptions = {};
scriptOptions.testDir=true;% to calculate the raw data, for recalibration always true
scriptOptions.matFileName='ftDataset';
scriptOptions.insituVar='reCabDataInsitu';
scriptOptions.printAll=true;
% Script of the mat file used for save the intermediate results
%scriptOptions.saveDataAll=true;
% clear all;
addpath ../utils
addpath ../external/quadfit

%Use only datasets where the same sensor is used
 experimentNames={
'icub-insitu-ft-analysis-big-datasets/2017_12_20_Green_iCub_leftLegFoot/poleGridLeftLeg'; % Name of the experiment;
     }; 
names={'Workbench';
      'newCalibrationMatrix';       
    };% except for the first one all others are short names for the expermients in experimentNames

% %Use only datasets where the same sensor is used
%  experimentNames={
% 'green-iCub-Insitu-Datasets/2017_10_31_3';
%  'green-iCub-Insitu-Datasets/2017_10_31_4'% Name of the experiment;
%      }; %this set is from iCubGenova02
% names={'Workbench';
%       'bestleftleg'; 
%       'bestleftfoot';
%     };% except for the first one all others are short names for the expermients in experimentNames
% % experimentNames={
%     %    'icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_06_17/fast';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_07_04/fast';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45'% Name of the experiment;
%     };%this set is form iCubGenova05

% sequence for creating the names based on the experiment and lambda value
% names={'Workbench';
%     %    'Yoga';
%     'ExtBalancing1';
%     'fastExtBalancing1';
%     'ExtBalancing2';
%     'fastExtBalancing2';
%     'gridMin30';
%     'gridMin45'
%     };% except for the first one all others are short names for the expermients in experimentNames

% lambdasNames={'';
%     '_l_5';
%     '_l1';
%     '_l1_5';
%     '_l2';
%     '_l4';
%     '_l6';
%     '_l8';
%     '_l10'};
%lambdasNames={'' };
% lambdasNames={'';
%     '_l_5';
%     '_l1';
%     '_l2';
%     '_l5';
%     '_l10';
%     '_l30';
%     '_l50';
%     '_l100';
%     '_l1000';
%     '_l1500';
%     '_l2000';
%     '_l3000';
%     '_l4000';
%     '_l10000';
%     '_l100000';
%     };

lambdasNames={''};

names2use{1}=names{1};
num=2;
for i=2:length(names)
    for j=1:length(lambdasNames)
        names2use{num}=(strcat(names{i},lambdasNames{j}));
        num=num+1;
    end
end
names2use=names2use';
paramScript=strcat('../data/',experimentNames{1},'/params.m');
run(paramScript)
ftNames=input.ftNames;

% sensorsToAnalize = {'left_leg','right_leg'};  %load the new calibration matrices
% sensorName={'l_leg_ft_sensor','r_leg_ft_sensor'}; % name of sensor in urdf

sensorsToAnalize = {'left_leg'};  %load the new calibration matrices
sensorName={'l_leg_ft_sensor'}; % name of sensor in urdf

%load the experiment calibration matrices
for i=1:length(experimentNames)
    paramScript=strcat('../data/',experimentNames{i},'/params.m');
    run(paramScript)
    
  
    
    if(scriptOptions.testDir==false)
        prefixDir='';
        
    else
        prefixDir='../';
    end
     for ii=1:size(input.calibMatFileNames,1)
           WorkbenchMat.(ftNames{ii})=getWorkbenchCalibMat(strcat(prefixDir,input.calibMatPath),input.calibMatFileNames{ii});
           
    end
   
    for lam=1:length(lambdasNames)
        (names2use{(i-1)*length(lambdasNames)+1+lam})
        for j=1:length(sensorsToAnalize)
            sIndx= find(strcmp(ftNames,sensorsToAnalize{j}));
            cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j}) = readCalibMat(strcat('../data/',experimentNames{i},'/calibrationMatrices/',input.calibMatFileNames{sIndx},lambdasNames{lam}));
            secMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})= cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})/WorkbenchMat.(sensorsToAnalize{j});
            xmlStr=cMat2xml(secMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j}),sensorName{j})% print in required format to use by WholeBodyDynamics
        end 
    end 
    
end
