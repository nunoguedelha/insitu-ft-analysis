function [dataset,extraSample,input]=read_estimate_experimentData(experimentName,scriptOptions)
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
%       scriptOptions.matFileName='ftDataset';
%% Default values for scriptOptions
if (~any(strcmp('forceCalculation', fieldnames(scriptOptions))))
    scriptOptions.forceCalculation=false;
    disp(' Using default value forceCalculation=false');
end
if (~any(strcmp('saveData', fieldnames(scriptOptions))))
    scriptOptions.saveData=false;
    disp(' Using default value saveData=false');
end
if (~any(strcmp('raw', fieldnames(scriptOptions))))
    scriptOptions.raw=false;
    disp(' Using default value raw=false');
end
if (~any(strcmp('useInertial', fieldnames(scriptOptions))))
    scriptOptions.useInertial=false;
    disp(' Using default value useInertial=false');
end
if (~any(strcmp('matFileName', fieldnames(scriptOptions))))
    scriptOptions.matFileName='iCubDataset';
    disp(' Using default value matFileName=false');
end

%% load the script of parameters relative
paramScript=strcat('data/',experimentName,'/params.m');
run(paramScript)
input.ftPortName; %for some reason you can not die fieldnames to input until you used input somewhere
%fieldnames(input)
% load the extra sample first (might change this to later in the code)
if (any(strcmp('extraSampleRight', fieldnames(input))))
    [extraSample.right,~]=read_estimate_experimentData(input.extraSampleRight,scriptOptions);
else
    extraSample.right=nan;
end

if (any(strcmp('extraSampleLeft', fieldnames(input))))
    [extraSample.left,~]=read_estimate_experimentData(input.extraSampleLeft,scriptOptions);
else
    extraSample.left=nan;
