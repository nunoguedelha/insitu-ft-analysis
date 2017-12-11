% clear all;
addpath ../utils
addpath ../external/quadfit
%% Prepare options of the test

scriptOptions = {};
scriptOptions.testDir=true;% to calculate the raw data, for recalibration always true
scriptOptions.matFileName='ftDataset';
scriptOptions.printAll=true;
% Script of the mat file used for save the intermediate results
%scriptOptions.saveDataAll=true;

%% Select datasets with which the matrices where generated and lambda values

%Use only datasets where the same sensor is used
experimentNames={
    'green-iCub-Insitu-Datasets/2017_10_31_3';
    'green-iCub-Insitu-Datasets/2017_10_31_4'% Name of the experiment;
    'green-iCub-Insitu-Datasets/2017_10_17Grid';
    'green-iCub-Insitu-Datasets/2017_10_30';
    }; %this set is from iCubGenova02
names={'Workbench';
    'bestleftleg';
    'bestleftfoot';
    'fristGreenSample';
    'day30';    
    };% except for the first one all others are short names for the expermients in experimentNames

lambdas=[0];
% lambdas=[0;
%     10
%     50;
%     1000;
%     10000;
%     50000;
%     100000;
%     500000;
%     1000000;
%     5000000;
%     10000000];
% Create appropiate names for the lambda variables
for namingIndex=1:length(lambdas)
    if (lambdas(namingIndex)==0)
        lambdasNames{namingIndex}='';
    else
        lambdasNames{namingIndex}=strcat('_l',num2str(lambdas(namingIndex)));
    end
end
lambdasNames=lambdasNames';


names2use{1}=names{1};
num=2;
for i=2:length(names)
    for j=1:length(lambdasNames)
        names2use{num}=(strcat(names{i},lambdasNames{j}));
        num=num+1;
    end
end
names2use=names2use';

%%  Select sensors and frames to analize
sensorsToAnalize = {'left_leg','right_leg'};  %load the new calibration matrices
framesToAnalize={'l_lower_leg','r_lower_leg'};
sensorName={'l_leg_ft_sensor','r_leg_ft_sensor'};

%% Read the calibration matrices to evaluate

[cMat,secMat,WorkbenchMat]=readGeneratedCalibMatrices(experimentNames,scriptOptions,sensorsToAnalize,names2use,lambdasNames);

%% Select datasets in which the matrices will be evaluated
toCompare={'leftYoga','leftYoga'};%datasets name 'leftYoga' 'failedLeftYoga'
toCompareNames={'leftYoga','leftYoga2'}; % short Name of the experiments

compareDatasetOptions = {};
compareDatasetOptions.forceCalculation=true;%false;
compareDatasetOptions.saveData=true;%true
compareDatasetOptions.matFileName='iCubDataset';
compareDatasetOptions.testDir=true;
compareDatasetOptions.raw=true;
compareDatasetOptions.testDir=true;% to calculate the raw data, for recalibration always true
compareDatasetOptions.filterData=false;
compareDatasetOptions.estimateWrenches=false;
compareDatasetOptions.useInertial=false;    

for c=1:length(toCompare)
    [data.(toCompareNames{c}),estimator,input]=readExperiment(toCompare{c},compareDatasetOptions);
    
    %TODO: have a more general structure with multiple datasets, and multiple
    %inputs to be able to check on multiple experiments in the end maybe
    %external forces can be combined from both experiments just to get the best
    %matrix considering all evaluated datasets.
    
    %% Calculate offset with a previously selected configuration of the robot during the experment
    %offsetContactFrame={'r_sole','l_sole'}; %'l_sole' 'root_link'
    %inspect data to select where to calculate offset
    robotName='iCubGenova04';
    onTestDir=true;
   % iCubVizWithSlider(data.(toCompareNames{c}),robotName,sensorsToAnalize,input.contactFrameName{1},onTestDir);
    sampleInit=[1600,1600];
    sampleEnd=[1650,1650];
    [offset.(toCompareNames{c})]=calculateOffsetUsingWBD(estimator,data.(toCompareNames{c}),sampleInit(c),sampleEnd(c),input);
    
    
    %TODO: should I filter before sampling? Or avoid data sampling and filtering to have more real like results
    fprintf('Filtering %s \n',(toCompareNames{c}));
    [data.(toCompareNames{c}).ftData,mask]=filterFtData(data.(toCompareNames{c}).ftData);
    data.(toCompareNames{c})=applyMask(data.(toCompareNames{c}),mask);
    [data.(toCompareNames{c}),~]= dataSampling(data.(toCompareNames{c}),2);
    
    
    % subsample dataset to speed up computations
    
    
    %% Comparison
    framesNames={'l_sole','r_sole','l_lower_leg','r_lower_leg','root_link','l_elbow_1','r_elbow_1'}; %there has to be atleast 6
    timeFrame=[0,15000];
    sMat={};
    for j=1:length(sensorsToAnalize) %why for each sensor? because there could be 2 sensors in the same leg
        %% Calculate external forces
        for i=1:length(names2use)
            sMat.(sensorsToAnalize{j})=secMat.(names2use{i}).(sensorsToAnalize{j});% select specific secondary matrices
            cd ../
            [results.(toCompareNames{c}).(sensorsToAnalize{j}).(names2use{i}).externalForces,results.(toCompareNames{c}).(sensorsToAnalize{j}).(names2use{i}).eForcesTime]= obtainExternalForces(input.robotName,data.(toCompareNames{c}),sMat,input.sensorNames,input.contactFrameName,timeFrame,framesNames,offset.(toCompareNames{c}));
            cd testResults/
        end
        if c==1
            stackedResults.(sensorsToAnalize{j})=results.(toCompareNames{c}).(sensorsToAnalize{j});
        else
            stackedResults.(sensorsToAnalize{j})=addDatasets(stackedResults.(sensorsToAnalize{j}),results.(toCompareNames{c}).(sensorsToAnalize{j}));
            
        end
    end
    
