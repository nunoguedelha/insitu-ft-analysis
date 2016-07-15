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
%     }; %this set is from iCubGenova02

experimentNames={
%    'icub-insitu-ft-analysis-big-datasets/2016_06_08/yoga';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_06_17/normal';% Name of the experiment;
%    'icub-insitu-ft-analysis-big-datasets/2016_06_17/fast';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_07_04/normal';% Name of the experiment;
    'icub-insitu-ft-analysis-big-datasets/2016_07_04/fast';% Name of the experiment;
%    'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin30';% Name of the experiment;
%    'icub-insitu-ft-analysis-big-datasets/2016_07_05/gridMin45'% Name of the experiment;
    };%this set is form iCubGenova05
% names2use={'Workbench';
% %    'Yoga';
%     'Yogapp1st';
% %    'fastYogapp';
% %    'Yogapp2nd';
%     'fastYogapp2';
% %    'gridMin30';
% %    'gridMin45'
% };% except for the first one all others are short names for the expermients in experimentNames
% toCompareWith='Yogapp2nd'; %choose in which experiment will comparison be made, it must have inertial data stored
% 
%   paramScript=strcat('..//data/',experimentNames{1},'/params.m');
% run(paramScript)
%   ftNames=input.ftNames;
% 
% sensorsToAnalize = {'right_foot','right_leg'};  %load the new calibration matrices
% framesNames={'l_sole','r_sole','l_lower_leg','r_lower_leg','root_link','l_elbow_1','r_elbow_1'}; %there has to be atleast 6
% %framesNames={'r_sole','r_lower_leg','root_link'};
% %load the experiment measurements
% 
% for i=1:length(experimentNames)
%     paramScript=strcat('..//data/',experimentNames{i},'/params.m');
%     run(paramScript)
%     [data.(names2use{i+1}),WorkbenchMat]=load_measurements_and_cMat(experimentNames{i},scriptOptions,26);
%     for j=1:length(sensorsToAnalize)
%         sIndx= find(strcmp(ftNames,sensorsToAnalize{j}));
%         cMat.(names2use{i+1}).(sensorsToAnalize{j}) = readCalibMat(strcat('../data/',experimentNames{i},'/calibrationMatrices/',input.calibMatFileNames{sIndx}));
%         secMat.(names2use{i+1}).(sensorsToAnalize{j})= cMat.(names2use{i+1}).(sensorsToAnalize{j})/WorkbenchMat.(sensorsToAnalize{j});
%         
%     end
%     
%     if(input.hangingInit==1)
%         load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'dataset');
%         [inertialData.(names2use{i+1})]=dataset.inertial;
%     end
% %     if   (exist(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'file')==2)
% %          recabInsitu=load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'));
% %     end
%     
% end

% sequence for creating the names based on the experiment and lambda value
names={'Workbench';
%    'Yoga';
    'Yogapp1st';
%    'fastYogapp';
    'Yogapp2nd';
    'fastYogapp2';
%    'gridMin30';
%    'gridMin45'
};% except for the first one all others are short names for the expermients in experimentNames
lambdasNames={'';
    '_l1';
    '_l1_5';
    '_l2';
    '_l4';
    '_l6';
    '_l8';
    '_l10'};

names2use{1}=names{1};
num=2;
for i=2:length(names)
    for j=1:length(lambdasNames)
        names2use{num}=(strcat(names{i},lambdasNames{j}));
        num=num+1;
    end
end
names2use=names2use';
toCompareWith='Yogapp1st'; %choose in which experiment will comparison be made, it must have inertial data stored

  paramScript=strcat('..//data/',experimentNames{1},'/params.m');
run(paramScript)
  ftNames=input.ftNames;

sensorsToAnalize = {'right_foot','right_leg'};  %load the new calibration matrices
framesNames={'l_sole','r_sole','l_lower_leg','r_lower_leg','root_link','l_elbow_1','r_elbow_1'}; %there has to be atleast 6
framesToAnalize={'r_sole','r_lower_leg'};
%load the experiment measurements

