function [estimatedFtMeasures]=obtainEstimatedWrenches(dataStateDirs,stateExtNames,robotName,resampledTime)% ,contactInfo)
%TODO: add contactInfo (which part of the robot is in contact) obtained from minimal knowledge on the FT sensors
left_support=false;
%% Load the estimator

% Create estimator class
estimator = iDynTree.ExtWrenchesAndJointTorquesEstimator();

% Load model and sensors from the URDF file
estimator.loadModelAndSensorsFromFile(strcat('./',robotName,'.urdf'));

% Check if the model was correctly created by printing the model
%estimator.model().toString()

%store number of sensors
nrOfFTSensors = estimator.sensors().getNrOfSensors(iDynTree.SIX_AXIS_FORCE_TORQUE);

%size of array with the expected measures
 ftMeasures=zeros(nrOfFTSensors,size(resampledTime,1),6);
%% Set kinematics information

% Set kinematics information: for this example, we will assume
% that the robot is balancing on the left foot. We can then
% compute the kinematics information necessary for the FT sensor
% measurements estimation using the knowledge of the gravity on a
% a frame fixed to the l_foot link (for convenience we use the l_sole
% frame). For more info on iCub frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions
grav_idyn = iDynTree.Vector3();
grav = [0.0;0.0;-9.81];
grav_idyn.fromMatlab(grav);

% Get joint information.
% Warning!! iDynTree takes in input **radians** based units,
% while the iCub port stream **degrees** based units.
dofs = estimator.model().getNrOfDOFs();
qj_all = zeros(dofs,size(resampledTime,1));
dqj_all = zeros(dofs,size(resampledTime,1));
ddqj_all = zeros(dofs,size(resampledTime,1));

% convert also to radians 
    deg2rad = pi/180.0;
%get the names of the model to match the names from the data file read
for i=0:dofs-1
    % disp(strcat('name=',estimator.model().getJointName(i),' , index=',num2str(i)))
    names{i+1}=estimator.model().getJointName(i);
end
fNames=fieldnames(stateExtNames);
%to iterate through a struct do the following
% stateExtNames.(fNames{i})
%for the first elment in the first field it would be
%stateExtnames.(fNames{1}){1}
for i=1:size(fNames)
    Dof=size(stateExtNames.(fNames{i}));
    [qj_temp,dqj_temp,ddqj_temp,time_temp]=readStateExt(Dof(1),dataStateDirs{i});
    %store only the ones that have a degree of freedom (the names of the joint
    %should match one of the names stored in the model of the robot
    % we resample joint encoders on the timestamp of the FT sensors
    fprintf('Resampiling the state\n');
    [qj_temp,dqj_temp,ddqj_temp] = resampleState(resampledTime, time_temp, qj_temp, dqj_temp, ddqj_temp);
    
    for j=1:Dof
        index = find(strcmp(names, stateExtNames.(fNames{i}){j}));
        if(isempty(index)==0)
            qj_all(index,:) = deg2rad*qj_temp(j,:);
            dqj_all(index,:) =deg2rad* dqj_temp(j,:);
            ddqj_all(index,:) =deg2rad* ddqj_temp(j,:);
        end
    end
    
end

%% Specify unknown wrenches

% We need to set the location of the unknown wrench. For the time being it
% is assumed that the contact will not change either on left or right foot
% so it is only defined once.
%TODO: recognize when the feet are in contact either left or right or both
%and establish the unkown wrench accordingly
% Set the contact information in the estimator
if (left_support==true)
    contact_index = estimator.model().getFrameIndex('l_sole');
else
    contact_index = estimator.model().getFrameIndex('r_sole');
end

unknownWrench = iDynTree.UnknownWrenchContact();
unknownWrench.unknownType = iDynTree.FULL_WRENCH;

% the position is the origin, so the conctact point wrt to l_sole is zero
unknownWrench.contactPoint.zero();

% The fullBodyUnknowns is a class storing all the unknown external wrenches
% acting on a class
fullBodyUnknowns = iDynTree.LinkUnknownWrenchContacts(estimator.model());
fullBodyUnknowns.clear();

fullBodyUnknowns.addNewContactInFrame(estimator.model(),contact_index,unknownWrench);

% Print the unknowns to make sure that everything is properly working
%fullBodyUnknowns.toString(estimator.model())

%% For each time instant
%TODO: replace the zeros with the loaded data from the robot
for t=1:size(resampledTime)
    qj=qj_all(:,t);
    dqj=dqj_all(:,t);
    ddqj=ddqj_all(:,t);
    
    qj_idyn   = iDynTree.JointPosDoubleArray(dofs);
    dqj_idyn  = iDynTree.JointDOFsDoubleArray(dofs);
    ddqj_idyn = iDynTree.JointDOFsDoubleArray(dofs);
    
    qj_idyn.fromMatlab(qj);
    dqj_idyn.fromMatlab(dqj);
    ddqj_idyn.fromMatlab(ddqj);
    
    % Set the kinematics information in the estimator
    estimator.updateKinematicsFromFixedBase(qj_idyn,dqj_idyn,ddqj_idyn,contact_index,grav_idyn);
    
    %% Run the prediction of FT measurements
    
    % There are three output of the estimation:
    
    % The estimated FT sensor measurements
    estFTmeasurements = iDynTree.SensorsMeasurements(estimator.sensors());
    
    % The estimated joint torques
    estJointTorques = iDynTree.JointDOFsDoubleArray(dofs);
    
    % The estimated contact forces
    estContactForces = iDynTree.LinkContactWrenches(estimator.model());
    
    % run the estimation
    estimator.computeExpectedFTSensorsMeasurements(fullBodyUnknowns,estFTmeasurements,estContactForces,estJointTorques);
    
    % store the estimated measurements
    for ftIndex = 0:(nrOfFTSensors-1)
        estimatedSensorWrench = iDynTree.Wrench();
        sens = estimator.sensors().getSensor(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex);
        estFTmeasurements.getMeasurement(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex,estimatedSensorWrench);
        %store in the correct variable, format from readDataDumpre results in (time,sensorindex)
        %TODO: generalized code for any number of sensors , idea create a
        %struct with the name of the sensor as field measures as values and
        %compare in the main with the name of the sensors.
        %estimatedSensorWrench.toMatlab() transforms the wrench into 6x1 vector of
        %matlab
        ftMeasures(ftIndex+1,t,:)=estimatedSensorWrench.toMatlab();
        
        
        % Print info
        %         fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
        %         fprintf('Sensor %s has index %d\n',sens.getName(),ftIndex);
        %         fprintf('Estimated measured wrench: %s',estimatedSensorWrench.toString());
        
        % the estimated sensor wrench can be easily converted to matlab with
        % estimatedSensorWrench.toMatlab()
    end
    
    % print the estimated contact forces
    %estContactForces.toString(estimator.model())
    
end
nrOfFTSensors = estimator.sensors().getNrOfSensors(iDynTree.SIX_AXIS_FORCE_TORQUE);
% sensorNames{nrOfFTSensors}='';
for ftIndex = 0:(nrOfFTSensors-1)
    sens = estimator.sensors().getSensor(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex);
    %sensorNames{ftIndex+1}=sens.getName();
    %squeeze(ftMeasures(ftIndex+1,:,:)) to remove singleton of ftIndex
    estimatedFtMeasures.(sens.getName())=squeeze(ftMeasures(ftIndex+1,:,:));
end
