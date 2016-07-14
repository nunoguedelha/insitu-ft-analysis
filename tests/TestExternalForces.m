%  experimentName='icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
%  experimentName='icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
%  experimentName='icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45';% Name of the experiment;



scriptOptions = {};
scriptOptions.testDir=true;% to calculate the raw data, for recalibration always true
scriptOptions.matFileName='ftDataset';
scriptOptions.printAll=true;
% Script of the mat file used for save the intermediate results 
%scriptOptions.saveDataAll=true;
% clear all;
addpath ../utils
addpath ../external/quadfit

%  serialNumber='SN192';%from iCubGenova05
%  sensorName='r_leg_ft_sensor';
%Use only datasets where the same sensor is used
% experimentNames={
%     'icub-insitu-ft-analysis-big-datasets/16_03_2016/leftRightLegsGrid';...% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/21_03_2016/yogaLeft1';...% Name of the experiment;
%     'icub-insitu-ft-analysis-big-datasets/2016_04_21/extendedYoga4StandingOnLeft';...% Name of the experiment;
%     }; %this set is from iCubGenova02
experimentNames={
%    'icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
%    'icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';% Name of the experiment;
%    'icub-insitu-ft-analysis-big-datasets/2016_06_17/fast';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
%    'icub-insitu-ft-analysis-big-datasets/2016_07_04/fast';% Name of the experiment;
%    'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45'% Name of the experiment;
    };%this set is form iCubGenova05
names2use={'Workbench';
%    'Yoga';
%    'Yogapp1st';
%    'fastYogapp';
    'Yogapp2nd';
%    'fastYogapp2';
%    'gridMin30';
    'gridMin45'};% except for the first one all others are short names for the expermients in experimentNames
toCompareWith='Yogapp2nd'; %choose in which experiment will comparison be made, it must have inertial data stored

 % [dataset]=load_measurements_and_cMat(experimentName,scriptOptions)
  
  paramScript=strcat('..//data/',experimentNames{1},'/params.m');
run(paramScript)
  ftNames=input.ftNames;

sensorsToAnalize = {'right_foot','right_leg'};  %load the new calibration matrices
%framesNames={'l_sole','r_sole','l_lower_leg','r_lower_leg','root_link','l_elbow_1','r_elbow_1'};
framesNames={'r_sole','r_lower_leg','root_link'};
for i=1:length(experimentNames)
    paramScript=strcat('..//data/',experimentNames{i},'/params.m');
    run(paramScript)
    [data.(names2use{i+1}),WorkbenchMat]=load_measurements_and_cMat(experimentNames{i},scriptOptions,26);
    for j=1:length(sensorsToAnalize)
        sIndx= find(strcmp(ftNames,sensorsToAnalize{j}));
        cMat.(names2use{i+1}).(sensorsToAnalize{j}) = readCalibMat(strcat('../data/',experimentNames{i},'/calibrationMatrices/',input.calibMatFileNames{sIndx}));
        secMat.(names2use{i+1}).(sensorsToAnalize{j})= cMat.(names2use{i+1}).(sensorsToAnalize{j})/WorkbenchMat.(sensorsToAnalize{j});
        
    end
    
    if(input.hangingInit==1)
        load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'dataset');
        [inertialData.(names2use{i+1})]=dataset.inertial;
    end
    %     timeFrame=[0,30];
    %    [data.(names2use{i+1}).externalForces,data.(names2use{i+1}).eForcesTime]=obtainExternalForces(input.robotName,data.(names2use{i+1}),secMat.(names2use{i+1}),input.sensorNames,input.contactFrameName,timeFrame) ;
end
for j=1:length(sensorsToAnalize)
    
    cMat.(names2use{1}).(sensorsToAnalize{j}) =WorkbenchMat.(sensorsToAnalize{j});
    secMat.(names2use{1}).(sensorsToAnalize{j})=eye(6);
    
end

%% Start comparison

timeFrame=[10,160];%this time is where we will assume that the external force should be 0, will be use to calculate the error of the calibration matrix
for i=1:length(names2use)
      [Offset.(names2use{i}),~]=calculateOffset(sensorsToAnalize,inertialData.(toCompareWith).ftData,inertialData.(toCompareWith).estimatedFtData,WorkbenchMat, cMat.(names2use{i}));
      [tF.(names2use{i}).externalForces,tF.(names2use{i}).eForcesTime]=obtainExternalForces(input.robotName,data.(toCompareWith),secMat.(names2use{i}),input.sensorNames,input.contactFrameName,timeFrame,framesNames,Offset.(names2use{i})) ;
end
for frN=1:length(framesNames)
    if(scriptOptions.printAll)
        for i=1:length(names2use)
            figure,plot3_matrix( tF.(names2use{i}).externalForces.(framesNames{frN})(:,1:3));hold on;
            legend(names2use{i},'Location','west');
            title(strcat('Wrench space on ',toCompareWithWith,' frame ', escapeUnderscores(framesNames{frN})));
            xlabel('F_{x}');
            ylabel('F_{y}');
            zlabel('F_{z}');
              grid on;
        end
          FTplots(struct(strcat(framesNames{frN},'_',names2use{i}),tF.(names2use{i}).externalForces.(framesNames{frN})),tF.(names2use{i}).eForcesTime);
    end
    figure,grid on;
    for i=1:length(names2use)
        plot3_matrix( tF.(names2use{i}).externalForces.(framesNames{frN})(:,1:3));hold on;
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