for i=1:length(experimentNames)
    paramScript=strcat('../data/',experimentNames{i},'/params.m');
    run(paramScript)
    [data.(names2use{(i-1)*length(lambdasNames)+2}),WorkbenchMat]=load_measurements_and_cMat(experimentNames{i},scriptOptions,26);
    if(input.hangingInit==1)
        load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'dataset');
        [inertialData.(names2use{(i-1)*length(lambdasNames)+2})]=dataset.inertial;
    end
    for lam=1:length(lambdasNames)
        for j=1:length(sensorsToAnalize)
            sIndx= find(strcmp(ftNames,sensorsToAnalize{j}));
            cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j}) = readCalibMat(strcat('../data/',experimentNames{i},'/calibrationMatrices/',input.calibMatFileNames{sIndx},lambdasNames{lam}));
            secMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})= cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})/WorkbenchMat.(sensorsToAnalize{j});
        end
        data.(names2use{(i-1)*length(lambdasNames)+1+lam})=data.(names2use{(i-1)*length(lambdasNames)+2});
        inertialData.(names2use{(i-1)*length(lambdasNames)+1+lam}) =inertialData.(names2use{(i-1)*length(lambdasNames)+2});
    end
    
    %     if   (exist(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'file')==2)
    %          recabInsitu=load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'));
    %     end
    
end
%to compare
toCompare=2;


%set worbench calibration matrix information to general format

for j=1:length(sensorsToAnalize)
    
    cMat.(names2use{1}).(sensorsToAnalize{j}) =WorkbenchMat.(sensorsToAnalize{j});
    secMat.(names2use{1}).(sensorsToAnalize{j})=eye(6);
    
end

%% Start comparison

timeFrame=[0,3];%this time is where we will assume that the external force should be 0, will be use to calculate the error of the calibration matrix
for i=1:length(names2use)
      [Offset.(names2use{i}),~]=calculateOffset(sensorsToAnalize,inertialData.(toCompareWith).ftData,inertialData.(toCompareWith).estimatedFtData,WorkbenchMat, cMat.(names2use{i}));
      [tF_general.(names2use{i}).externalForces,tF_general.(names2use{i}).eForcesTime]=obtainExternalForces(input.robotName,data.(toCompareWith),secMat.(names2use{i}),input.sensorNames,input.contactFrameName,timeFrame,framesNames,Offset.(names2use{i})) ;
end
%filter data
for i=1:length(names2use)
     
   
[filteredFtData.(names2use{i}),mask]=filterFtData(tF_general.(names2use{i}).externalForces);

    tFf.(names2use{i})=applyMask(tF_general.(names2use{i}),mask);
    filteredFtData.(names2use{i})=applyMask(filteredFtData.(names2use{i}),mask);
    tFf.(names2use{i}).filtered= filteredFtData.(names2use{i});
 end

%re frame the time if desired
timeFrame=[0,1];

