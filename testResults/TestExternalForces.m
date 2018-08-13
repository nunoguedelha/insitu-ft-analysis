scriptOptions = {};
scriptOptions.testDir=true;% to calculate the raw data, for recalibration always true
scriptOptions.raw=true;
scriptOptions.matFileName='ftDataset';
% scriptOptions.multiSens=false;
scriptOptions.insituVar='reCabDataInsitu';
scriptOptions.printAll=true;
% Script of the mat file used for save the intermediate results
%scriptOptions.saveDataAll=true;
% clear all;
addpath ../utils
addpath ../external/quadfit

%Use only datasets where the same sensor is used
 experimentNames={
'green-iCub-Insitu-Datasets/2017_08_29_2';% Name of the experiment;
'green-iCub-Insitu-Datasets/2017_12_7_TestYogaExtendedRIght';
     }; %this set is from iCubGenova02
names={'Workbench';
      'gridMin30';
      'rightYoga';
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
% lambdasNames={'';
%     '_l_5';
%     '_l1';
%     '_l2';
%     '_l5';
%     '_l10';
%     '_l30';
%     '_l50';
%     '_l100';
%     '_l1000'
%     };
lambdasNames={'';    
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
%to compare
toCompare=2;
toCompareWith='rightYoga'; %choose in which experiment will comparison be made, it must have inertial data stored
ttCompare=3; %should match the position of the toCompareWith name in the names list
paramScript=strcat('../data/',experimentNames{1},'/params.m');
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
sensorName='r_leg_ft_sensor';

for i=1:length(experimentNames)
    clear input;
    paramScript=strcat('../data/',experimentNames{i},'/params.m');
    run(paramScript)
    if (i==ttCompare-1)
        inputToCompare=input;
    end
    [data.(names2use{(i-1)*length(lambdasNames)+2}),WorkbenchMat]=readExperiment(experimentNames{i},scriptOptions);
    WorkbenchMat=data.(names2use{(i-1)*length(lambdasNames)+2}).cMat;
    data.(names2use{(i-1)*length(lambdasNames)+2})=dataSampling(data.(names2use{(i-1)*length(lambdasNames)+2}),10);
   if (any(strcmp('hangingInit', fieldnames(input))))
    if(input.hangingInit==1)
        load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'dataset');
        [inertialData.(names2use{(i-1)*length(lambdasNames)+2})]=dataset.inertial;
    end
   end
    for lam=1:length(lambdasNames)
        for j=1:length(sensorsToAnalize)
            sIndx= find(strcmp(ftNames,sensorsToAnalize{j}));
            cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j}) = readCalibMat(strcat('../data/',experimentNames{i},'/calibrationMatrices/',input.calibMatFileNames{sIndx},lambdasNames{lam}));
            secMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})= cMat.(names2use{(i-1)*length(lambdasNames)+1+lam}).(sensorsToAnalize{j})/WorkbenchMat.(sensorsToAnalize{j});
        end
        data.(names2use{(i-1)*length(lambdasNames)+1+lam})=data.(names2use{(i-1)*length(lambdasNames)+2});
       if (any(strcmp('hangingInit', fieldnames(input))))
        if(input.hangingInit==1)
            inertialData.(names2use{(i-1)*length(lambdasNames)+1+lam}) =inertialData.(names2use{(i-1)*length(lambdasNames)+2});
        end
       end
    end
    
    %     if   (exist(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'),'file')==2)
    %          recabInsitu=load(strcat('../data/',experimentNames{i},'/',scriptOptions.matFileName,'.mat'));
    %     end
    
end

input=inputToCompare;


%% Create contactFrame vector
contactFrame(1:length(data.(toCompareWith).time))={''};
contactFrame=contactFrame';
noInertial=false;
if (any(strcmp('intervals', fieldnames(input))))
    intervalsNames=fieldnames(input.intervals);
    if (~any(strcmp('hanging', intervalsNames)))
        noInertial=true; 
    end
    for index=1:length(intervalsNames)
        
        intName=intervalsNames{index};
        mask=data.(toCompareWith).time>=data.(toCompareWith).time(1)+input.intervals.(intName).initTime & data.(toCompareWith).time<=data.(toCompareWith).time(1)+input.intervals.(intName).endTime;
        contactFrame(mask)={input.intervals.(intName).contactFrame};
        
        
    end
    if (length(intervalsNames)==1 && ~any(strcmp('hanging', intervalsNames)))
        
    else
        if (input.intervals.leftLeg.initTime<input.intervals.rightLeg.initTime)
            mask=data.(toCompareWith).time>=data.(toCompareWith).time(1)+input.intervals.hanging.endTime & data.(toCompareWith).time<=data.(toCompareWith).time(1)+input.intervals.leftLeg.initTime;
            contactFrame(mask)={input.intervals.leftLeg.contactFrame};
            t2=(input.intervals.rightLeg.initTime-input.intervals.leftLeg.endTime)/2+input.intervals.leftLeg.endTime;
            mask=data.(toCompareWith).time>=data.(toCompareWith).time(1)+input.intervals.leftLeg.endTime & data.(toCompareWith).time<=data.(toCompareWith).time(1)+t2;
            contactFrame(mask)={input.intervals.leftLeg.contactFrame};
            mask=data.(toCompareWith).time>=data.(toCompareWith).time(1)+t2 & data.(toCompareWith).time<=data.(toCompareWith).time(1)+input.intervals.rightLeg.initTime;
            contactFrame(mask)={input.intervals.rightLeg.contactFrame};
            mask=data.(toCompareWith).time>=data.(toCompareWith).time(1)+input.intervals.rightLeg.endTime;
            contactFrame(mask)={input.intervals.rightLeg.contactFrame};
        else
            mask=data.(toCompareWith).time>=data.(toCompareWith).time(1)+input.intervals.hanging.endTime & data.(toCompareWith).time<=data.(toCompareWith).time(1)+input.intervals.rightLeg.initTime;
            contactFrame(mask)={input.intervals.rightLeg.contactFrame};
            t2=(input.intervals.leftLeg.initTime-input.intervals.rightLeg.endTime)/2+input.intervals.rightLeg.endTime;
            mask=data.(toCompareWith).time>=data.(toCompareWith).time(1)+input.intervals.rightLeg.endTime & data.(toCompareWith).time<=data.(toCompareWith).time(1)+t2;
            contactFrame(mask)={input.intervals.rightLeg.contactFrame};
            mask=data.(toCompareWith).time>=data.(toCompareWith).time(1)+t2 & data.(toCompareWith).time<=data.(toCompareWith).time(1)+input.intervals.leftLeg.initTime;
            contactFrame(mask)={input.intervals.leftLeg.contactFrame};
            mask=data.(toCompareWith).time>=data.(toCompareWith).time(1)+input.intervals.leftLeg.endTime;
            contactFrame(mask)={input.intervals.leftLeg.contactFrame};
        end
    end
else
    contactFrame(1:length(data.(toCompareWith).time))=input.contactFrameName;
    if (~any(strcmp('hangingInit', fieldnames(input))))
         noInertial=true; 
    else
    if (input.hangingInit==0)
       noInertial=true; 
    end
    end
end

%% Start comparison
%set worbench calibration matrix information to general format

for j=1:length(sensorsToAnalize)
    
    cMat.(names2use{1}).(sensorsToAnalize{j}) =WorkbenchMat.(sensorsToAnalize{j});
    secMat.(names2use{1}).(sensorsToAnalize{j})=eye(6);
    
    %end
    
    
    timeFrame=[0,300];%this time is where we will assume that the external force should be 0, will be use to calculate the error of the calibration matrix
    for i=1:length(names2use)
        calMat.(names2use{i})=WorkbenchMat;
        % for j=1:length(sensorsToAnalize)
        
        calMat.(names2use{i}).(sensorsToAnalize{j}) =cMat.(names2use{i}).(sensorsToAnalize{j});
        sMat.(sensorsToAnalize{j})=secMat.(names2use{i}).(sensorsToAnalize{j});
        
        % end
        %% TODO: fill the offset with the values of the comparison set when not available in the temp dataset.
        if noInertial
            load(strcat('../data/',experimentNames{1},'/',scriptOptions.matFileName,'.mat'),'dataset');
            datatemp=dataSampling(dataset,100);
            [Offset.(names2use{i}),~]=calculateOffset(sensorsToAnalize2,datatemp.ftData,datatemp.estimatedFtData,WorkbenchMat, calMat.(names2use{i}));
    
        else
       %       [Offset.(names2use{i}),~]=calculateOffset(sensorsToAnalize,inertialData.(toCompareWith).ftData,inertialData.(toCompareWith).estimatedFtData,WorkbenchMat, cMat.(names2use{i}));
        [Offset.(names2use{i}),~]=calculateOffset(sensorsToAnalize2,inertialData.(toCompareWith).ftData,inertialData.(toCompareWith).estimatedFtData,WorkbenchMat, calMat.(names2use{i}));
        end
        cd ..
        [tF_general.(names2use{i}).externalForces,tF_general.(names2use{i}).eForcesTime]=obtainExternalForces(input.robotName,data.(toCompareWith),sMat,input.sensorNames,contactFrame,timeFrame,framesNames,Offset.(names2use{i})) ;
        cd testResults/
        clear sMat;
    end
    %filter data
    for i=1:length(names2use)
        
        fprintf('Filtering %s \n',names2use{i});
        [filteredFtData.(names2use{i}),mask]=filterFtData(tF_general.(names2use{i}).externalForces);
        
        tFf.(names2use{i})=applyMask(tF_general.(names2use{i}),mask);
        filteredFtData.(names2use{i})=applyMask(filteredFtData.(names2use{i}),mask);
        tFf.(names2use{i}).filtered= filteredFtData.(names2use{i});
    end
    
    %re frame the time if desired
    timeFrame=[0,290];
    
    mask=tFf.(names2use{i}).eForcesTime>tFf.(names2use{i}).eForcesTime(1)+timeFrame(1) & tFf.(names2use{i}).eForcesTime<tFf.(names2use{i}).eForcesTime(1)+timeFrame(2);
    tF=applyMask(tFf,mask);
    for frN=1:length(framesToAnalize)
        
        
        for i=1:length(names2use)
            error.(sensorsToAnalize{j}).(framesToAnalize{frN})(toCompare-1,i)=norm(mean(abs(tF.(names2use{i}).filtered.(framesToAnalize{frN})(:,1:3))));
            errorXaxis.(sensorsToAnalize{j}).(framesToAnalize{frN})(toCompare-1,i,:)=mean(abs(tF.(names2use{i}).filtered.(framesToAnalize{frN})));
        end
        
        [minErrall,minIndall]=min(error.(sensorsToAnalize{j}).(framesToAnalize{frN}));
        fprintf('The calibration matrix with least error among all datasets is from %s , with a total of %d percentage on average \n',names2use{minIndall}, minErrall);
        sCalibMat.(sensorsToAnalize{j})=cMat.(names2use{minIndall}).(sensorsToAnalize{j})/(cMat.Workbench.(sensorsToAnalize{j}));%calculate secondary calibration matrix
        bestCMat.(sensorsToAnalize{j})=cMat.(names2use{minIndall}).(sensorsToAnalize{j});
        bestName.(sensorsToAnalize{j})=names2use{minIndall};
        xmlStr=cMat2xml(sCalibMat.(sensorsToAnalize{j}),sensorName);% print in required format to use by WholeBodyDynamics
        
        axisName={'fx','fy','fz','tx','ty','tz'};
        for axis=1:6
            totalerrorXaxis=errorXaxis.(sensorsToAnalize{j}).(framesToAnalize{frN})(:,:,axis);
            
            [minErr,minInd]=min(totalerrorXaxis);
            fprintf('The calibration matrix with least error on %s among all datasets is from %s , with a total of %d percentage on average \n',axisName{axis},names2use{minInd}, minErr);
            frankieMatrix.(sensorsToAnalize{j})(axis,:)=cMat.(names2use{minInd}).(sensorsToAnalize{j})(axis,:);
            frankieData.(framesToAnalize{frN})(:,axis)=tF.(names2use{minInd}).filtered.(framesToAnalize{frN})(:,axis);
        end
        
        %plot the best ones
        
        figure,plot3_matrix( tF.(names2use{1}).filtered.(framesToAnalize{frN})(:,1:3));hold on;
        plot3_matrix( tF.(names2use{minIndall}).filtered.(framesToAnalize{frN})(:,1:3));hold on;
        plot3_matrix( frankieData.(framesToAnalize{frN})(:,1:3));hold on;
        legend({'workbench';'best';'frankie'},'Location','west');
        title(strcat('Wrench space on ',toCompareWith,' frame ', escapeUnderscores(framesToAnalize{frN})));
        xlabel('F_{x}');
        ylabel('F_{y}');
        zlabel('F_{z}');
        grid on;
        
        
        FTplotsWithOption(struct(strcat(framesToAnalize{frN},'_',names2use{1}),tF.(names2use{1}).filtered.(framesToAnalize{frN}),strcat('best','_',names2use{minIndall}), tF.(names2use{minIndall}).filtered.(framesToAnalize{frN})),tF.(names2use{1}).eForcesTime,true);
        FTplotsWithOption(struct(strcat(framesToAnalize{frN},'_',names2use{1}),tF.(names2use{1}).filtered.(framesToAnalize{frN}),strcat('frankie'), frankieData.(framesToAnalize{frN})),tF.(names2use{1}).eForcesTime,true);
        FTplotsWithOption(struct(strcat(framesToAnalize{frN},'_',names2use{minIndall}),tF.(names2use{minIndall}).filtered.(framesToAnalize{frN}),strcat('frankie'), frankieData.(framesToAnalize{frN})),tF.(names2use{1}).eForcesTime,true);
        
        fCalibMat=frankieMatrix.(sensorsToAnalize{j})/(cMat.Workbench.(sensorsToAnalize{j}));%calculate secondary calibration matrix
        xmlStrf=cMat2xml(fCalibMat,sensorName);% print in required format to use by WholeBodyDynamics
        
    end
end


%%% calculate external forces with both new best calibration matrices

cbMat=WorkbenchMat;
% for j=1:length(sensorsToAnalize)
for j=1:length(sensorsToAnalize)
    cbMat.(sensorsToAnalize{j}) =bestCMat.(sensorsToAnalize{j});
    sbMat.(sensorsToAnalize{j})=sCalibMat.(sensorsToAnalize{j});
end
% end
%       [Offset.(names2use{i}),~]=calculateOffset(sensorsToAnalize,inertialData.(toCompareWith).ftData,inertialData.(toCompareWith).estimatedFtData,WorkbenchMat, cMat.(names2use{i}));
[bOffset,~]=calculateOffset(sensorsToAnalize2,inertialData.(toCompareWith).ftData,inertialData.(toCompareWith).estimatedFtData,WorkbenchMat, cbMat);
[best.externalForces,best.eForcesTime]=obtainExternalForces(input.robotName,data.(toCompareWith),sbMat,input.sensorNames,contactFrame,timeFrame,framesNames,bOffset) ;

fprintf('Filtering %s \n',names2use{i});
[filteredFtData,mask]=filterFtData(best.externalForces);

bestT=applyMask(best,mask);
filteredFtData.(names2use{i})=applyMask(filteredFtData,mask);
bestT.filtered= filteredFtData.(names2use{i});
timeFrame=[0,290];

mask=bestT.eForcesTime>bestT.eForcesTime(1)+timeFrame(1) & bestT.eForcesTime<bestT.eForcesTime(1)+timeFrame(2);
bestTt=applyMask(bestT,mask);
FTplotsWithOption(struct(strcat(framesToAnalize{frN},'_',names2use{1}),tF.(names2use{1}).filtered.(framesToAnalize{frN}),strcat('best','_using_both'), bestTt.filtered.(framesToAnalize{frN})),tF.(names2use{1}).eForcesTime,true);

%%% do the same but with both hybrid calibration matrices

cbMat=WorkbenchMat;
% for j=1:length(sensorsToAnalize)
for j=1:length(sensorsToAnalize)
    cbMat.(sensorsToAnalize{j}) =frankieMatrix.(sensorsToAnalize{j});
    sbMat.(sensorsToAnalize{j})=frankieMatrix.(sensorsToAnalize{j})/(cMat.Workbench.(sensorsToAnalize{j}));
end
% end
%       [Offset.(names2use{i}),~]=calculateOffset(sensorsToAnalize,inertialData.(toCompareWith).ftData,inertialData.(toCompareWith).estimatedFtData,WorkbenchMat, cMat.(names2use{i}));
[bOffset,~]=calculateOffset(sensorsToAnalize2,inertialData.(toCompareWith).ftData,inertialData.(toCompareWith).estimatedFtData,WorkbenchMat, cbMat);
[fbest.externalForces,fbest.eForcesTime]=obtainExternalForces(input.robotName,data.(toCompareWith),sbMat,input.sensorNames,contactFrame,timeFrame,framesNames,bOffset) ;

fprintf('Filtering %s \n',names2use{i});
[filteredFtData,mask]=filterFtData(fbest.externalForces);

fbestT=applyMask(fbest,mask);
filteredFtData.(names2use{i})=applyMask(filteredFtData,mask);
fbestT.filtered= filteredFtData.(names2use{i});
timeFrame=[0,290];

mask=fbestT.eForcesTime>fbestT.eForcesTime(1)+timeFrame(1) & fbestT.eForcesTime<fbestT.eForcesTime(1)+timeFrame(2);
fbestTt=applyMask(fbestT,mask);
FTplotsWithOption(struct(strcat(framesToAnalize{frN},'_',names2use{1}),tF.(names2use{1}).filtered.(framesToAnalize{frN}),strcat('fbest','_using_both'), fbestTt.filtered.(framesToAnalize{frN})),tF.(names2use{1}).eForcesTime,true);


FTplotsWithOption(struct(strcat('best','_using_both'), bestTt.filtered.(framesToAnalize{frN}),strcat('fbest','_using_both'), fbestTt.filtered.(framesToAnalize{frN})),tF.(names2use{1}).eForcesTime,true);