end

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
    %%
    %% Load the estimator
    
    % Create estimator class
    estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();
    
    % Load model and sensors from the URDF file
    estimator.loadModelAndSensorsFromFile(strcat('./robots/',input.robotName,'.urdf'));
    
    % Check if the model was correctly created by printing the model
    %estimator.model().toString()
    
    
    
    %% Set kinematics information
    
    % Set kinematics information: for this example, we will assume
    % that the robot is balancing on the left foot. We can then
    % compute the kinematics information necessary for the FT sensor
    % measurements estimation using the knowledge of the gravity on a
    % a frame fixed to the l_foot link (for convenience we use the l_sole
    % frame). For more info on iCub frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions
    
    
    % Get joint information.
    % Warning!! iDynTree takes in input **radians** based units,
    % while the iCub port stream **degrees** based units.
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
    % input.stateNames.(fNames{i})
    %for the first elment in the first field it would be
    %input.stateNames.(fNames{1}){1}
    dataset.jointNames = {};
    
    fprintf('read_estimate_experimentData: Resampling the state\n');
    for i=1:size(fNames)
        Dof=size(input.stateNames.(fNames{i}));
        [qj_temp,dqj_temp,ddqj_temp,time_temp]=readStateExt(Dof(1),dataStateDirs{i});
        %store only the ones that have a degree of freedom (the names of the joint
        %should match one of the names stored in the model of the robot
        % we resample joint encoders on the timestamp of the FT sensors
        fprintf('read_estimate_experimentData: Resampling the state for the part %s\n',fNames{i});
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
    
    dataset.time=time;
    dataset.ftData=ftData;
    
    %% filter only relevant samples
    if (any(strcmp('intervals', fieldnames(input))))
        intervalsNames=fieldnames(input.intervals);
        if(~isempty(intervalsNames))
            if (any(strcmp('hanging', intervalsNames))||scriptOptions.useInertial)
                if (any(strcmp('inertialName', fieldnames(input))))
                    dataInertialDir=strcat('data/',experimentName,'/icub/',input.inertialName,'/data.log');
                else
                    dataInertialDir=strcat('data/',experimentName,'/icub/inertial/data.log');
                end
                
                [linAcc_temp,angVel_temp, time_temp,euler_temp]=readInertial(dataInertialDir);
                [linAcc,angVel_temp,~] = resampleState(time, time_temp, linAcc_temp',angVel_temp', euler_temp');
                
                %Convert to radians
                angVel = deg2rad*angVel_temp;
                
                inertialData.linAcc=linAcc';
                inertialData.angVel=angVel';
                
                % Insert into final output
                dataset.inertialData=inertialData;
            end
            if (any(strcmp('hanging', intervalsNames)))
                mask=dataset.time>=dataset.time(1)+input.intervals.hanging.initTime & dataset.time<=dataset.time(1)+input.intervals.hanging.endTime;
               
                [inertialEstimatedFtData]=obtainEstimatedWrenches(estimator,dataset.time,{input.intervals.hanging.contactFrame},dataset,mask,inertialData);
                
                inertial.ftData=inertialEstimatedFtData.ftData;
                inertial.time=inertialEstimatedFtData.time;
                
                sensorNames=fieldnames(inertialEstimatedFtData.estimatedFtData);
                % match field names with sensor loaded through readDataDumper
                %
                matchup=zeros(size(input.sensorNames,1),1);
                for i=1:size(input.sensorNames,1)
                    matchup(i) = find(strcmp(sensorNames, input.sensorNames{i}));
                end
                %replace the estored estimatedFtData for one with the same order as the
                %ftData
                for i=1:size(input.ftNames,1)
                    inertial.estimatedFtData.(input.ftNames{i})=inertialEstimatedFtData.estimatedFtData.(sensorNames{matchup(i)});
                end
                
            end
            %% This part of code needs to be revised copied from previous version of read estimate experiment enables converting to an array of contact frames it might allow to have a continuos experiment without necesarily separating calculation of external forces by support contact
            %%mask=dataset.time<0;
            %             contactFrameName='';
            %             for index=1:length(intervalsNames)
            %                 if(~strcmp('hanging', intervalsNames{index}))
            %                     intName=intervalsNames{index};
            %                     maskTemp=dataset.time>=dataset.time(1)+input.intervals.(intName).initTime & dataset.time<=dataset.time(1)+input.intervals.(intName).endTime;
            %                     contactTemp(1:length(find(maskTemp)))={input.intervals.(intName).contactFrame};
            %                     mask=or(mask,maskTemp);
            %
            %                     %TODO: have to match the contactFrame vectors with the time
            %                     %the interval happens (compare init time of all intervals
            %                     %to order it
            %                     % contactFrameName=[contactFrameName,contactTemp];
            %                     contactFrameName=[contactTemp,contactFrameName];
            %                 end
            %
            %             end
            %
            %             dataset=applyMask(dataset,mask);            
            for index=1:length(intervalsNames)
                
                if(~strcmp('hanging', intervalsNames{index}))
                    intName=intervalsNames{index};
                    mask=dataset.time>=dataset.time(1)+input.intervals.(intName).initTime & dataset.time<=dataset.time(1)+input.intervals.(intName).endTime;
                    
                    if (scriptOptions.useInertial)                                                
                        [dataset2]=obtainEstimatedWrenches(estimator,dataset.time,{input.intervals.(intName).contactFrame},dataset,mask,inertialData);
                    else
                        [dataset2]=obtainEstimatedWrenches(estimator,dataset.time,{input.intervals.(intName).contactFrame},dataset,mask);
                    end
                    sensorNames=fieldnames(dataset2.estimatedFtData);
                    
                    % match field names with sensor loaded through readDataDumper
                    matchup=zeros(size(input.sensorNames,1),1);
                    for i=1:size(input.sensorNames,1)
                        matchup(i) = find(strcmp(sensorNames, input.sensorNames{i}));
                    end
                    
                    %replace the estored estimatedFtData for one with the same order as the
                    %ftData
                    for i=1:size(input.ftNames,1)
                        estimatedFtData.(input.ftNames{i})=dataset2.estimatedFtData.(sensorNames{matchup(i)});
                    end
                    dataset2.estimatedFtData=estimatedFtData;
                    
                    %% Filter data
                    % filtered ft data
                    [filteredFtData,mask]=filterFtData(dataset2.ftData);
                    
                    dataset2=applyMask(dataset2,mask);
                    filterd=applyMask(filteredFtData,mask);
                    dataset2.filteredFtData=filterd;
                    if (any(strcmp('hanging', intervalsNames)))
                        if(strcmp('hanging', intervalsNames{index-1}))
                            data=dataset2;
                        end
                    else
                        if (length(intervalsNames)==1)
                            data=dataset2;
                        else
                            if (input.intervals.(intervalsNames{index-1}).initTime<input.intervals.(intName).initTime)
                                data=addDatasets(data,dataset2);
                            else
                                data=addDatasets(dataset2,data);
                            end
                        end
                    end
                end
            end
            dataset=data;            
        else
            disp('intervals is empty avoiding all estimation');
        end
        %getting raw data
        %should be on filtered data proven.
        if(scriptOptions.raw)
            if (any(strcmp('calibFlag', fieldnames(input))))
                [dataset.rawDataFiltered,cMat]=getRawData(dataset.filteredFtData,input.calibMatPath,input.calibMatFileNames,input.calibFlag);
                [dataset.rawData]=getRawData(dataset.ftData,cMat);
                if (~input.calibFlag)
                    dataset.rawData=swapFT(dataset.rawData);
                end
            else
                [dataset.rawDataFiltered,cMat]=getRawData(dataset.filteredFtData,input.calibMatPath,input.calibMatFileNames);
                [dataset.rawData]=getRawData(dataset.ftData,cMat);
            end
            dataset.cMat=cMat;            
            dataset.calibMatFileNames=input.calibMatFileNames;
        end
        
       if (any(strcmp('hanging', intervalsNames)))
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
    else
        disp('input.intervals needs to exist to estimate, no estimation has been done');
    end
end