end
%% Evaluate error
useMean=false; %select which means of evaluation should be considered is either mean or standard deviation.
for j=1:length(sensorsToAnalize) %why for each sensor? because there could be 2 sensors in the same leg
    for frN=1:length(framesToAnalize)
        
        
        for i=1:length(names2use)
            error.(sensorsToAnalize{j}).(framesToAnalize{frN})(1,i)=norm(mean(abs(stackedResults.(sensorsToAnalize{j}).(names2use{i}).externalForces.(framesToAnalize{frN})(:,1:3))));
            errorXaxis.(sensorsToAnalize{j}).(framesToAnalize{frN})(1,i,:)=mean(abs(stackedResults.(sensorsToAnalize{j}).(names2use{i}).externalForces.(framesToAnalize{frN})));
            strd.(sensorsToAnalize{j}).(framesToAnalize{frN})(1,i)=std(mean(stackedResults.(sensorsToAnalize{j}).(names2use{i}).externalForces.(framesToAnalize{frN})(:,1:3)));
            strd_axis.(sensorsToAnalize{j}).(framesToAnalize{frN})(1,i,:)=std(stackedResults.(sensorsToAnalize{j}).(names2use{i}).externalForces.(framesToAnalize{frN}));
            % we probably want the mean of the standard deviations of the
            % forces during experiment. the lower the variability the
            % better
            
            
            %             for num=1:size(stackedResults.(sensorsToAnalize{j}).(names2use{i}).externalForces.(framesToAnalize{frN}),1)
            %                 testStd(num)=std(stackedResults.(sensorsToAnalize{j}).(names2use{i}).externalForces.(framesToAnalize{frN})(num,:));
            %             end
            %             strd.(sensorsToAnalize{j}).(framesToAnalize{frN})(1,i)=mean(testStd);
            % it seems easier from matlab notation to apply the std of the
            % mean which I am not sure is the similar enough to what we
            % want
        end
        
        if ( std(error.(sensorsToAnalize{j}).(framesToAnalize{frN}))> 1*10^(-10))
            if useMean
                [minErrall,minIndall]=min(error.(sensorsToAnalize{j}).(framesToAnalize{frN}));
                fprintf('Matrix with least external force is from %s for %s when considering %s frame, with a total of %d N on average \n',names2use{minIndall},(sensorsToAnalize{j}),(framesToAnalize{frN}), minErrall);
                
            else
                [minErrall,minIndall]=min(strd.(sensorsToAnalize{j}).(framesToAnalize{frN}));
                fprintf('Matrix with least standard deviation is from %s for %s when considering %s frame, with a total of %d N on average \n',names2use{minIndall},(sensorsToAnalize{j}),(framesToAnalize{frN}), minErrall);
                
            end
            sCalibMat.(sensorsToAnalize{j})=cMat.(names2use{minIndall}).(sensorsToAnalize{j})/(WorkbenchMat.(sensorsToAnalize{j}));%calculate secondary calibration matrix
            bestCMat.(sensorsToAnalize{j})=cMat.(names2use{minIndall}).(sensorsToAnalize{j});
            bestName.(sensorsToAnalize{j})=names2use{minIndall};
            xmlStr=cMat2xml(sCalibMat.(sensorsToAnalize{j}),sensorName{j});% print in required format to use by WholeBodyDynamics
            
            axisName={'fx','fy','fz','tx','ty','tz'};
            for axis=1:6
                if useMean
                    totalerrorXaxis=errorXaxis.(sensorsToAnalize{j}).(framesToAnalize{frN})(:,:,axis);
                    fprintf('Matrix with least external force on %s sensor evaluted on %s frame',(sensorsToAnalize{j}),(framesToAnalize{frN}));
                    
                else
                    totalerrorXaxis=strd_axis.(sensorsToAnalize{j}).(framesToAnalize{frN})(:,:,axis);
                    fprintf('Matrix with least variation on %s sensor evaluted on %s frame',(sensorsToAnalize{j}),(framesToAnalize{frN}));
                    
                end                
                [minErr,minInd]=min(totalerrorXaxis);
                fprintf(' in %s is from %s , with a total of %d N or Nm on average \n',axisName{axis},names2use{minInd}, minErr);
                frankieMatrix.(sensorsToAnalize{j})(axis,:)=cMat.(names2use{minInd}).(sensorsToAnalize{j})(axis,:);
                frankieData.(framesToAnalize{frN})(:,axis)=stackedResults.(sensorsToAnalize{j}).(names2use{minInd}).externalForces.(framesToAnalize{frN})(:,axis);
            end
        else
            fprintf('Effect of %s on %s frame is neglegible \n',(sensorsToAnalize{j}),(framesToAnalize{frN}));
        end
        
    end
end
