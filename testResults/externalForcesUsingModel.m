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
% experimentNames={
%     'icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';...% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';...% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';...% Name of the experiment;
%     }; %this set is from iCubGenova02 'icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';
%experimentName=('icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45');%this set is form iCubGenova05
%experimentName=('icub-insitu-ft-analysis-big-datasets/2016_07_04/normal');%this set is form iCubGenova05
experimentName='/green-iCub-Insitu-Datasets/2017_12_5_TestGrid';% first sample with cable corrected ;

names2use={'Estimated';
%    'Yoga';
%    'Yogapp1st';
%    'fastYogapp';
%    'Yogapp2nd';
%    'fastYogapp2';
%    'gridMin30';
    'gridMin45'};% except for the first one all others are short names for the expermients in experimentNames
toCompareWith='gridMin45'; %choose in which experiment will comparison be made, it must have inertial data stored

  paramScript=strcat('../data/',experimentName,'/params.m');
run(paramScript)
  ftNames=input.ftNames;

%sensorsToAnalize = {'right_foot','right_leg'};  %load the new calibration matrices
sensorsToAnalize = {'right_leg'};  %load the new calibration matrices
framesNames={'l_sole','r_sole','l_lower_leg','r_lower_leg','root_link','l_elbow_1','r_elbow_1'};
%framesNames={'r_sole','r_lower_leg','root_link'};
%load the experiment measurements
if(scriptOptions.testDir==false)
    prefixDir='';

else
   prefixDir='../';
end
for i=1:size(input.calibMatFileNames,1)
    Workbench.(ftNames{i})=getWorkbenchCalibMat(strcat(prefixDir,input.calibMatPath),input.calibMatFileNames{i});
    
end

paramScript=strcat('../data/',experimentName,'/params.m');
run(paramScript)
data= load(strcat('../data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset');
i=1;
%load(strcat('../data/',experimentName,'/',scriptOptions.insituVar,'.mat'));
for j=1:length(sensorsToAnalize)
    sIndx= find(strcmp(ftNames,sensorsToAnalize{j}));
    cMat.(names2use{i+1}).(sensorsToAnalize{j}) = readCalibMat(strcat('../data/',experimentName,'/calibrationMatrices/',input.calibMatFileNames{sIndx}));
    secMat.(names2use{i+1}).(sensorsToAnalize{j})= cMat.(names2use{i+1}).(sensorsToAnalize{j})/Workbench.(sensorsToAnalize{j});
    
end
if(input.hangingInit==1)
    load(strcat('../data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset');
    [inertialData]=dataset.inertial;
end
%set worbench calibration matrix information to general format

for j=1:length(sensorsToAnalize)
    
    cMat.(names2use{1}).(sensorsToAnalize{j}) =Workbench.(sensorsToAnalize{j});
    secMat.(names2use{1}).(sensorsToAnalize{j})=eye(6);
    
end

%% Start comparison
%before going on variable cMat from dataset should be eliminated or it will
%give error
timeFrame=[0,60];%this time is where we will assume that the external force should be 0, will be use to calculate the error of the calibration matrix
i=2
%      reCabData.offsetInsitu.(sensorsToAnalize{2})=reCabData.offsetInsitu.(sensorsToAnalize{2})*-1;
%       [tF_general.(names2use{i}).externalForces,tF_general.(names2use{i}).eForcesTime]=obtainExternalForces(input.robotName,data.dataset,secMat.(names2use{i}),input.sensorNames,input.contactFrameName,timeFrame,framesNames,reCabData.offsetInsitu) ;
[Offset.(names2use{i}),~]=calculateOffset(sensorsToAnalize,inertialData.ftData,inertialData.estimatedFtData,Workbench, cMat.(names2use{i}));        
[tF_general.(names2use{i}).externalForces,tF_general.(names2use{i}).eForcesTime]=obtainExternalForces(input.robotName,data.dataset,secMat.(names2use{i}),input.sensorNames,input.contactFrameName,timeFrame,framesNames,Offset.(names2use{i})) ;
      i=1
data.dataset.ftData=data.dataset.estimatedFtData;
%reCabData2=reCabData;
reCabData2.offsetInsitu.(sensorsToAnalize{2})=zeros(6,1);
reCabData2.offsetInsitu.(sensorsToAnalize{i})=zeros(6,1);
      [tF_general.(names2use{i}).externalForces,tF_general.(names2use{i}).eForcesTime]=obtainExternalForces(input.robotName,data.dataset,secMat.(names2use{i}),input.sensorNames,input.contactFrameName,timeFrame,framesNames,reCabData2.offsetInsitu) ;

%re frame the time if desired
% timeFrame=[0,60];
% 
% mask=tF.(names2use{i}).eForcesTime>tF.(names2use{i}).eForcesTime(1)+timeFrame(1) & tF.(names2use{i}).eForcesTime<tF.(names2use{i}).eForcesTime(1)+timeFrame(2);
%         tF=applyMask(tF,mask);
     tF=tF_general;
for frN=1:length(framesNames)-2
    if(scriptOptions.printAll)
        for i=1:length(names2use)
           figure,plot3_matrix( tF.(names2use{i}).externalForces.(framesNames{frN})(:,1:3));hold on;
            %figure,plot3_matrix( tF.(names2use{i}).filtered.(framesNames{frN})(:,1:3));hold on;
            legend(names2use{i},'Location','west');
            title(strcat('Wrench space on ',toCompareWith,' frame ', escapeUnderscores(framesNames{frN})));
            xlabel('F_{x}');
            ylabel('F_{y}');
            zlabel('F_{z}');
              grid on;
                    FTplots(struct(strcat(framesNames{frN},'_',names2use{i}),tF.(names2use{i}).externalForces.(framesNames{frN})),tF.(names2use{i}).eForcesTime);
          %FTplots(struct(strcat(framesNames{frN},'_',names2use{i}),tF.(names2use{i}).filtered.(framesNames{frN})),tF.(names2use{i}).eForcesTime);
        end
         
    end
    figure,grid on;
    for i=1:length(names2use)
        plot3_matrix( tF.(names2use{i}).externalForces.(framesNames{frN})(:,1:3));hold on;
      %   plot3_matrix( tF.(names2use{i}).filtered.(framesNames{frN})(:,1:3));hold on;
    end
    legend(names2use,'Location','west');
    
    title(strcat('Wrench space on ',toCompareWith,{' frame '}, escapeUnderscores(framesNames{frN})));
    xlabel('F_{x}');
    ylabel('F_{y}');
    zlabel('F_{z}');
end
% [filteredsec200,mask]=filterFtData(sec200.(names2use{i+1}).externalForces);
% 
% filterd=applyMask(filteredFtData,mask);
% dataset.filteredFtData=filterd;