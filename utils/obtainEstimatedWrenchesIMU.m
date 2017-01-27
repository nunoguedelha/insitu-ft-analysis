 function [estimatedFtData]=obtainEstimatedWrenchesIMU(dataDir,estimator,resampledTime,dataset)
% OBTAINESTIMATEDWRENCH Get (model) estimated wrenches for a iCub dataset
%   dataStateDirs  : address to find the files
%   stateExtNames  : sensor names
%   robotName      : the YARP_ROBOT_NAME (iCubCity01 style) name of the
%                    robot, used to load the correct model.
%   resampleTime   : time used to resample the inertial measurements
%   dataset : kinematic information from the desired period of time


%% Load the estimator

%store number of sensors
nrOfFTSensors = estimator.sensors().getNrOfSensors(iDynTree.SIX_AXIS_FORCE_TORQUE);

%size of array with the expected Data
ftData=zeros(nrOfFTSensors,size(resampledTime,1),6);

%% Set kinematics information

% Set kinematics information: for this example, we will assume
% that the robot is hanging and not moving so we take the contact frame from the torso (root_link).
%For more info on iCub frames check: http://wiki.icub.org/wiki/ICub_Model_naming_conventions
grav_idyn = iDynTree.Vector3();
angVel_idyn = iDynTree.Vector3();
angAcc_idyn = iDynTree.Vector3();


% Get joint information.
% Warning!! iDynTree takes in input **radians** based units,
% while the iCub port stream **degrees** based units.
dofs = estimator.model().getNrOfDOFs();


% convert also to radians
deg2rad = pi/180.0;


fprintf('obtainEstimatedWrenchesIMU: Resampling the inertia\n');
   [linAcc_temp,angVel_temp, time_temp,euler_temp]=readInertial(dataDir);
   
    [linAcc,angVel_temp,~] = resampleState(resampledTime, time_temp, linAcc_temp',angVel_temp', euler_temp');
    
   %Convert to radians
    angVel = deg2rad*angVel_temp;
    linAcc=linAcc';
    angVel=angVel';

% Take the used position from the dataset
qj_all=dataset.qj;
dqj_all=dataset.dqj;
ddqj_all=dataset.ddqj;


%% Specify unknown wrenches

% We need to set the location of the unknown wrench. For the time being it
% is assumed that the contact will not change either on left or right foot
% so it is only defined once.
%TODO: recognize when the feet are in contact either left or right or both
%and establish the unkown wrench accordingly
% Set the contact information in the estimator

contact_index = estimator.model().getFrameIndex('root_link');


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

% Prepare the datastructure that we used in the loop outside the loop 
% (to improve performances, as otherwise we allocate memory at each 
% loop step, and allocating memory is usually quite a slow operation) 
qj_idyn   = iDynTree.JointPosDoubleArray(dofs);
dqj_idyn  = iDynTree.JointDOFsDoubleArray(dofs);
ddqj_idyn = iDynTree.JointDOFsDoubleArray(dofs);

    
% The estimated FT sensor measurements
estFTmeasurements = iDynTree.SensorsMeasurements(estimator.sensors());
    
% The estimated joint torques
estJointTorques = iDynTree.JointDOFsDoubleArray(dofs);
    
% The estimated contact forces
estContactForces = iDynTree.LinkContactWrenches(estimator.model());

% Sensor wrench buffer 
estimatedSensorWrench = iDynTree.Wrench();


%% For each time instant
fprintf('obtainEstimatedWrenchesIMU: Computing the estimated wrenches\n');
for t=1:length(resampledTime)
    tic 
    % print progress test 
    if( mod(t,10000) == 0 ) 
        fprintf('obtainedEstimatedWrenchesIMU: process the %d sample out of %d\n',t,length(resampledTime))
    end
    
    qj=qj_all(t,:);
    dqj=dqj_all(t,:);
    ddqj=ddqj_all(t,:);
    
    
    qj_idyn.fromMatlab(qj);
    dqj_idyn.fromMatlab(dqj);
    ddqj_idyn.fromMatlab(ddqj);
    grav_idyn.fromMatlab(linAcc(t,:));
    angVel_idyn.fromMatlab(angVel(t,:));
    angAcc_idyn.fromMatlab([0;0;0]);
    % Set the kinematics information in the estimator
    ok = estimator.updateKinematicsFromFloatingBase(qj_idyn,dqj_idyn,ddqj_idyn,contact_index,grav_idyn,angVel_idyn,angAcc_idyn);
    
    %% Run the prediction of FT measurements
    
    % There are three output of the estimation, FT measurements, contact 
    % forces and joint torques (they are declared outside the loop for 
    % performance reason)

    % run the estimation
    estimator.computeExpectedFTSensorsMeasurements(fullBodyUnknowns,estFTmeasurements,estContactForces,estJointTorques);
    
    % store the estimated measurements
    for ftIndex = 0:(nrOfFTSensors-1)
        %sens = estimator.sensors().getSensor(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex);
        ok = estFTmeasurements.getMeasurement(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex,estimatedSensorWrench);
      
        %estimatedSensorWrench.toMatlab() transforms the wrench into 6x1 vector of
        %matlab
        ftData(ftIndex+1,t,:)=estimatedSensorWrench.toMatlab();
    end
    
    % print the estimated contact forces
    %estContactForces.toString(estimator.model())
end


nrOfFTSensors = estimator.sensors().getNrOfSensors(iDynTree.SIX_AXIS_FORCE_TORQUE);
% sensorNames{nrOfFTSensors}='';
for ftIndex = 0:(nrOfFTSensors-1)
    sens = estimator.sensors().getSensor(iDynTree.SIX_AXIS_FORCE_TORQUE,ftIndex);
    %sensorNames{ftIndex+1}=sens.getName();
    %squeeze(ftData(ftIndex+1,:,:)) to remove singleton of ftIndex
    estimatedFtData.(sens.getName())=squeeze(ftData(ftIndex+1,:,:));
end

