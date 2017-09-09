function [dataset,estimator,input]=readExperiment(experimentName,scriptOptions)

% This function is meant to read all info available in a dataset obtained
% from analog and stateExt ports. It also estimates forces and torques and
% calculates the raw measurments of ft sensors
%Obtained Information:
%   timeStamp of the experiment
%   joints positions, velocities and accelerations
%   force/torque measurements
%   motor side enconder positions, velocities and accelerations (optional not implemented at the moment but ready for it) 
%   joint torques 
%   inertial data optional from config file (params.m)
%Output variables:
%   dataset: structure containinng all obtained information
%   estimator: iDynTree.ExtWrenchesAndJointTorquesEstimator() class with a
%   the model of the robot loaded
%   input: configuration variables read in the params.m file
%Input variables:
%   experimentName: address and name of the experiment in the data folder
%   scriptOptions should include :
%       scriptOptions = {};
%       scriptOptions.forceCalculation=true;%false;
%       scriptOptions.saveData=true;%true       
% % Script of the mat file used for save the intermediate results 
%       striptOptions.matFileName='iCubDataset';

 % convertion to radians
    deg2rad = pi/180.0;

% load the script of parameters relative 
paramScript=strcat('data/',experimentName,'/params.m');
run(paramScript)
  % Create estimator class
  
    %%% Load the estimator and model information
      estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();
    
    % Load model and sensors from the URDF file
    estimator.loadModelAndSensorsFromFile(strcat('./',input.robotName,'.urdf'));
    
    % Check if the model was correctly created by printing the model
    %estimator.model().toString()
    
% This script will produce dataset (containing the raw data) and dataset2
% (contained the original data and the filtered ft). 

