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
'2017_08_29_2';% Name of the experiment;
     }; %this set is from iCubGenova02
names={'Workbench';
      'gridMin30'; 
    };% except for the first one all others are short names for the expermients in experimentNames
% experimentNames={
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
lambdasNames={'';
    '_l_5';
    '_l1';
    '_l2';
    '_l5';
    '_l10';
    '_l30';
    '_l50';
    '_l100';
    '_l1000';
    '_l1500';
    '_l2000';
    '_l3000';
    '_l4000';
    '_l10000';
    '_l100000';
    };

names2use{1}=names{1};
num=2;
for i=2:length(names)
    for j=1:length(lambdasNames)
        names2use{num}=(strcat(names{i},lambdasNames{j}));
        num=num+1;
    end
end
names2use=names2use';
toCompare=2;
toCompareWith='gridMin30'; %choose in which experiment will comparison be made, it must have inertial data stored
ttCompare=2; %should match the position of the toCompareWith name in the names list
paramScript=strcat('..//data/',experimentNames{1},'/params.m');
run(paramScript)
ftNames=input.ftNames;

%sensorsToAnalize2 = {'left_arm';'right_arm';'left_leg';'right_leg';'left_foot';'right_foot'};  %load the new calibration matrices
%sensorsToAnalize = {'right_foot','right_leg'};  %load the new calibration matrices
sensorsToAnalize2 = {'left_leg';'right_leg'};  %load the new calibration matrices
sensorsToAnalize = {'left_leg','right_leg'};  %load the new calibration matrices
framesNames={'l_sole','r_sole','l_lower_leg','r_lower_leg','root_link','l_elbow_1','r_elbow_1'}; %there has to be atleast 6
framesToAnalize={'l_lower_leg','r_lower_leg'};
% framesToAnalize={'r_sole','r_lower_leg'};
%framesToAnalize={'r_lower_leg'};
%load the experiment measurements
sensorName={'l_leg_ft_sensor','r_leg_ft_sensor'};

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
    
    %     if   (exist(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'file')==2)
    %          recabInsitu=load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'));
    %     end
   
    
end
