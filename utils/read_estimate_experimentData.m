function [dataset]=read_estimate_experimentData(experimentName,scriptOptions)
% This function is meant to read all info available in a dataset obtained
% from analog and stateExt ports. It also estimates forces and torques and
% calculates the raw measurments of ft sensors
%Obtained Information:
%   timeStamp of the experiment
%   joints positions, velocities and accelerations
%   force/torque measurements
%   estimated force/torque wrenches in the ft sensor frames
%   workbench calibration matrices
%   raw measurments from force/torque sensors
%   motor side enconder positions, velocities and accelerations (coming soon)
%   joint torques (coming soon)
%Input variables:
%   experimentName: address and name of the experiment in the data folder
%   scriptOptions should include :
%       scriptOptions = {};
%       scriptOptions.forceCalculation=true;%false;
%       scriptOptions.saveData=true;%true
%       scriptOptions.raw=true;
% % Script of the mat file used for save the intermediate results 
%       striptOptions.matFileName='ftDataset';


% load the script of parameters relative 
paramScript=strcat('data/',experimentName,'/params.m');
run(paramScript)

% This script will produce dataset (containing the raw data) and dataset2
% (contained the original data and the filtered ft). 

if (exist(strcat('data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'file')==2 && scriptOptions.forceCalculation==false)
    %% Load from workspace
    %     %load meaninful data, estimated data, meaninful data no offset
    load(strcat('data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset')
    
else
    ftDataName=strcat(input.ftPortName,'/data.log'); % (arm, foot and leg have FT data)
    stateDataName=strcat(input.statePortName,'/data.log');  % (only foot has no state data)
    %params.m is expected to have contactInfo (1 right ,0 left ), relevant (if
    %there is an specific interval desired to study (1 true, 0 false ) and
    %rData which is a double array 1x2 that has begining and ending of interval in seconds
    
    
    for i=1:size(input.ftNames,1)
        dataFTDirs{i}=strcat('data/',experimentName,'/icub/',input.ftNames{i},'/',ftDataName);
        
    end
    stateNames=fieldnames(input.stateNames);
    for i=1:size(stateNames,1)
        dataStateDirs{i}=strcat('data/',experimentName,'/icub/',stateNames{i},'/',stateDataName);     
    end
    %TODO: replace "icub" for robot model? so that it can be used for other
    %robots, although this is dependent on the output kind of the data dumper
    
    
    %% load FT data
    [ftData.(input.ftNames{1}),time]=readDataDumper(dataFTDirs{1});
    for i=2:size(input.ftNames,1)
        %read from dataDumper
        [ftData_temp,time_temp]=readDataDumper(dataFTDirs{i});
        %resample FT data
        ftData.(input.ftNames{i})=resampleFt(time,time_temp,ftData_temp);
    end
    
    %% load state and calculate estimated wrenches for comparison
    [dataset]=obtainEstimatedWrenches(dataStateDirs,input.stateNames,input.robotName,time,contactFrameName);
    
%     inertialDir=strcat('data/',experimentName,'/icub/inertial/data.log');
%      [dataset]=obtainEstimatedWrenchesFloatingBase(dataStateDirs,input.stateNames,input.robotName,time,contactFrameName,inertialDir);
     
    dataset.time=time;
    dataset.ftData=ftData;
    
    sensorNames=fieldnames(dataset.estimatedFtData);
    
    % match field names with sensor loaded through readDataDumper
    %
    matchup=zeros(size(input.sensorNames,1),1);
    for i=1:size(input.sensorNames,1)
        matchup(i) = find(strcmp(sensorNames, input.sensorNames{i}));
    end
    
    %replace the estored estimatedFtData for one with the same order as the
    %ftData
    for i=1:size(input.ftNames,1)
        estimatedFtData.(input.ftNames{i})=dataset.estimatedFtData.(sensorNames{matchup(i)});
    end
    dataset.estimatedFtData=estimatedFtData;
%     if(scriptOptions.saveDataAll)
%         allData=dataset;
%         save(strcat('data/',experimentName,'/all',scriptOptions.matFileName,'.mat'),'allData')
%     end
    if(input.hangingInit==1)
        dataDir=strcat('data/',experimentName,'/icub/inertial/data.log');
        mask=dataset.time>dataset.time(1)+input.hangingInterval(1) & dataset.time<dataset.time(1)+input.hangingInterval(2);
        datasetInertial=applyMask(dataset,mask);
        [inertialEstimatedFtData]=obtainEstimatedWrenchesIMU(dataDir,input.robotName,datasetInertial.time,datasetInertial);
        
        inertial.ftData=datasetInertial.ftData;
        inertial.time=datasetInertial.time;
        
         %replace the estored estimatedFtData for one with the same order as the
        %ftData
        for i=1:size(input.ftNames,1)
            inertial.estimatedFtData.(input.ftNames{i})=inertialEstimatedFtData.(sensorNames{matchup(i)});
        end
       
    end
    
    if (relevant==1)
        mask=dataset.time>dataset.time(1)+rData(1) & dataset.time<dataset.time(1)+rData(2);
        dataset=applyMask(dataset,mask);
    end
     
    %% Filter data
    % filtered ft data
    [filteredFtData,mask]=filterFtData(dataset.ftData);

    dataset=applyMask(dataset,mask);
    filterd=applyMask(filteredFtData,mask);
    dataset.filteredFtData=filterd;
    
    %getting raw data
    if(scriptOptions.raw)
        [dataset.rawData,cMat]=getRawData(dataset.filteredFtData,input.calibMatPath,input.calibMatFileNames);
        dataset.cMat=cMat;
        dataset.calibMatFileNames=input.calibMatFileNames;
    end
    
     if(input.hangingInit==1)
      
        dataset.inertial=inertial;
        
    end
    %% Save the workspace
    %     %save ft measurements, filtered measurements, raw measurements,
    %     estimated wrenches, joints position velocities and accelerations,
    %     time stamp, workbench calibration matrices with their serial
    %     numbers
    if(scriptOptions.saveData)
        save(strcat('data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset')
    end
end


