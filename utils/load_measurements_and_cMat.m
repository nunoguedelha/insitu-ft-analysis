function [dataset]=load_measurements_and_cMat(experimentName,scriptOptions)
% This function is meant to read all info available in a dataset obtained
% from analog and stateExt ports. It also estimates forces and torques and
% calculates the raw measurments of ft sensors
%Obtained Information:
%   timeStamp of the experiment
%   joints positions, velocities and accelerations
%   force/torque measurements
%   workbench calibration matrices
%   motor side enconder positions, velocities and accelerations (coming soon)
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
    
    
    dataset.ftData=ftData;
    dataset.time=time;
    % Create estimator class
    estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();
    
    % Load model and sensors from the URDF file
    estimator.loadModelAndSensorsFromFile(strcat('./',input.robotName,'.urdf'));
    
    dofs = estimator.model().getNrOfDOFs();
    qj_all = zeros(dofs,size(time,1));
    dqj_all = zeros(dofs,size(time,1));
    ddqj_all = zeros(dofs,size(time,1));
    
    % convert also to radians
    deg2rad = pi/180.0;
    %get the names of the model to match the names from the data file read
    for i=0:dofs-1
        % disp(strcat('name=',estimator.model().getJointName(i),' , index=',num2str(i)))
        names{i+1}=estimator.model().getJointName(i);
    end
    fNames=fieldnames(input.stateNames);
    %to iterate through a struct do the following
    % stateExtNames.(fNames{i})
    %for the first elment in the first field it would be
    %stateExtnames.(fNames{1}){1}
    dataset.jointNames = {};
    
    fprintf('obtainEstimatedWrenches: Resampling the state\n');
    for i=1:size(fNames)
        Dof=size(input.stateNames.(fNames{i}));
        [qj_temp,dqj_temp,ddqj_temp,time_temp]=readStateExt(Dof(1),dataStateDirs{i});
        %store only the ones that have a degree of freedom (the names of the joint
        %should match one of the names stored in the model of the robot
        % we resample joint encoders on the timestamp of the FT sensors
        fprintf('obtainEstimatedWrenches: Resampling the state for the part %s\n',fNames{i});
        [qj_temp,dqj_temp,ddqj_temp] = resampleState(time, time_temp, qj_temp, dqj_temp, ddqj_temp);
        
        for j=1:Dof
            index = find(strcmp(names, input.stateNames.(fNames{i}){j}));
            if(isempty(index)==0)
                dataset.jointNames{index} = input.stateNames.(fNames{i}){j};
                qj_all(index,:) = deg2rad*qj_temp(j,:);
                dqj_all(index,:) =deg2rad* dqj_temp(j,:);
                ddqj_all(index,:) =deg2rad* ddqj_temp(j,:);
            end
        end
    end
    
    % Store the used position in the returned dataset
    dataset.qj = qj_all';
    dataset.dqj = dqj_all';
    dataset.ddqj = ddqj_all';
   %% Filter data
    % filtered ft data
    [filteredFtData,mask]=filterFtData(dataset.ftData);

    dataset=applyMask(dataset,mask);
    filterd=applyMask(filteredFtData,mask);
    dataset.filteredFtData=filterd;
    
    %getting raw data
    
        ftNames=fieldnames(ftData);

    for i=1:size(input.calibMatFileNames,1)
           cMat.(ftNames{i})=getWorkbenchCalibMat(input.calibMatPath,input.calibMatFileNames{i});
           
    end

        dataset.cMat=cMat;
        dataset.calibMatFileNames=input.calibMatFileNames;
    end 