if (exist(strcat('data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'file')==2 && scriptOptions.forceCalculation==false)
    %% Load from workspace
    %     %load meaninful data, estimated data, meaninful data no offset
    load(strcat('data/',experimentName,'/',scriptOptions.matFileName,'.mat'),'dataset')
    
    
else
    %% load FT data
    ftDataName=strcat(input.ftPortName,'/data.log'); % (arm, foot and leg have FT data)
         
    for i=1:size(input.ftNames,1)
        dataFTDirs{i}=strcat('data/',experimentName,'/icub/',input.ftNames{i},'/',ftDataName);
        
    end    
    [ftData.(input.ftNames{1}),time]=readDataDumper(dataFTDirs{1});
    
    for i=2:size(input.ftNames,1)
        %read from dataDumper
        [ftData_temp,time_temp]=readDataDumper(dataFTDirs{i});
        %resample FT data
        ftData.(input.ftNames{i})=resampleFt(time,time_temp,ftData_temp);
    end
    
    % Insert into final output
    dataset.time=time;
    dataset.ftData=ftData;
   
    %% load Inertial data
    if (any(strcmp('inertialName', fieldnames(input))))
    dataInertialDir=strcat('data/',experimentName,'/icub/',input.inertialName,'/data.log');
      
    
    [linAcc_temp,angVel_temp, time_temp,euler_temp]=readInertial(dataInertialDir);
   
    [linAcc,angVel_temp,~] = resampleState(time, time_temp, linAcc_temp',angVel_temp', euler_temp');
    
   %Convert to radians
    angVel = deg2rad*angVel_temp;
    
    inertialData.linAcc=linAcc';
    inertialData.angVel=angVel';  
    
    % Insert into final output
    dataset.inertialData=inertialData;
    
    end  
    
   %% Prepare to load stateExt data
     stateDataName=strcat(input.statePortName,'/data.log');  % (only foot has no state data)
        stateNames=fieldnames(input.stateNames);
    for i=1:size(stateNames,1)
        dataStateDirs{i}=strcat('data/',experimentName,'/icub/',stateNames{i},'/',stateDataName);
    end    
    
    %%% Set model information   
    % For more info on iCub frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions    
    
    % Get joint information.
    % Warning!! iDynTree takes in input **radians** based units,
    % while the iCub port stream **degrees** based units.
    dofs = estimator.model().getNrOfDOFs();
    qj_all = zeros(dofs,size(time,1));
    dqj_all = zeros(dofs,size(time,1));
    ddqj_all = zeros(dofs,size(time,1)); 
    tau_all = zeros(dofs,size(time,1));
   
    %get the names of the model to match the names from the data file read
    for i=0:dofs-1
        % disp(strcat('name=',estimator.model().getJointName(i),' , index=',num2str(i)))
        names{i+1}=estimator.model().getJointName(i);
    end
    fNames=fieldnames(input.stateNames);
    %to iterate through a struct do the following
    % input.stateNames.(fNames{i})
    %for the first elment in the first field it would be
    %input.stateNames.(fNames{1}){1}
    dataset.jointNames = {};
    
    fprintf('readExperiment: Resampling the state\n');
    for i=1:size(fNames)
        Dof=size(input.stateNames.(fNames{i}));
        [qj_temp,dqj_temp,ddqj_temp,time_temp, ~, ~, ~, tau_temp,]=readStateExt(Dof(1),dataStateDirs{i});
        %store only the ones that have a degree of freedom (the names of the joint
        %should match one of the names stored in the model of the robot
        % we resample joint encoders on the timestamp of the FT sensors
        fprintf('readExperiment: Resampling the state for the part %s\n',fNames{i});
        [qj_temp,dqj_temp,ddqj_temp] = resampleState(time, time_temp, qj_temp, dqj_temp, ddqj_temp);
        tau_temp= interp1(time_temp, tau_temp'  , time)';
        
        for j=1:Dof
            index = find(strcmp(names, input.stateNames.(fNames{i}){j}));
            if(isempty(index)==0)
                dataset.jointNames{index} = input.stateNames.(fNames{i}){j};
                qj_all(index,:) = deg2rad*qj_temp(j,:);
                dqj_all(index,:) =deg2rad* dqj_temp(j,:);
                ddqj_all(index,:) =deg2rad* ddqj_temp(j,:);
                tau_all(index,:) =tau_temp(j,:);
            end
        end
    end
    
    % Store the information into final output
    dataset.qj = qj_all';
    dataset.dqj = dqj_all';
    dataset.ddqj = ddqj_all';    
    dataset.tau=tau_all';
    
    %% Load skin events information
     if (any(strcmp('skinEventsName', fieldnames(input))))
    dataSkinDir=strcat('data/',experimentName,'/skinManager/',input.skinEventsName,'/data.log');
      
    %TODO: replace with appropiate information read from 
    [time_temp, cop_temp ,force_temp,torque_temp,normalDirection_temp,~, ~,wrench_temp]=readSkinEvents(dataSkinDir);
    %[linAcc_temp,angVel_temp, time_temp,euler_temp]=readSkinEvents(dataSkinDir);
    try
        [cop_temp ,force_temp,torque_temp] = resampleState(time, time_temp, cop_temp' ,force_temp',torque_temp');
        normalDirection_temp= interp1(time_temp, normalDirection_temp'  , time)';   
        wrench_temp= interp1(time_temp, wrench_temp'  , time)';
    catch ME        
         disp( 'readExperiment:loadSkinEvents:timeMismatch could not resample to default time, adding skin time ' )
        if (strcmp(ME.identifier,'MATLAB:griddedInterpolant:CompVecValueMismatchErrId'))
            msg = ['Can not resample to ft time frame: Initial time of ft is ', ...
                num2str(time(1)),' while skin time initial time is ', ...
                num2str(time_temp(1)),' difference (ft - skin) is ', num2str(time(1)-time_temp(1)), ' end times are ft=', num2str(time(end)),' skin= ', ...
                num2str(time_temp(end)) ,' difference is ', num2str(time(end)-time_temp(end))];
            causeException = MException('readExperiment:loadSkinEvents:timeMismatch',msg);
            ME = addCause(ME,causeException);
        end
        skinData.time=time_temp';
        %rethrow(ME)
    end
    %Convert to radians
    skinData.cop=cop_temp';
    skinData.force=force_temp';
    skinData.torque=torque_temp';
    skinData.normalDirection=normalDirection_temp';  
    skinData.wrench=wrench_temp';
    
    % Insert into final output
    dataset.skinData=skinData;
     end
     
         %% Load wholeBodyDynamics torques information
     if (any(strcmp('wbdPortNames', fieldnames(input))))
    torquesPortName=strcat(input.torquesPortName,'/data.log'); % (arm, foot and leg have FT data)   
    for p=1:size(input.wbdPortNames,1)
        for i=1:size(input.subModels,1)           
            dataTorqueDirs{i}=strcat('data/',experimentName,'/',input.wbdPortNames{p},'/',input.subModels{i},'/',torquesPortName);  
            %read from dataDumper
            [torqueData_temp,time_temp]=readTorqueData(dataTorqueDirs{i});
            %resample Torque data
            try
                torqueData.(input.subModels{i})=torqueData_temp;
                torqueData.time=time_temp;
                %resampleFt(time,time_temp,torqueData_temp); need to match
                %by time without interpolating since there is a mismatch
                %between the time the skin event is registerd and the
                %torque is evaluated
            catch ME
                disp( 'readExperiment:loadWBD:timeMismatch could not resample to default time, adding skin time ' )
                if (strcmp(ME.identifier,'MATLAB:griddedInterpolant:CompVecValueMismatchErrId'))
                    msg = ['Can not resample to ft time frame: Initial time of ft is ', ...
                        num2str(time(1)),' while skin time initial time is ', ...
                        num2str(time_temp(1)),' difference (ft - skin) is ', num2str(time(1)-time_temp(1)), ' end times are ft=', num2str(time(end)),' skin= ', ...
                        num2str(time_temp(end)) ,' difference is ', num2str(time(end)-time_temp(end))];
                    causeException = MException('readExperiment:loadWBD:timeMismatch',msg);
                    ME = addCause(ME,causeException);
                end
                torqueData.(input.subModels{i})=torqueData_temp;
               torqueData.time=time_temp;
            end
        end
        
        % Insert into final output        
        dataset.(input.wbdNames{p})=torqueData;
    end
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