mask=tFf.(names2use{i}).eForcesTime>tFf.(names2use{i}).eForcesTime(1)+timeFrame(1) & tFf.(names2use{i}).eForcesTime<tFf.(names2use{i}).eForcesTime(1)+timeFrame(2);
tF=applyMask(tFf,mask);
for frN=1:length(framesToAnalize)-1
%     if(scriptOptions.printAll)
%         for i=1:length(names2use)
%             %            % figure,plot3_matrix( tF.(names2use{i}).externalForces.(framesNames{frN})(:,1:3));hold on;
%             %             figure,plot3_matrix( tF.(names2use{i}).filtered.(framesToAnalize{frN})(:,1:3));hold on;
%             %             legend(names2use{i},'Location','west');
%             %             title(strcat('Wrench space on ',toCompareWith,' frame ', escapeUnderscores(framesToAnalize{frN})));
%             %             xlabel('F_{x}');
%             %             ylabel('F_{y}');
%             %             zlabel('F_{z}');
%             %               grid on;
%             %          FTplots(struct(strcat(framesToAnalize{frN},'_',names2use{i}),tF.(names2use{i}).externalForces.(framesToAnalize{frN})),tF.(names2use{i}).eForcesTime);
%             FTplots(struct(strcat(framesToAnalize{frN},'_',names2use{i}),tF.(names2use{i}).filtered.(framesToAnalize{frN})),tF.(names2use{i}).eForcesTime);
%         end
%         
%     end
%     figure,grid on;
%     for i=1:length(names2use)
%         %  plot3_matrix( tF.(names2use{i}).externalForces.(framesToAnalize{frN})(:,1:3));hold on;
%         plot3_matrix( tF.(names2use{i}).filtered.(framesToAnalize{frN})(:,1:3));hold on;
%     end
%     legend(names2use,'Location','west');
%     
%     title(strcat('Wrench space on ',toCompareWith,{' frame '}, escapeUnderscores(framesToAnalize{frN})));
%     xlabel('F_{x}');
%     ylabel('F_{y}');
%     zlabel('F_{z}');
    
    for i=1:length(names2use)
        error.(framesToAnalize{frN})(toCompare-1,i)=mean(mean(abs(tF.(names2use{i}).filtered.(framesToAnalize{frN}))));
        errorXaxis.(framesToAnalize{frN})(toCompare-1,i,:)=mean(abs(tF.(names2use{i}).filtered.(framesToAnalize{frN})));
    end
    
    [minErrall,minIndall]=min(error.(framesToAnalize{frN}));
     fprintf('The calibration matrix with least error among all datasets is from %s , with a total of %d percentage on average \n',names2use{minIndall}, minErrall);
 sCalibMat.(sensorsToAnalize{frN})=cMat.(names2use{minIndall}).(sensorsToAnalize{frN})/(cMat.Workbench.(sensorsToAnalize{frN}));%calculate secondary calibration matrix 
 %xmlStr=cMat2xml(sCalibMat.(sensorsToAnalize{frN}),sensorName);% print in required format to use by WholeBodyDynamics
 bestCMat.(sensorsToAnalize{frN})=cMat.(names2use{minIndall}).(sensorsToAnalize{frN});
 bestName.(sensorsToAnalize{frN})=names2use{minIndall};
    axisName={'fx','fy','fz','tx','ty','tz'};
 for axis=1:6
      totalerrorXaxis=errorXaxis.(framesToAnalize{frN})(:,:,axis);
      
     [minErr,minInd]=min(totalerrorXaxis);
     fprintf('The calibration matrix with least error on %s among all datasets is from %s , with a total of %d percentage on average \n',axisName{axis},names2use{minInd}, minErr);
     frankieMatrix(axis,:)=cMat.(names2use{minInd}).(sensorsToAnalize{frN})(axis,:);
     frankieData.(framesToAnalize{frN})(:,axis)=tF.(names2use{minInd}).filtered.(framesToAnalize{frN})(:,axis);
 end
    
 %plot the best ones
   
                      figure,plot3_matrix( tF.(names2use{1}).filtered.(framesToAnalize{frN})(:,1:3));hold on;
                        figure,plot3_matrix( tF.(names2use{minIndall}).filtered.(framesToAnalize{frN})(:,1:3));hold on;
                        figure,plot3_matrix( frankieData.(framesToAnalize{frN})(:,1:3));hold on;
                        legend(['workbench','best','frankie'],'Location','west');
                        title(strcat('Wrench space on ',toCompareWith,' frame ', escapeUnderscores(framesToAnalize{frN})));
                        xlabel('F_{x}');
                        ylabel('F_{y}');
                        zlabel('F_{z}');
                          grid on;
                    
          
       FTplotsWithOption(struct(strcat(framesToAnalize{frN},'_',names2use{1}),tF.(names2use{1}).filtered.(framesToAnalize{frN}),strcat('best','_',names2use{minIndall}), tF.(names2use{minIndall}).filtered.(framesToAnalize{frN})),tF.(names2use{1}).eForcesTime,true);
 FTplotsWithOption(struct(strcat(framesToAnalize{frN},'_',names2use{1}),tF.(names2use{1}).filtered.(framesToAnalize{frN}),strcat('frankie'), frankieData.(framesToAnalize{frN})),tF.(names2use{1}).eForcesTime,true);
  FTplotsWithOption(struct(strcat(framesToAnalize{frN},'_',names2use{minIndall}),tF.(names2use{minIndall}).filtered.(framesToAnalize{frN}),strcat('frankie'), frankieData.(framesToAnalize{frN})),tF.(names2use{1}).eForcesTime,true);

end
% [filteredsec200,mask]=filterFtData(sec200.(names2use{i+1}).externalForces);
%
% filterd=applyMask(filteredFtData,mask);
% dataset.filteredFtData=filterd;